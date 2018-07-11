<#
.Synopsis
   Requires module sqlserver
.DESCRIPTION
   imports CSV as a table to SQL. This specific case for posting AD logon data from 'ADLastLogonData.ps1'
.EXAMPLE
   Example of how to use this cmdlet
#>
function Send-CSVtoSQL
    {
    # To be run from SQL Server
    Import-Module sqlserver
    $SQLInstance = "localhost\INSTANCE"
    $DomainName = ''
    # insecure user account. should probably use a Managed Service Account here in the future.
    $User = "sqluseraccount"
    $PWord = ConvertTo-SecureString -String "randomPasswordShouldGoHere" -AsPlainText -Force
    $Credential = New-Object -TypeName "System.Management.Automation.pscredential" -ArgumentList $User, $PWord
    $FTPcontents = Get-ChildItem -Path '\\ftp.example.com\ftpFOLDER'

    foreach ($file in $FTPcontents) {
        if ($file.name -like "*example*") {
            $importedFile = Import-Csv $file.FullName
            $DomainName = "example.local"
            $importedFile | Write-SqlTableData -ServerInstance $SQLInstance -DatabaseName "database1" -SchemaName "adlogondata" -TableName $DomainName -Credential $Credential -Force
        }
        elseif ($file.name -like "*example2*") {
            $importedFile = Import-Csv $file.FullName
            $DomainName = "example2.com"
            $importedFile | Write-SqlTableData -ServerInstance $SQLInstance -DatabaseName "database1" -SchemaName "adlogondata" -TableName $DomainName -Credential $Credential -Force

        }
    }
}
