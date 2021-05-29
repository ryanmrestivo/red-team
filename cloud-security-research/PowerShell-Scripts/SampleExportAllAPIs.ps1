
$ApiMgmtContext = New-AzureRmApiManagementContext -ResourceGroupName "rgSWIDMEOAPImgmt" -ServiceName "apiservicegt6wqoby66zhk"

$APIs = Get-AzureRmApiManagementApi -Context $ApiMgmtContext

foreach ($API in $APIs) {

$wadlpath = "C:\APIs\specifications\" + $API.Name + ".wadl"

Export-AzureRmApiManagementApi -Context $ApiMgmtContext -ApiId $API.ApiId -SpecificationFormat "Wadl" -SaveAs $wadlpath

$jsonpath = "C:\APIs\specifications\" + $API.Name + ".json"

Export-AzureRmApiManagementApi -Context $ApiMgmtContext -ApiId $API.ApiId -SpecificationFormat "swagger" -SaveAs $jsonpath

}