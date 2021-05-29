# Created On: 6/13/2018 1:21 PM
# Created By: Nathan Swift nate.swift@live.com
# This script is as is and not supported by Microsoft 
# Microsoft does not assume any risk of data loss
# Use it at your own risk
################################################################################

<#  Possible Futures:
 
1. Logic to handle multiple Nics and information on VM, especially for NVAs
2. Logic to handle disk detection count, size, and performance of disks attached to VM, 
3. Provide some samples/Guidance for authentication using SPN, Scheduled Task, Stored Cred in Win, AutomationAccount
4. Other Resources change header string to accomodate L7LB, ELB PIPs

#>

# Path and filename for output data file being generated.
$path = C:\temp\subsazuinventory.txt
$csvpath = "C:\temp\azuinventory.csv"

# Authenticate Piece
Login-AzureRmAccount

# Time Tracking Start
$datetime = Get-Date
Write-Host $datetime

# File check to overwrite existing vm inventory collection
$filecheck = Get-FileHash -Path $path

If ($filecheck.Path -eq $path)
{
Remove-Item -Path $path
Write-host "Removed Previous File"
}
else
{
Write-host "No Previous File Found"
}

# File check to overwrite existing vm inventory collection
$filecheck2 = Get-FileHash -Path $csvpath

If ($filecheck2.Path -eq $csvpath)
{
Remove-Item -Path $csvpath
Write-host "Removed Previous File"
}
else
{
Write-host "No Previous File Found"
}

# Collect all subscriptions
$subs = Get-AzureRmSubscription

# Outputfile for vm inventory
$outputFile = $path

#Set and apply 1st line of csv headers
$vmstring = "Subscription,ResourceGroup,Type,ResourceName,Location,MACAddress,IPAdress,Allocation,NumberOfCores,MemoryMB,VMSize,Publisher,Offer,Sku"
$vmstring | Out-File $outputFile -append -force

# Iterate through all subscriptions
foreach($sub in $subs) {

# Set the current  Azure Subscription to pull information from
Set-AzureRmContext -Subscription $sub.Name


#Collect all VMs in current context Subscription
$VMs = Get-AzureRmVM

# Loop and iterate through all VMs to begin collecting data
foreach($VM in $VMs) {

# Type of Azure resource
$Type = "VM"

#Find VM OS Properties
$image = $VM.Storageprofile.ImageReference

#Find VM Size
$vmhw = $VM.hardwareProfile.VmSize

#Find VM Cores
$vmhwcore = Get-AzureRMvmsize -location $VM.Location | ?{ $_.name -eq $vmhw }

#Find VM Image Publisher
$publisher = $image.publisher

#If Publisher is NULL VM Image is Custom Maintained
If ($publisher -eq $null)
{
    $publisher = "CustomImage"
}

#Find VM Image Offer
$offer = $image.offer

#Find VM SKU
$sku = $image.sku

#Obtain Nic Configuration and obtain/use use the resourceid to get nic properties
## Only collecting the Primary or 1st NIC on VM, NVAs could have multiple nics, script logic will need to be introduced and csv format thought through for multiple entries in a column to handle multiple nics and store data however this logic is not baked in the script, possibly future release
$VMnicid = $VM.NetworkProfile.NetworkInterfaces[0].Id
$VMnicprop = Get-AzureRmResource -ResourceId $VMNicid -ExpandProperties

#Obtain MAC Address
$VMAMC = (Get-AzureRmResource -ResourceId $VMNicid -ExpandProperties).Properties.macAddress

#Obtain IP Address of Nic ## Stored even when VM is Stopped Deallocated, however MAC is not stored when Stopped Deallocated
$VMprivip = (Get-AzureRmResource -ResourceId $VMNicid -ExpandProperties).Properties.ipConfigurations[0].properties.PrivateIPAddress

#Obtain IP Address Allocation
$VMprivipq = (Get-AzureRmResource -ResourceId $VMNicid -ExpandProperties).Properties.ipConfigurations[0].properties.privateIPAllocationMethod

# "Subscription,ResourceGroup,Type,ResourceName,Location,MACAddress,IPAdress,Allocation,NumberOfCores,MemoryMB,VMSize,Publisher,Offer,Sku"
# Write out VM line of data collected and place into csv
$vmstring = "$($sub.Name),$($VM.ResourceGroupName),$($Type),$($VM.name),$($VM.Location),$($VMAMC),$($VMprivip),$($VMprivipq),$($vmhwcore.NumberOfCores),$($vmhwcore.MemoryInMB),$($VM.HardwareProfile.VMSize),$($publisher),$($offer),$($sku)"

#Write into and append into output file
$vmstring | Out-File $outputFile -append -force

}

#Collect all LBs in current context Subscription
$LBs = Get-AzureRmLoadBalancer

# Loop and iterate through all LBss to begin collecting data
foreach($LB in $LBs) {

# Type of Azure resource
$Type = "L4LB"

#Obtain Private IP Address of LB
$LBprivip = $LB.FrontendIpConfigurations.PrivateIpAddress

#Obtain IP Address Allocation
$LBprivipq = $LB.FrontendIpConfigurations.PrivateIpAllocationMethod

$sku = $LBs[0].Sku.Name

# "Subscription,ResourceGroup,Type,ResourceName,Location,MACAddress,IPAdress,Allocation,NumberOfCores,MemoryMB,VMSize,Publisher,Offer,Sku"
# Write out LB line of data collected and place into csv
$lbstring = "$($sub.Name),$($LB.ResourceGroupName),$($Type),$($LB.name),$($LB.Location),,$($LBprivip),$($LBprivipq),,,,,,$($sku)"

#Write into and append into output file
$lbstring | Out-File $outputFile -append -force


}


}

# Time Tracking Finished
$datetime = Get-Date
Write-Host $datetime

# Once done import the data into excel

$CSV = Import-Csv -Path $path
$CSV | Export-Csv -Path $csvpath -NoTypeInformation
