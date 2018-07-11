# Add sites to 'Trusted Sites' via powershell on a workstation

$httpsSites = "google.com", "appsforoffice.microsoft.com", "microsoft.com"
$httpSites = "google-analytics.com", "microsoft.com"

ForEach ($s in $httpsSites) {


    set-location "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    set-location ZoneMap\Domains
    new-item $s
    set-location $s
    new-itemproperty . -Name https -Value 2 -Type DWORD

    }

ForEach ($h in $httpSites) {


    set-location "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    set-location ZoneMap\Domains
    new-item $h
    set-location $h
    new-itemproperty . -Name http -Value 2 -Type DWORD

    }