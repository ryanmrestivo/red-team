####################################################################################
#.Synopsis 
#    Parse XML output files of the nmap port scanner (www.nmap.org). 
#
#.Description 
#    Parse XML output files of the nmap port scanner (www.nmap.org) and  
#    emit custom objects with properties containing the scan data. The 
#    script can accept either piped or parameter input.  The script can be
#    safely dot-sourced without error as is. 
#
#.Parameter Path  
#    Either 1) a string with or without wildcards to one or more XML output
#    files, or 2) one or more FileInfo objects representing XML output files.
#
#.Parameter OutputDelimiter
#    The delimiter for the strings in the OS, Ports and Services properties. 
#    Default is a newline.  Change it when you want single-line output. 
#
#.Parameter RunStatsOnly
#    Only displays general scan information from each XML output file, such
#    as scan start/stop time, elapsed time, command-line arguments, etc.
#
#.Example 
#    dir *.xml | .\parse-nmap.ps1
#
#.Example 
#	 .\parse-nmap.ps1 -path onefile.xml
#    .\parse-nmap.ps1 -path *files.xml 
#
#.Example 
#    $files = dir *some.xml,others*.xml 
#    .\parse-nmap.ps1 -path $files    
#
#.Example 
#    .\parse-nmap.ps1 -path scanfile.xml -runstatsonly
#
#.Example 
#    .\parse-nmap.ps1 scanfile.xml -OutputDelimiter " "
#
#Requires -Version 2 
#
#.Notes 
#  Author: Enclave Consulting LLC, Jason Fossen (http://www.sans.org/sec505)  
# Version: 4.6
# Updated: 27.Feb.2016
#   Legal: 0BSD.
####################################################################################

[CmdletBinding(SupportsShouldProcess=$True)]
Param ([Parameter(Mandatory=$True, ValueFromPipeline=$true)] $Path, [String] $OutputDelimiter = "`n", [Switch] $RunStatsOnly)


function parse-nmap 
{
	param ($Path, [String] $OutputDelimiter = "`n", [Switch] $RunStatsOnly)
	
	if ($Path -match '/\?|/help|--h|--help') 
	{ 
        $MyInvocation = (Get-Variable -Name MyInvocation -Scope Script).Value
        get-help -full ($MyInvocation.MyCommand.Path)   
		exit 
	}

	if ($Path -eq $null) {$Path = @(); $input | foreach { $Path += $_ } } 
	if (($Path -ne $null) -and ($Path.gettype().name -eq "String")) {$Path = dir $path} #To support wildcards in $path.  
	$1970 = [DateTime] "01 Jan 1970 01:00:00 GMT"

	if ($RunStatsOnly)
	{
		ForEach ($file in $Path) 
		{
			$xmldoc = new-object System.XML.XMLdocument
			$xmldoc.Load($file)
			$stat = ($stat = " " | select-object FilePath,FileName,Scanner,Profile,ProfileName,Hint,ScanName,Arguments,Options,NmapVersion,XmlOutputVersion,StartTime,FinishedTime,ElapsedSeconds,ScanTypes,TcpPorts,UdpPorts,IpProtocols,SctpPorts,VerboseLevel,DebuggingLevel,HostsUp,HostsDown,HostsTotal)
			$stat.FilePath = $file.fullname
			$stat.FileName = $file.name
			$stat.Scanner = $xmldoc.nmaprun.scanner
			$stat.Profile = $xmldoc.nmaprun.profile
			$stat.ProfileName = $xmldoc.nmaprun.profile_name
			$stat.Hint = $xmldoc.nmaprun.hint
			$stat.ScanName = $xmldoc.nmaprun.scan_name
			$stat.Arguments = $xmldoc.nmaprun.args
			$stat.Options = $xmldoc.nmaprun.options
			$stat.NmapVersion = $xmldoc.nmaprun.version
			$stat.XmlOutputVersion = $xmldoc.nmaprun.xmloutputversion
			$stat.StartTime = $1970.AddSeconds($xmldoc.nmaprun.start) 	
			$stat.FinishedTime = $1970.AddSeconds($xmldoc.nmaprun.runstats.finished.time)
			$stat.ElapsedSeconds = $xmldoc.nmaprun.runstats.finished.elapsed
            
            $xmldoc.nmaprun.scaninfo | foreach {
                $stat.ScanTypes += $_.type + " "
                $services = $_.services  #Seems unnecessary, but solves a problem. 

                if ($services -ne $null -and $services.contains("-"))
                {
                    #In the original XML, ranges of ports are summarized, e.g., "500-522", 
                    #but the script will list each port separately for easier searching.
                    $array = $($services.replace("-","..")).Split(",")
                    $temp  = @($array | where { $_ -notlike "*..*" })  
                    $array | where { $_ -like "*..*" } | foreach { invoke-expression "$_" } | foreach { $temp += $_ } 
                    $temp = [Int32[]] $temp | sort-object
                    $services = [String]::Join(",",$temp) 
                } 
                    
                switch ($_.protocol)
                {
                    "tcp"  { $stat.TcpPorts  = $services ; break }
                    "udp"  { $stat.UdpPorts  = $services ; break }
                    "ip"   { $stat.IpProtocols = $services ; break }
                    "sctp" { $stat.SctpPorts = $services ; break }
                }
            } 
            
            $stat.ScanTypes = $($stat.ScanTypes).Trim()
            
			$stat.VerboseLevel = $xmldoc.nmaprun.verbose.level
			$stat.DebuggingLevel = $xmldoc.nmaprun.debugging.level		
			$stat.HostsUp = $xmldoc.nmaprun.runstats.hosts.up
			$stat.HostsDown = $xmldoc.nmaprun.runstats.hosts.down		
			$stat.HostsTotal = $xmldoc.nmaprun.runstats.hosts.total
			$stat 			
		}
		return #Don't process hosts.  
	}
	

    # Not doing just -RunStats, so process hosts from XML file.
	ForEach ($file in $Path) 
    {
		Write-Verbose -Message ("[" + (get-date).ToLongTimeString() + "] Starting $file" )
        $StartTime = get-date  

		$xmldoc = new-object System.XML.XMLdocument
		$xmldoc.Load($file)
		
		# Process each of the <host> nodes from the nmap report.
		$i = 0  #Counter for <host> nodes processed.

        foreach ($hostnode in $xmldoc.nmaprun.host) 
        { 
            # Init some variables, with $entry being the custom object for each <host>. 
	        $service = " " #service needs to be a single space.
	        $entry = ($entry = " " | select-object HostName, FQDN, Status, IPv4, IPv6, MAC, Ports, Services, OS, Script) 

			# Extract state element of status:
			if ($hostnode.Status -ne $null -and $hostnode.Status.length -ne 0) { $entry.Status = $hostnode.status.state.Trim() }  
			if ($entry.Status.length -lt 2) { $entry.Status = "<no-status>" }

			# Extract computer names provided by user or through PTR record, but avoid duplicates and allow multiple names.
            # Note that $hostnode.hostnames can be empty, and the formatting of one versus multiple names is different.
            # The crazy foreach-ing here is to deal with backwards compatibility issues...
            $tempFQDN = $tempHostName = ""
			ForEach ($hostname in $hostnode.hostnames)
            {
                ForEach ($hname in $hostname.hostname)
                {
                    ForEach ($namer in $hname.name)
                    {
                        if ($namer -ne $null -and $namer.length -ne 0 -and $namer.IndexOf(".") -ne -1) 
                        {
                            #Only append to temp variable if it would be unique.
                            if($tempFQDN.IndexOf($namer.tolower()) -eq -1)
                            { $tempFQDN = $tempFQDN + " " + $namer.tolower() }
                        }
                        elseif ($namer -ne $null -and $namer.length -ne 0)
                        {
                            #Only append to temp variable if it would be unique.
                            if($tempHostName.IndexOf($namer.tolower()) -eq -1)
                            { $tempHostName = $tempHostName + " " + $namer.tolower() } 
                        }
                    }
                }
            }

            $tempFQDN = $tempFQDN.Trim()
            $tempHostName = $tempHostName.Trim()

            if ($tempHostName.Length -eq 0 -and $tempFQDN.Length -eq 0) { $tempHostName = "<no-hostname>" } 

            #Extract hostname from the first (and only the first) FQDN, if FQDN present.
            if ($tempFQDN.Length -ne 0 -and $tempHostName.Length -eq 0) 
            { $tempHostName = $tempFQDN.Substring(0,$tempFQDN.IndexOf("."))  } 

            if ($tempFQDN.Length -eq 0) { $tempFQDN = "<no-fullname>" }

            $entry.FQDN = $tempFQDN
            $entry.HostName = $tempHostName  #This can be different than FQDN because PTR might not equal user-supplied hostname.
            


			# Process each of the <address> nodes, extracting by type.
			ForEach ($addr in $hostnode.address)
            {
				if ($addr.addrtype -eq "ipv4") { $entry.IPv4 += $addr.addr + " "}
				if ($addr.addrtype -eq "ipv6") { $entry.IPv6 += $addr.addr + " "}
				if ($addr.addrtype -eq "mac")  { $entry.MAC  += $addr.addr + " "}
			}        
			if ($entry.IPv4 -eq $null) { $entry.IPv4 = "<no-ipv4>" } else { $entry.IPv4 = $entry.IPv4.Trim()}
			if ($entry.IPv6 -eq $null) { $entry.IPv6 = "<no-ipv6>" } else { $entry.IPv6 = $entry.IPv6.Trim()}
			if ($entry.MAC  -eq $null) { $entry.MAC  = "<no-mac>"  } else { $entry.MAC  = $entry.MAC.Trim() }


			# Process all ports from <ports><port>, and note that <port> does not contain an array if it only has one item in it.
            # This could be parsed out into separate properties, but that would be overkill.  We still want to be able to use
            # simple regex patterns to do our filtering afterwards, and it's helpful to have the output look similar to
            # the console output of nmap by itself for easier first-time comprehension.  
			if ($hostnode.ports.port -eq $null) { $entry.Ports = "<no-ports>" ; $entry.Services = "<no-services>" } 
			else 
			{
				ForEach ($porto in $hostnode.ports.port)
                {
					if ($porto.service.name -eq $null) { $service = "unknown" } else { $service = $porto.service.name } 
					$entry.Ports += $porto.state.state + ":" + $porto.protocol + ":" + $porto.portid + ":" + $service + $OutputDelimiter 
                    # Build Services property. What a mess...but exclude non-open/non-open|filtered ports and blank service info, and exclude servicefp too for the sake of tidiness.
                    if ($porto.state.state -like "open*" -and ($porto.service.tunnel.length -gt 2 -or $porto.service.product.length -gt 2 -or $porto.service.proto.length -gt 2)) { $entry.Services += $porto.protocol + ":" + $porto.portid + ":" + $service + ":" + ($porto.service.product + " " + $porto.service.version + " " + $porto.service.tunnel + " " + $porto.service.proto + " " + $porto.service.rpcnum).Trim() + " <" + ([Int] $porto.service.conf * 10) + "%-confidence>$OutputDelimiter" }
				}
				$entry.Ports = $entry.Ports.Trim()
                if ($entry.Services -eq $null) { $entry.Services = "<no-services>" } else { $entry.Services = $entry.Services.Trim() }
                if ($entry.Services -ne $null) { $entry.Services = $entry.Services.Trim() } 
			}


			# Extract fingerprinted OS type and percent of accuracy.
			ForEach ($osm in $hostnode.os.osmatch) {$entry.OS += $osm.name + " <" + ([String] $osm.accuracy) + "%-accuracy>$OutputDelimiter"} 
            ForEach ($osc in $hostnode.os.osclass) {$entry.OS += $osc.type + " " + $osc.vendor + " " + $osc.osfamily + " " + $osc.osgen + " <" + ([String] $osc.accuracy) + "%-accuracy>$OutputDelimiter"}  
            if ($entry.OS -ne $null -and $entry.OS.length -gt 0)
            {
               $entry.OS = $entry.OS.Replace("  "," ")
               $entry.OS = $entry.OS.Replace("<%-accuracy>","") #Sometimes no osmatch.
			   $entry.OS = $entry.OS.Trim()
            }
			if ($entry.OS.length -lt 16) { $entry.OS = "<no-os>" }

            
            # Extract script output, first for port scripts, then for host scripts.
            ForEach ($pp in $hostnode.ports.port)
            {
                if ($pp.script -ne $null) { 
                    $entry.Script += "<PortScript id=""" + $pp.script.id + """>$OutputDelimiter" + ($pp.script.output -replace "`n","$OutputDelimiter") + "$OutputDelimiter</PortScript> $OutputDelimiter $OutputDelimiter" 
                }
            } 
            
            if ($hostnode.hostscript -ne $null) {
                ForEach ($scr in $hostnode.hostscript.script)
                {
                    $entry.Script += '<HostScript id="' + $scr.id + '">' + $OutputDelimiter + ($scr.output.replace("`n","$OutputDelimiter")) + "$OutputDelimiter</HostScript> $OutputDelimiter $OutputDelimiter" 
                }
            }
            
            if ($entry.Script -eq $null) { $entry.Script = "<no-script>" } 
    
    
			# Emit custom object from script.
			$i++  #Progress counter...
			$entry
		}

		Write-Verbose -Message ( "[" + (get-date).ToLongTimeString() + "] Finished $file, processed $i entries." ) 
        Write-Verbose -Message ('Total Run Time: ' + ( [MATH]::Round( ((Get-date) - $StartTime).TotalSeconds, 3 )) + ' seconds')
        Write-Verbose -Message ('Entries/Second: ' + ( [MATH]::Round( ($i / $((Get-date) - $StartTime).TotalSeconds), 3 ) ) )  
	}
}


# Build hashtable for splatting the parameters:
$ParamArgs = @{ Path = $Path ; OutputDelimiter = $OutputDelimiter ; RunStatsOnly = $RunStatsOnly } 

# Allow XML files to be piped into script:
if ($ParamArgs.Path -eq $null) { $ParamArgs.Path = @(); $input | foreach { $ParamArgs.Path += $_ } } 

# Run the main function with the splatted params:
parse-nmap @ParamArgs


# Notes:
# I know that the proper PowerShell way is to output $null instead of
# strings like "<no-os>" for properties with no data, but this actually
# caused confusion with people new to PowerShell and makes the output
# more digestible when exported to CSV and other formats.

