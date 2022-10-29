variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "local AWS profile to be used by terraform to access the AWS account to create the resources."
  type        = string
}

variable "terraform_state_dynamodb_table_name" {
  description = "name of the dynamo DB table to store the terraform state lock"
  type        = string
  default     = "maxf-004-e1-SOWI-prod-terraform_statelock-use"
}

variable "terraform_state_bucket_name" {
  description = "name of the S3 bucket to store the terraform state"
  type        = string
  default     = "maxf-004-e1-SOWI-prod-tfstate-use-terraformstate-use"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "maxf-004-e1-SOWI-prod-tfstate-use"
}

variable "availability_zone_1" {
  description = "1st availability_zone within USE maxf-XXX-e1-xxxx-prod VPC"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_2" {
  description = "2nd availability_zone within USE maxf-XXX-e1-xxxx-prod VPC"
  type        = string
  default     = "us-east-1b"
}

variable "availability_zone_3" {
  description = "3rd availability_zone within USE maxf-XXX-e1-xxxx-prod VPC"
  type        = string
  default     = "us-east-1c"
}

variable "vpc_cidr_block_1" {
  description = "1st CIDR block for maxf-XXX-e1-xxxx-prod VPC"
  type        = string
}

variable "vpc_cidr_block_2" {
  description = "2nd CIDR block for maxf-XXX-e1-xxxx-prod VPC"
  type        = string
}

variable "vpc_cidr_block_3" {
  description = "3rd CIDR block for maxf-XXX-e1-xxxx-prod VPC"
  type        = string
}
variable "tools_vpc" {
  description = "Tools CIDR range to allow inbound traffic to VPC"
  type        = string
  default = "10.116.88.0/22"
}
variable "subnets" {
  type        = list
  description = "(Required) A list of subnet ids where mount targets will be."
  default = ["subnet-021c97e3f8b2875c0","subnet-0b6247fd1a3e9acb0","subnet-014de670ee65021b0"]
}

variable "instance_type_node" {
  type        = string
  description = "Instance type."
  default = "c5n.xlarge"
}
variable "default_route_table_use1" {
  description = "default_route_table_use1"
  type        = string
}
variable "transit_gateway_id" {
  description = "transit-gateway-id for maxf-XXX-e1-xxxx-prod VPC"
  type        = string
}

variable "transit_gateway_route_table_id" {
  description = "transit_gateway_route_table_id for maxf-XXX-e1-xxxx-prod VPC"
  type        = string
}

variable "use1_sg_ec2" {
  description = "004-w2-SOWI-ec2-sg VPC"
  type        = string
  default = "sg-08172d6dd46afde25"
}
variable "use1_sg_rds" {
  description = "004-w2-SOWI-rds-sg VPC"
  type        = string
  default = "sg-03c62083e5d021b05"
}
variable "resource_tags" {
  description = "Tags to set for all resources in the stack"
  type        = map(string)
  default     = {
    Name                    = "MAXF-004-E1-SOWI-PROD"
    project                 = "MAXF-004-E1-SOWI-PROD"
    DataClassification      = "restricted"
    Provisioner             = "terraform" 
    environment             = "prod"
    owner                   = "owner"
    TechincalPointOfContact = "tevincurtis@maximus.com"
  }
}
variable "create" {
  description = "Whether to create an instance"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to be used on EC2 instance created"
  type        = string
  default     = ""
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = null
}

variable "availability_zone" {
  description = "AZ to start the instance in"
  type        = string
  default     = null
}

variable "capacity_reservation_specification" {
  description = "Describes an instance's Capacity Reservation targeting option"
  type        = any
  default     = null
}

variable "cpu_credits" {
  description = "The credit option for CPU usage (unlimited or standard)"
  type        = string
  default     = null
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  type        = bool
  default     = null
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = list(map(string))
  default     = []
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = null
}

variable "enclave_options_enabled" {
  description = "Whether Nitro Enclaves will be enabled on the instance. Defaults to `false`"
  type        = bool
  default     = null
}

variable "ephemeral_block_device" {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance"
  type        = list(map(string))
  default     = []
}

variable "get_password_data" {
  description = "If true, wait for password data to become available and retrieve it."
  type        = bool
  default     = null
}

variable "hibernation" {
  description = "If true, the launched EC2 instance will support hibernation"
  type        = bool
  default     = null
}

variable "host_id" {
  description = "ID of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instance" # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t3.micro"
}

variable "ipv6_address_count" {
  description = "A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet"
  type        = number
  default     = null
}

variable "ipv6_addresses" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface"
  type        = list(string)
  default     = null
}

variable "key_name" {
  description = "Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource"
  type        = string
  default     = null
}

variable "launch_template" {
  description = "Specifies a Launch Template to configure the instance. Parameters configured on this resource will override the corresponding parameters in the Launch Template"
  type        = map(string)
  default     = null
}

variable "metadata_options" {
  description = "Customize the metadata options of the instance"
  type        = map(string)
  default     = {}
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}

variable "network_interface" {
  description = "Customize network interfaces to be attached at instance boot time"
  type        = list(map(string))
  default     = []
}

variable "placement_group" {
  description = "The Placement Group to start the instance in"
  type        = string
  default     = null
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  type        = string
  default     = null
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  type        = list(any)
  default     = []
}

variable "secondary_private_ips" {
  description = "A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. Can only be assigned to the primary network interface (eth0) attached at instance creation, not a pre-existing network interface i.e. referenced in a `network_interface block`"
  type        = list(string)
  default     = null
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  type        = string
  default     = null
}

variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption."
  type        = string
  default     = null
}

variable "volume_tags" {
  description = "A mapping of tags to assign to the devices created by the instance at launch time"
  type        = map(string)
  default     = {}
}

variable "enable_volume_tags" {
  description = "Whether to enable volume tags (if enabled it conflicts with root_block_device tags)"
  type        = bool
  default     = true
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = null
}

variable "timeouts" {
  description = "Define maximum timeout for creating, updating, and deleting EC2 instance resources"
  type        = map(string)
  default     = {}
}

variable "cpu_core_count" {
  description = "Sets the number of CPU cores for an instance." # This option is only supported on creation of instance type that support CPU Options https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-optimize-cpu.html#cpu-options-supported-instances-values
  type        = number
  default     = null
}

variable "cpu_threads_per_core" {
  description = "Sets the number of CPU threads per core for an instance (has no effect unless cpu_core_count is also set)."
  type        = number
  default     = null
}

# Spot instance request
variable "create_spot_instance" {
  description = "Depicts if the instance is a spot instance"
  type        = bool
  default     = false
}

variable "spot_price" {
  description = "The maximum price to request on the spot market. Defaults to on-demand price"
  type        = string
  default     = null
}

variable "spot_wait_for_fulfillment" {
  description = "If set, Terraform will wait for the Spot Request to be fulfilled, and will throw an error if the timeout of 10m is reached"
  type        = bool
  default     = null
}

variable "spot_type" {
  description = "If set to one-time, after the instance is terminated, the spot request will be closed. Default `persistent`"
  type        = string
  default     = null
}

variable "spot_launch_group" {
  description = "A launch group is a group of spot instances that launch together and terminate together. If left empty instances are launched and terminated individually"
  type        = string
  default     = null
}

variable "spot_block_duration_minutes" {
  description = "The required duration for the Spot instances, in minutes. This value must be a multiple of 60 (60, 120, 180, 240, 300, or 360)"
  type        = number
  default     = null
}

variable "spot_instance_interruption_behavior" {
  description = "Indicates Spot instance behavior when it is interrupted. Valid values are `terminate`, `stop`, or `hibernate`"
  type        = string
  default     = null
}

variable "spot_valid_until" {
  description = "The end date and time of the request, in UTC RFC3339 format(for example, YYYY-MM-DDTHH:MM:SSZ)"
  type        = string
  default     = null
}

variable "spot_valid_from" {
  description = "The start date and time of the request, in UTC RFC3339 format(for example, YYYY-MM-DDTHH:MM:SSZ)"
  type        = string
  default     = null
}

variable "putin_khuylo" {
  description = "Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo!"
  type        = bool
  default     = true
}

variable "vpc_id" {
  default = "vpc-05e5897ff26ebcc5f"
}

variable "subnet_ids" {
  type    = list(any)
  default = ["subnet-0c452a624fa6fc468","subnet-05a98e80b9266939f"]
}

variable "security_groups_ids" {
  type    = list(any)
  default = ["sg-03383addabcf61c6c"]
}

variable "instance_id_1" {
  default = "i-05a384b70763c424b"
}

variable "instance_id_2_8080" {
  default = "i-05a7d4ab2aac88cc3"
}
variable "domain" {
  default = "sowi.mgep.info"
}
/*
variable "domain" {
  default = "SOWI.mgep.info"
}
*/
variable "auth" {
  default = "auth.SOWI-local.mgep.info"
}

variable "comment" {
description = "Comment added in hosted zone"      
}

variable "ttl" {
description = "TTL of Record"
}

variable "primaryhealthcheck" {
description = "Tag Name for Primary Instance Health Check"
}

variable "secondaryhealthcheck" {
description = "Tag Name for Secondary Instance Health Check"
}

variable "identifier1" {
}

variable "identifier2" {
}

variable "primaryip" {
}

variable "secondaryip" {
}

variable "albs_with_certs" {
  type = map(any)
  default = {
    alb1 = {
      alb_name         = "gms-use",
      tg_name   = "gms-tg",
      r53_record_primary_name   = "gms.sowi.mgep.info",
      instance_LM025_id   = "i-0e7f1def31308d713",
      instance_LM026_id = "i-0444a12e7007193d7",
      instance_LM033_id   = "i-07656b37df447adec",
      acm_cert_arn     = "arn:aws:acm:us-east-1:912042807419:certificate/3d6b7efb-df48-47e7-92a9-c1eba7c5e8ec",
      tg_port = "8443",
      tgbkp_port = "8443",
      bkp_protocol = "HTTPS",
      tg_healthcheckpath = "/genesys/admin/login.jsp",
      stickiness_state = true
    },
  }
}
