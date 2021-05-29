## REQS ## You will need ARMClient, AZ CLI, Az, and Az.Security modules installed

# Variables to report exemptions on

#Login into Azure enviroment
Login-AzAccount
ARMClient.exe azlogin

#Path for report file
$csvpath = "C:\temp\exemptionreport.csv"

# File check to overwrite existing exemptioncoveragereport.csv
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
$exempstring = "SubscriptionName,SubscriptionId,ResourceName,ResourceType,ExmeptionName,Category,Notes,PolicyDefIds,CreatedBy,CreatedOn,ExpiresOn"
$exempstring | Out-File $outputFile -append -force

# gather all subscriptions
$subs = Get-AzSubscription

# For each subscription set contect and invoke REST GET policyExemptions API
Foreach ($sub in $subs){

    # Set subscription context
    Set-AzContext -SubscriptionId $subid

    #Subscription Id
    $subid = $sub.Id


    # ARM Call URL invoke REST GET policyExemptions API
    $armcall = "/subscriptions/" + $subid + "/providers/Microsoft.Authorization/policyExemptions?api-version=2020-07-01-preview"

    # Make ARM Client call for GET policyExemptions API
    $exemptions = armclient GET $armcall

    # convert the exemptions from JSON into table lists
    $exemptionaudits = $exemptions | ConvertFrom-Json

    # Format exemptions table lists values
    $exemptionaudits = $exemptionaudits.value

    # fore each table exemption item
    foreach ($exemptionaudit in $exemptionaudits) {
    
        # generate a variable for the Provider Type
        $providertype = $exemptionaudit.Id.split(“/”)[6]

        # generate a variable for the Resource name
        $resourcename = $exemptionaudit.Id.split(“/”)[8]

        #generate the table list entry into the report
        #"SubscriptionName,SubscriptionId,ResourceName,ResourceType,ExmeptionName,Category,Notes,PolicyDefIds,CreatedBy,CreatedOn,ExpiresOn"
        $exempstring = "$($sub.Name),$($subid),$($resourcename),$($providertype),$($exemptionaudit.properties.displayName),$($exemptionaudit.properties.exemptionCategory),$($exemptionaudit.properties.description),$($exemptionaudit.properties.policyDefinitionReferenceIds),$($exemptionaudit.systemData.createdBy),$($exemptionaudit.systemData.createdAt),$($exemptionaudit.properties.expiresOn)"

        #Write into and append into output file
        $exempstring | Out-File $outputFile -append -force

    }

}