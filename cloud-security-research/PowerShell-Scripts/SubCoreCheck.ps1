Login-AzureRmAccount

$Sub = Get-AzureRmSubscription | Out-GridView -PassThru

Set-AzureRmContext -Subscription $Sub.Name

$outputFile = "C:\temp\"+$Sub.Name+".txt"

#Get all VMs in Subscription
$VMs = Get-AzureRmVM

#Set and apply 1st line of csv headers
$vmstring = "ResourceGroup,VMName,Location,NumberOfCores,VMSize,Publisher,Offer,Sku"
$vmstring | Out-File $outputFile -append -force

# Loop and iterate through all VMs
foreach($VM in $VMs) {

#Find VM OS Properties
$resource = (Get-AzureRmResource -ResourceName $VM.Name -ResourceType "Microsoft.Compute/virtualMachines" -ResourceGroupName $VM.ResourceGroupName -ApiVersion 2017-03-30).properties.storageProfile | Select imageReference

#Find VM Size
$vmhw = (Get-AzureRmVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.name).hardwareProfile.VmSize

#Find VM Cores
$vmhwcore = Get-AzureRMvmsize -location $VM.Location | ?{ $_.name -eq $vmhw }

#Find VM Image Publisher
$publisher = $resource.psobject.properties.value.publisher

#Find VM Image Offer
$offer = $resource.psobject.properties.value.offer

#Find VM SKU
$sku = $resource.psobject.properties.value.sku

# $vmstring = "$VM.name ,$VM.ResourceGroupName,$VM.Location,$VM.HardwareProfile.VMSize,$publisher,$offer,$sku,$vmhwcore.NumberOfCores,$Sub.Name"

# Write out VM line of data collected and place into csv
$vmstring = "$($VM.ResourceGroupName),$($VM.name),$($VM.Location),$($vmhwcore.NumberOfCores),$($VM.HardwareProfile.VMSize),$($publisher),$($offer),$($sku)"

$vmstring | Out-File $outputFile -append -force

}

# Once done imort the data into excel