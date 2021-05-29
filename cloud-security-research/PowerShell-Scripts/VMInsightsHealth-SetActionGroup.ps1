#PRE REQs - ARMCLient, Azure CLI, Azure PowerShell, an ActionGroup created

# Sets a specific Action Group on all VMs using VM Insights Health, specifically useful to bulk update VMs ALerts to a ActionGroup - Email, ServiceNow Ticket, or Automation.

# Login in
Connect-AzAccount

armclient login

# Global Variables, see $Payload - values must be manually entered for SubId and ActionGroup Name
$subid = ""
$actiongroup = ""

# SPecific Payload REST PUT API to modify VM Alert to a Action Group
$payload = "{'properties':{'ActionGroupResourceIds':['/subscriptions/{SUBSCRIPTIONIDHERE}/resourceGroups/default-activitylogalerts/providers/microsoft.insights/actionGroups/{ACTIONGROUPNAMEHERE}']}}"

# Find all the VMs
$VMs = Get-AzVm

# Foreach VM set the VM Alert to use a Action Group
Foreach ($VM in $VMs){

    $url = "https://management.azure.com/subscriptions/" + $subid + "/resourceGroups/" + $VM.ResourceGroupName + "/providers/Microsoft.Compute/virtualMachines/" + $VM.Name + "/providers/Microsoft.WorkloadMonitor/notificationSettings/default?api-version=2018-08-31-preview"
    armclient PUT $url $payload

}