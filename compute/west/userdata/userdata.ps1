<powershell>

#------------------------------------------------------------------------------
# Script parameters
#------------------------------------------------------------------------------
[string]$SecretAD = "s-adjoin-user"
[string]$LogPath = "C:\ProgramData\Amazon\CustomLaunch"
[string]$OUPath = "OU=Windows,OU=Servers,OU=SOWI,OU=Customers,DC=maxomni,DC=com"
#Transcript of all actions
Start-Transcript -path ($LogPath + "\userdata-output.log") -append
#------------------------------------------------------------------------------
#region Logger class
#----------------------------------------------
class Logger {
    [string] hidden $logFileName
    #----------------------------------------
    Logger([string] $Path, [string] $LogName) {
        if (!(Test-Path -Path $Path -pathType container))
        { $dummy = New-Item -ItemType directory -Path $Path }
        $this.logFileName = [System.IO.Path]::Combine($Path, ($LogName + ".log"))
    }
    #----------------------------------------
    [void] WriteLine([string] $msg) {
        [string] $logLine = (Get-Date -Format 'hh:mm:ss')
        if ($msg) { Out-File -LiteralPath $this.logFileName -Append -InputObject ($logLine + " " + $msg) }
        # Msg is null - creating new file
        else { Out-File -LiteralPath $this.logFileName -InputObject ($logLine + " Log created") }
    }
}
#----------------------------------------------
#endregion
#------------------------------------------------------------------------------
# Create Logger
#------------------------------------------------------------------------------
[Logger]$log = [Logger]::new($LogPath, "ADMgmt")
$log.WriteLine("--------------------------------------------------------------------")
$log.WriteLine("Log Started")
#------------------------------------------------------------------------------
$log.WriteLine("Loading Secret <" + $SecretAD + ">")
#------------------------------------------------------------------------------

# Initialize and Format Disk
Get-Disk | Where-Object partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize |  Format-Volume -FileSystem NTFS -NewFileSystemLabel "CustDrive" -Confirm:$false

# Set Offline disk to online.
Start-Sleep -s 60

# Get-Disk | Where-Object IsOffline -Eq $True | Set-Disk -IsOffline $
$offlinedisks = get-disk | Where-Object OperationalStatus -EQ offline
foreach ($disk in $offlinedisks) {
    set-disk -Number $disk.Number -IsOffline $false
}

Start-Sleep -s 60

$offlinedisks = get-disk | Where-Object OperationalStatus -EQ offline
foreach ($disk in $offlinedisks) {
    set-disk -Number $disk.Number -IsOffline $false
}

Import-Module AWSPowerShell
try { $SecretObj = (Get-SECSecretValue -SecretId $SecretAD) }
catch {
    $log.WriteLine("Could not load secret <" + $SecretAD + "> - terminating execution")
    return
}
[PSCustomObject]$Secret = ($SecretObj.SecretString | ConvertFrom-Json)
$log.WriteLine("Domain (from Secret): <" + $Secret.Domain + ">")
$log.WriteLine("OU Path : <" + $OUPath + ">")
#------------------------------------------------------------------------------
# Verify domain membership
#------------------------------------------------------------------------------
$compSys = Get-WmiObject -Class Win32_ComputerSystem
#------------------------------------------------------------------------------
if ( ($compSys.PartOfDomain) -and ($compSys.Domain -eq $Secret.Domain)) {
    $log.WriteLine("Already member of: <" + $compSys.Domain + "> - Verifying RSAT Status")
    #------------------------------------------------------------------------------
    $RSAT = (Get-WindowsFeature RSAT-AD-PowerShell)
    if ($RSAT -eq $null) {
        $log.WriteLine("<RSAT-AD-PowerShell> feature not found - terminating script")
        return
    }
    #------------------------------------------------------------------------------
    if ( (-Not $RSAT.Installed) -and ($RSAT.InstallState -eq "Available") ) {
        $log.WriteLine("Installing <RSAT-AD-PowerShell> feature")
        Install-WindowsFeature RSAT-AD-PowerShell
    }
    #--------------------------------------------------------------------------
    $log.WriteLine("Terminating script - ")
    return
}
#------------------------------------------------------------------------------
# Performing Domain Join
#------------------------------------------------------------------------------
$log.WriteLine("Domain Join required")
#------------------------------------------------------------------------------
$log.WriteLine("Disable OnShutdown task to avoid reboot loop")
$password = $Secret.Password | ConvertTo-SecureString -asPlainText -Force
$username = $Secret.UserID + "@" + $Secret.Domain
$credential = New-Object System.Management.Automation.PSCredential($username, $password)
#------------------------------------------------------------------------------
#Change DNS zone
# $log.WriteLine("Setting the DNS suffix to <" + $Suffix + ">")
# Set-DnsClient -InterfaceAlias "*Ethernet*" -ConnectionSpecificSuffix $Suffix -RegisterThisConnectionsAddress:$false -UseSuffixWhenRegistering:$false -Verbose
# Set-DnsClient -InterfaceAlias "*Ethernet*" -ConnectionSpecificSuffix $Suffix -RegisterThisConnectionsAddress:$true -UseSuffixWhenRegistering:$true -Verbose
#------------------------------------------------------------------------------
#Rename the instance to the AWS Name tag
$instanceId = (invoke-webrequest http://169.254.169.254/latest/meta-data/instance-id -UseBasicParsing).content
$nameValue = (get-ec2tag -filter @{Name = "resource-id"; Value = $instanceid }, @{Name = "key"; Value = "Name" }).Value
$pattern = "^(?![0-9]{1,15}$)[a-zA-Z0-9-]{1,15}$"
##Verify Name Value satisfies best practices for Windows hostnames
$log.WriteLine("Renaming the hostname <" + $nameValue + ">")
#------------------------------------------------------------------------------
If ($nameValue -match $pattern) {
    Try {
        Rename-Computer -NewName $nameValue -ErrorAction Stop
        $log.WriteLine("Hostname renamed to <" + $nameValue + ">")
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        $log.WriteLine("Rename failed: $ErrorMessage")
    }
}
Else {
    $log.WriteLine("Provided name not a valid hostname. Please ensure Name value is between 1 and 15 characters in length and contains only alphanumeric or hyphen characters")
}
#------------------------------------------------------------------------------
$log.WriteLine("Attempting to join domain <" + $Secret.Domain + ">")
#------------------------------------------------------------------------------
Add-Computer -DomainName $Secret.Domain -NewName $nameValue -Credential $credential -PassThru -OUPath $OUPath -Restart -Force
#------------------------------------------------------------------------------
$log.WriteLine("Requesting restart...")
#------------------------------------------------------------------------------
Stop-Transcript
</powershell>