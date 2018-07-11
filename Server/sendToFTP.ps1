<#
.Synopsis
   Sending a target CSV file to a basic FTP server
.DESCRIPTION
   Uses .net calls to send a file to a FTP server
.EXAMPLE
   Edit all $variables to proper values. This goes for accounts, ftp server, password, and csv filename.
   Send-toFTP
#>
function Send-toFTP {
    # To be used from DC
    #local folder containing csv data
    $Dir="C:\"
    #ftp server
    $ftp = "ftp://ftp.example.com/"
    $user = "myFTPuser"
    $pass = "unsecure-pass-goes-here"
    $webclient = New-Object System.Net.WebClient
    $webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)
    #list csv files to upload
    foreach($item in (Get-ChildItem $Dir "*testFile.csv")){
        "Uploading $item..."
        $uri = New-Object System.Uri($ftp+$item.Name)
        $webclient.UploadFile($uri, $item.FullName)
     }

}