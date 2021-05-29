#PRE REQs - ARMCLient, Azure CLI, Azure PowerShell, an ActionGroup created

# Login in
Connect-AzAccount
armclient login

#Your AAD Tenant ID if your login is associated to many tenants
armclient token {YOUR AAD TENANT ID}

# URL and payload for continuous Export Rule to Storage for Heartbeat and SecurityEvents Tables
$url1 = "https://management.azure.com/subscriptions/{YOUR SUB ID}/resourceGroups/{YOUR RG NAME}/providers/Microsoft.OperationalInsights/workspaces/{YOUR WORKSPACE NAME}/dataexports/exporttostore?api-version=2019-08-01-preview"
$payload1 = "{'properties':{'destination':{'resourceId':'/subscriptions/{YOUR SUB ID}/resourceGroups/{YOUR RG NAME}/providers/Microsoft.Storage/storageAccounts/{YOUR STORAGE NAME}'},'tablenames':['Heartbeat','SecurityEvent'],'enable':true}}"

# URL and payload for continuous Export Rule to Event Hubs for Heartbeat and SecurityEvents Tables
$url2 = "https://management.azure.com/subscriptions/{YOUR SUB ID}/resourceGroups/{YOUR RG NAME}/providers/Microsoft.OperationalInsights/workspaces/{YOUR WORKSPACE NAME}/dataexports/exporttoeh?api-version=2019-08-01-preview"
$payload2 = "{'properties':{'destination':{'resourceId':'/subscriptions/{YOUR SUB ID}/resourceGroups/{YOUR RG NAME}/providers/Microsoft.EventHub/namespaces/{YOUR EVENTHUB NAME}'},'tablenames':['Heartbeat','SecurityEvent'],'enable':true}}"

# PUT Api to setup continuous export rule to send to Storage
armclient PUT $url1 $payload1

# PUT Api to setup continuous export rule to send to Event Hubs
armclient PUT $url2 $payload2