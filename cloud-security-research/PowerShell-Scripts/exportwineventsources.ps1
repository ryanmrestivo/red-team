## REQS

# PS Module Az, powershell-yaml
# ARMClient

#Variables

$SubId = "SUBID HERE"
$rgname = "RG NAME HERE"
$workspacename = "WORKSPACE NAME HERE"

#via ARMClient - API

#https://management.azure.com/subscriptions/{SUBID}/resourcegroups/{ResourceGroup}/providers/Microsoft.OperationalInsights/workspaces/{WorkspaceName}/dataSources?%24filter=%24filter%3Dkind%20eq%20'WindowsEvent'&api-version=2020-08-01

armclient login

$armcall = "/subscriptions/" + $SubId + "/resourcegroups/" + $rgname + "/providers/Microsoft.OperationalInsights/workspaces/" + $workspacename + "/dataSources?%24filter=%24filter%3Dkind%20eq%20'WindowsEvent'&api-version=2020-08-01"

$wineventsourceapi = armclient GET $armcall

$wineventsourceapi | Out-File c:\temp\winevtsourcesapi.json


# via PowerShell

Login-AzAccount

Set-AzContext -Subscription $SubId

$wineventsource = Get-AzOperationalInsightsDataSource -WorkspaceName $workspacename -ResourceGroupName $rgname -Kind WindowsEvent

$wineventsourcejson = $wineventsource | ConvertTo-Json -Depth 4

$wineventsourceyaml = $wineventsource | ConvertTo-Yaml

$wineventsourcejson | Out-File c:\temp\winevtsourcesps.json

$wineventsourceyaml | Out-File c:\temp\winevtsourcesps.yaml