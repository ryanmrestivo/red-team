# using AzureRM Powershell
# using ARMClient 

$subs = Get-AzureRmSubscription

foreach ($sub in $subs){

$subid = $sub.id

$subname = $sub.name

armclient POST https://management.azure.com/subscriptions/$subid/providers/Microsoft.Advisor/generateRecommendations?api-version=2017-03-31

armclient GET https://management.azure.com/subscriptions/$subid/providers/Microsoft.Advisor/recommendations?api-version=2017-03-31 | Out-File -FilePath C:\temp\armadvisor$subname.json

}
