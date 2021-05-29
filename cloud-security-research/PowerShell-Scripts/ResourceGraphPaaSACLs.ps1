# Created On: 12/5/2018 1:21 PM
# Created By: Nathan Swift nate.swift@live.com
# This script is as is and not supported by Microsoft 
# Microsoft does not assume any risk of data loss
# Use it at your own risk
# Requirements: AzurePS 6.3.0 or Higher, Module: AzureRM.ResourceGraph - https://docs.microsoft.com/en-us/azure/governance/resource-graph/first-query-powershell

################################################################################

<# 
Current Services:

Storage Account
KeyVault

#>

<#  Possible Futures:
 
 Cleaner output string data and Out-File 

 Azure SQL Database
 Azure SQLDW
 Azure PostgreSQL
 Azure MySQL
 Azure CosmosDB
 Azure Service Bus
 Azure EventHubs
 Azure Data Lake Storage Gen1

#>

# Path and filename for output data file being generated.
$path = "C:\temp\PaaSACLsinventory.txt"
$csvpath = "C:\temp\PaaSACLsinventory.csv"

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


# Outputfile for PaaS ACL inventory
$outputFile = $path

#Set and apply 1st line of csv headers
$string = "Name,Type,PaaS-ACL"
$string | Out-File $outputFile -append -force

# Graph Search Storage Account
$stores = Search-AzureRmGraph -Query "where type contains 'storageaccounts' | order by name asc"  | Select name, type, properties

# Iterate through each storage account and output into file
foreach ($store in $stores){


    $string = "$($Store.name),$($store.type),$($store.properties.networkAcls.defaultAction)"

    $string | Out-File $outputFile -append -force

}

# Graph Search KeyVaults
$kvs = Search-AzureRmGraph -Query "where type contains 'keyvault' | order by name asc" | Select name, type, aliases

# Iterate through each KeyVault and output into file
foreach ($kv in $kvs){

    if ($kv.aliases.'Microsoft.KeyVault/vaults/networkAcls.defaultAction' -contains 'deny'){

        $kvacl = "Deny"

    } Else {

        $kvacl = "Allow"

    }

    $string = "$($kv.name),$($kv.type),$($kvacl)"

    $string | Out-File $outputFile -append -force

}

# Time Tracking Finished
$datetime = Get-Date
Write-Host $datetime

# Once done import the data into excel

$CSV = Import-Csv -Path $path
$CSV | Export-Csv -Path $csvpath -NoTypeInformation