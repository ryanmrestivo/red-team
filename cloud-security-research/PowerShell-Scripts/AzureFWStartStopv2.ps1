<#

    Created On: 2/15/2020 2:00 AM
    Created By: Nathan Swift nate.swift@live.com
    
    This script is as is and not supported by Microsoft 
    Microsoft does not assume any risk of data loss

    Use it at your own risk

    NOTES: !! Be sure to add Tags on the Azure Resource RouteTables that need to be associated and disassociated to the subnets during the start and stop of Azure Firewall. 
              
              Use the following tags subnet:vnetname,subnetname - ex subnet:Spoke-VNET,WEB

    REQUIREMENTS: Az.Network Module Version 4.1.0 - Tracking issue with latest Az.Network Module - https://github.com/Azure/azure-powershell/issues/13544

#>

Param
(
  [Parameter (Mandatory= $true)]
  [String] $process = "stop",
  
  [Parameter (Mandatory= $true)]
  [String] $azfwname = "DemoFirewall",

  [Parameter (Mandatory= $true)]
  [String] $azfwrg = "rgAzFwPremiumLab",

  [Parameter (Mandatory= $false)]
  [String] $vnetname = "FirewallVnet",

  [Parameter (Mandatory= $false)]
  [String] $vnetrg = "rgAzFwPremiumLab",

  [Parameter (Mandatory= $false)]
  [String] $pipname = "FirewallPublicIP",

  [Parameter (Mandatory= $false)]
  [String] $piprg = "rgAzFwPremiumLab"

)

# SUed for Starting async jobs to start \ stop azure fw
Enable-AzContextAutosave

# Azure FW Object
$azfw = Get-AzFirewall -Name $azfwname -ResourceGroupName $azfwrg

# Deallocate
if ($process -match "stop"){


    # Deallocate
    $azfw.Deallocate()
    Start-Job {Set-AzFirewall -AzureFirewall $azfw}
    Write-Output ("Azure Firewal $azfw.name Stopped")

    # Find the RouteTables
    $tagudrs = Get-AzResource -ResourceType "Microsoft.Network/routeTables" -TagName 'subnet'

    #For each Route Table execute commands to disassociate the RouteTable from Subnet
    foreach ($tagudr in $tagudrs){
    
        #Collect information for later lookup
        $vnetname = ($tagudr.Tags.subnet).Split(',')[0]
        $subnetname = ($tagudr.Tags.subnet).Split(',')[1]

        #Collect configuration information
        $vnet = Get-AzVirtualNetwork -Name $vnetname
        $subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetname

        #disassociate from subnet config
        $subnet.RouteTable = $null

        #update the VNET and remove RouteTable from Subnet
        Set-AzVirtualNetwork -VirtualNetwork $vnet
        
    }

}

#Reallocate
Elseif ($process -match "start"){

    $vnet = Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $vnetrg
    $publicip = Get-AzPublicIpAddress -Name $pipname -ResourceGroupName $piprg
    $azfw.Allocate($vnet,$publicip)
    Start-Job {Set-AzFirewall -AzureFirewall $azfw}
    Write-Output ("Azure Firewal $azfw.name Started")

    # Find the RouteTables
    $tagudrs = Get-AzResource -ResourceType "Microsoft.Network/routeTables" -TagName 'subnet'

    #For each Route Table execute commands to disassociate the RouteTable from Subnet
    foreach ($tagudr in $tagudrs){
    
        #Collect information for later lookup
        $vnetname = ($tagudr.Tags.subnet).Split(',')[0]
        $subnetname = ($tagudr.Tags.subnet).Split(',')[1]

        #Collect configuration information
        $vnet = Get-AzVirtualNetwork -Name $vnetname
        $subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetname

        #update the VNET and add RouteTable to Subnet
        Set-AzVirtualNetworkSubnetConfig `
        -VirtualNetwork $vnet `
        -Name $subnetname `
        -AddressPrefix $subnet.AddressPrefix `
        -RouteTableId $tagudr.ResourceId | `
        Set-AzVirtualNetwork
        
    }
}

Else {

    Write-Output ("Azure Firewal $azfw.name incorrect process parameter")

    }