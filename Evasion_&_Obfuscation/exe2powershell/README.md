# exe2powershell
**exe2powershell - exe2bat reborn for modern Windows**

exe2bat reborn in exe2powershell for modern Windows

exe2powershell is used to convert any binary file (*.exe) to a BAT file.
The resulting BAT file contains only "echo" command and finally a powershell command to re-create the original binary file.

This kind of tool is usefull during pentesting when an auditor trigger a shell without any upload feature. With "echo" and "powershell" the auditor is able to "upload" any binary file on the targeted system.

initial author ninar1, based on riftor work, and modernized by ycam
exe2powershell - keep up to date : www.asafety.fr / synetis.com
         
Main code taken from Riftors "exe2hex".

Adapted for Windows BAT file by ninar1.

Modernized to newer Windows systems by Yann CAM (ycam - http://www.asafety.fr | http://www.synetis.com)

This version is modernized from exe2bat to work with modern Windows version.
exe2bat have limitation :
* Need "debug.exe" available on the target computer (16-bit application removed on Windows 7 x64 but available on Windows 7 x86)
* Limit input exe to 64kB

exe2powershell replace the need of "debug.exe" by a PowerShell command line available on all Windows since Windows 7 / 2008.
There is no more limitation in input exe size.

How to use :

```shell
C:\exe2powershell\bin>exe2powershell.exe
  ______          ___  _____                       _____ _          _ _
 |  ____|        |__ \|  __ \                     / ____| |        | | |
 | |__  __  _____   ) | |__) |____      _____ _ _| (___ | |__   ___| | |
 |  __| \ \/ / _ \ / /|  ___/ _ \ \ /\ / / _ \ '__\___ \| '_ \ / _ \ | |
 | |____ >  <  __// /_| |  | (_) \ V  V /  __/ |  ____) | | | |  __/ | |
 |______/_/\_\___|____|_|   \___/ \_/\_/ \___|_| |_____/|_| |_|\___|_|_|

        [ exe2bat reborn in exe2powershell for modern Windows ]
 [ initial author ninar1, based on riftor work, and modernized by ycam ]
 [ exe2powershell version 1.0 - keep up2date: asafety.fr / synetis.com ]

 [*] Usage : exe2powershell.exe inputfile outputfile
 [*] e.g.  : exe2powershell.exe nc.exe nc.bat
```

* Details (in french) :
    * https://www.asafety.fr/vuln-exploit-poc/windows-dos-powershell-upload-de-fichier-en-ligne-de-commande-one-liner/

Credits : Riftor, ninar1, BCK and ycam
