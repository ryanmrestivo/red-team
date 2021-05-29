#################################### Single Instance Subnet monitored

$vnet = "XXXXXX"
$subnet = "XXXXX"
$vnetobj = Get-AzVirtualNetwork -Name $vnet

#define the consumed private ips within the subnet
$subnetobj = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnetobj -Name $subnet
$consumedprivips = $subnetobj.IpConfigurations.Count

# Define the subnet's cidr 
$cidr = $subnetobj.AddressPrefix -split "/"
$cidr = $cidr[1]

# Table for /cidr into private ips allowed
$maxprivips = switch ($cidr)
{
    20 {4091}
    21 {2043}
    22 {1019}
    23 {507}
    24 {251}
    25 {123}
    26 {59}
    27 {27}
    28 {11}
    29 {3}
}

$percent_s = ($consumedprivips/$maxprivips).tostring("P")
$percent_i = ([Math]::Round(($consumedprivips/$maxprivips)*100 + 0.005, 2))

Write-Host $percent_s

#################################### Subnets within VNETS in Subscription Report \ Could be used for conditional logic alerting or briefing report

# Object table for VNET\Subnet remaining private ips
$priviptable = @()

#Obtain all VNETs out there in Subscription
$VNETs = Get-AzVirtualNetwork

foreach ($VNET in $VNETs){
    
    $vnetobj = Get-AzVirtualNetwork -Name $VNET.Name
    $subnets = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnetobj
    foreach ($subnet in $subnets){
    
        $subnetobj = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnetobj -Name $subnet.Name
        $consumedprivips = $subnetobj.IpConfigurations.Count

        # Define the subnet's cidr 
        $cidr = $subnetobj.AddressPrefix -split "/"
        $cidr = $cidr[1]

        # Table for /cidr into private ips allowed
        $maxprivips = switch ($cidr)
        {
            20 {4091}
            21 {2043}
            22 {1019}
            23 {507}
            24 {251}
            25 {123}
            26 {59}
            27 {27}
            28 {11}
            29 {3}
        }

        # Basic Math for precent consumed

        $percent_s = ($consumedprivips/$maxprivips).tostring("P")
        $percent_i = ([Math]::Round(($consumedprivips/$maxprivips)*100 + 0.005, 2))
    
        #Define PS Object Entry
        $Object = New-Object psobject -Property @{
            VNET = $VNET.Name
            Subnet = $subnet.Name
            SubnetUsed = $consumedprivips
            SubnetTotal = $maxprivips
            SubnetConsumed = $percent_s
        }
        #Entry into PSTable
        $priviptable += $Object

    }

}

$priviptable