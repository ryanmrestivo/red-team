

# Link: https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.apimanagement/v3.2.0/get-azurermapimanagementpolicy
# https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.apimanagement/v3.3.0/set-azurermapimanagementpolicy
#Obtain API Context
$ApiMgmtContext = New-AzureRmApiManagementContext -ResourceGroupName "rgSWIDMEOAPImgmt" -ServiceName "apiservicegt6wqoby66zhk"

#Export Tenant Policy
Get-AzureRmApiManagementPolicy -Context $APIMgmtContext -SaveAs "C:\APIs\policies\tenantpolicy.xml"

# Work on iteration Logic for exporting Product scope policy
#Get-AzureRmApiManagementPolicy -Context $APIMgmtContext -ProductId "0123456789"

# Iteration logic for APIs exporting API-Scope Policy
$APIs = Get-AzureRmApiManagementApi -Context $ApiMgmtContext

foreach ($API in $APIs) {

$xmlpath = "C:\APIs\policies\" + $API.Name + "_apiscope.xml" #Work on naming path with $API.Apiname

Get-AzureRmApiManagementPolicy -Context $APIMgmtContext -ApiId $API.ApiId -SaveAs $xmlpath

}

# Work on iteration Logic for operation scope policy
#Get-AzureRmApiManagementPolicy -Context $APImContext -ApiId "9876543210" -OperationId "777" -SaveAs 