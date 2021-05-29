<#
    .DESCRIPTION
        Runbook Rotates Storages Keys in Azure and stores them in keyvault

    .NOTES
        AUTHOR: Azure Automation Team
        LASTEDIT: Mar 14, 2016
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


$storageaccounts = Get-AzureRMStorageAccount 
 
foreach ($storageaccount in $storageaccounts) {

New-AzureRmStorageAccountKey -ResourceGroupName $storageaccount.resourcegroupname -Name $storageaccount.storageaccountname -KeyName key1

$storageaccountkey = ((Get-AzureRmStorageAccountKey -ResourceGroupName $storageaccount.resourcegroupname -Name $storageaccount.storageaccountname)[0]).value

$secretvalue = ConvertTo-SecureString $storageaccountkey -AsPlainText -Force
$storagename = $storageaccount.storageaccountname
$Secretname = $storagename + "-Key1"

$secret = Set-AzureKeyVaultSecret -VaultName 'keyvaultname' -Name $Secretname -SecretValue $secretvalue


#Secondary Key
#New-AzureRmStorageAccountKey -ResourceGroupName $storageaccount.resourcegroupname -Name $storageaccount.storageaccountname -KeyName key2
#$storageaccountkey = ((Get-AzureRmStorageAccountKey -ResourceGroupName $storageaccount.resourcegroupname -Name $storageaccount.storageaccountname)[1]).value
#$secretvalue = ConvertTo-SecureString $storageaccountkey -AsPlainText -Force
#$Secretname = $storagename + "-Key2"
#$secret2 = Set-AzureKeyVaultSecret -VaultName 'keyvaultname' -Name $Secretname -SecretValue $secretvalue

}
