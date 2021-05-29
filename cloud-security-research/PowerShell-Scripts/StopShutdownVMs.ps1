<#

    .DESCRIPTION

        Runbook Checks for VMs in Shutdown state from a OS and Stops \ Deallocates them in Azure

    .NOTES

        AUTHOR: Nathan Swift

        LASTEDIT: 2/5/2018
#>

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

# Set Azure Subscription Context
$SubName = "Yoursubscriptionnamehere"
Set-AzureRmContext -Subscription $SubName

# Collect VMs in a state of Shutdown but not Stopped
$VMs = Get-AzureRmVM -Status | Where-Object {$_.PowerState -contains "VM stopped"}

#Run through and stop VMs that were in a OS shutdown state
foreach ($VM in $VMs) {

    Stop-AzureRmVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Force

}