<#
.Synopsis
   Used in conjunction with ADLastLogon.ps1 to send csv to email accounts.
.DESCRIPTION
   Sends email using personal internal SMTP relay. Typically used to send AD Logon Data internally.
.EXAMPLE
   Send-toEmail
#>
function Send-toEmail {
    # To be used from DC
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,
                   Position=0)]
        $AttachmentPath = (Get-ChildItem c:\*AD-LogonData.csv)
    )
    $from = $env:USERDOMAIN + "-LogonData@example.com"
    $To = "myEmail@example.com"
    $SMTPServer = "myRelay.example.net"
    $SMTPPort = "25"
    $Subject = $env:USERDOMAIN + " "  + (get-date -Format MMMM).ToString() + " AD Logon Information "
    $Body = "See attached CSV record for this month's logon data for " + $env:USERDNSDOMAIN + " Sent from: " + $env:COMPUTERNAME
    $Attachment = $AttachmentPath[0].ToString()


    Send-MailMessage    -Subject $Subject `
                        -Body $Body `
                        -From $from `
                        -To $To `
                        -SmtpServer $SMTPServer `
                        -Port $SMTPPort `
                        -Attachments $Attachment
}
