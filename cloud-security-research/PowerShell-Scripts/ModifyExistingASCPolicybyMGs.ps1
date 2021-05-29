# Created On: 3/22/2020 6:03 PM
# Created By: Nathan Swift nate.swift@live.com
# This script is as is and not supported by Microsoft 
# Microsoft does not assume any risk of data loss
# Use it at your own risk
# PreReqs Need PS 7, Az Modules
################################################################################

#$managementGroupName = "SwiftOrg"

#$mgascassignmentname = "ASC Default"

#comment the below line out if using cloud shell
#$outfilepath = "C:\users\subs.txt"

#comment out the below line if using local powershell (will detect in later release)
$outfilepath = "~/clouddrive/asc_pol_removed.txt"

$subascassignmentname = "ASC Default"

# gets all management groups from authorized login 
$azuremgmts = Get-AzManagementGroup

#loop through each management group
foreach ($azuremgmt in $azuremgmts){

    if ($azuremgmt.DisplayName -notmatch "Tenant Root Group"){

        $managementGroupName = $azuremgmt.Name
        $azmgmt = Get-AzManagementGroup -GroupName $managementGroupName -Expand
    
        # get the assigned subscriptions to the managaement group
        $azmgmtsubs = $azmgmt.Children

        # run through all subscriptions under Management group
        $azmgmtsubs | ForEach-Object -ThrottleLimit 10 -Parallel {

            # Matching to ensure the subscription is not "Access to Azure Active Directory" those subscriptions are non billable\deploayble into
            if ($_.DisplayName -notmatch "Access to Azure Active Directory"){

                # Get policy Assignments from each subscription
                
                Write-Host $_.Type
                Write-Host $_.Id
                Write-Host $_.Name
                Write-Host $_.DisplayName

                $policyassignsub = Get-AzPolicyAssignment -Scope $_.Id

                # Matching condition of policy assignment resourcename and subid not being null, mgmt assignments do not have SubscriptionId in object
                if ($policyassignsub.ResourceName -contains "SecurityCenterBuiltIn" -and $policyassignsub.SubscriptionId -ne $null ) {
    
                    ## Used below for Testing ensure no false positives in above if matching
                    #Write-Host $policyassignsub.Name
                    #Write-Host $policyassignsub.ResourceId[0] 
    
                    ## Remove the following policy assignemnt from subscription.
                    Remove-AzPolicyAssignment -Id $policyassignsub.ResourceId[0]
                    $policyassignsub.Name | out-file $outfilepath -append

                }

            }

        }    

    }

}
