$serverlist = Get-ADComputer -Filter 'OperatingSystem -like "*server*"'

foreach ($server in $serverlist) {

    $testrun = invoke-command -computername $server.DNSHostName -scriptblock {Test-Path “HKLM:\Software\Microsoft\Microsoft SQL Server\Instance Names\SQL”}

    $props = @{'ComputerName' = $server.name;
               'SQL Instance Detected' = $testrun;
               'Date' = (get-date).ToShortDateString()
               }
    $object = New-Object -TypeName psobject -Property $props

    if ($testrun -eq "True") {
    Export-Csv -InputObject $object -LiteralPath C:\sql_installed.csv -Append -NoTypeInformation
    }

}