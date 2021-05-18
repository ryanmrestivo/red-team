# Run this script repeatedly to improve automatically add the newly used DLLs to the exclusions.
# Do a reboot after installing the "base" Sysmon config to log all the DLLs loaded in the Windows boot process.

$SYSMON_EXECUTABLE = "C:\Sysmon\Sysmon64.exe" # Modify to point to the Sysmon executable.
$CONFIG_FILE = "C:\Sysmon\config.xml" # Modify to point to the new config. (Will be overwritten!)

Function Get-DLLs {
    # Using a HashSet to avoid having to filter for duplicates
	$dlls = New-Object System.Collections.Generic.HashSet[String]
	
    try {
	    $events = Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -FilterXPath "Event[System[(EventID=7)]]"
		$events.Message | ForEach-Object -Process {
            # Extract the ImageLoaded from the events
			$loaded = (Select-String -InputObject $_ -Pattern "ImageLoaded: (.*)").Matches.Groups[1]
			$dlls.add($loaded) | Out-Null
		}
	} catch {}
	
    # Sort before returning for consistent & managable output
	$dlls | Sort-Object
}

Function Export-SysmonConfig {
	Param($dlls)
	
	$XMLHeader = @"
<Sysmon schemaversion=`"4.22`">
    <EventFiltering>
        <RuleGroup name="" groupRelation=`"or`">
            <ImageLoad onmatch=`"exclude`">

"@
	$XMLTrailer = @"
            </ImageLoad>
        </RuleGroup>
    </EventFiltering>
</Sysmon>
"@
    # To indent correctly for readability
    $ImageLoadedOffset = "                "
	
	Function Format-Exclusion {
		Param($dll)
		$dll = $dll.trim()
		$ImageLoadedOffset + "<ImageLoaded condition=`"is`">$dll</ImageLoaded>`n"
	}
		
	$XMLConfig = $XMLHeader
	$XMLConfig += $ImageLoadedOffset + "<ImageLoaded condition=`"is`">$SYSMON_EXECUTABLE</ImageLoaded>`n"
	$XMLConfig += $ImageLoadedOffset + "<ImageLoaded condition=`"begin with`">C:\Windows\System32\</ImageLoaded>`n"
	$XMLConfig += $ImageLoadedOffset + "<ImageLoaded condition=`"begin with`">C:\Windows\SysWOW64\</ImageLoaded>`n"
	foreach ($dll in $dlls) {
		$XMLConfig += Format-Exclusion $dll
	}
	$XMLConfig += $XMLTrailer
	
	$XMLConfig
}

$dlls = Get-DLLs
Export-SysmonConfig $dlls | Tee-Object -FilePath $CONFIG_FILE
# Install the new config to lower the amount of logs generated.
Start-Process -FilePath $SYSMON_EXECUTABLE -ArgumentList @('-c', $CONFIG_FILE)
