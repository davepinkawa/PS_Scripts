# $Userlist = all users you want to edit. Use -searchbase parameter for full-OU grouping.
# Use this to set the Home / H: Drive for RDS / Citrix XenDesktop users in their AD object

$userlist = Get-ADUser -Filter * -SearchBase "OU=_Users,DC=corp,DC=example,DC=com"

foreach ($u in $userlist) {

$Huser = $u.SamAccountName.ToString()
$Hpath = "\\corp.example.com\Shares$\Home$\" + $Huser

Set-RDUserSetting -SAMAccountname $u.SamAccountName -AllowLogon $True -TerminalServicesHomeDrive "H:" -TerminalServicesHomeDirectory $Hpath -Passthru

}