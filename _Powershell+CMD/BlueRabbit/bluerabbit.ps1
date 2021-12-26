$logo = @(
'__________.__               __________       ___.  ___.   .__  __                \\\,_',
'\______   \  |  __ __   ____\______   \_____ \_ |__\_ |__ |__|/  |_               \` ,\ ',
' |    |  _/  | |  |  \_/ __ \|       _/\__  \ | __ \| __ \|  \   __\         __,.-" =__)',
' |    |   \  |_|  |  /\  ___/|    |   \ / __ \| \_\ \ \_\ \  ||  |         ."        )',
' |______  /____/____/  \___  >____|_  /(____  /___  /___  /__||__|      ,_/   ,    \/\_',
'        \/                 \/       \/      \/    \/    \/              \_|    )_-\ \_-`',
"",
"Creator: https://securethelogs.com / @securethelogs",
"")

$logo


    Write-Output "Please select one of the following:"
    Write-Output ""

    
    Write-Output "Option 1: PSpanner - Network Scanner"
    Write-Output "Option 2: PSdnsresolver - Resolve IP > DNS"
    Write-Output "Option 3: Bluechecker - Audit Powershell"
    Write-Output "Option 4: ZorkAzure - Scan For Azure Resources"

    Write-Output ""

    Write-Output "Option 5: Test Single Connection"
    Write-Output "Option 6: What's My Public IP?"
    Write-Output "Option 7: Get Kerberos Ticket"
    Write-Output "Option 8: Display Windows Firewall Rules"
    Write-Output "Option 9: Show Windows Event IDs (Cheatsheet)"
    Write-Output "Option 10: Enter Remote Powershell Session (WinRM)"

    Write-Output ""
    
    
    [string]$option = Read-Host -Prompt "Option:"

    if ($option -eq "1"){powershell –nop –c “iex(New-Object Net.WebClient).DownloadString(‘https://raw.githubusercontent.com/securethelogs/PSpanner/master/PSpanner.ps1’)”}
    if ($option -eq "2"){powershell –nop –c “iex(New-Object Net.WebClient).DownloadString(‘https://raw.githubusercontent.com/securethelogs/PSdnsresolver/master/PSdnsresolver.ps1’)”}
    if ($option -eq "3"){powershell –nop –c “iex(New-Object Net.WebClient).DownloadString(‘https://raw.githubusercontent.com/securethelogs/Bluechecker/master/BlueChecker.ps1')”}
    if ($option -eq "4"){powershell –nop –c “iex(New-Object Net.WebClient).DownloadString(‘https://raw.githubusercontent.com/securethelogs/PSBruteZip/master/PSBruteZip.ps1’)”}
    
    
    
    # Other Options....


    if ($option -eq "5"){
    
    $target = Read-Host -Prompt "Target"
    $port = Read-Host -Prompt "Port"

    Test-NetConnection $target -Port $port 
    
    
    }


    if ($option -eq "6"){
    
    $publicip = (curl http://ipinfo.io/ip).content
    
    Write-Output ""
    Write-Output "Your Public IP: $publicip"
    Write-Output ""
   
    
    }



    if ($option -eq "7"){[System.Security.Principal.WindowsIdentity]::GetCurrent()}

    if ($option -eq "8"){

    Get-NetFirewallRule |
Format-Table -Property Name,
DisplayName,
DisplayGroup,
@{Name='Protocol';Expression={($PSItem | Get-NetFirewallPortFilter).Protocol}},
@{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}},
@{Name='RemotePort';Expression={($PSItem | Get-NetFirewallPortFilter).RemotePort}},
@{Name='RemoteAddress';Expression={($PSItem | Get-NetFirewallAddressFilter).RemoteAddress}},
Enabled,
Profile,
Direction,
Action

    
    }


    if ($option -eq "9"){
    
    $wineventlist = @("", 
"Security		4624	Account Logon",
"Security		4625	Failed login",
"Security		4720	A user account was created",
"Security		4722	A user account was enabled",
"Security		4726	A user account was deleted",
"Security		4740	A user account was locked out",
"Security		4724, 4738	Additional user creation events",
"Security		4728	A member was added to a security-enabled global group",
"Security		4732	A member was added to a security-enabled local group",
"Security		4724	An attempt was made to reset an accounts password",
"Security		4767	A user account was unlocked",
"Security 	    4781	The name of an account was changed",
"Security		4738	A user account was changed",
"Security		4660	 An object was deleted",
"Security		4776	The domain controller attempted to validate the credentials for an account",
"Security		4743	A computer account was deleted",
"Security		1100	The event logging service has shut down",
"Security		1102	Clear Event log",
"Firewall		2003	Disable firewall",
"Firewall		4948	A change has been made to Windows Firewall exception list. A rule was deleted",
"Firewall		4950	A Windows Firewall setting has changed",
"Firewall		5025	The Windows Firewall Service has been stopped")
    
    $wineventlist
    Write-Output ""
    
    }

    if ($option -eq "10"){
    
    Write-Output "`n"
$comp = Read-Host -Prompt "Enter The Computer Name or IP"
$testcont = test-netconnection -ComputerName "$comp" -CommonTCPPort WINRM -InformationLevel Quiet



if ($testcont -eq "True"){

#If successful, write message
Write-Output "`n"
Write-Output "Services Appears To Be Running...."
Write-Output "Attempting To Connect To $comp.............."
Write-Output "`n"

Enter-PSSession -ComputerName $comp


} 

#If failed, write message

elseif ($results -eq "False" -or $results -contains "failed") {
Write-Output "`n"
Write-Output "Failed To Connect To $comp"


}
    }


    
    
    else {
    
    #Do Nothing


    }