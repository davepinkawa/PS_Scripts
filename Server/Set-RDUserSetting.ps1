Function Set-RDUserSetting {
[cmdletbinding(SupportsShouldProcess)]
 
Param(
[Parameter(Position=0,Mandatory,HelpMessage="Enter a user's sAMAccountName",
ValueFromPipeline,ParameterSetName="SAM")]
[ValidateNotNullorEmpty()]
[Alias("Name")]
[string]$SAMAccountname,
[Parameter(ParameterSetName="SAM")]
[string]$SearchRoot,
 
[Parameter(Mandatory,HelpMessage="Enter a user's distingished name",
ValueFromPipelineByPropertyName,ParameterSetName="DN")]
[ValidateNotNullorEmpty()]
[Alias("DN")]
[string]$DistinguishedName,
 
[boolean]$AllowLogon,
[Alias("Profile")]
[string]$TerminalServicesProfilePath,
[Alias("HomeDirectory")]
[string]$TerminalServicesHomeDirectory,
[Alias("HomeDrive")]
[string]$TerminalServicesHomeDrive,
 
[string]$Server,
 
[switch]$Passthru
)
 
Begin {
    Write-Verbose "Starting $($MyInvocation.MyCommand)"
    Write-Verbose ($PSBoundParameters | out-string)
    #remote desktop properties
    $TSSettings = @("TerminalServicesProfilePath","TerminalServicesHomeDirectory","TerminalServicesHomeDrive")
} #Begin
 
Process {
  
  Write-Verbose "Using parameter set $($PSCmdlet.ParameterSetName)"
    Switch ($PSCmdlet.ParameterSetName) {
    
    "SAM" {
        Write-Verbose "Retrieving distinguishedname for $samAccountname"
        $searcher = New-Object DirectoryServices.DirectorySearcher
        $searcher.Filter = "(&(objectcategory=person)(objectclass=user)(samAccountname=$sAMAccountname))"
        Write-Verbose $searcher.filter
        if ($SearchRoot) {
            Write-Verbose "Searching from $SearchRoot"
            if ($Server) {
                $searchPath = "LDAP://$server/$SearchRoot"
            }
            else {
                $searchPath = "LDAP://$SearchRoot"
            }
            $r = New-Object System.DirectoryServices.DirectoryEntry $SearchPath
 
            $searcher.SearchRoot = $r
        }
        $user = $searcher.FindOne().GetDirectoryEntry()
    } 
    "DN" {
        Write-Verbose "Processing $DistinguishedName"
        if ($server) {
            Write-Verbose "Connecting to $Server"
            [ADSI]$User = "LDAP://$Server/$DistinguishedName"
        }
        else {
            [ADSI]$User = "LDAP://$DistinguishedName"
        }
    }
    } #close Switch
 
    if ($user.path) {
        if ($PSBoundParameters.ContainsKey("AllowLogon")) {
            Write-Verbose "Configuring AllowLogon"
            $user.psbase.invokeSet("AllowLogon",$AllowLogon -as [int])
        }       
        foreach ($property in $TSSettings) {
        if ($PSBoundParameters.ContainsKey($property)) {
            Write-Verbose "Setting $property = $($PSBoundParameters[$property])"
            $user.psbase.invokeSet($property,$PSBoundParameters[$property])
        }       
        }
        #commit changes
        if ($PSCmdlet.ShouldProcess($DistinguishedName)){
            $user.setInfo()
        } #Whatif
 
        if ($Passthru) {
           $hash=[ordered]@{
            DistinguishedName = $User.DistinguishedName.Value
            Name = $user.name.Value
            samAccountName = $user.samAccountName.value
            AllowLogon = $user.psbase.InvokeGet("AllowLogon") -as [Boolean]
            }
 
         foreach ($property in $TSSettings) {
            $hash.Add($property,$user.psbase.InvokeGet($property))
            
        } #foreach
               
        #create an object
        New-Object -TypeName PSObject -Property $hash
        }
    } #if user found
    else {
        Write-Warning "Failed to find user $DistinguishedName"
    }
 
} #Process
 
 
End {
    Write-Verbose "Ending $($MyInvocation.MyCommand)"
} #End
 
 
} #end function