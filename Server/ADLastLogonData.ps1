<#
.Synopsis
   Pulls User LastLogon data in an ingestible way for Citrix Licensing reconciliation. Creates CSV.
.DESCRIPTION
   Can be run in any domain to create a CSV file of user data. Default Location = Root of C:\DomainLogonData\########_AD-UserLogonData.csv
   Only selects users with following Criteria:
   Enabled, have logged on at least 1 time, and have a created date before the 1st of the previous month.
.EXAMPLE
   Get-ADUserLogonData
.EXAMPLE
   Get-ADUserLogonData -Path "C:\Users\Administrator\Desktop\example.csv"
#>
function Get-ADUserLogonData
{
    # To be run from DC server
    [CmdletBinding()]
    Param
    (
        # Path for CSV file to be exported to.
        [Parameter(Mandatory=$false,
                   Position=0)]
        $Path = "C:\" + (get-date).Day + (get-date).Month + (get-date).Year + "_" + $env:USERDNSDOMAIN + "_AD-UserLogonData.csv"
    )
    Process
    {
        $date = Get-Date
        $firstofLastMonth = Get-Date $date.addmonths(-1) -Day 1 -Hour 0 -Minute 0 -Second 0

        Get-ADDomainController -filter * |
        ForEach-Object { Write-host "testing $psitem.name"
        Get-ADUser -Filter {(Enabled -eq 'True') -and (createtimestamp -lt $firstofLastMonth) -and (LastLogon -ne 0) -and (LastLogon -gt $firstofLastMonth)} -Server $PSItem.name -Properties Name,SamAccountName, userprincipalname, LastLogon, LastLogonTimestamp, Company, createtimestamp, logoncount -Verbose |
        Select-Object Name,SamAccountName, UserPrincipalName, Company, CreateTimestamp, `
                    @{N='CreatedMonthYear';E={("{0:yyyy/MM}" -f ($PSItem.createtimestamp))}}, `
                    @{N='LastLogonTimestamp'; E={[DateTime]::FromFileTime($PSItem.LastLogontimestamp)}}, `
                    @{N='LastLogonMonth';E={("{0:MM}" -f [DateTime]::FromFileTime($PSItem.LastLogontimestamp))}}, `
                    @{N='LastLogonYear';E={("{0:yyyy}" -f [DateTime]::FromFileTime($PSItem.LastLogontimestamp))}}, `
                    @{n='CurrentTimestamp';e={$date}}}|
        Group-Object samaccountname |
        ForEach-Object{$PSItem.Group | Sort-Object LastLogonTimestamp -Descending | Select-Object -First 1} |
        Export-Csv "$Path" -NoTypeInformation
    }
}