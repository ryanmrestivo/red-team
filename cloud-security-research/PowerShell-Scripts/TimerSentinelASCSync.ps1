#########################################################################################
## Author:      Nathan Swift
## Date:        02.13.2020
## Description: This script acts as a sync engine between Sentinel Incidents that are closed and then dismissing the matched ASC Alert.
## Needs PS Core 6 or 7, Az.Security and AzSentinel modules  
# Install-Module -Name Az.Security
# Install-Module -Name AzSentinel
#########################################################################################

#Some authentication to Azure to occur, Function as MSI or Automation Account RunAs

#Set timing filter
$filterDate = (Get-Date).AddDays(-1)

#get a list of closed incidents within timeframe
$incidents = Get-AzSentinelIncident -WorkspaceName SwiftEnvLogs | Where-Object {$_.Status -eq "Closed" -and $_.lastUpdatedTimeUtc -ge $filterDate -and $_.relatedAlertProductNames -contains "Azure Security Center"}

#get a list of open ASC Alerts within time frame
$alerts = Get-AzSecurityAlert | Where-Object {$_.State -eq "Active" -and $_.ReportedTimeUtc -ge $filterDate}

# loop through closed incidents and compare against ASC alerts and find a match
ForEach ($incident in $incidents){

    # Room for improvement use Switch instead of nested foreach loops
    Foreach ($alert in $alerts){

        ## Matching condition titles must match, timestamps on the second must match
        if ($incident.title -eq $alert.AlertDisplayName -and $incident.endTimeUtc.ToString("yyyyMMddTHHmmss") -match $alert.DetectedTimeUtc.ToString("yyyyMMddTHHmmss")){
            
            ## Used to tshoot and verify Match Condition logic above in If statement
            #Write-Host "TitleMatchfound"
            #Write-Host "Sentinel"
            #Write-Host $incident.title
            #Write-Host $incident.endTimeUtc
            #Write-Host "ASC"
            #Write-Host $alert.AlertDisplayName
            #Write-Host $alert.DetectedTimeUtc
            #Write-Host $alert.InstanceId
            #Write-Host $incident.caseNumber

            #Dismiss the ASC Alert
            Set-AzSecurityAlert -ResourceId $alert.Id -ActionType Dismiss
        }

    }

}
