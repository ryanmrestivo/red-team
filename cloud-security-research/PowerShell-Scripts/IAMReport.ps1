## this is more a snippet than a PowerShell Runbook for Automation accounts, but could be easily modified.

## Foreach \ foreach is slow, reworking next version of script to open up parallelism and also utilize Switch rather than If

#Authenticate into ARM

#Authenticate into AAD
$scriptdatetime = get-date
Write-host $scriptdatetime 

$date = Get-Date -format R
$filename = "IAMReport.csv"


# Azure Storage Account Name, Container Name, and Storage Key
## Could rewrite to call a secret from KeyVault, store key in Automation Variable
$StorageAccountName = '' 

$ContainerName = ''

$StorageAccountKey = ''



$ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

$IAMReportFile = Get-AzureStorageBlob -Container $containername -Blob $filename -context $ctx| Get-AzureStorageBlobContent -Force

#$statsObj = New-Object PSCustomObject

$Subs = Get-AzureRmSubscription


foreach ($Sub in $Subs ) {
    
    #In case we need global subscription properties
    #$SubIdValue = $Sub.SubscriptionId
    #$SubNameValue = $Sub.SubscriptionName
    #$TenantTrustIdValue = $Sub.TenantId
    
    
    $TenantId = $Sub.TenantId
    $SubscriptionName = $Sub.SubscriptionName

    $iams = Get-AzureRmRoleAssignment

    foreach ($iam in $iams ) {
        
        $statsObj = New-Object PSCustomObject

        $statsObj | add-member -NotePropertyName DisplayName -NotePropertyValue $iam.DisplayName
        $statsObj | add-member -NotePropertyName SignInName -NotePropertyValue $iam.SignInName
        $statsObj | add-member -NotePropertyName Type -NotePropertyValue $iam.ObjectType
        $statsObj | add-member -NotePropertyName RoleDefinition -NotePropertyValue $iam.RoleDefinitionName
        $statsObj | add-member -NotePropertyName TenantId -NotePropertyValue $TenantId
        

        
        $iamscopesplit = ($iam.Scope) -split '/'

        $iamscopesplintcount = [regex]::matches($iam.scope,"/").count

        If ($iamscopesplintcount -eq 2){

            $subid = $iamscopesplit[2]
            $subname = (Get-AzureRmSubscription -SubscriptionId $subid).SubscriptionName

            #$iamscopename = "/" + $iamscopesplit[1] + "/" + $subname
            $statsObj | add-member -NotePropertyName Scope -NotePropertyValue $iam.Scope
            $statsObj | add-member -NotePropertyName ScopeType -NotePropertyValue "Subscription"
            $statsObj | add-member -NotePropertyName SubscriptionName -NotePropertyValue $subname
            $statsObj | add-member -NotePropertyName Provider -NotePropertyValue "none"
            $statsObj | add-member -NotePropertyName TimeStamp -NotePropertyValue $date

        }
        ElseIf ($iamscopesplintcount -eq 4) {
        
            $subid = $iamscopesplit[2]
            $subname = (Get-AzureRmSubscription -SubscriptionId $subid).SubscriptionName

            #$iamscopename = "/" + $iamscopesplit[1] + "/" + $subname + "/" + $iamscopesplit[3] + "/" + $iamscopesplit[4]
            $statsObj | add-member -NotePropertyName Scope -NotePropertyValue $iam.Scope
            $statsObj | add-member -NotePropertyName ScopeType -NotePropertyValue "ResourceGroup"
            $statsObj | add-member -NotePropertyName SubscriptionName -NotePropertyValue $subname
            $statsObj | add-member -NotePropertyName Provider -NotePropertyValue "none"
            $statsObj | add-member -NotePropertyName TimeStamp -NotePropertyValue $date
        }
        ElseIf ($iamscopesplintcount -eq 8) {
        
            $subid = $iamscopesplit[2]
            $subname = (Get-AzureRmSubscription -SubscriptionId $subid).SubscriptionName

            #$iamscopename = "/" + $iamscopesplit[1] + "/" + $subname + "/" + $iamscopesplit[3] + "/" + $iamscopesplit[4] + "/" + $iamscopesplit[5] + "/" + $iamscopesplit[6] + "/" + $iamscopesplit[7] + "/" + $iamscopesplit[8]
            $statsObj | add-member -NotePropertyName Scope -NotePropertyValue $iam.Scope
            $statsObj | add-member -NotePropertyName ScopeType -NotePropertyValue "Resource"
            $statsObj | add-member -NotePropertyName SubscriptionName -NotePropertyValue $subname
            $statsObj | add-member -NotePropertyName Provider -NotePropertyValue $iamscopesplit[6]
            $statsObj | add-member -NotePropertyName TimeStamp -NotePropertyValue $date
        }
        Else {
            $statsObj | add-member -NotePropertyName Scope -NotePropertyValue $iam.Scope + "Unknown Count - " + $iamscopesplintcount
            }
        ##Build out for RoleAssigmentId translation if desired
        #$iamroleassignsplit = ($iam.RoleAssignmentId) -split '/'
        #$iamroleassignsplitcount = [regex]::matches($iam.RoleAssignmentId,"/").count

        $statsObj | Export-Csv $filename -NoTypeInformation -Delimiter "," -append

        $file = gci $filename

        Set-AzureStorageBlobContent -File $file.FullName -Container $ContainerName -Blob $filename -Context $ctx -Force
    }

   

}

$scriptdatetime = get-date
Write-host $scriptdatetime 
