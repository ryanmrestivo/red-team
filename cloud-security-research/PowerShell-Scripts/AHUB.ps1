Login-AzureRmAccount

$Sub = Get-AzureRmSubscription | Out-GridView -PassThru

Set-AzureRmContext -Subscription $Sub.Name

#Set var for total number of ahub lics qualified, future state logic to not exceed counting loop # stated
$maxahublic = 100


# Set the output location for the logs
$outputFile = "C:\temp\ahubset.txt"

#Set and apply 1st line of csv headers
$vmstring = "VMName,NumberOfCores"
$vmstring | Out-File $outputFile -append -force



    $vms = Get-AzureRmVM

    ForEach ($vm in $vms)
    {
        
        #Find VM Size
        $vmhw = (Get-AzureRmVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.name).hardwareProfile.VmSize

        #Find VM Cores in Size
        $vmhwcore = Get-AzureRMvmsize -location $VM.Location | ?{ $_.name -eq $vmhw }

        #trigger AHUB setting on VMs with Windows OS and with optimal desired core counts 8 or 16
        If ( $vm.OSProfile.WindowsConfiguration -ne $null -and $vmhwcore.NumberOfCores -eq 8 -or $vmhwcore.NumberOfCores -eq 16)
            {
                Write-host "$VM.name core match, setting AHUB"

                # Sets AHUB on VM
                $vm = Get-AzureRmVM -ResourceGroup $VM.ResourceGroupName -Name $VM.name
                $vm.LicenseType = "Windows_Server"
                Update-AzureRmVM -ResourceGroupName $VM.ResourceGroupName -VM $vm

                # Write out VM line of data collected and place into csv
                $vmstring = "$($VM.name),$($vmhwcore.NumberOfCores)"
                $vmstring | Out-File $outputFile -append -force

            }

    }

    Write-Output "All VMs in Subscription checked"

