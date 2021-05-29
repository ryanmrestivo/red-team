#########################################################################################
## Author:      David das Neves
## Date:        09.11.2019
## Modified:    Nathan Swift
## Date:        11.11.2019
## Description: Filtering of Ignite session files with OutGridView
##              Downloading with 10 downloads in parallel including resume functionality
#########################################################################################

#  Start PowerShell as admin 
#via code:   Start-Process powershell -Verb runAs


# have a look at VSCode to switch between pwsh versions

####################################################################################
## Needs only to be run once
####################################################################################

#region prep

#Path to download all the Ignite videos
$downloadPath = "C:\Ignite\" #you can modify that

#Creating Path
if (!(Test-Path $downloadPath)) {
    New-Item $downloadPath -ItemType Directory
}

#Installing PowerShell 7 - add to path!
 #Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -Preview" 

<# not included, yet - still some issues
    ## Installing OutGridView to pwsh v7 
    pwsh-preview -c "Install-Module Microsoft.PowerShell.GraphicalTools" -Force
#>

#endregion

#############################################################################################################
## If you want to create a new download job - execute the code starting from here with PowerShell version 5
#############################################################################################################

#region LoadingAllSessions

#Load all sessions - only from online because some download URIs are still being added
#Retrieving all Ignite sessions
$allSessions = (Invoke-RestMethod 'https://api-myignite.techcommunity.microsoft.com/api/session/all') | Where-Object { $_.downloadVideoLink } | Select-Object sessionCode, title, topic, speakerNames, level, description, downloadVideoLink, slideDeck

#endregion

#Picking sessions with a GridView and serializing the sessions to be downloaded to file for resume.
#region creatingADownloadJob

#Picking sessions for download
$sessionsToDownload = $allSessions | Out-GridView -PassThru
<#IMPORTANT: You can also work 
    - with CTRL+A for selecting all
    - with CTRL+MouseClick for selecting several sessions
    - with Shift+Mouseclick for selecting several sessions in a row  
#>

# OutGridView is not yet available in pwsh v7 #SHAME
# Context: https://devblogs.microsoft.com/powershell/the-next-release-of-powershell-powershell-7/

#Serializing the sessions for download to possibly continue after interruption
$sessionsToDownload | Export-Clixml (Join-Path -Path $downloadPath -Childpath "sessionsToDownload.clixml")

#endregion

################################################################################################################
## If you want to start or continue a download job - execute the code starting from here in PowerShell version 7 
################################################################################################################

#region StartOrResumeADownloadJob

#Now continue with the new PowerShell version
#Opening up PowerShell 7 - check VSCode to have a better control on versions
# pwsh-preview #Starting PowerShell Preview / Version 7

#Path to download all the Ignite videos
$downloadPath = "C:\Ignite\" #you can modify that

#Deserializing sessions for download
$sessionsToDownload = Import-Clixml (Join-Path -Path $downloadPath -Childpath "sessionsToDownload.clixml")

#Total number of sessions in the download job
$numberOfSessionsToDownload = $($sessionsToDownload.title.Count)

Write-Host "You are about to download $numberOfSessionsToDownload sessions in total."
#$ErrorActionPreference = 'SilentlyContinue' #already downloaded objects would create an error

#Cleaning titles and extending the PSCustomObject with a downloadPath
$sessionsToDownloadCleanedAndExtended = $sessionsToDownload | Select-Object *, @{ Name = 'downloadPath'; Expression = { Join-Path -Path $downloadPath -ChildPath ($_.sessionCode + "_" + $($_.title).Substring(0, [Math]::Min(50, $($_.title).length) ) + ".mp4").Replace('?', '').Replace(':', '') } } 
$sessionsToDownloadCleanedAndExtendedslidedeck = $sessionsToDownload | Select-Object *, @{ Name = 'downloadPath'; Expression = { Join-Path -Path $downloadPath -ChildPath ($_.sessionCode + "_" + $($_.title).Substring(0, [Math]::Min(50, $($_.title).length) ) + ".pptx").Replace('?', '').Replace(':', '') } } 


#Download all sessions including sessionCode and title (max length 50) with 10 downloads in parallel
#The downloding files are printed out
$sessionsToDownloadCleanedAndExtendedslidedeck | Foreach-Object -Parallel { Write-Host $_.downloadPath; Invoke-WebRequest $($_.slideDeck) -Resume -OutFile $_.downloadPath} -ThrottleLimit 10 
$sessionsToDownloadCleanedAndExtended | Foreach-Object -Parallel { Write-Host $_.downloadPath; Invoke-WebRequest $($_.downloadVideoLink) -Resume -OutFile $_.downloadPath} -ThrottleLimit 10 

#$sessionsToDownloadCleanedAndExtended
#endregion