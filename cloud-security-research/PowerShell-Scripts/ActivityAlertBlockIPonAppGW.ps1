<#
.SYNOPSIS
This runbook recieves IPs to block in an data array from a Azure Security Center PlayBook it then applies them to NSG Rules and a NSG that is protecting the Application Gateway.

.DESCRIPTION


DEPENDENCIES
- The runbook must be called from an Azure Security PlayBook where the public ips being sent are in an ARRAY, trigger is a Logic App to webhook.

REQUIRED AUTOMATION ASSETS
- An Automation connection asset called "AzureRunAsConnection" that is of type AzureRunAsConnection.
- An Automation certificate asset called "AzureRunAsCertificate".

.PARAMETER WebhookData
Optional. (The user doesn't need to enter anything, but the service always passes an object.)
This is the data that's sent in the webhook that's triggered from the Azure Security Playbook.

.NOTES
AUTHOR: Nathan Swift
LASTEDIT: 2018-11-19
#>

[OutputType("PSAzureOperationResponse")]

param
(
    [Parameter (Mandatory=$false)]
    [object] $WebhookData
)

$ErrorActionPreference = "stop"

        $connectionName = "AzureRunAsConnection"
        try
        {
            # Get the connection "AzureRunAsConnection "
            $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

            "Logging in to Azure..."
            Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
        }
    catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }


##Manual Testing
#$WebhookData = Get-Content 'C:\temp\activitylog2.json' | Out-String | ConvertFrom-Json

Write-Host ($WebhookData)

#Take Webhook Data and take request body of Data in alert and convert JSON into PS Object
$WebhookRequestBody = $WebhookData.RequestBody | ConvertFrom-Json

#Take Webhook Data and taketody of Data in alert and convert JSON into PS Object
Write-Host ($WebhookRequestBody)

#Ensure Activity Log Alert from ASC pertains to applicationGateways
$mgmturl = $WebhookRequestBody.data.context.activityLog.properties.managementURL -split "/"

#Conditional check to make sure it matches to applicationGateway to execure NSG rules.
if ($WebhookRequestBody.data.context.activityLog.properties.resourceType -eq "Networking" -and $mgmturl[9] -contains "applicationGateways"){

    #store the Rows results of alert data into a variable
    $SourceIps = $WebhookRequestBody.data.context.activityLog.properties.sourceIPs

    #Create an Array from the string
    $SourceIps = $SourceIps -split ","

    #Take Webhook Data and taketody of Data in alert and convert JSON into PS Object
    Write-Host ($SourceIps)

    #Static Variables
    $NSGname = "YOUR NSG NAME"
    $NSGrg = "YOUR NSG RESOURCE GROUP NAME"
    $i = 1


    foreach ($pip in $SourceIps) {

        $i++
        Write-Host ("counter is :$i")
        Write-Host ($pip)

        #/32 CIDR to PIP for NSG rule
        $pipcidr = $pip+"/32"

        Write-Host ($pipcidr)

        #obtain the NSG you want to add a rule to - Set you unique NSG anme and ResourceGroupName
        $NSG = Get-AzureRmNetworkSecurityGroup -Name $NSGname -ResourceGroupName $NSGrg

        #Check the custom rules count and add to the next priority so oes not overlap with existing priority rule
        $priority = $NSG.SecurityRules.Priority.Count + 801 + $i

        $rulename = New-Guid
        Write-Host ($rulename)

        #Construct the NSG Rule based of the pity found and the PIP CIDR found above and apply the new rule to the NSG - Set you unique NSG anme and ResourceGroupName
        Get-AzureRmNetworkSecurityGroup -Name $NSGname -ResourceGroupName $NSGrg | Add-AzureRmNetworkSecurityRuleConfig -Name "activitylogrb_$pip" -Direction Inbound -Priority $priority -Access Deny -SourceAddressPrefix $pipcidr -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol '*' | Set-AzureRmNetworkSecurityGroup
    }
}
Else
{
    Write-Host ("Logic Conditions not matched")
}
