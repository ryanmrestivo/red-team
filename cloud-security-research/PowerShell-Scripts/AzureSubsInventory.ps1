# Created On: 8/8/2018 11:00 PM
# Created By: Nathan Swift nate.swift@live.com
# This script is as is and not supported by Microsoft 
# Microsoft does not assume any risk of data loss
# Use it at your own risk
################################################################################


# Path and filename for output data file being generated.
$path = "C:\temp\azuresubinventory.txt"
$csvpath = "C:\temp\azuresubinventory.csv"

# Authenticate Piece
#Login-AzureRmAccount

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
$azusubstring = "SubscriptionName,SubscriptionGUID,SubscriptionSKU,SubscriptionOwners,TenantID,TenantName"
$azusubstring | Out-File $outputFile -append -force

# Iterate through all subscriptions
foreach($sub in $subs) {

# Set the current  Azure Subscription to pull information from
Set-AzureRmContext -Subscription $sub.Name

$SubOwner = Get-AzureRmRoleAssignment | where-object {$_.RoleDefinitionName –eq “Owner” -and $_.SignInName -ne $null} | Select -First 3


#FUTURE AREA TO CAPTURE
$subsku = "TBD"

#Obtain TenantName trying to find way to end and capture tenant name in error response header.
#$URL = "https://management.azure.com/subscriptions/$sub" +"?api-version=2016-01-01"
#$tenantname = try{Invoke-RestMethod -UseBasicParsing -Uri $URL} catch {$err=$_.Exception}
#$err.Response.GetResponseHeader()
$tenantname = "TBD"

# "Subscription,ResourceGroup,Type,ResourceName,Location,MACAddress,IPAdress,Allocation,NumberOfCores,MemoryMB,VMSize,Publisher,Offer,Sku"
# Write out VM line of data collected and place into csv
$azusubstring = "$($sub.Name),$($sub.Id),$($subsku),$($SubOwner.SignInName),$($sub.TenantId),$($tenantname)"

#Write into and append into output file
$azusubstring | Out-File $outputFile -append -force


}



# Time Tracking Finished
$datetime = Get-Date
Write-Host $datetime

# Once done import the data into excel

$CSV = Import-Csv -Path $path
$CSV | Export-Csv -Path $csvpath -NoTypeInformation