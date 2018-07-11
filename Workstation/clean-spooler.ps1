<#
.SYNOPSIS
    Clean old spooled documents.
.DESCRIPTION
    This script will delete old spooled documents that are stuck in queue.
.EXAMPLE
    ./Clean-Spooler.ps1
#>

$Date = Get-Date

Stop-Service spooler
Start-Sleep 5
Get-ChildItem -Path "C:\Windows\System32\spool\PRINTERS" | Where-Object { $_.LastWriteTime -lt $Date } | Remove-Item -Verbose
Start-Service spooler