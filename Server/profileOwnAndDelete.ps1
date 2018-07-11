# Use Case:  If user account removed from AD, and the profile folders exist and need deleting requiring ownership.

# Script has been tested running directly on the Profile-containing file server

# This should be able to be invoked from any server to the File Server if needed via Invoke-Command (See:Help Invoke-Command -Full)

# User that has been deleted from AD, but profiles persist and require ownership to remove. Only edit this single value.
$ownUser = "AD_Username_here"

# Both the V2 and V6 profile names
$v2prof = $ownUser + ".V2"
$v6prof = $ownUser + ".V6"

# Server path of the file server concatentated with the profile names
$profPathv2 = "\\fileserver-path\Profiles" + $v2Prof
$profPathv6 = "\\fileserver-path\Profiles\" + $v6Prof


# Takeown.exe takes ownership of the profile folder
# icacles.exe grants Administrators group full access to the profile folder
# Remove-Item is Powershell to delete the folder and all contents

Write-Host "Processing $v2Prof"
    if ((Test-Path $profPathv2) -eq $true) {
        C:\Windows\System32\takeown.exe /F $profPathv2 /R /D Y
        C:\Windows\System32\icacls.exe $profPathv2 /grant Administrators:F /T /C
        Remove-Item -Path $profPathv2 -Verbose -Recurse -force
    }
    Else {
        Write-Host "Path does not exist for $profPathv2; exiting script"
        Break
    }

Write-Host "Processing $v6Prof"
    if ((Test-Path $profPathv6) -eq $true) {
        C:\Windows\System32\takeown.exe /F $profPathv6 /R /D Y
        .\icacls.exe $profPathv6 /grant Administrators:F /T /C
        Remove-Item -Path $profPathv6 -Verbose -Recurse -force
    }
    Else {
        Write-Host "Path does not exist for $profPathv6; exiting script"
        Break
    }