# Set subscription context
$sub = "SUBSCRIPTIONNAME OR GUID"
Set-AzContext -Subscription $sub

# Collect Storage Accounts in Subscrition
$storeaccts = Get-AzStorageAccount
# Exports CSV list of storage accounts, customer can remove accounts as needed
$storeaccts | Export-Csv c:\temp\storageaccounts.csv
# Prompt a break in script to allow the customer to modify the .CSV list
Read-Host -Prompt 'Please modify c:\temp\storageaccount.csv removing any storage accounts you do not want to have Storage ATP turned on, Once finished press enter to continue script'
# Import the modified storage account .csv list
$stores = Import-csv c:\temp\storageaccounts.csv

# Install az.security module
Install-Module Az.Security -Force

# Disable ASC Storage protection on Subscription, switch to free
Write-Host  "Disabling Storage Account Protectition on ASC"
Set-AzSecurityPricing -Name "StorageAccounts" -PricingTier "Free"

# Run through each storage id in imported modified list and enable ATP on Storage Account 
foreach($store in $stores){

    Enable-AzSecurityAdvancedThreatProtection -ResourceId $store.id
    Write-Host "Storage Account ATP Enabled on " $store.StorageAccountName

}