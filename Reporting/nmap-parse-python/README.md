# nmap-parse
nmap-parse is  a python3 command line nmap XML parser. The default use of the tool accepts a list of nmap XML files and/or directories (containing nmap XML files). The '-r' flag can be used to recurse all sub-directories in search of additional nmap files.

## Main Features
* Ability to handle hundreds of nmap files simultaneously
* Automatically locate nmap files when provided with a directory (and -r recurse flag)
* Ability to filter nmap output by services, ports and/or hosts/CIDR ranges
* Show open ports matching filter
* Show unique ports for specified filter
* View single host details
* Ability to create new nessus policy for hosts/ports currently matching filter

## Prerequisites
All prerequisites can be installed by running the following command:

    pip3 install -r requirements.txt

This script requires python3 and the following modules:
* IPy, tabulate, bs4, cmd2, cmd2-submenu, colorama, requests, urllib3
  
## Quick Start
Launch interactive mode against a directory of nmap files:

`./nmap-parse.py -i /tmp/nmap-files-directory/`

Use the `help` command or the Wiki to see what commands are available

## Help Output
Help output for nmap-parse:

	> nmap-parse --help
	Usage: nmap-parse.py [options] [list of nmap xml files or directories containing xml files]

	Options:
	-h, --help            show this help message and exit
	-p PORTS, --port=PORTS
			    Optional port filter argument e.g. 80 or 80,443
	--service=SVCFILTER   Optional service filter argument e.g. http or ntp,http
			    (only used in conjunction with -s)
	-e CMD, --exec=CMD    Script or tool to run on each IP remaining after port
			    filter is applied. IP will be appended to end of
			    script command line
	-l, --iplist          Print plain list of matching IPs
	-a, --alive-hosts     Print plain list of all alive IPs
	-s, --service-list     Also print list of unique services with names
	-S, --host-summary    Show summary of scanned/alive hosts
	-v, --verbose         Verbose service list
	-u, --unique-ports     Print list of unique open ports
	-R, --raw             Only print raw output (no headers)
	-r, --recurse         Recurse subdirectories if directory provided for nmap
			    files
	-i, --interactive     Enter interactive shell
	-c COMBINE, --combine=COMBINE
			    Combine all input files into single nmap-parse
			    compatible xml file
	-V, --version         Print version info



## Default usage
By default the script outputs a summary of open ports for each host as well as a unique port list (accross all hosts).

The following example uses the nmap XML found at: https://nmap.org/book/output-formats-xml-output.html

**Command:**

	> nmap-parse /tmp/example.xml 
**Output:**

	Loading [1 of 1] /tmp/example.xml
	Successfully loaded 1 files

	IP and port list
	----------------

	74.207.244.221[scanme.nmap.org] [22, 80]

	Unique open port list
	---------------------
	TCP:
	----
	22,80

	UDP:
	----


	Combined:
	---------
	22,80

	Summary
	-------
	Total hosts: 1
	Alive hosts: 1
    
## Flags
Below are additional details regarding the flags available
* **-h (help)**
	* Displays help information
* **-l (list ips)**
	* Lists all IP addresses and ports if the host matches the specified port and/or service filter
* **-p / --ports [comma seperated ports]**
	*  Filters output for **-l and -e** to only include hosts which have one or more specified ports open
* **--service [comma seperated services**
	*  Filters output for **-l and -e** to only include hosts which have one or more specified services open (e.g. http/telnet/ftp)
* **-e / --exec**
	* Executes the specified command against each IP that matches filter in the format *'[exec_command] [ip_address]'*
* **-a / --alive-hosts**
	* Prints all IP addresses with a status of 'up' within the nmap XML files
* **-s / --service-list**
	* Prints list of all unique services identified as well as all ports the service was found on
	* Includes host information when used in conjuction with verbose flag '-v'
* **-S / --host-summary**
	* Prints total scanned and active hosts
* **-v / --verbose**
	* Includes relevant IP's within service list output **(-s / --service-list)**
* **-u / --unique-ports**
	* Prints the list of unique TCP and UDP ports. Also outputs a combined list containing all unique ports regardless of protocol
* **-R / --raw**
	* When set, no headers will be output, only the raw output will be printed to console
* **-i / --interactive**
	* Begin interactive session, see below 
* **-c / --combine**
	* Will combine all nmap XML files into one single nmap-parse compatible XML file
	* When dealing with tens/hundreds of nmap files, consolidation into a single file significantly improves nmap-parse's performance



# Interactive Mode
This is the most feature which allows the parsed nmap data to be queried and saved interactivly. All nmap files are parsed during initialisation therefore there is no delay between queries (waiting for the XML to parse) as there is with the command flags.

### Usage
    > nmap-parse /tmp/example.xml -i

### Console output
	Loading [1 of 1] /tmp/example.xml
	Successfully loaded 1 files
	-----------------------------------------------------------

	 /$$   /$$                                             
	| $$$ | $$                                             
	| $$$$| $$ /$$$$$$/$$$$   /$$$$$$   /$$$$$$            
	| $$ $$ $$| $$_  $$_  $$ |____  $$ /$$__  $$           
	| $$  $$$$| $$ \ $$ \ $$  /$$$$$$$| $$  \ $$           
	| $$\  $$$| $$ | $$ | $$ /$$__  $$| $$  | $$           
	| $$ \  $$| $$ | $$ | $$|  $$$$$$$| $$$$$$$/           
	|__/  \__/|__/ |__/ |__/ \_______/| $$____/            
					  | $$                 
					  | $$                 
					  |__/                 
	       /$$$$$$$                                        
	      | $$__  $$                                       
	      | $$  \ $$ /$$$$$$   /$$$$$$   /$$$$$$$  /$$$$$$ 
	      | $$$$$$$/|____  $$ /$$__  $$ /$$_____/ /$$__  $$
	      | $$____/  /$$$$$$$| $$  \__/|  $$$$$$ | $$$$$$$$
	      | $$      /$$__  $$| $$       \____  $$| $$_____/
	      | $$     |  $$$$$$$| $$       /$$$$$$$/|  $$$$$$$
	      |__/      \_______/|__/      |_______/  \_______/

	-----------------------------------------------------------

	Welcome to nmap parse! Type ? to list commands
	Tip: You can send output to clipboard using the redirect '>' operator without a filename

	np> help

	Documented commands (type help <topic>):

	Nmap Commands
	=============
	alive_hosts  list  ports  scanned_hosts  set  show  unset

	Other
	=====
	alias  exit  history  macro  pyscript  shell    
	edit   help  load     py     quit      shortcuts


	np> 

## Available Commands
### show options
This lists all available user configurable options:

	np> show options

	| Setting        | Type   | Value   | Description                                                                       |
	|----------------|--------|---------|-----------------------------------------------------------------------------------|
	| service_filter | string |         | Comma seperated list of services to show, e.g. "http,ntp"                         |
	| port_filter    | string |         | Comma seperated list of ports to show, e.g. "80,123"                              |
	| host_filter    | string |         | Comma seperated list of hosts/subnets to show, e.g. "127.0.0.1,10.0.0.0/24"       |
	| have_ports     | bool   | True    | When enabled, hosts with no open ports are excluded from output  [ True / False ] |
	| include_ports  | bool   | True    | Toggles whether ports are included in 'list/services' output  [ True / False ]    |
	| verbose        | bool   | False   | Shows verbose service information  [ True / False ]                               |
	| raw            | bool   | False   | Shows raw output (no headings)  [ True / False ]                                  |
  

### set [option] [value]
The set command is used to set an option. Tab completion is supported for service_filter and host_filter. The service_filter attempts to complete from the following files (in order):
* /usr/share/nmap/nmap-services
* /etc/services
* C:\windows\system32\drivers\etc\services

##### Usage:
	np> set host_filter 74.207.244.221 
	Set [host_filter] ==> '74.207.244.221'  

### unset [option]
The unset command is used to unset an option. 

##### Usage:
	np> unset host_filter 
	Set [host_filter] ==> ''  
        
### list
This works in the same way as the "**-l / --iplist**" flag and prints all hosts that match the specified filters. When service_filter or port_filter is set (and coloured output is supported) the output will colour the affected ports green.

##### Usage:

	np> list

	Matched IP list
	---------------
	74.207.244.221	tcp:[22,80]  udp:[]  

### alive_hosts
This works in the same way as the "**-a / --alive-hosts**" flag and prints all hosts with a status of 'up'.  

### ports
By default this will list all unique TCP and UDP ports as well as a combined list, e.g.:

	np> ports

	Unique open port list
	---------------------
	TCP:
	----
	22,80

	UDP:
	----


	Combined:
	---------
	22,80

### scanned_hosts
This lists all IP addresses that were part of the nmap scans regardless of their status

## Useful Tips
* Command output can be **saved to file** using the redirect operator '**>**' followed by a filename
* Command output can be copied to **clipboard** using the redirect operator '**>**' **WITHOUT** a filename
* Shell commands can still be executed by prefixing them with '**!**'

## Examples
Get all open ports for subnet 74.207.244.0/24

	np> set host_filter 74.207.244.0/24
	host_filter - was: 
	now: 74.207.244.0/24

	np> ports combined 

	Unique open port list (combined)
	--------------------------------

	22,80

Copy ports to clipboard (headings arent copied)

	np> ports combined >

List all systems with http running

	np> set service_filter http
	service_filter - was: 
	now: http

	np> list

	Output filtered by:
	-------------------
	Service filter: ['http']


	Matched IP list
	---------------

	74.207.244.221	tcp:[22,80]  udp:[]  

List all systems with http running (only IP):

	np> set include_ports false
	include_ports - was: True
	now: False

	np> list

	Output filtered by:
	-------------------
	Service filter: ['http']


	Matched IP list
	---------------

	74.207.244.221

Disable headings from console (this is the same output as the above command)

	np> set raw true
	raw - was: False
	now: True

	np> list
	74.207.244.221

