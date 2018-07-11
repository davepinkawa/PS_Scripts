$plainpassword = 'Example123!'
$password = $plainpassword | ConvertTo-SecureString -AsPlainText -Force

$csv = Import-Csv C:\Users\Administrator\Desktop\users.csv

$csv |
ForEach-Object {
    $Name = ($PSItem.FirstName.replace(' ','') + ' ' + $PSItem.LastName.replace(' ',''))
    $AccountName = ($PSItem.FirstName + '.' + $PSItem.LastName)

    New-ADUser -Name $Name -DisplayName $Name -GivenName $PSItem.FirstName -Surname $PSItem.LastName `
    -SamAccountName $AccountName -UserPrincipalName ($AccountName + '@domain.local') `
    -AccountPassword $password -Enabled $true -Path $PSItem.Path `
    -ProfilePath ('\\my-fileserver.domain.local\Profile$\' + $AccountName) -HomeDirectory ('\\my-fileserver.domain.local\home$\' + $AccountName) -HomeDrive H:
    Write-Host Processed $Name
        }

        #home path not working