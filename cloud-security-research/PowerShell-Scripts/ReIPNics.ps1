Login-AzureRmAccount

Set-AzureRMContext -Subscription ""


# Your Resource Group where the nics need to be changed
$RGnics = ""

# Your Resource Group where the existing VNET with new Ip Address Space is
$RGVNET = ""

# Your VNET name with new Ip Address Space is
$VNETname = ""

# Your VNET and new Subnet to change Nics to with new address space
$newsubnetname = ""

# Your Nic Ip config Name it is typically "ipconfig1"
$Nicipname = "ipconfig1"

#Obtains Nics to change
$Nics = Get-AzureRmNetworkInterface -ResourceGroupName $RGnics

#Obtain VNET PS Object
$VNET = Get-AzureRmVirtualNetwork -Name $VNETName -ResourceGroupName $RG

#Obtains Subnet PS Object
$newsubnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $VNET -Name $newsubnetname

# Loop to change the NICS
foreach ($Nic in $Nics){

#Change the PS object of SubnetID to new one
$Nic.IpConfigurations[0].Subnet.Id = $newsubnet.id

#Save PS Object Changes to the Nic
Set-AzureRmNetworkInterface -NetworkInterface $Nic

}

$LBs = Get-AzureRmLoadBalancer -ResourceGroupName $RGVNET

## Future build for ILB reIPs
# Loop to change the ILB FrontEnd
#foreach ($LB in $LBs){

#Change the PS object of SubnetID to new one
#$LB.FrontEndIpConfigurations[0].Subnet.Id = $newsubnet.id

#Save PS Object Changes to the Nic
#Set-AzureRmLoadBalancerFrontendIpConfig -LoadBalancer $LB -Name $LB.Name -Subnet $newsubnet


#}
