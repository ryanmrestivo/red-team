
#-----------------------------------------------------------------------------------------------------------------------
Function Log-Time { #---------------------------------------------------------------------------------------------------
	<#
		.SYNOPSIS
		Logs a timestamp to a .csv log file.
		
		.DESCRIPTION
		Logs a UTC/GMT (Coordinated Universal Time, Greenwich Mean Time) date & time value, the local timezone from where the entry was logged (ID and Name), a timestamp idenfitication 'type' tag, and a [Begin]/[End] tag for filtering purposes.
		
		.PARAMETER TimeLogFile
		TimeLogFile = "$env:USERPROFILE\Documents\TimeLog.csv"
		
		.PARAMETER Interactive
		Interactive
		
		.PARAMETER DateTimeInput
		DateTimeInput <date_time_object>
		
		.PARAMETER Description
		Description <string>
		
		.PARAMETER PickTimeOnly
		PickTimeOnly
		
		.PARAMETER OptionalDatePicker
		OptionalDatePicker
		
		.PARAMETER TimeStampTag
		TimeStampTag <custom_tag>
		
		.PARAMETER ClockIn
		ClockIn
		
		.PARAMETER ClockOut
		ClockOut
		
		.PARAMETER TimeStamp
		TimeStamp <timestamp_message>
		
		.PARAMETER TaskStart
		TaskStart <task_name>
		
		.PARAMETER TaskStop
		TaskStop
		
		.PARAMETER BreakStart
		BreakStart
		
		.PARAMETER BreakStop
		BreakStop
		
		.PARAMETER PauseStart
		PauseStart <pause_reason>
		
		.PARAMETER PauseStop
		PauseStop
		
		.PARAMETER ProjectStart
		ProjectStart <project_name>
		
		.PARAMETER ProjectStop
		ProjectStop <project_name>
		
		.PARAMETER Distraction
		Distraction
		
		.EXAMPLE
		Test-Param -A "Anne" -D "Dave" -F "Freddy"
		C:\PS>
		
		.NOTES
		CSV file format headers:

		TimeStampUT,TimeZoneID,TimeZoneName,[Begin/End/TimeStamp],Tag

	#>
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	#http://techgenix.com/powershell-functions-common-parameters/
	# To enable common parameters in functions (-Verbose, -Debug, etc.) the following 2 lines must be present:
	#[CmdletBinding()]
	#Param()
	
	[CmdletBinding(DefaultParameterSetName='TimeStampTag')]
	
	Param (
		#[CmdletBinding(DefaultParameterSetName="ByUserName")]
		# Script parameters go here
		#https://ss64.com/ps/syntax-args.html
		#http://wahlnetwork.com/2017/07/10/powershell-aliases/
		#https://www.jonathanmedd.net/2013/01/add-a-parameter-to-multiple-parameter-sets-in-powershell.html
		[Parameter(Mandatory=$true,Position=0)]
		[Alias('File','Path','FilePath')]
		[string]$TimeLogFile = "$env:USERPROFILE\Documents\TimeLog.csv", 
		
		[Parameter(Mandatory=$false)]
		[Alias('i','PickTime','Add')]
		[switch]$Interactive = $false,
		
		[Parameter(Mandatory=$false,
		ValueFromPipeline = $true)]
		[Alias('Date','Time')]
		[DateTime]$DateTimeInput,
		
		[Parameter(Mandatory=$false)]
		[Alias('d')]
		[string]$Description,
		
		[Parameter(Mandatory=$false)]
		[switch]$PickTimeOnly = $false,
		
		[Parameter(Mandatory=$false)]
		[switch]$OptionalDatePicker = $false,
		
		[Parameter(Mandatory=$false,
		Position=1,
		ParameterSetName='CustomTag')]
		[string]$TimeStampTag,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='ClockInTag')]
		[switch]$ClockIn,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='ClockOutTag')]
		[switch]$ClockOut,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='TimeStampTag')]
		[string]$TimeStamp,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='TaskStartTag')]
		[string]$TaskStart,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='TaskStopTag')]
		[switch]$TaskStop,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='BreakStartTag')]
		[switch]$BreakStart,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='BreakStopTag')]
		[switch]$BreakStop,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='PauseStartTag')]
		[string]$PauseStart,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='PauseStopTag')]
		[switch]$PauseStop,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='ProjectStartTag')]
		[string]$ProjectStart,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='ProjectStopTag')]
		[string]$ProjectStop,
		
		[Parameter(Mandatory=$false,
		ParameterSetName='DistractionTag')]
		[switch]$Distraction
		
	)
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Function name:
	# https://stackoverflow.com/questions/3689543/is-there-a-way-to-retrieve-a-powershell-function-name-from-within-a-function#3690830
	#$FunctionName = (Get-PSCallStack | Select-Object FunctionName -Skip 1 -First 1).FunctionName
	#$FunctionName = (Get-Variable MyInvocation -Scope 1).Value.MyCommand.Name
	$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
	Write-Verbose "Running function: $FunctionName"
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	<#
	$TimeLogColumns = "TimeStampUT"
	$TimeLogColumns += ",TimeStampUT_Human-Readable"
	$TimeLogColumns += ",TimeZoneID"
	$TimeLogColumns += ",TimeZoneName"
	$TimeLogColumns += ",[Begin/End/TimeStamp]"
	$TimeLogColumns += ",Tag"
	$TimeLogColumns += ",Description"
	Write-Verbose "Log columns:`r`n'$TimeLogColumns'"
	#>
	
	$TimeLogColumns = "TimeStampUT,TimeStampUT_Human-Readable,TimeZoneID,TimeZoneName,[Begin/End/TimeStamp],Tag,Description"
	
	Write-Verbose "Log columns:`r`n'$TimeLogColumns'"
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	#-----------------------------------------------------------------------------------------------------------------------
	# Evaluate input parameters
	#-----------------------------------------------------------------------------------------------------------------------
	
	#Bugfix: Old outputs were coming out of the function as well as the new ones.
	
	Clear-Variable -Name DateTimeToLog -ErrorAction SilentlyContinue | Out-Null
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Evaluate log file input parameter
	
	Write-Verbose "`$TimeLogFile = $TimeLogFile"
	
	If (!(Test-Path $TimeLogFile)) {
		Write-HR -IsWarning
		Write-Warning "Time-Log file does not exist: '$TimeLogFile'"
		Do {
			$UserInput = Read-Host "Would you like to create it? [Y/N]"
		} until ($UserInput -eq 'y' -Or $UserInput -eq 'n')
		If ($UserInput -eq 'y') {
			#New-Item -Path $TimeLogFile -Credential (Get-Credential -Credential "$env:USERNAME") -ItemType "file" -Force #| Out-Null
			#Write-host "TROUBLESHOOTING 1"
			New-Item -Path $TimeLogFile -ItemType "file" -Force
			#Write-host "TROUBLESHOOTING 2"
			$CSVheaders = $TimeLogColumns
			$CSVheaders > $TimeLogFile
			$TimeLogPath = Split-Path -Path $TimeLogFile -Parent
			#dir $TimeLogPath
		} else {
			# No, do not create new file
			Return
		}
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Evaluate -Interactive/-DateTimeInput parameters
	
	If ($DateTimeInput) {
		Write-Verbose "DateTimeInput = $DateTimeInput"
		Write-Host "DateTimeInput = $DateTimeInput"
		$DateTimeMode = 'InputProvided'
		$DateTimeValue = $DateTimeInput
		#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
		#$DateInput = Get-Date -Date ((Get-Date -Date $DateTimeInput).ToUniversalTime()) -Format FileDateUniversal
		#$DateInput = Get-Date -Date $DateInput
		If ($PickTimeOnly -eq $true) {
			$DateInput = Get-Date -Date $DateTimeInput -Hour 0 -Minute 0 -Second 0 -Millisecond 0
		} Else {
			$DateInput = Get-Date -Date $DateTimeInput
		}
		Write-Verbose "Date input given = $DateInput"
	} elseif ($Interactive) {
		Write-Verbose "Interactive mode selected"
		Write-Host "Interactive mode selected"
		$DateTimeMode = 'Interactive'
	} else {
		Write-HR -IsWarning
		Write-Warning "No -DateTimeInput or -Interactive mode selected. Defaulting to -Interactive"
		$DateTimeMode = 'Interactive'
	}
	Write-Verbose "Date/Time mode selected = $DateTimeMode"
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Set Timestamp Tag and Begin/End tag.
	
	If ($TimeStampTag) {
		$TimeLogTag = $TimeStampTag
		$BeginEnd = "[TimeStamp]"
	}
	
	If ($ClockIn) {
		$TimeLogTag = "Clock-In"
		$BeginEnd = "[Begin]"
	}
	
	If ($ClockOut) {
		$TimeLogTag = "Clock-Out"
		$BeginEnd = "[End]"
	}
	
	If ($TimeStamp) {
		$TimeLogTag = "TimeStamp='$TimeStamp'"
		$BeginEnd = "[TimeStamp]"
	}
	
	If ($TaskStart) {
		$TimeLogTag = "Task-Start='$TaskStart'"
		$BeginEnd = "[Begin]"
	}
	
	If ($TaskStop) {
		$TimeLogTag = "Task-Stop"
		$BeginEnd = "[End]"
	}
	
	If ($BreakStart) {
		$TimeLogTag = "Break-Start"
		$BeginEnd = "[Begin]"
	}
	
	If ($BreakStop) {
		$TimeLogTag = "Break-Stop"
		$BeginEnd = "[End]"
	}
	
	If ($PauseStart) {
		$TimeLogTag = "Pause-Start='$PauseStart'"
		$BeginEnd = "[Begin]"
	}
	
	If ($PauseStop) {
		$TimeLogTag = "Pause-Stop"
		$BeginEnd = "[End]"
	}
	
	If ($ProjectStart) {
		$TimeLogTag = "Project-Start='$ProjectStart'"
		$BeginEnd = "[TimeStamp]"
	}
	
	If ($ProjectStop) {
		$TimeLogTag = "Project-Stop='$ProjectStop'"
		$BeginEnd = "[TimeStamp]"
	}
	
	If ($Distraction) {
		$TimeLogTag = "Distraction"
		$BeginEnd = "[TimeStamp]"
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	# Default to [TimeStamp] tag if nothing else is selected.
	
	#If ($TimeLogTag -eq $null -Or $TimeLogTag -eq "") {
	If (($TimeLogTag -eq $null -Or $TimeLogTag -eq "") -And ($TimeLogTag -eq $null -Or $TimeLogTag -eq "")) {
		Write-HR -IsWarning
		Write-Warning "No TimeStampTag seleceted. Defaulting to [TimeStamp]"
		Write-Warning "No type of timestamp tag selected. Default is `"TimeStamp`""
		$TimeLogTag = "TimeStamp='defaultNoTagSelected'"
		$BeginEnd = "[TimeStamp]"
	}
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	#-----------------------------------------------------------------------------------------------------------------------
	# Build Time-Log Entry
	#-----------------------------------------------------------------------------------------------------------------------
	
	#=======================================================================================================================
	#
	
	$TodayDateTime = Get-Date
	Write-Verbose "`rToday: $TodayDateTime`r"
	$TodayDoWLong = Get-Date -UFormat %A
	# Month/Day (MM/DD)
	$TodayMonthDay = Get-Date -UFormat %m/%d
	# Day/Month (DD/MM)
	$TodayDayMonth = Get-Date -UFormat %d/%m
	
	$YesterdayDateTime = (Get-Date).AddDays(-1)
	Write-Verbose "Yesterday: $YesterdayDateTime"
	$YesterdayDoWLong = Get-Date -Date $YesterdayDateTime -UFormat %A
	# Month/Day (MM/DD)
	$YesterdayMonthDay = Get-Date -Date $YesterdayDateTime -UFormat %m/%d
	# Day/Month (DD/MM)
	$YesterdayDayMonth = Get-Date -Date $YesterdayDateTime -UFormat %d/%m
	
	$TomorrowDateTime = (Get-Date).AddDays(1)
	Write-Verbose "Tomorrow: $TomorrowDateTime"
	$TomorrowDoWLong = Get-Date -Date $TomorrowDateTime -UFormat %A
	# Month/Day (MM/DD)
	$TomorrowMonthDay = Get-Date -Date $TomorrowDateTime -UFormat %m/%d
	# Day/Month (DD/MM)
	$TomorrowDayMonth = Get-Date -Date $TomorrowDateTime -UFormat %d/%m
	
	#
	#=======================================================================================================================
	
	#-----------------------------------------------------------------------------------------------------------------------
	# Collect Date/Time value if interactive mode is set
	#-----------------------------------------------------------------------------------------------------------------------
	
	If ($DateTimeMode -eq 'Interactive') {
		Write-Host "Choose Day and Time . . . "
	}
	
	#
	If (!$Interactive) {
		Write-Host "Writing current TimeStamp '(Get-Date)' to log ($TimeLogFile) . . ."
		$DateTimeToLog = Get-Date
	} Else {
		
		#
		# Choose Date:
$DatePickerSimple = @"
Choose date:

[T] - ($TodayMonthDay) $TodayDoWLong - [T]oday
[Y] - ($YesterdayMonthDay) $YesterdayDoWLong - [Y]esterday

[P] - Pick a different date
"@
		If (!$PickTimeOnly) {
		
			#PAUSE

			Do {
				#Clear-Host
				Start-Sleep -Milliseconds 100 #Bugfix: Clear-Host acts so quickly, sometimes it won't actually wipe the terminal properly. If you force it to wait, then after PowerShell will display any specially-formatted text properly.
				Write-Host $DatePickerSimple
				$UserResponse = Read-Host "`nEnter selection"
			} until ($UserResponse -eq 't' -Or $UserResponse -eq 'y' -Or $UserResponse -eq 'p')
			If ($UserResponse -eq 't') {
				$DateToLog = Get-Date
			} ElseIf ($UserResponse -eq 'y') {
				$DateToLog = (Get-Date).AddDays(-1)
			} ElseIf ($UserResponse -eq 'p') {
				$DateToLog = PromptForChoice-DayDate # -Verbose
			}

		} Else {
			$DateToLog = Get-Date -Date $DateInput
		}


		#
		# Choose Time:
		
		# Collect time (display header)
		#Clear-Host
		Start-Sleep -Milliseconds 100 #Bugfix: Clear-Host acts so quickly, sometimes it won't actually wipe the terminal properly. If you force it to wait, then after PowerShell will display any specially-formatted text properly.
		Write-Host "`r`nSelected date: $($DateToLog.ToLongDateString())`n"
		Write-Host "`r`n# Select Time #`n`r`n" -ForegroundColor Yellow

		#Get Selected time hour value
		$SelectedHour = ReadPrompt-Hour
		
		#Get Selected time minute value
		$SelectedMin = ReadPrompt-Minute
		
		# Check if we even need to prompt the user for AM/PM time
		If ($SelectedHour -gt 12 -Or $SelectedHour -eq 0) {
			$SelectedAMPM = 24
		} else {
			$SelectedAMPM = ReadPrompt-AMPM24 # -Verbose
		}
		
		#Write-HorizontalRuleAdv -SingleLine
		
		If ($SelectedAMPM -eq "AM") {
			$24hour = Convert-AMPMhourTo24hour $SelectedHour -AM
			#$24hour = Convert-AMPMhourTo24hour $SelectedHour -AM -Verbose
		} elseif ($SelectedAMPM -eq "PM") {
			$24hour = Convert-AMPMhourTo24hour $SelectedHour -PM
			#$24hour = Convert-AMPMhourTo24hour $SelectedHour -PM -Verbose
		} elseif ($SelectedAMPM -eq 24) {
			$24hour = $SelectedHour
		} else {
			Write-Error "AM/PM/24-hour time mode not recognized."
		}
		
		$DateTimeObj = Get-Date -Date $DateToLog -Hour $24hour -Minute $SelectedMin -Second 0 -Millisecond 0
		
		Write-Verbose "DateTimeObj = $DateTimeObj"
		
		#https://ss64.com/ps/syntax-dateformats.html
		#$DateTimeToLog = Get-Date -Date $DateTimeToLog -Format F

		#Write-Host "DateTimeToLog = $DateTimeToLog"
		
		[DateTime]$DateTimeToLog = $DateTimeObj

	}
	#
	
	#-----------------------------------------------------------------------------------------------------------------------
	# Write Time-Log Entry
	#-----------------------------------------------------------------------------------------------------------------------
	
	$UTCToLog = $DateTimeToLog.ToUniversalTime()
	# UniversalSortableDateTimePattern using the format for universal time display E.g. 2019-10-22 20:33:56Z
	$UTCToLog_Readable = Get-Date -Date $UTCToLog -Format u
	# FileDateTimeUniversal date and time in universal time (UTC), in 24-hour format. The format is yyyyMMddTHHmmssffffZ (case-sensitive, using a 4-digit year, 2-digit month, 2-digit day, the letter T as a time separator, 2-digit hour, 2-digit minute, 2-digit second, 4-digit millisecond, and the letter Z as the UTC indicator). For example: 20190627T1540500718Z.
	$UTCToLog = Get-Date -Date $UTCToLog -Format FileDateTimeUniversal
	$LocalTimeZoneID = (Get-TimeZone).Id
	$LocalTimeZoneName = (Get-TimeZone).DisplayName
	
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
	<#
	$TimeLogColumns = "TimeStampUT"
	$TimeLogColumns += ",TimeStampUT_Human-Readable"
	$TimeLogColumns += ",TimeZoneID"
	$TimeLogColumns += ",TimeZoneName"
	$TimeLogColumns += ",[Begin/End/TimeStamp]"
	$TimeLogColumns += ",Tag"
	$TimeLogColumns += ",Description"
	Write-Verbose "Log columns:`r`n'$TimeLogColumns'"
	#>
	
	$TimeLogEntry = "$UTCToLog" #DateTime
	$TimeLogEntry += ",$UTCToLog_Readable"
	$TimeLogEntry += ",$LocalTimeZoneID"
	$TimeLogEntry += ",$LocalTimeZoneName"
	$TimeLogEntry += ",$BeginEnd"
	$TimeLogEntry += ",$TimeLogTag"
	$TimeLogEntry += ",$Description"
	
	$NewRecord = $TimeLogEntry
	
	$NewRecord = "$UTCToLog,$UTCToLog_Readable,$LocalTimeZoneID,$LocalTimeZoneName,$BeginEnd,$TimeLogTag,$Description"
	$NewRecord >> $TimeLogFile | Out-Null

	#=======================================================================================================================
	
	Write-Host "DateTimeToLog = $DateTimeToLog"
	$DateTimeToLog = Get-Date -Date $DateTimeToLog
	
	Write-Host "DateTimeToLog = $DateTimeToLog"
	$DateTimeToLog = ($DateTimeToLog).DateTime
	
	Write-Host "DateTimeToLog = $DateTimeToLog"
	#$DateTimeToLog = [DateTime]$DateTimeToLog
	
	#Write-Host "DateTimeToLog = $DateTimeToLog"
	
	#Return $DateTimeToLog
	Write-Output -InputObject $DateTimeToLog -NoEnumerate
	#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	
} # End Log-Time function ----------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
