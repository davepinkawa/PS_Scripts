# Lists all AD Groups that a particular AD object is member of
# Must be run from the DC via pssession or as a wholy invoked command

# Change $userorgroup to your search item

$UserOrGroup = "david.example"

Get-ADPrincipalGroupMembership "$UserOrGroup" |
    get-adgroup -property description, groupcategory |
    select-object Name, GroupCategory, Description |
    Sort-Object GroupCategory, Name |
    Format-Table -AutoSize