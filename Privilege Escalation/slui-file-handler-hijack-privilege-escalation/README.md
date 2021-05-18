# Slui File Handler Hijack LPE

| Exploit Information |                                   |
|:------------------- |:--------------------------------- |
| Date                | 15.01.2018                        |
| Patched             | Windows 10 20H1 (19041)           |
| exploit-db          | [44830](https://www.exploit-db.com/exploits/44830/) |
| Tested on           | Windows 8-10, x86/x64 independent |

## Description

slui.exe is an auto-elevated binary that is vulnerable to file handler hijacking.

Read access to HKCU\Software\Classes\exefile\shell\open is performed upon execution. Due to the registry key being accessible from user mode, an arbitrary executable file can be injected.

This exploit is generally independent from programming language and bitness, as no DLL injection or privileged file copy is needed. In addition, if default system binaries suffice, file drops can be avoided altogether.

## Expected Result

When everything worked correctly, a cmd.exe should be spawned with high IL.

## Downloads

Compiled binaries:

[![](http://bytecode77.com/public/fileicons/zip.png) SluiFileHandlerHijackLPE.zip](https://bytecode77.com/downloads/SluiFileHandlerHijackLPE.zip)
(**ZIP Password:** bytecode77)

## Project Page

[![](https://bytecode77.com/public/favicon16.png) bytecode77.com/slui-file-handler-hijack-privilege-escalation](https://bytecode77.com/slui-file-handler-hijack-privilege-escalation)