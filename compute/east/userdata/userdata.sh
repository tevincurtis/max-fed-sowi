#!/bin/bash

set -x; exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1 ; echo BEGIN `date '+%m/%d/%Y %H:%M:%S'`

# *************** SCRIPT to Add,Format and Mount a disk in Instance. ************** #
# Get list of all Disk.
DISKS=$(fdisk -l | grep -i Disk | grep dev | awk '{ print $2 }' | cut -d ":" -f 1)

    # Check if Disks has any partition.
for i in $DISKS; do
    # Format DISK if it does not contain a partition yet
    if [ "$(file -b -s $i)" == "data" ]; then
        echo -e "o\nn\np\n1\n\n\nw" | fdisk $i

        # Make a file system in there.
        mkfs -t xfs $(fdisk -l | grep ^$i | awk '{ print $1 }')

        mkdir -p /genesys
        mount $(fdisk -l | grep ^$i | awk '{ print $1 }') /genesys

        # Add entry in the fstab.

        grep $(fdisk -l | grep ^$i | awk '{ print $1 }') /etc/fstab

        RESULT=$?
        if [ $RESULT -eq 1 ]; then
        echo "$(fdisk -l | grep ^$i | awk '{ print $1 }')   /genesys    xfs     defaults        0 0" >> /etc/fstab
        fi
    fi
done

#setup repo and installs
aws s3 cp s3://packer1/irontec.repo /etc/yum.repos.d/
yum install -y  https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm --nogpgcheck
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm --nogpgcheck
rpm --import http://packages.irontec.com/public.key
yum install -y libpq5 redhat-lsb redhat-lsb-core.i686 net-tools libnsl libnsl.i686 lsof telnet vim
yum install -y perl python39 gcc git ftp patch dos2unix bind-utils mailx wget firewalld sngrep

aws s3 cp s3://packer1/compat-libcap1-1.10-7.el7.x86_64.rpm /tmp/
sudo dnf -y install /tmp/compat-libcap1-1.10-7.el7.x86_64.rpm --nogpgcheck

#setting hostname
AWS_INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
AWS_REGION=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/'`
HOST_NAME=$(aws ec2 describe-tags --region $AWS_REGION --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)
sudo hostnamectl set-hostname $HOST_NAME
echo "$(curl http://169.254.169.254/latest/meta-data/local-ipv4) $HOST_NAME.maxomni.com $HOST_NAME" >> /etc/hosts
sed -i'_orig' -r "s/(HOSTNAME=).*/\1$HOST_NAME.maxomni.com/g" /etc/sysconfig/network


# Add aws-cli in your environment path.
export PATH=$PATH:/usr/local/bin/

# Create directory to hold certify package.
mkdir -p /home/ec2-user/centrify_install
cd /home/ec2-user/centrify_install

aws s3 cp s3://packer1/centrify-infrastructure-services-19.9-rhel5-x86_64.tar .

chown -R ec2-user:wheel /home/ec2-user/centrify_install/

tar -xvf centrify-infrastructure-services-19.9-rhel5-x86_64.tar
find /home/ec2-user/centrify_install -type f -exec chmod 0755 {} \;
find /home/ec2-user/centrify_install -type d -exec chmod 0755 {} \;

# Install Centrify.
sh /home/ec2-user/centrify_install/install.sh -n

# Retrieve the username and pass from AWS Secrets manager.

AD_USER=$(aws secretsmanager get-secret-value --secret-id s-adjoin-user --query SecretString --output text | tr -d '{}' | awk -F ':' '{ print $2 }' | sed 's/"//g' |awk -F ',' '{ print $1 }')

AD_USER_PASS=$(aws secretsmanager get-secret-value --secret-id s-adjoin-user --query SecretString --output text | tr -d '{}' | awk -F ':' '{ print $3 }' | sed 's/"//g'|awk -F ',' '{ print $1 }')

#join to domain
OU="OU=Cent_OS,OU=Servers,OU=SOWI,OU=Customers,DC=maxomni,DC=com"
ZONE="sowi"
DOMAIN="maxomni.com"
#adjoin --forceDeleteObj --user $AD_USER --password $AD_USER_PASS --container "OU=Cent_OS,OU=Servers,OU=SOWI,OU=Customers,DC=maxomni,DC=com"  --zone "sowi" --verbose maxomni.com
adjoin --forceDeleteObj --user $AD_USER --password $AD_USER_PASS --container "$OU"  --zone "$ZONE" --verbose $DOMAIN

# revert SSHd to allow PASSWDAUTHENTICTION.
sed -i "s/^PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config

#comment out - Allow users, Restart sshd and flush the ad
sed -i.bak '/AllowUsers/s/^/#/g' /etc/ssh/sshd_config; systemctl restart sshd; adflush -f

#Update DNS Records
dzdo  addns -Umf -d $DOMAIN --user $AD_USER --password $AD_USER_PASS

#stop iptables
service iptables stop; chkconfig iptables off; systemctl stop firewalld; systemctl disable firewalld; firewall-cmd --state; service iptables status

#check fibs
fips-mode-setup --check
getenforce

mkdir -p /genesys/gcti/certs
cd /genesys/gcti/certs/
aws s3 cp s3://packer1/certs_shells.tar.gz .
tar -zxvf  certs_shells.tar.gz
rm -rf /genesys/gcti/certs/certs_shells.tar.gz

mkdir -p /genesys/logs/lca
cd /genesys/gcti/
aws s3 cp s3://packer1/lca.tar.gz .
tar -zxvf lca.tar.gz
rm -rf /genesys/gcti/lca.tar.gz

aws s3 cp s3://packer1/security_pack.tar.gz .
tar -zxvf security_pack.tar.gz
rm -rf /genesys/gcti/security_pack.tar.gz

chown genesys:genesys /genesys -Rv
chmod 755 /genesys -R

echo "/genesys/gcti/security_pack/fips140_lib64" > /etc/ld.so.conf.d/genesys.conf

cat /etc/ld.so.conf.d/genesys.conf

aws s3 cp s3://packer1/genesys-lca.service /etc/systemd/system/
chmod 644 /etc/systemd/system/genesys-lca.service
systemctl daemon-reload
systemctl enable genesys-lca.service
systemctl start genesys-lca

aws s3 cp s3://packer1/MAXOmni-Issuing-Root-CA-Chain.pem /var/centrify/net/certs/
chown genesys:genesys /genesys/gcti/security_pack/fips140_lib64/ -Rv
chmod 644 /var/centrify/net/certs/ -Rv
chown root:root /var/centrify/net/certs/*
chown -Rf genesys:genesys /genesys
echo "export LD_LIBRARY_PATH=\"/genesys/gcti/security_pack/fips140_lib64\"" >> /etc/bashrc
source /etc/bashrc
cd /genesys/gcti/security_pack/fips140_lib64/
ln -s ../libgsecurity_openssl_64.so libgsecurity_openssl_64.so
ln -s ../libgsecurity_rsa_64.so libgsecurity_rsa_64.so
chown genesys:genesys /genesys/gcti/security_pack/fips140_lib64/* -Rv

rm -f /genesys/gcti/certs/basic_security.sh
cd  /genesys/gcti/certs/
wget http://10.116.85.87/repos/security/basic_security.sh  .
chmod 755 /genesys/gcti/certs/basic_security.sh
chown genesys:genesys /genesys/gcti/certs/basic_security.sh
bash /genesys/gcti/certs/basic_security.sh

yum update -y

#End Script
echo "Script $0 ***************** END ****************** `date '+%m/%d/%Y %H:%M:%S'`"\
shutdown -r +5
#delete