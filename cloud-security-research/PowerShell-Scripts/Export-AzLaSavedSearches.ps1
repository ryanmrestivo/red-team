Login-AzAccount

# define variables
$rgname = "YOUR RG NAME"
$workspacename = "YOUR WORKSPACE NAME"
$LogFilePath = "c:\temp\kql\"


# get all saved searches
$savedsearches = Get-AzOperationalInsightsSavedSearch -ResourceGroupName $rgname -WorkspaceName $workspacename

# run through each saved search
foreach ($savedsearch in $savedsearches.Value) {

    # obtain the KQL query data
    $savedkql = $savedsearch.Properties.Query

    #generate a filename using Category and Saved Search query name
    $filename = $savedsearch.Properties.Category + '_-_' + $savedsearch.Properties.DisplayName

    $LogFile = $LogFilePath + $filename + ".txt"
    
    try {
        # output saved search kql to a new file
        $run = Write-Output $savedkql | Out-File -FilePath $LogFile -ErrorAction Stop
    }

    # sometimes saved searches may have a illegal character for a windows file path name
    catch {
        
        #genrate a new guid name
        $newguid = New-Guid

        #filename will be guid now because it had a illegal char throwing an error we want to ensure the kql query is saved
        $filename = $savedsearch.Properties.Category + '_-_' + $newguid
        $LogFile = $LogFilePath + $filename + ".txt"

        # output saved search kql to a new file
        $run = Write-Output $savedkql | Out-File -FilePath $LogFile
    }

}