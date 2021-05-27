## METASPLOIT RESOURCE FILES

<blockquote>Resource scripts provides an easy way for us to automate repetitive tasks in Metasploit. Conceptually they're just like batch scripts, they contain a set of commands that are automatically and sequentially executed when you load the script in Metasploit. You can create a resource script by chaining together a series of Metasploit console commands or by directly embedding Ruby to do things like call APIs, interact with objects in the database, modules and iterate actions.</blockquote>

**This repository contains various resource files to assiste in exploitation or metasploit database related issues.**<br />
![pic](http://u.cubeupload.com/pedroubuntu10/metasploit1024x480.jpg)

<br />

### DISCLAMER
The resource scripts this repository contains serves as proof of concept (**POC**) of this [article](https://github.com/r00t-3xp10it/hacking-material-books/blob/master/metasploit-RC%5BERB%5D/metasploit_resource_files.md#metasploit-resource-files) published on resource files scripting. This repository is designed to demonstrate what resource files [ERB](https://www.offensive-security.com/metasploit-unleashed/custom-scripting/) can accomplish when automating tasks in msfconsole, and they are written to take advantage of multi-hosts-exploitation-scan tasks (manage large databases of hosts) from scanning the local lan for alive hosts, scan attackers input rhosts or scan wan networks in search of rhosts to exploit.


---

<br />

## Mosquito - Automating reconnaissance and brute force attacks

![mosquito_banner](http://u.cubeupload.com/pedroubuntu10/mosquitobanner.png)

<br />

### Index
[1] [Project History](https://github.com/r00t-3xp10it/resource_files#project-history)<br />
[2] [Framework Description](https://github.com/r00t-3xp10it/resource_files#framework-description)<br />
[3] [Framework Dictionary files](https://github.com/r00t-3xp10it/resource_files#framework-dictionary-files)<br />
[4] [Framework Dependencies](https://github.com/r00t-3xp10it/resource_files#framework-dependencies)<br />
[5] [Framework Limitations](https://github.com/r00t-3xp10it/resource_files#framework-limitations)<br />
[6] [Framework Download](https://github.com/r00t-3xp10it/resource_files#framework-download)<br />
[7] [Framework help-update-install-execution](https://github.com/r00t-3xp10it/resource_files#framework-help-update-install-execution)<br />
[8] [Project Referencies url's](https://github.com/r00t-3xp10it/resource_files#referencies)<br />
[9] [Project Acknowledgment](https://github.com/r00t-3xp10it/resource_files#project-acknowledgment)<br />
[10] [Project releases description](https://github.com/r00t-3xp10it/resource_files/releases)<br />

---
<br />

### Project History
Mosquito.sh (**BASH**) script was written for the purpose of automating the resource files (**ERB**) contained in this [repository](https://github.com/r00t-3xp10it/resource_files). Each resource file is written to allow users to run them in three different ways, from scan the Local Lan, scan user inputs (**RHOSTS/LHOSTS**) or randomly scan the **WAN** network for possible targets to add to metasploit database.

![mosquito_banner](https://i.imgur.com/Ibrvsjk.png)

**WARNING:** In 'Random search WAN for rhosts' its advice to use default **LIMMIT** values (4 to 5 minuts scan aprox.)

---
<br />

### Framework Description
Mosquito as first step uses nmap to seach-recon hosts information (or possible targets), then adds all the hosts found (with open ports) to metasploit database to be used in further recon, exploration or brute force jobs carried out later with msf.

![mosquito_banner](http://u.cubeupload.com/pedroubuntu10/mosquitorecon2.png)
![mosquito_banner](https://i.imgur.com/nbbhj5N.png)
![mosquito_banner](http://u.cubeupload.com/pedroubuntu10/mosquitorecon3.png)

Mosquito allow us to scan Local Lan or WAN networks using nmap (search-recon) and metasploit (recon-exploration-brute-force), but unlike msf the scans performed by nmap will use a fake UserAgent (IPhone/Safari) stealth scans (SYN ack) and Cloak scan(s) with decoys (-D decoy_ip,decoy_ip,ME) that makes forensic IDS analysis more dificult to identify the attack.

![mosquito_banner](http://u.cubeupload.com/pedroubuntu10/mosquitoIDSevasion.png)

**WARNING:** All this stealth technics will not prevent us from beeing caugth, so its advice to **not** use mosquito inside your home network (Local Lan), but insted find a public hotspot to use and abuse of mosquito framework.

    stealth technics used to evade IDS analysis
    -------------------------------------------
    nmap -sS [stealth scan using SYN ack]
    nmap -D 188.234.11.254,167.113.24.80,ME [Cloak a scan with decoys]
    nmap --script-args http.useragent="Apache-HttpClient/4.0.3 (java 1.5)" [spoof your UserAgent]

Mosquito also allow us to search-scan-exploit-brute-force multiple targets at the same time (multi-tasking).

![mosquito_multi_targets](https://i.imgur.com/r3BXpZa.png)
![mosquito_multi_targets](https://i.imgur.com/3noMbfS.png)

And each valid credentials found (brute-force) will spawn a shell session to remote host.

![mosquito_banner](http://u.cubeupload.com/pedroubuntu10/telnetbrutecreds.png)
![mosquito_banner](https://i.imgur.com/630IHhF.png)


[jump to top](https://github.com/r00t-3xp10it/resource_files#index)

---
<br />

### Framework Dictionary files
Initialy all resource scripts that this project contains are written to allow is users to input dictionary file absoluct path before the scan take place (own dictionary), but mosquito ships with is own set of dictionary files to assist in brute force tasks, and it does not allow is users to input another dictionary file when running mosquito framework.

nevertheless mosquito users can still improve the existing dictionary(s) by edit them before executing the framework.<br />
All dictionary files can be found in project working directory under: 'resource_files/bin/worldlists'.

![mosquito_banner](http://u.cubeupload.com/pedroubuntu10/dic.png)

[jump to top](https://github.com/r00t-3xp10it/resource_files#index)

---
<br />

### Framework Dependencies
|Dependencie|Function|Install|
|---|---|---|
|zenity|Bash script GUI interfaces|[zenity download](https://help.gnome.org/users/zenity/) * |
|nmap| WAN random search; recon | [nmap download](https://nmap.org/download.html) * |
|metasploit| msf database; recon; exploitation; brute force | [metasploit download](https://www.metasploit.com/download) |
|geoiplookup| hosts geo location | sudo apt-get install geoip-bin * |
|curl| hosts geo location | sudo apt-get install curl * |
|dig| ip address resolver | Linux native installed package ** |
|vulners.nse| CVE recon | mosquito native nse script * |
|freevulnsearch.nse| CVE recon | mosquito native nse script * |
|http-winrm.nse| http winrm recon | mosquito native nse script * |

    * ./mosquito.sh -i = to install all packages/scripts/modules
    ** Linux native installed package = no need to install it

**Hint:** All mosquito dependencies can be easy installed by runing: **sudo ./mosquito.sh -i**<br />
Adicionaly to the dependencies described above, diferent resource scripts requires diferent msf auxiliarys
or nmap nse adicional scripts installed, the -i switch in mosquito allow us to download/install all that extra modules fast and easy.

[jump to top](https://github.com/r00t-3xp10it/resource_files#index)

---
<br />

### Framework Limitations
**a)** mosquito only accepts ip addr inputs, not domain names<br />
**b)** brute forcing takes time, use 'CTRL+C' to skip current task(s)<br />
**c)** mosquito dicionarys can be found in resource_files/bin/worldlists<br />
**d)** finding valid credentials sometimes fails to spawn a shell<br />
**e)** multiple sessions open (msf) migth slowdown your pc<br />

**Hint:** This resource scripts requires that the msf database to be empty of hosts and services data. Thats the main reason why this scripts creates a new workspace named **'mosquito'** and stores all data inside that workspace while working, then the resource script deletes the **'mosquito'** workspace in the end of execution and leave *default database intact.

[jump to top](https://github.com/r00t-3xp10it/resource_files#index)

---
<br />

### Framework Download
```
[download]   git clone https://github.com/r00t-3xp10it/resource_files.git
[permitions] cd resource_files && find ./ -name "*.sh" -exec chmod +x {} \;
```

### Framework help-update-install-execution

    [help]    sudo ./mosquito.sh -h
![mosquito_banner](https://i.imgur.com/TjoLWrh.png)

    [update]  sudo ./mosquito.sh -u
![mosquito_banner](http://u.cubeupload.com/pedroubuntu10/mosquitoupdate.png)


[jump to top](https://github.com/r00t-3xp10it/resource_files#index)

---
<br />

### Referencies
[1] [Project home page](https://github.com/r00t-3xp10it/resource_files)<br />
[2] [Project wiki - dependencies](https://github.com/r00t-3xp10it/resource_files/wiki/Offensive-Resource_Files-%7C-Dependencies)<br />
[3] [offensive resource script - geo_location.rc](https://github.com/r00t-3xp10it/resource_files/wiki/Offensive-Resource_Files--%7C-Geo_Location)<br />
[4] [offensive resource script - post_exploitation.rc](https://github.com/r00t-3xp10it/resource_files/wiki/post_exploitation.rc-%7C-offensive-resource-script)<br />
[5] [hacking-material-books - metasploit_resource_files](https://github.com/r00t-3xp10it/hacking-material-books/blob/master/metasploit-RC%5BERB%5D/metasploit_resource_files.md#metasploit-resource-files)<br />

<br />

### Project Acknowledgment
@fyodor - nmap framework<br />
@Hhdm - metasploit framework<br />
@gmedian - vulners.nse script<br />
@SeanWarnock - http-winrm.nse script<br />
@MathiasGut - freevulnsearch.nse script<br />

[jump to top](https://github.com/r00t-3xp10it/resource_files#index)

<br />

## Suspicious Shell Activity redteam@2019
