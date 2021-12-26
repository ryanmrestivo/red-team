function Get-Attack {
  <#
  .SYNOPSIS
  Find a PowerShell attack for a given keyword

  .DESCRIPTION
  Get-Attack will return a list of attacks available in PS>Attack for a given search query. Running it without a term to search for will print out a PS>Attack help message.

  .EXAMPLE
  PS> Get-Attack password

  .EXAMPLE
  PS> Get-Attack -term password 
  
  .PARAMETER term
  What you want to search for.
  #>

  [CmdletBinding()]
  param
  (
    [Parameter(HelpMessage='What are we searching for?')]
    [string[]]$term = ""
  )

  begin 
  {

    $attacksCSV = 'Module,Command,Type,Description
PowershellMafia\Invoke-Mimikatz.ps1,Invoke-Mimikatz,Passwords,This script leverages Mimikatz 2.0 and Invoke-ReflectivePEInjection to reflectively load Mimikatz completely in memory. This allows you to do things such as dump credentials without ever writing the mimikatz binary to disk. The script has a ComputerName parameter which allows it to be executed against multiple computers.
PowershellMafia\Get-GPPPassword.ps1,Get-GPPPassword,Passwords,Retrieves the plaintext password and other information for accounts pushed through Group Policy Preferences.
PowershellMafia\Invoke-NinjaCopy.ps1,Invoke-NinjaCopy,Exfiltration,This script can copy files off an NTFS volume by opening a read handle to the entire volume (such as c:) and parsing the NTFS structures. This requires you are an administrator of the server.
PowershellMafia\Invoke-Shellcode.ps1,Invoke-Shellcode,Code Execution,Inject shellcode into the process ID of your choosing or within the context of the running PowerShell process.
PowershellMafia\Invoke-WMICommand.ps1,Invoke-WMICommand,Code Execution,Executes a PowerShell ScriptBlock on a target computer using WMI as a pure C2 channel.
PowershellMafia\VolumeShadowCopyTools.ps1,Get-VolumeShadowCopy,File Tools,Lists the device paths of all local volume shadow copies.
PowershellMafia\VolumeShadowCopyTools.ps1,New-VolumeShadowCopy,File Tools,Creates a new volume shadow copy.
PowershellMafia\VolumeShadowCopyTools.ps1,Remove-VolumeShadowCopy,File Tools,Deletes a volume shadow copy.
PowershellMafia\VolumeShadowCopyTools.ps1,Mount-VolumeShadowCopy,File Tools,Mounts a volume shadow copy.
PowershellMafia\PowerView.ps1,Export-PowerViewCSV,Exfiltration,This function exports to a .csv in a thread-safe manner.
PowershellMafia\PowerView.ps1,Set-MacAttribute,File Tools,Sets the modified accessed and created (Mac) attributes for a file based on another file or input.
PowershellMafia\PowerView.ps1,Copy-ClonedFile,File Tools,Copy a source file to a destination location matching any MAC properties as appropriate.
PowershellMafia\PowerView.ps1,Get-IPAddress,Recon,This function resolves a given hostename to its associated IPv4 address. If no hostname is provided it defaults to returning the IP address of the local host the script be being run on.
PowershellMafia\PowerView.ps1,Convert-NameToSid,Recon; Active Directory,Converts a given user/group name to a security identifier (SID).
PowershellMafia\PowerView.ps1,Convert-SidToName,Recon; Active Directory,Converts a security identifier (SID) to a group/user name.
PowershellMafia\PowerView.ps1,Convert-NT4toCanonical,Recon; Active Directory,Converts a user/group NT4 name (i.e. dev/john) to canonical format.
PowershellMafia\PowerView.ps1,Get-Proxy,Recon; Network,Enumerates the proxy server and WPAD conents for the current user.
PowershellMafia\PowerView.ps1,Get-PathAcl,File Tools,Returns the file permissions for a given path.
PowershellMafia\PowerView.ps1,Get-UserProperty,Recon; Active Directory,Returns a list of all user object properties. If a property name is specified it returns all [user:property] values.
PowershellMafia\PowerView.ps1,Get-ComputerProperty,Recon; Active Directory,Returns a list of all computer object properties. If a property name is specified it returns all [computer:property] values.
PowershellMafia\PowerView.ps1,Find-InterestingFile,Recon; Active Directory,This function recursively searches a given UNC path for files with specific keywords in the name (default of pass sensitive secret admin login and unattend*.xml). The output can be piped out to a csv with the -OutFile flag. By default hidden files/folders are included in search results.
PowershellMafia\PowerView.ps1,Invoke-CheckLocalAdminAccess,Recon,This function will use the OpenSCManagerW Win32API call to to establish a handle to the remote host. If this succeeds the current user context has local administrator acess to the target.
PowershellMafia\PowerView.ps1,Get-DomainSearcher,Recon; Active Directory,Helper used by various functions that takes an ADSpath and domain specifier and builds the correct ADSI searcher object.
PowershellMafia\PowerView.ps1,Get-ObjectAcl,Recon; Active Directory,Returns the ACLs associated with a specific active directory object.
PowershellMafia\PowerView.ps1,Add-ObjectAcl,Recon; Active Directory,Adds an ACL for a specific active directory object.
PowershellMafia\PowerView.ps1,Get-LastLoggedOn,Recon; Active Directory,This function uses remote registry functionality to return the last user logged onto a target machine.
PowershellMafia\PowerView.ps1,Get-CachedRDPConnection,Recon; Active Directory,"Uses remote registry functionality to query all entries for the ""Windows Remote Desktop Connection Client"" on a machine separated by user and target server."
PowershellMafia\PowerView.ps1,Invoke-ACLScanner,Recon; Active Directory,Searches for ACLs for specifable AD objects (default to all domain objects) with a domain sid of > -1000 and have modifiable rights.
PowershellMafia\PowerView.ps1,Get-GUIDMap,Active Directory,Helper to build a hash table of [GUID] -> resolved names
PowershellMafia\PowerView.ps1,Get-DomainSID,Active Directory,Gets the SID for the domain.
PowershellMafia\PowerView.ps1,Get-NetDomain,Active Directory,Returns a given domain object.
PowershellMafia\PowerView.ps1,Get-NetForest,Active Directory,Returns a given forest object.
PowershellMafia\PowerView.ps1,Get-NetForestDomain,Active Directory,Return all domains for a given forest.
PowershellMafia\PowerView.ps1,Get-NetDomainController,Active Directory,Return the current domain controllers for the active domain.
PowershellMafia\PowerView.ps1,Get-NetUser,Recon; Active Directory,"Query information for a given user or users in the domain using ADSI and LDAP. Another -Domain can be specified to query for users across a trust.Replacement for ""net users /domain"""
PowershellMafia\PowerView.ps1,Add-NetUser,Active Directory,Adds a domain user or a local user to the current (or remote) machine if permissions allow utilizing the WinNT service provider and DirectoryServices.AccountManagement respectively.
PowershellMafia\PowerView.ps1,Get-NetComputer,Recon; Active Directory,This function utilizes adsisearcher to query the current AD context for current computer objects. Based off of Carlos Perezs Audit.psm1 script in Posh-SecMod (link below).
PowershellMafia\PowerView.ps1,Get-NetOU,Recon; Active Directory,Gets a list of all current OUs in a domain.
PowershellMafia\PowerView.ps1,Get-NetSite,Recon; Active Directory,Gets a list of all current sites in a domain.
PowershellMafia\PowerView.ps1,Get-NetSubnet,Recon; Active Directory,Gets a list of all current subnets in a domain.
PowershellMafia\PowerView.ps1,Get-NetGroup,Recon; Active Directory,Gets a list of all current groups in a domain or all the groups a given user/group object belongs to.
PowershellMafia\PowerView.ps1,Get-NetGroupMember,Recon; Active Directory,"This function users [ADSI] and LDAP to query the current AD context or trusted domain for users in a specified group. If no GroupName is specified it defaults to querying the ""Domain Admins"" group. This is a replacement for ""net group name /domain"""
PowershellMafia\PowerView.ps1,Get-NetLocalGroup,Recon,Gets a list of all current users in a specified local group or returns the names of all local groups with -ListGroups.
PowershellMafia\PowerView.ps1,Add-NetGroupUser,Active Directory,Adds a user to a domain group or a local group on the current (or remote) machine if permissions allow utilizing the WinNT service provider and DirectoryServices.AccountManagement respectively.
PowershellMafia\PowerView.ps1,Get-NetFileServer,Recon; Active Directory,Returns a list of all file servers extracted from user  homedirectory scriptpath and profilepath fields.
PowershellMafia\PowerView.ps1,Get-DFSshare,Recon; Active Directory,Returns a list of all fault-tolerant distributed file systems for a given domain.
PowershellMafia\PowerView.ps1,Get-NetShare,Recon; Active Directory,"This function will execute the NetShareEnum Win32API call to query a given host for open shares. This is a replacement for ""net share \\hostname"""
PowershellMafia\PowerView.ps1,Get-NetLoggedon,Recon; Active Directory,This function will execute the NetWkstaUserEnum Win32API call to query a given host for actively logged on users.
PowershellMafia\PowerView.ps1,Get-NetSession,Recon; Active Directory,This function will execute the NetSessionEnum Win32API call to query a given host for active sessions on the host.
PowershellMafia\PowerView.ps1,Get-NetRDPSession,Recon; Active Directory,This function will execute the WTSEnumerateSessionsEx and WTSQuerySessionInformation Win32API calls to query a given RDP remote service for active sessions and originating IPs. This is a replacement for qwinsta.
PowershellMafia\PowerView.ps1,Get-NetProcess,Recon; Active Directory,Gets a list of processes/owners on a remote machine.
PowershellMafia\PowerView.ps1,Get-UserEvent,Recon,Dump and parse security events relating to an account logon (ID 4624) or a TGT request event (ID 4768). Intended to be used and tested on Windows 2008 Domain Controllers.
PowershellMafia\PowerView.ps1,Get-ADObject,Active Directory,Takes a domain SID and returns the user group or computer object associated with it.
PowershellMafia\PowerView.ps1,Set-ADObject,Active Directory,Takes a SID name or SamAccountName to query for a specified domain object and then sets a specified PropertyName to a specified PropertyValue.
PowershellMafia\PowerView.ps1,Get-NetGPO,Recon; Active Directory,Gets a list of all current GPOs in a domain.
PowershellMafia\PowerView.ps1,Get-NetGPOGroup,Recon; Active Directory,"Returns all GPOs in a domain that set ""Restricted Groups"" or use groups.xml on on target machines."
PowershellMafia\PowerView.ps1,Find-GPOLocation,Recon; Active Directory,Takes a user/group name and optional domain and determines the computers in the domain the user/group has local admin (or RDP) rights to.
PowershellMafia\PowerView.ps1,Find-GPOComputerAdmin,Recon; Active Directory,Takes a computer (or GPO) object and determines what users/groups have administrative access over it.
PowershellMafia\PowerView.ps1,Get-DomainPolicy,Recon; Active Directory,Returns the default domain or DC policy for a given domain or domain controller.
PowershellMafia\PowerView.ps1,Invoke-UserHunter,Recon,Finds which machines users of a specified group are logged into.
PowershellMafia\PowerView.ps1,Invoke-StealthUserHunter,Recon,Finds which machines users of a specified group are logged into enumerating commonly used servers and checking just sessions for each.
PowershellMafia\PowerView.ps1,Invoke-ProcessHunter,Recon,Query the process lists of remote machines searching for processes with a specific name or owned by a specific user.
PowershellMafia\PowerView.ps1,Get-NetDomainTrust,Recon; Active Directory,Return all domain trusts for the current domain or a specified domain.
PowershellMafia\PowerView.ps1,Get-NetForestTrust,Recon; Active Directory,Return all trusts for the current forest.
PowershellMafia\PowerView.ps1,Find-ForeignUser,Recon; Active Directory,Enumerates users who are in groups outside of their principal domain. The -Recurse option will try to map all  transitive domain trust relationships and enumerate all  users who are in groups outside of their principal domain.
PowershellMafia\PowerView.ps1,Find-ForeignGroup,Recon; Active Directory,Enumerates all the members of a given domains groups and finds users that are not in the queried domain. The -Recurse flag will perform this enumeration for all eachable domain trusts.
PowershellMafia\PowerView.ps1,Invoke-MapDomainTrust,Recon; Active Directory,This function gets all trusts for the current domain and tries to get all trusts for each domain it finds.
PowershellMafia\PowerView.ps1,Invoke-ShareFinder,Recon,This function finds the local domain name for a host using Get-NetDomain queries the domain for all active machines with Get-NetComputer then for each server it lists of active shares with Get-NetShare. Non-standard shares can be filtered out with -Exclude* flags.
PowershellMafia\PowerView.ps1,Invoke-FileFinder,Recon,Finds sensitive files on the domain.
PowershellMafia\PowerView.ps1,Find-LocalAdminAccess,Recon,Finds machines on the local domain where the current user has local administrator access. Uses multithreading to speed up enumeration.
PowershellMafia\PowerView.ps1,Find-UserField,Recon; Active Directory,Searches user object fields for a given word (default *pass*). Default field being searched is description.
PowershellMafia\PowerView.ps1,Find-ComputerField,Recon; Active Directory,Searches computer object fields for a given word (default *pass*). Default field being searched is description.
PowershellMafia\PowerView.ps1,Get-ExploitableSystem,Recon,This module will query Active Directory for the hostname OS version and service pack level   for each computer account.  That information is then cross-referenced against a list of common Metasploit exploits that can be used during penetration testing.
PowershellMafia\PowerView.ps1,Invoke-EnumerateLocalAdmin,Recon,This function queries the domain for all active machines with Get-NetComputer then for each server it queries the local Administrators with Get-NetLocalGroup.
PowershellMafia\PowerUp.ps1,Get-ServiceUnquoted,Escalation,Returns the name and binary path for services with unquoted paths that also have a space in the name.
PowershellMafia\PowerUp.ps1,Get-ServiceFilePermission,Escalation,This function finds all services where the current user can  write to the associated binary or its arguments.  If the associated binary (or config file) is overwritten  privileges may be able to be escalated.
PowershellMafia\PowerUp.ps1,Get-ServicePermission,Escalation,This function enumerates all available services and tries to open the service for modification returning the service object if the process doesnt failed.
PowershellMafia\PowerUp.ps1,Get-ServiceDetail,Escalation,Returns detailed information about a specified service.
PowershellMafia\PowerUp.ps1,Invoke-ServiceAbuse,Escalation,This function stops a service modifies it to create a user starts  the service stops it modifies it to add the user to the specified group  stops it and then restores the original EXE path. It can also take a   custom -CMD argument to trigger a custom command instead of adding a user.
PowershellMafia\PowerUp.ps1,Write-ServiceBinary,Escalation,Takes a precompiled C# service executable and binary patches in a custom shell command or commands to add a local administrator.  It then writes the binary out to the specified location.  Domain users are only added to the specified LocalGroup.
PowershellMafia\PowerUp.ps1,Install-ServiceBinary,Escalation,Users Write-ServiceBinary to write a C# service that creates a local UserName  and adds it to specified LocalGroup or executes a custom command.  Domain users are only added to the specified LocalGroup.
PowershellMafia\PowerUp.ps1,Restore-ServiceBinary,Escalation,Copies in the backup executable to the original binary path for a service.
PowershellMafia\PowerUp.ps1,Find-DLLHijack,Escalation,Checks all loaded modules for each process and returns locations   where a loaded module does not exist in the executable base path.
PowershellMafia\PowerUp.ps1,Find-PathHijack,Escalation,Checks if the current %PATH% has any directories that are   writeable by the current user.
PowershellMafia\PowerUp.ps1,Write-HijackDll,Escalation,Writes out a self-deleting debug.bat file that executes a given command to  $env:Temp\debug.bat and writes out a hijackable .dll that launches the .bat.
PowershellMafia\PowerUp.ps1,Get-RegAlwaysInstallElevated,Escalation,Checks if the AlwaysInstallElevated registry key is set.  This meains that MSI files are always run with SYSTEM  level privileges.
PowershellMafia\PowerUp.ps1,Get-RegAutoLogon,Escalation,Checks for DefaultUserName/DefaultPassword in the Winlogin registry section   if the AutoAdminLogon key is set.
PowershellMafia\PowerUp.ps1,Get-VulnAutoRun,Escalation,Returns HKLM autoruns where the current user can modify  the binary/script (or its config) specified.
PowershellMafia\PowerUp.ps1,Get-VulnSchTask,Escalation,Returns scheduled tasks where the current user can modify  the script associated with the task action.
PowershellMafia\PowerUp.ps1,Get-UnattendedInstallFile,Escalation,Checks several locations for remaining unattended installation files   which may have deployment credentials.
PowershellMafia\PowerUp.ps1,Get-Webconfig,Escalation,This script will recover cleartext and encrypted connection strings from all web.config   files on the system.  Also it will decrypt them if needed.
PowershellMafia\PowerUp.ps1,Get-ApplicationHost,Escalation,This script will recover encrypted application pool and virtual directory passwords from the applicationHost.config on the system.
PowershellMafia\PowerUp.ps1,Write-UserAddMSI,Escalation,Writes out a precompiled MSI installer that prompts for a user/group addition. This function can be used to abuse Get-RegAlwaysInstallElevated.
PowershellMafia\PowerUp.ps1,Invoke-AllChecks,Escalation,Runs all functions that check for various Windows privilege escalation opportunities.
Nishang\Gupt-Backdoor.ps1,Gupt-Backdoor,Backdoor,Gupt is a backdoor in Nishang which could execute commands and scripts from specially crafted Wireless Network Names.
Nishang\Do-Exfiltration.ps1,Do-Exfiltration,Exfiltration,Use this script to exfiltrate data from a target.
Nishang\DNS-TXT-Pwnage.ps1,DNS-TXT-Pwnage,Backdoor,A backdoor capable of recieving commands and PowerShell scripts from DNS TXT queries.
Nishang\Get-Information.ps1,Get-Information,Recon,Nishang Payload which gathers juicy information from the target.
Nishang\Get-WLAN-Keys.ps1,Get-WLAN-Keys,Passwords,Nishang Payload which dumps keys for WLAN profiles.
Nishang\Invoke-PsUACme.ps1,Invoke-PsUACme,Escalation,Nishang script which uses known methods to bypass UAC.
Inveigh\Inveigh.ps1,Invoke-Inveigh,Recon; Passwords,Inveigh is a Windows PowerShell LLMNR/NBNS spoofer with challenge/response capture over HTTP(S)/SMB and NTLMv2 HTTP to SMB relay.
Inveigh\Inveigh.ps1,Get-Inveigh,Recon; Passwords,Get-Inveigh will display queued Inveigh output.
Inveigh\Inveigh.ps1,Get-InveghLog,Recon; Passwords,Get-InveighLog will get log.
Inveigh\Inveigh.ps1,Get-InveighNTLM,Recon; Passwords,Get-InveighNTLM will get all captured challenge/response hashes
Inveigh\Inveigh.ps1,Get-InveighNTLMv1,Recon; Passwords,Get-InveighNTLMv1 will get captured NTLMv1 challenge/response hashes.
Inveigh\Inveigh.ps1,Get-InveighNTLMv2,Recon; Passwords,Get-InveighNTLMv2 will get captured NTLMv1 challenge/response hashes.
Inveigh\Inveigh.ps1,Get-InveighStats,Recon; Passwords,Get-InveighStats displays NTLM stats
Inveigh\Inveigh.ps1,Stop-Inveigh,Recon; Passwords,Stop-InveighRelay will stop all running Inveigh functions.
Inveigh\Inveigh.ps1,Watch-Inveigh,Recon; Passwords,Watch-Inveigh will enabled real time console output. If using this function through a shell test to ensure that it doesnt hang the shell.
Powercat\Powercat.ps1,Powercat,Recon; Exfiltration; Backdoors,Netcat - The Powershell Version'

    Write-Verbose "Checking Attacks.."
    try {
        $attacks = ConvertFrom-CSV $attacksCSV
    }
    catch {
        Write-Error "Could not parse `$attackSource!"
        break
    }
    
  }

  process 
  {
	if ($term) 
	{
		Write-Verbose "Searching Attacks for $term.."
		$results = $attacks | Where-Object {$_.Description -like "*" + $term + "*" -or $_.Type -like "*" + $term + "*"}
		return $results
	}
	else
	{
		$message = @"
Welcome to PS>Attack!

Get-Attack will let you search through the built in attacks to find what you're looking for.

The search will look through the description of the attacks as well as some predefined
categories. Those categories are:

[*] Recon
[*] Passwords
[*] Exfiltration
[*] Code Execution
[*] File Tools
[*] Network

Get-Attack Examples:
[*] get-attack netcat
[*] get-attack passwords
[*] get-attack smb

Once you find an attack you want to try, you can find out more about the command with the
get-help command. You can also use the -Examples parameter with 'get-help' to view examples
of using most commands.

Get-Help Examples:
[*] get-help invoke-mimikatz
[*] get-help invoke-mimikatz -Examples
		
"@
		return $message
	}

  }
}