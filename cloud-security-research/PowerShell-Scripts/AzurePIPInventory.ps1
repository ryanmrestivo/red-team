# Created On: 8/3/2018 1:21 PM
# Created By: Nathan Swift nate.swift@live.com
# This script is as is and not supported by Microsoft 
# Microsoft does not assume any risk of data loss
# Use it at your own risk
################################################################################

<# 
Current Services:

PaaS SQL DB
PaaS MySQL DB
Cosmos DB
Functions
Storage Account

#>

<#  Possible Futures:
 
#>

Function Get-DnsEntry($iphost)

{

 If($ipHost -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")

  {

    [System.Net.Dns]::GetHostEntry($iphost).HostName

  }

 ElseIf( $ipHost -match "^.*\.\.*")

   {

    [System.Net.Dns]::GetHostEntry($iphost).AddressList[0].IPAddressToString

   }

 ELSE { Throw "Specify either an IP V4 address or a hostname" }

} 

# Path and filename for output data file being generated.
$path = "C:\temp\subspipinventory.txt"
$csvpath = "C:\temp\subspipinventory.csv"

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
$vmstring = "Subscription,ResourceGroupName,Type,ResourceName,ResourcePIP"
$vmstring | Out-File $outputFile -append -force

# Iterate through all subscriptions
foreach($sub in $subs) {

# Set the current  Azure Subscription to pull information from
Set-AzureRmContext -Subscription $sub.Name


#Collect all VMs in current context Subscription
$Resources = Get-AzureRmResource

# Loop and iterate through all VMs to begin collecting data
foreach($Resource in $Resources) {

# Type of Azure resource
$Type = $Resource.resourcetype

#If Publisher is NULL VM Image is Custom Maintained
If ($Type -eq "Microsoft.Storage/storageAccounts")
{

$URL = $Resource.Name + ".blob.core.windows.net"

$ResourcePIP = Get-DnsEntry $URL

# "Subscription,ResourceGroup,Type,ResourceName,Location,MACAddress,IPAdress,Allocation,NumberOfCores,MemoryMB,VMSize,Publisher,Offer,Sku"
# Write out VM line of data collected and place into csv
$vmstring = "$($sub.Name),$($Resource.ResourceGroupName),$($Type),$($Resource.name),$($ResourcePIP)"

#Write into and append into output file
$vmstring | Out-File $outputFile -append -force

$URL = $Resource.Name + ".file.core.windows.net"

$ResourcePIP = Get-DnsEntry $URL

# "Subscription,ResourceGroup,Type,ResourceName,Location,MACAddress,IPAdress,Allocation,NumberOfCores,MemoryMB,VMSize,Publisher,Offer,Sku"
# Write out VM line of data collected and place into csv
$vmstring = "$($sub.Name),$($Resource.ResourceGroupName),$($Type),$($Resource.name),$($ResourcePIP)"

#Write into and append into output file
$vmstring | Out-File $outputFile -append -force

$URL = $Resource.Name + ".queue.core.windows.net"

$ResourcePIP = Get-DnsEntry $URL

# "Subscription,ResourceGroup,Type,ResourceName,Location,MACAddress,IPAdress,Allocation,NumberOfCores,MemoryMB,VMSize,Publisher,Offer,Sku"
# Write out VM line of data collected and place into csv
$vmstring = "$($sub.Name),$($Resource.ResourceGroupName),$($Type),$($Resource.name),$($ResourcePIP)"

#Write into and append into output file
$vmstring | Out-File $outputFile -append -force

$URL = $Resource.Name + ".table.core.windows.net"

$ResourcePIP = Get-DnsEntry $URL

# "Subscription,ResourceGroup,Type,ResourceName,Location,MACAddress,IPAdress,Allocation,NumberOfCores,MemoryMB,VMSize,Publisher,Offer,Sku"
# Write out VM line of data collected and place into csv
$vmstring = "$($sub.Name),$($Resource.ResourceGroupName),$($Type),$($Resource.name),$($ResourcePIP)"

#Write into and append into output file
$vmstring | Out-File $outputFile -append -force

}


# RESEARCH https://docs.microsoft.com/en-us/azure/sql-database/sql-database-connectivity-architecture
ElseIf ($Type -eq "Microsoft.Sql/servers") {

$URL = $Resource.Name + ".database.windows.net"

$ResourcePIP = Get-DnsEntry $URL

# "Subscription,ResourceGroup,Type,ResourceName,Location,MACAddress,IPAdress,Allocation,NumberOfCores,MemoryMB,VMSize,Publisher,Offer,Sku"
# Write out VM line of data collected and place into csv
$vmstring = "$($sub.Name),$($Resource.ResourceGroupName),$($Type),$($Resource.name),$($ResourcePIP)"

#Write into and append into output file
$vmstring | Out-File $outputFile -append -force

}

ElseIf ($Type -eq "Microsoft.DBforMySQL/servers") {

$URL = $Resource.Name + ".mysql.database.azure.com"

$ResourcePIP = Get-DnsEntry $URL

# "Subscription,ResourceGroup,Type,ResourceName,Location,MACAddress,IPAdress,Allocation,NumberOfCores,MemoryMB,VMSize,Publisher,Offer,Sku"
# Write out VM line of data collected and place into csv
$vmstring = "$($sub.Name),$($Resource.ResourceGroupName),$($Type),$($Resource.name),$($ResourcePIP)"

#Write into and append into output file
$vmstring | Out-File $outputFile -append -force

}

ElseIf ($Type -eq "Microsoft.Web/sites/functions") {

$URL = $Resource.Name + ".azurewebsites.net"

$ResourcePIP = Get-DnsEntry $URL

# "Subscription,ResourceGroup,Type,ResourceName,Location,MACAddress,IPAdress,Allocation,NumberOfCores,MemoryMB,VMSize,Publisher,Offer,Sku"
# Write out VM line of data collected and place into csv
$vmstring = "$($sub.Name),$($Resource.ResourceGroupName),$($Type),$($Resource.name),$($ResourcePIP)"

#Write into and append into output file
$vmstring | Out-File $outputFile -append -force

}

ElseIf ($Type -eq "Microsoft.DocumentDB/databaseAccounts") {

$URL = $Resource.Name + "documents.azure.com"

$ResourcePIP = Get-DnsEntry $URL

# "Subscription,ResourceGroup,Type,ResourceName,Location,MACAddress,IPAdress,Allocation,NumberOfCores,MemoryMB,VMSize,Publisher,Offer,Sku"
# Write out VM line of data collected and place into csv
$vmstring = "$($sub.Name),$($Resource.ResourceGroupName),$($Type),$($Resource.name),$($ResourcePIP)"

#Write into and append into output file
$vmstring | Out-File $outputFile -append -force

}

}


}

# Time Tracking Finished
$datetime = Get-Date
Write-Host $datetime

# Once done import the data into excel

$CSV = Import-Csv -Path $path
$CSV | Export-Csv -Path $csvpath -NoTypeInformation