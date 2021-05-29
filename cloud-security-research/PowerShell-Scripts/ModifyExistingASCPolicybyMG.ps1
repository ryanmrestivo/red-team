# Created On: 3/22/2020 4:48 PM
# Created By: Nathan Swift nate.swift@live.com
# This script is as is and not supported by Microsoft 
# Microsoft does not assume any risk of data loss
# Use it at your own risk
# PreReqs Need PS 7, Az Modules
################################################################################

$managementGroupName = "SwiftOrg"

#$mgascassignmentname = "ASC Default"

$subascassignmentname = "ASC Default"

# get a specific management group defined above 
$azmgmt = Get-AzManagementGroup -GroupName $managementGroupName -Expand

# get the assigned subscriptions to the managaement group
$azmgmtsubs = $azmgmt.Children

# run through all subscriptions under Management group
$azmgmtsubs | ForEach-Object -ThrottleLimit 10 -Parallel {

    # Matching to ensure the subscription is not "Access to Azure Active Directory" those subscriptions are non billable\deploayble into
    if ($_.DisplayName -ne "Access to Azure Active Directory"){

        # Get policy Assignments from each subscription
        $policyassignsub = Get-AzPolicyAssignment -Scope $_.Id

        # Matching condition of policy assignment resourcename and subid not being null, mgmt assignments do not have SubscriptionId in object
        if ($policyassignsub.ResourceName -contains "SecurityCenterBuiltIn" -and $policyassignsub.SubscriptionId -ne $null ) {
    
            ## Used below for Testing ensure no false positives in above if matching
            #Write-Host $policyassignsub.Name
            #Write-Host $policyassignsub.ResourceId[0] 
    
            ## Remove the following policy assignemnt from subscription.
            Remove-AzPolicyAssignment -Id $policyassignsub.ResourceId[0]

        }

    }

}    