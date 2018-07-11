# LogicMonitor custom datasource to test servers for domain secure channel = True
# get the hostname of the device
$hostname = '##SYSTEM.HOSTNAME##';
$userid   = '##WMI.USER##';
$passwd   = '##WMI.PASS##';

# builds a credential object
$secure_passwd  = ConvertTo-SecureString -String $passwd -AsPlainText -Force;
$user_credential = New-Object -typename System.Management.Automation.PSCredential ($userid, $secure_passwd);

# PowerShell remote commands REQUIRE WinRM to be enabled for the servers targetted.
# Server 2012 and up this is enabled by default. < 2012 require the command "WinRM Quickconfig -q" to be run.
# Test-ComputerSecureChannel is for all domain joined computers, that are NOT the domain PDC emulator. Will fail for PDC.
$script = Invoke-Command -ComputerName $hostname -ScriptBlock {Test-ComputerSecureChannel} -Credential $user_credential

# Error handling here will mark the script as "1" if the error targetname reports as the hostname.
if (($script -eq $true) -or ($error[0].CategoryInfo.TargetName -ccontains "$hostname")){
    Write-Host "1"
}
else{
    Write-Host "0"
}