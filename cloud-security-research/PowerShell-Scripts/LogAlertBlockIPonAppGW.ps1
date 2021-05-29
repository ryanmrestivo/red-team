<#
.SYNOPSIS


.DESCRIPTION


DEPENDENCIES
- The runbook must be called from an Azure Log Analytics alert via a webhook.

REQUIRED AUTOMATION ASSETS
- An Automation connection asset called "AzureRunAsConnection" that is of type AzureRunAsConnection.
- An Automation certificate asset called "AzureRunAsCertificate".

.PARAMETER WebhookData
Optional. (The user doesn't need to enter anything, but the service always passes an object.)
This is the data that's sent in the webhook that's triggered from the alert.

.NOTES
AUTHOR: Nathan Swift
LASTEDIT: 2018-11-18
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
#$WebhookData = Get-Content 'C:\temp\alertip14.json' | Out-String | ConvertFrom-Json

#Static Variables
$NSGname = "YOUR NSG NAME"
$NSGrg = "YOUR NSG RESOURCE GROUP NAME"
[array]$pipentries = {}

#Take Webhook Data and taketody of Data in alert and convert JSON into PS Object
$WebhookRequestBody = $WebhookData.RequestBody | ConvertFrom-Json



#store the Rows results of alert data into a variable
$rows = $WebhookRequestBody.data.SearchResult.tables.rows | select -Unique

# Search in each Row Object
foreach ($row in $rows){

    # Search in each row
    ForEach($item in $row) {
        # Match for public ip address, data is not consistent in alert row objects
        $pip = $item -match "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"

        # If match occurs then write the pip into an array
        if ($pip -eq $true){
            Write-Host $item
            $pipentries = $pipentries += $item
        }
    }
}

# make the array unique entries only and remove the first null entry
$pipentries = $pipentries | Select -Unique
$pipentries = $pipentries -ne $pipentries[0]

# loop through each pip and create a NSG rule
foreach ($sourceip in $pipentries){
    Write-Host ($sourceip)
    

    #/32 CIDR to PIP for NSG rule
    $pipcidr = $sourceip+"/32"

    Write-Host ($pipcidr)

    #obtain the NSG you want to add a rule to - Set you unique NSG anme and ResourceGroupName
    $NSG = Get-AzureRmNetworkSecurityGroup -Name $NSGname -ResourceGroupName $NSGrg

    #Check the custom rules count and add to the next priority so oes not overlap with existing priority rule
    $priority = $NSG.SecurityRules.Priority.Count + 101

    #Construct the NSG Rule based of the pip found and the PIP CIDR found above and apply the new rule to the NSG - Set you unique NSG anme and ResourceGroupName
    Get-AzureRmNetworkSecurityGroup -Name $NSGname -ResourceGroupName $NSGrg | Add-AzureRmNetworkSecurityRuleConfig -Name "logrb_$sourceip" -Direction Inbound -Priority $priority -Access Deny -SourceAddressPrefix $pipcidr -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol '*' | Set-AzureRmNetworkSecurityGroup

}
