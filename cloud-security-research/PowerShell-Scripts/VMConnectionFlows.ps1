<#

    .REQUIREMENTS
        That the Log Analytics Workspace have the ServiceMap Solution and WireData Solution installed.

    .DESCRIPTION
        A script that will export some of the ServiceMap Details around inboun and outbound connections in you enviroment for further analysis. 
        Might be ran before an Azure Migration project was ending the 180 Day Free Trial of ServiceMap
        Might be ran for additional analysis offline or update of a CMDB

    .NOTES
        AUTHOR: Nathan Swift
        LASTEDIT: July 2, 2019
#>

# variables
$Sub = "YOURScriptionName"
$WorkspaceId = "YOURLogAnalyticsWorkSpaceID"

#login and set Subscription context
Login-AzAccount
$Sub = Set-AzContext -Subscription $Sub

#Outbound Query will filter out same to same IPs, will include a TO:Computername, and find distinct connections outbound
$QueryOut = @'

//UNIQUE Outbound Flows to a VM
VMConnection
| where SourceIp != "127.0.0.1" and DestinationIp != "127.0.0.1"
| distinct Computer, ProcessName, SourceIp, DestinationIp, DestinationPort, Direction
| join kind = fullouter ( WireData )
on $left.DestinationIp == $right.LocalIP
| where Direction == "outbound"
| where SourceIp != DestinationIp
| distinct Computer, Computer1, ProcessName, DestinationPort, Direction, SourceIp, DestinationIp

'@

#Outbound Query will filter out same to same IPs, will include a From:Computername, and find distinct connections inbound
$QueryIn = @'

VMConnection
| where SourceIp != "127.0.0.1" and DestinationIp != "127.0.0.1"
| distinct Computer, ProcessName, SourceIp, DestinationIp, DestinationPort, Direction
| join kind = fullouter ( WireData )
on $left.SourceIp == $right.LocalIP
| where Direction == "inbound"
| where SourceIp != DestinationIp
| distinct Computer1, Computer, ProcessName, DestinationPort, Direction, SourceIp, DestinationIp

'@

# Invoke the PS KQL Query, save as a object, invoke query for 24 Hours, adjustable as needed.
$queryresultsout = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $QueryOut -Timespan (New-TimeSpan -Hours 24)
$queryresultsin = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $QueryIn -Timespan (New-TimeSpan -Hours 24)

# parse the results out of the object query job and export to a CSV formatted file
$queryresultsout.Results | Export-Csv C:\temp\VMConnectionsOutbound.csv
$queryresultsin.Results | Export-Csv C:\temp\VMConnectionsInbound.csv
