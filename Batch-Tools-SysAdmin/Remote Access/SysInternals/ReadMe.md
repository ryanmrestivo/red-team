
# Sysinternals Notes

### Psexec notes

`-d` Don't wait for process to terminate, non-interactive

`-u [<domain>\]<username>`

`-p <password>`

`-i <session>` Use `tasklist` command to get session number to interact with

`-accepteula` This flag suppresses the display of the license dialog.

`-h` If the target system is Vista or higher, has the process run with the account's elevated token, if available.

`-c` Copy the specified program to the remote system for execution. If you omit this option the application must be in the system path on the remote system.

### Extra SysInternals commands:

http://www.howtogeek.com/school/sysinternals-pro/lesson8/all/

---

# Running commands through an interactive shell on a remote machine

`psinfo \\HOSTNAME` Get info on remote system

`psexec \\HOSTNAME tasklist` Use the `tasklist` tool to get Session Name and Session# in a list of processes running on the remote machine.

Session Name:

- Services = SYSTEM-run background processes
- Console = Physical screen terminal user
- RDP-Tcp#0 = Remote desktop users

Session# = value for `psexec -i` for where you want process to start:

- Services = 0 *(not recommended to mess around with the system's session)*
- Console = 1
- etc.

`psexec \\HOSTNAME ipconfig /all` Display networking information about the remote system

`psexec \\HOSTNAME cmd.exe` Enter a interactive command prompt with remote machine.

`psexec \\HOSTNAME -u domain\johndoe -p ******** cmd.exe` Enter a interactive command prompt with remote machine using alternate credentials

---

**Commands to run once connected to remote interactive command prompt:**

`hostname` Verify you're executing commands from the remote machine.

`nslookup myip.opendns.com. resolver1.opendns.com` Retrieve public IP address, useful if connecting to a remote site through VPN tunnel.

`mkdir "C:\Users\janedoe\Desktop\Hikvision Plugin"` Create folder on remote machine.

`xcopy \\SERVER_NAME\Applications\USSCWebComponents.exe "C:\Users\janedoe\Desktop\Hikvision Plugin"` Copy file from a remote machine accessible on the network to the newly created folder.

`xcopy \\SERVER_NAME\Applications\USSCWebComponents(1).exe "C:\Users\janedoe\Desktop\Hikvision Plugin"` Copy second file from a remote machine accessible on the network to the newly created folder.

`xcopy \\SERVER_NAME\Applications\USSCWebComponents*.exe "C:\Users\janedoe\Desktop\Hikvision Plugin"` Alternatively, xcopy supports wildcards `*` so instead of the two above commands, you could use this one command.

`dir "C:\Users\janedoe\Desktop\Hikvision Plugin"` Verify that the files were written to the folder.

`systeminfo | find "System Boot Time:"` Get system up-time

`exit` Exit interactive shell

---

**Commands to run once you've disconnected:**

`psexec \\HOSTNAME -d -i 1 -accepteula -h -u domain\johndoe -p ******** "C:\Users\janedoe\Desktop\Hikvision Plugin\USSCWebComponents.exe"` Execute the newly copied program on the remote machine with Elevated permissions (`-h`), in the user's desktop session (`-i 1`) and do not wait for command to complete before resuming our command line (`-d`)

---

# Get users logged-in to the remote machine

`-c` Copy the specified program to the remote system for execution. If you omit this option the application must be in the system path on the remote system.

`psexec \\HOSTNAME -c %ChocolateyInstall%\lib\sysinternals\tools\logonsessions.exe -accepteula`

`psexec \\HOSTNAME -c logonsessions.exe -accepteula`

---

`WMIC /NODE: "workstation_name" COMPUTERSYSTEM GET USERNAME` Get username currently logged into "workstation_name"

---

`psloggedon.exe -l` Get users logged-on to the local machine.

`psloggedon.exe \\HOSTNAME` Get users logged-on to remote machine.

---

`psexec \\HOSTNAME tasklist`

---

# Other commands

`psexec \\HOSTNAME -d -i 2 -accepteula -u domain\johndoe -p ******** winver` Get Windows version of remote machine. Weird error: this command requires username and password, otherwise window will open but content won't load. 

---

# PowerShell & Remoting

## Get PowerShell version on remote machine:

`psexec \\HOSTNAME -accepteula powershell.exe -NoProfile -Command $PSVersionTable.PSVersion`

`psexec \\HOSTNAME -accepteula -h -u domain\johndoe powershell.exe -NoProfile -Command $PSVersionTable.PSVersion`

## Get interactive PowerShell prompt on remote machine:

`-h` If the target system is Vista or higher, has the process run with the account's elevated token, if available.

`psexec \\HOSTNAME -d -i 3 -accepteula -u domain\johndoe -p ******** powershell.exe`

`psexec \\HOSTNAME -d -i 3 -accepteula -h -u domain\johndoe -p ******** powershell.exe`

