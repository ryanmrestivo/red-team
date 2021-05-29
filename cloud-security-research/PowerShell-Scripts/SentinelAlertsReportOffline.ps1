#########################################################################################
## Author:      Nathan Swift
## Date:        02.11.2020
## Description: Downloads Sentinel Rules and generates a report
## Needs PS Core 6 or 7 and Module powershell-yaml 
# Install-Module -Name powershell-yaml
#########################################################################################

# download the Azure Sentinel Github zip
Invoke-WebRequest -Uri "https://github.com/Azure/Azure-Sentinel/archive/master.zip" -OutFile C:\temp\sentinel.zip

# Extract the Sentinel Github .zip
Expand-Archive -Path C:\temp\sentinel.zip -DestinationPath c:\temp\sentinel -Force

# New Report
$filename = "SentinelAlertsReport.csv"

# base path variable
$basepath = "C:\temp\sentinel\Azure-Sentinel-master\Detections"

# Get all the detection .ayml rules
$files = Get-ChildItem -Path C:\temp\sentinel\Azure-Sentinel-master\Detections -Recurse -File -Include "*.yaml"

# for testing
#$files = Get-ChildItem -Path C:\temp\sentinel\Azure-Sentinel-master\Detections

# For each yaml rule get unique field from the rule and import them into the csv file.
foreach ($file in $files){

    # obtain the unique file's path and https:// link
    $pathfile = $basepath + "\" + $file.Directory.Name + "\" + $file.Name
    $linkpath = "https://github.com/Azure/Azure-Sentinel/tree/master/Detections/" + $file.Directory.Name + "/" + $file.Name

    # obtain detection rule yaml and convert from yaml for extracting certain columns and reporting
    $rule = [pscustomobject](Get-Content $pathfile -Raw | ConvertFrom-Yaml)

    # Create a new null object to collect detection information into
    $reportObj = New-Object PSCustomObject

    # string value
    $reportObj | Add-Member -NotePropertyName Name -NotePropertyValue $rule.Name
    $reportObj | Add-Member -NotePropertyName Severity -NotePropertyValue $rule.Severity

    ##  string array values
    $reportObj | Add-Member -Type NoteProperty -Name Tactics -value ($rule.tactics -join '/')
    $reportObj | Add-Member -Type NoteProperty -Name Connectors -value ($rule.requiredDataConnectors.connectorId -join '/')
    $reportObj | Add-Member -Type NoteProperty -Name Logs -value ($rule.requiredDataConnectors.dataTypes -join '/') 
    $reportObj | Add-Member -Type NoteProperty -Name Techniques -value ($rule.relevantTechniques -join '/')

    # string value
    $reportObj | Add-Member -NotePropertyName Description -NotePropertyValue $rule.description
    $reportObj | Add-Member -NotePropertyName Link -NotePropertyValue $linkpath

    # write out unique detection and collected properties into .csv report
    $reportObj | Export-Csv C:\temp\$filename -NoTypeInformation -Delimiter "," -append

}
