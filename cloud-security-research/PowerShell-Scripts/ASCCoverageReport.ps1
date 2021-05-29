  
## REQS ## You will need Az.Security and Az modules installed
# Created On: 4/20/2020 5:32 PM
# Created By: Nathan Swift nate.swift@live.com
# This script is as is and not supported by Microsoft 
# Microsoft does not assume any risk of data loss
# Use it at your own risk
################################################################################

$subs = Get-AzSubscription

$csvpath = "C:\temp\asccoveragereport.csv"

# File check to overwrite existing asccoveragereport.csv
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

# File check to overwrite existing asccoveragereport.csv
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


$outputFile = $csvpath

# write out headers of CSV
$ascstring = "SubscriptionName,SubscriptionId,ServiceName,PricingTier,FreeTrialTimeRemaining"
$ascstring | Out-File $outputFile -append -force

# For each subscription lookup the ASC Pricing information and 
ForEach ($sub in $subs) {

    # Set the current subscription context
    Set-AzContext -Subscription $sub.Id

    # get the asc pricing information for services on subscription
    $azsecprices = Get-AzSecurityPricing

    # for each asc service within subscription write the information into report
    foreach ($azsecprice in $azsecprices) {
        
        #Generate the string of data for the asc service and pricing information
        $ascstring = "$($sub.Name),$($sub.Id),$($azsecprice.Name),$($azsecprice.PricingTier),$($azsecprice.FreeTrialRemainingTime)"

        #Write into and append into output file
        $ascstring | Out-File $outputFile -append -force

    }


}