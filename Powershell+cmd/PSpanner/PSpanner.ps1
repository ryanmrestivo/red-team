   <#
	.SYNOPSIS
		Scan Network Devices

	.DESCRIPTION
		Simple Light Weight Network Scanner

	.NOTES
		Aurthor: https://securethelogs.com

    		
#>



$logo = @(  "",
"__________  _________      ",                               
"\______   \/   _____/__________    ____   ____   ___________ ",
" |     ___/\_____  \\____ \__  \  /    \ /    \_/ __ \_  __ \",
" |    |    /        \  |_> > __ \|   |  \   |  \  ___/|  | \/",
" |____|   /_______  /   __(____  /___|  /___|  /\___  >__|   ",
 "                 \/|__|       \/     \/     \/     \/     ",
"",

"Creator: https://securethelogs.com / @securethelogs",
"")



       
    # Set Variables and Arrays

    $ScanAll = ""
    
    $waittime = 400
    $liveports = @()
   
    $destip = @() 
          
    $Portarray = @(20,21,22,23,25,50,51,53,80,110,119,135,136,137,138,139,143,161,162,389,443,445,636,1025,1443,3389,5985,5986,8080,10000)

    

    # -------------- Get the Details From The User -------------

    
    $logo

    # Get the Target/s
    
    Write-Output "Please enter either an IP Address, URL or File Path (Example: C:\Temp\IPList.txt)....."
    
    [string]$Typeofscan = Read-Host -Prompt "Target"
  

    if ($Typeofscan -like "*txt") {
    
    $PulledIPs = Get-Content $Typeofscan
    
    foreach ($i in $PulledIPs) {

    # Fill destination array with all IPs
    
    $destip += $i
    
    } # for each

    }

    else {
    
    # Single Scan

    $destip = $Typeofscan
    
    }


    # ------------------- Get the Ports -----------------
    Write-Output "`n"
    Write-Output "Option 1:  Common Scan |  Option 2:  Full Scan (1-65535) |  Options 3:  Quick Scan (Less Accurate)"
    Write-Output "--------------------------------------------------------------------------------------------------"

    $ScanPorts = Read-Host -Prompt "Option Number" 

    if ($ScanPorts -eq 1) {$ScanAll = ""}
    if ($ScanPorts -eq 2) {$ScanAll = "True"}
    if ($ScanPorts -eq 3) {$ScanAll = "Quick"}
    if ($ScanPorts -ne 1 -AND $ScanPorts -ne 2 -AND $ScanPorts -ne 3){exit}



  # --------------- Get the Ports -------------------------------------

 
    if ($ScanAll -eq "True") {

    $waittime = 400
    $Portarray = 1..65535 
    
    }

    if ($ScanAll -eq "Quick") {

    $waittime = 40
    $Portarray = 1..65535

    }

    else {
    
    # Portarray remains the same (Common ports)

    }



    #----------------------- SCAN -----------------------------------------

    
    Write-Output ""
    Write-Output "Running Scan................"
    

    foreach ($i in $destip){ # Scan Every Dest



    foreach ($p in $Portarray){


    $TCPObject = new-Object system.Net.Sockets.TcpClient

    $Result = $TCPObject.ConnectAsync($i,$p).Wait($waittime)


    if ($Result -eq "True") {
    
    $liveports += $p  

    }


    } # For each Array

    # --------------- Show Known Ports ------------------------------


    $Knownservices = @()
    
    $ftp = "Port: 20,21     Service: FTP"
    $http = "Port: 80     Service: HTTP"
    $https = "Port: 443     Service: HTTPS"
    $ssh = "Port: 22     Service: SSH"
    $telnet = "Port: 23     Service: Telnet"
    $smtp = "Port: 25     Service: SMTP"
    $ipsec = "Port: 50,51     Service: IPSec"
    $dns = "Port: 53     Service: DNS"
    $pop3 = "Port: 110     Service: POP3"
    $netbios = "Port: 135-139     Service: NetBIOS"
    $imap4 = "Port: 143     Service: IMAP4"
    $snmp = "Port: 161,162     Service: SNMP"
    $ldap = "Port: 389     Service: LDAP"
    $smb = "Port: 445     Service: SMB"
    $ldaps = "Port: 636     Service: LDAPS"
    $rpc = "Port: 1025     Service: Microsoft RPC"
    $sql = "Port: 1433     Service: SQL"
    $rdp = "Port: 3389     Service: RDP"
    $winrm = "Port: 5985,5986     Service: WinRM"
    $proxy = "Port: 8080     Service: HTTP Proxy"
    $webmin = "Port: 10000     Service: Webmin"
        

    if ($liveports -contains "20" -or $liveports -contains "21"){$knownservices += $ftp}
    if ($liveports -contains "22"){$knownservices += $ssh}
    if ($liveports -contains "23"){$knownservices += $telnet}
    if ($liveports -contains "50" -or $liveports -contains "51"){$knownservices += $ipsec}
    if ($liveports -contains "53"){$knownservices += $dns}
    if ($liveports -contains "80"){$knownservices += $http}
    if ($liveports -contains "110"){$knownservices += $pop3}
    if ($liveports -contains "135" -or $liveports -contains "136" -or $liveports -contains "137" -or $liveports -contains "138" -or $liveports -contains "139"){$knownservices += $netbios}
    if ($liveports -contains "143"){$knownservices += $IMAP4}
    if ($liveports -contains "161"-or $liveports -contains "162"){$knownservices += $snmp}
    if ($liveports -contains "389"){$knownservices += $ldap}
    if ($liveports -contains "443"){$knownservices += $https}
    if ($liveports -contains "445"){$knownservices += $smb}
    if ($liveports -contains "636"){$knownservices += $ldaps}
    if ($liveports -contains "1025"){$knownservices += $rpc}
    if ($liveports -contains "1433"){$knownservices += $sql}
    if ($liveports -contains "3389"){$knownservices += $rdp}
    if ($liveports -contains "5985" -or $liveports -contains "5986"){$knownservices += $winrm}
    if ($liveports -contains "8080"){$knownservices += $proxy}
    if ($liveports -contains "10000"){$knownservices += $webmin}
    
    # -------------------------- Output Results ---------------------------------
    
    Write-Output "--------------------------------------------------------------------------------------------------"
    Write-Output ""
    Write-Output "Target: $i"
    Write-Output ""
    Write-Output "Ports Found: "
    Write-Output ""
    Write-Output $liveports
    Write-Output ""
    Write-Output ""
    Write-Output "Known Services:"
    Write-Output ""
    Write-Output $Knownservices
    Write-Output ""
    

    #Clear Array for next
    $liveports = @()

    

    } # For Each $i in DestIP


