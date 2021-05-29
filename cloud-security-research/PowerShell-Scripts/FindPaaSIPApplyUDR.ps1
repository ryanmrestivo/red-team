# Created On: 10/30/2018 5:21 PM
# Created By: Nathan Swift nate.swift@live.com
# This script is as is and not supported by Microsoft 
# Microsoft does not assume any risk of data loss
# Use it at your own risk
################################################################################

<# 
Current Services:

Storage Account
PaaS SQL DB
DataLakeGen

#>

<#  Possible Futures:
 
#>
## Subscription name here
$Sub = "Subscription Name Here"

# Authenticate Piece
Login-AzureRmAccount

# Set the current  Azure Subscription to pull information from
Set-AzureRmContext -Subscription $Sub

$datetimestart = Get-Date

# This function will look up DNS hostname passed into it and respond and return the ipv4 response value
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


{



}

#Collect all resources in current context Subscription
    $Resources = Get-AzureRmResource -ExpandProperties
  
    # Loop and iterate through all Azure Resources to begin collecting data
    foreach ($Resource in $Resources) {
  
      # Type of Azure resource
      $RGName = $Resource.ResourceGroupName
      $Name = $Resource.name
      $Type = $Resource.resourcetype
  
      # Set variable $URL to NOTSET to prevent azure services that do not contain public enpoint from being executed against
      $URL = "NOTSET"
   
      try {
          
        switch -Regex ($Type) {
          ## Storage Accounts
          "Microsoft.Storage/storageAccounts$" {
            #storage accounts are weird, so we have to wire the output up differently
            "blob", "file", "queue", "table" | ForEach-Object {
              $URL = "$Name.$_.core.windows.net"
              $RouteAdd = Get-DnsEntry $URL
              $RouteAdd = $RouteAdd+"/32"
              Get-AzureRmRouteTable -ResourceGroupName "rgSampleRT" -Name "Sample-RT" | Add-AzureRmRouteConfig -Name $URL -AddressPrefix $RouteAdd -NextHopType "Internet" | Set-AzureRmRouteTable
            }; break
          }
          ## SQL
          "Microsoft.Sql/servers$" { $URL = $Resource.Properties.fullyQualifiedDomainName
          $RouteAdd = Get-DnsEntry $URL
          $RouteAdd = $RouteAdd+"/32"
          Get-AzureRmRouteTable -ResourceGroupName "rgSampleRT" -Name "Sample-RT" | Add-AzureRmRouteConfig -Name $URL -AddressPrefix $RouteAdd -NextHopType "Internet" | Set-AzureRmRouteTable
          ; break }
          ## DataLake
          "Microsoft.DataLakeStore/accounts$" { $URL = $Resource.Properties.endpoint
          $RouteAdd = Get-DnsEntry $URL
          $RouteAdd = $RouteAdd+"/32"
          Get-AzureRmRouteTable -ResourceGroupName "rgSampleRT" -Name "Sample-RT" | Add-AzureRmRouteConfig -Name $URL -AddressPrefix $RouteAdd -NextHopType "Internet" | Set-AzureRmRouteTable          
          ; break }
        }
      } Catch [Exception] {
          Write-Error "An error occurred: $_"
      }
    } #foreach($Resource in $Resources)
  
  # Time Tracking Finished
  $datetimeend = Get-Date
  Write-Host "Started on $datetimestart"
  Write-Host "Finished on $datetimeend"
