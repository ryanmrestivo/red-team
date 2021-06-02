# Overview

This is a custom .NET assembly which will perform a number of situational awareness activities. There are a number of current featuresets:

* BASIC - Obtains information from the disk and registry.
* LDAP - Allows customised AD LDAP queries to be made.
* RESOLVEHOST - Performs DNS lookup queries.
* INDEXSEARCH - Searches the Windows Indexing Service for local files and e-mails (filename and content).
* PROXYCHECK - Displays the proxy server that will be used when attempting to access a provided URL.

I had no idea that GhostPack was being developed when I wrote this; we ended up releasing our tools at aroud the same time. The reality is that GhostPack is now far more feature rich. I am removing the PrivescCheck function because SharpUp covers all its functionality and more.

The key point about this is that it is all implemented in raw .NET - so no powershell.

It is configured and controlled by command line parameters, making it suitable for use with Beacon's ```execute-assembly``` directive.

## BASIC

### Overview

This obtains a number of pieces of information from the host. Be warned that there might be a LOT of output. It will display:

* All environment variables (API)
* The hostname, workgroup and Windows version number of the host (API)
* Word, Access, Excel, Publisher & Powerpoint Most Recently Used Documents for all versions installed (Registry)
* Word, Access, Excel, Publisher & Powerpoint Trusted Locations for all versions installed (Registry)
* Favourites (Bookmarks) and extracts the URL from the bookmark. Could be interesting to easily find sharepoint/confluence/wiki/self service payroll etc. (Disk)
* Mapped drives, including the drive letter, description and remote location (WMI)
* Installed applications, for all users and for the specific user only (Registry)
* Teamsites/tenants that OneDrive is configured to synchronise with across all users (Registry)

### Parameters

The verb 'basic' needs to be passed on the command line, followed by the specific check that is required. If the word 'all' is passed as the second parameter, every check will be performed.

| Check | Description | 
| ---- | ---- |
| env | Displays all of the environment variables. | 
| info | Displays the IP address of the host and the major/minor OS version identifier. | 
| mru | Searches various "most recently used" lists. These currently comprise the Run box history and the Office file and path MRU for all versions of Word, Excel, Powerpoint, Access, Publisher and Visio. It also displays the location of the special "Recent" folder. | 
| favourites | Displays the URLs stored in the favourites folder (which is basically the user's bookmarks). It currently does not support subfolders; I'll need to fix that. |
| mappeddrives | Displays the network mapped drives from the user's session. Useful for quickly finding central file shares and home directories. If it is mapped, it probably contains useful data. |
| installedapplications | Lists the applications that have been installed. This includes applications which have been installed as an admin (on the local machine) AND applications which have been installed by the current user. They are listed in different places in the registry. |
| onedrive | Displays information around OneDrive (including teamsites/tenants that are synchronised). |

Note that if 'all' is used, a 'proxycheck http://www.google.com' is automatically included. See the proxycheck section for details.

### Examples

Perform all basic checks: ```beacon> execute-assembly /tmp/Reconerator.exe``` or ```beacon> execute-assembly /tmp/Reconerator.exe basic all```

Perform mru enumeration only: ```beacon> execute-assembly /tmp/Reconerator.exe basic mru```

List the mapped drives only: ```beacon> execute-assembly /tmp/Reconerator.exe basic mappeddrives```

### OpSec

Reasonably safe. This is querying the system registry; it is unlikely to be monitored.

### Limitations (and further work)

* You can't pick and choose what you want - its all or nothing.
* Favourites do not recurse through directories
* Missing a load of stuff.

## LDAP

This allows you to perform an LDAP query. The easiest way of demonstrating this is by example.

### Examples 

This will show all users on the domain 'dc=stufus,dc=lan' with W2K8DC as a domain controller:

```beacon> execute-assembly /tmp/Reconerator.exe ldap "LDAP://W2K8DC/dc=stufus,dc=lan" "objectClass=user" 0```

This will show a maximum of 5 users on the domain 'dc=stufus,dc=lan' with W2K8DC as a domain controller:

```beacon> execute-assembly /tmp/Reconerator.exe ldap "LDAP://W2K8DC/dc=stufus,dc=lan" "objectClass=user" 5```

This will show all members of the domain admin group on the domain 'dc=stufus,dc=lan' with W2K8DC as a domain controller:

```beacon> execute-assembly /tmp/Reconerator.exe ldap "LDAP://W2K8DC/dc=stufus,dc=lan" "(&(objectClass=group)(cn=Domain Admins))" 0```

This will show all members of the domain admin or enterprise admin groups on the domain 'dc=stufus,dc=lan' with W2012DC as a domain controller:

```beacon> execute-assembly /tmp/Reconerator.exe ldap "LDAP://W2012DC/dc=stufus,dc=lan" "(&(objectClass=group)(|(cn=Enterprise Admins)(cn=Domain Admins)))" 0```

### OpSec

This will generate network traffic to the domain controller that you specify. For the avoidance of doubt, it uses LDAP (as opposed to RPC or similar).

### Limitations (and further work)

* Its a little untidy
* It won't display anything that isn't a .NET string (needs more parsing)
* Can't specify specific fields/attributes to show
* You need to work out the DC yourself (you can get that from the LOGONSERVER environment variable) and work out the DN yourself. I'll get round to retrieving that automatically at some point.
 
## RESOLVEHOST

### Overview

This performs a DNS query using the host's DNS server.

### Example

Resolve www.google.com:

```beacon> execute-assembly /tmp/Reconerator.exe resolvehost www.google.com```

### OpSec

This will generate a DNS query to the domain controller, but it is unlikely that anything will raise this as an alert due to the sheer volume of legitimate DNS requests.

## INDEXSEARCH

### Overview

This allows you to interact with Windows Search (formerly the Windows Indexing Service) which will allow you to search for interesting files and folders (and their contents) really quickly. E-Mails are usually indexed, but network folders are not, so it may not be perfect for searching users' home directories if they are stored remotely. However, it is very fast.

The interface to Windows Search is SQL-like; this implementation allows you to, in effect, specify the contents of the 'WHERE' clause. It is easiest to explain by example, but you will need to read MSDN if you want to know every possible criteria.

### Examples ###

Find everything that has been indexed which contains the word 'password' in it somewhere (i.e. searches the contents of files and e-mails):

```beacon> execute-assembly /tmp/Reconerator.exe indexsearch "CONTAINS('password')"```

Find everything that has been indexed which has the word 'stufus' in the path or filename somewhere:

```beacon> execute-assembly /tmp/Reconerator.exe indexsearch "System.ItemPathDisplay LIKE '%stufus%'"```

Find everything that has been indexed which has the word 'stufus' in the filename OR contains the word 'secret':

```beacon> execute-assembly /tmp/Reconerator.exe indexsearch "System.ItemName LIKE '%stufus%' OR CONTAINS('secret')"```

### OpSec

I'm not aware of anything that would raise this as suspicious.

## PROXYCHECK

### Overview

This returns the proxy server that would be used to visit a given URL. This is to cope with the situation where there may be different proxies for different URLs, or various complex exclusions in place. The URL of interest is passed as a parameter.

Note that if 'basic all' is specified (see above), it automatically includes a proxycheck to http://www.google.com, on the assumption that most organisations have one outbound proxy for all non-internal internet access.

### Examples

Display the proxy server which will be used when visiting www.google.com:

```beacon> execute-assembly /tmp/Reconerator.exe proxycheck www.google.com```

Display the proxy server which will be used when visiting https://www.mwrinfosecurity.com:

```beacon> execute-assembly /tmp/Reconerator.exe proxycheck https://www.mwrinfosecurity.com```

### OpSec

This is a local activity and a legitimate one; I'm not aware of anything that would raise it as suspicious.

## PRIVESCCHECK

### Overview

This will explore a number of privilege escalation vectors and report on whether they are possible or not. Currently, that number is 1.

Much like the BASIC module above, ```privesccheck all``` can be specified on the command line to attempt all checks, or a specific check can be specified if required.

### Parameters

The verb 'basic' needs to be passed on the command line, followed by the specific check that is required. If the word 'all' is passed as the second parameter, every check will be performed.

| Check | Description | 
| ---- | ---- | 
| alwaysinstallelevated | Determine whether the 'AlwaysInstallElevated' key is set to 1 or not. If set, this will run any MSI file as a local administrator. |

### OpSec

| Check | Notes | 
| ---- | ---- | 
| alwaysinstallelevated | This is a local registry query; it is unlikely that anything will flag this as malicious. |

### Examples

Attempt all privilege escalation checks:

```beacon> execute-assembly /tmp/Reconerator.exe privesccheck all```

Check whether the AlwaysInstallElevated registry key is set only:

```beacon> execute-assembly /tmp/Reconerator.exe privesccheck alwaysinstallelevated```

# Compiling

Compile this in Visual Studio 2019. It currently targets .NET v4. You can change that in the compilation preferences if you want to.
