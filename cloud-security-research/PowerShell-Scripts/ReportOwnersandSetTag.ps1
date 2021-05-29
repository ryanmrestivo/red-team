Login-AzAccount

# Time Tracking Start
$datetime = Get-Date
Write-Host $datetime

$logs = Get-AzLog -StartTime (Get-Date).AddDays(-89)

$path = "C:\temp\loginventory.txt"
$csvpath = "C:\temp\loginventory.csv"

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


$outputFile = $path

$logstring = "Owner,Type,Kind,ResourceName,Date,ResourceId"
$logstring | Out-File $outputFile -append -force

foreach ($log in $logs) {

   if ($log.OperationName.Value -like "*/write") {
   
    $resname = ($log.ResourceId) -split '/'
    $logstring = "$($log.caller),$($log.ResourceProviderName.Value),$($resname[7]),$($resname[8]),$($log.EventTimestamp),$($log.ResourceId)"

    #Write into and append into output file
    $logstring | Out-File $outputFile -append -force
   
    ## Remove # comments to apply owner tags
    #$tags = (Get-AzResource -ResourceId $log.ResourceId).Tags
    #$tags += @{owner=$log.caller}
    #Set-AzResource -ResourceId $log.ResourceId -Tag $tags -Force

   }
    
}

# Time Tracking Finished
$datetime = Get-Date
Write-Host $datetime

# Once done import the data into excel

$CSV = Import-Csv -Path $path
$CSV | Export-Csv -Path $csvpath -NoTypeInformation