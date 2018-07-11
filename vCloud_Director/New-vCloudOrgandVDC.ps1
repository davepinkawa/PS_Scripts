# Global Variables for this script 
$OrgShortName = ""        # No Spaces
$OrgFullName = ""         # Spaces allowed
$OrgDescription = ""      # Whatever Description if applicable
$OrgvCDDescription = ""   # VCD Description

$StorageProfile = ""      # Customer Storage Profile that is NOT  *any

# Creates organization in vCloud - Requires Provider Administrator rights - Enabled status by Default
New-Org -Name $OrgShortName `
        -FullName $OrgFullName `
        -Description $OrgDescription

New-OrgVdc  -Name $OrgShortName `
            -Org $OrgFullName `
            -Description $OrgDescription `
            -ProviderVdc `
            -AllocationModelAllocationPool `
            -CpuAllocationGhz `
            -MemoryAllocationGB `
            -NetworkPool `
            -StorageAllocationGB `




Function New-CIOrgVdc {
Param (
$OrgName = "$OrgShortName",
$OrgvDCName = "$OrgFullName",
$ProviderVDC,
$CPuGHz,
$CPuReservation,
$MEmMB,
$MEmReservation,
$StorageLimitMB,
$StorageProfile,
$NetworkPool
)
Process {

#Storage Profile “Any” is needed for initial VDC creation – will be deleted afterwards
New-OrgVdc -Name $orgvDCName -AllocationModelAllocationPool -CPUAllocationGHz $CPuGHz -MemoryAllocationGB $MEmMB -Org $orgName -ProviderVDC $ProviderVDC -StorageAllocationGB 1

# Add a Storage Profile to the newly created Org VDC
# Find the desired Storage Profile in the Provider vDC to be added to the Org vDC
$orgPvDCProfile = search-cloud -QueryType ProviderVdcStorageProfile -Name $storageProfile | Get-CIView

# Create a new object of type VdcStorageProfileParams and configure the parameters for the Storage Profile
$spParams = new-object VMware.VimAutomation.Cloud.Views.VdcStorageProfileParams
$spParams.Limit = $StorageLimitMB
$spParams.Units = “MB”
$spParams.ProviderVdcStorageProfile = $orgPvDCProfile.href
$spParams.Enabled = $true
$spParams.Default = $false

# Create an UpdateVdcStorageProfiles object and put the new parameters into the AddStorageProfile element
$UpdateParams = new-object VMware.VimAutomation.Cloud.Views.UpdateVdcStorageProfiles
$UpdateParams.AddStorageProfile = $spParams

# Get the Org VDC and create the Storage Profile
#Get-OrgVcd $name -> not working with ISE
$orgVdc = Get-OrgVdc -Name $orgvDCName

$orgVdc.ExtensionData.CreateVdcStorageProfile($UpdateParams)

#Set the new storage profile as default
$orgvDCStorageProfile = search-cloud -querytype AdminOrgVdcStorageProfile | where {($_.Name -match $storageProfile) -and ($_.VdcName -eq $orgvDCName)} | Get-CIView
$orgvDCStorageProfile.Default = $True
$orgvDCStorageProfile.UpdateServerData()

# Delete the *(Any) Storage Profile
# Get object representing the * (Any) Profile in the Org vDC
$orgvDCAnyProfile = search-cloud -querytype AdminOrgVdcStorageProfile | where {($_.Name -match ‘\*’) -and ($_.VdcName -eq $orgvDCName)} | Get-CIView

# Disable the “* (any)” Profile
$orgvDCAnyProfile.Enabled = $False
$orgvDCAnyProfile.UpdateServerData()

# Remove the “* (any)” profile form the Org vDC completely
$ProfileUpdateParams = new-object VMware.VimAutomation.Cloud.Views.UpdateVdcStorageProfiles
$ProfileUpdateParams.RemoveStorageProfile = $orgvDCAnyProfile.href
$orgvDC.extensiondata.CreatevDCStorageProfile($ProfileUpdateParams)

#Set Org VDC Params
$orgvDC | Set-OrgVdc -CpuGuaranteedPercent $CPuReservation -MemoryGuaranteedPercent $MEmReservation -VMMaxCount $null -ThinProvisioned $true -UseFastProvisioning $false -NetworkMaxCount “10” -NetworkPool $NetworkPool

}

}