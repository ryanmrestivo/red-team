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
    [array] $WebhookData
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
#$WebhookData = [array]("185.95.187.94", "103.120.176.139")

#Static Variables
$NSGname = "YOUR NSG NAME"
$NSGrg = "YOUR NSG RESOURCE GROUP NAME"
$i = 1

#Take Webhook Data and taketody of Data in alert and convert JSON into PS Object
Write-Host ($WebhookData)

#obtain the NSG you want to add a rule to - Set your unique NSG name and ResourceGroupName above in Static Variables
$NSG = Get-AzureRmNetworkSecurityGroup -Name $NSGname -ResourceGroupName $NSGrg

Foreach ($entry in $WebhookData){
    $i++
    Write-Host ("counter is :$i")
    Write-Host ("PIP is :$entry")

    #/32 CIDR to PIP for NSG rule
    $pipcidr = $entry+"/32"

    Write-Host ($pipcidr)

    #NSG Priority
    $priority = $NSG.SecurityRules.Priority.Count + 101 + $i

    #Add NSG Rule
    Get-AzureRmNetworkSecurityGroup -Name $NSGname -ResourceGroupName $NSGrg | Add-AzureRmNetworkSecurityRuleConfig -Name "ascla_$entry" -Direction Inbound -Priority $priority -Access Deny -SourceAddressPrefix $pipcidr -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol '*' | Set-AzureRmNetworkSecurityGroup

}
