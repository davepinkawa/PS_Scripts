# Compares 2 AD groups and shows a list of users that are ONLY in the second group. 

$A = "nocusers"
$B = "domain users"

Compare-Object (Get-ADGroupMember $A) (Get-ADGroupMember $B) -Property 'Name' -IncludeEqual | 
    sort-object name  | 
    where-object -filter {$_.SideIndicator -eq '=>'}

# Result = list of users that are in Group "B" but NOT in Group "A"