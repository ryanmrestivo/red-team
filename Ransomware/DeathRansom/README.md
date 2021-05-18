# DeathRansom

## What is a ransomware?

A ransomware is malware that encrypts all your files and shows a ransom request, which tells you to pay a set amount, usually in bitcoins (BTC), in a set time to decrypt your files, or he will delete your files.

## How it works?

First, the script checks if it's in a sandbox, debugger, vm, etc, and try bypass it.                                                       
It then encrypts all files starting with the defined directory.                                                                          
Then, downloads the ransom request script, disable cmd, taskmanager and the registry tools. And starts the counter to delete the files.

## How to use?

Generate the keys, upload the public key to pastebin, copy the raw link, and change the site on the line 7 in deathransom.py  ``` python generate_key.py ```                                                                                                                     
Transform time_script.py and main.py(Located at Ransom Request) into exe.                                                      
Transform the time_script into exe using pyinstaller in python2 version typing ``` pyinstaller --onefile --windowed <FILE> ```                                                                                                                                    
To transform the main of ransom request we will use the pyinstaller in the python3 version ``` pyinstaller --onefile --windowed main.py ```                                                                                                                                    
Then uploads the scripts to any file hosting service and change the links on the line 28 and 31 in deathransom.py                        
So just transform deathransom.py into exe using pyinstaller in python2 version and be happy :D

## Bypass Technics

- ### Anti-Disassembly
Creates several variables to try to make disassembly difficult.

- ### Anti-Debugger
Checks if a debugger is active using the ctypes function: windll.kernel32.IsDebuggerPresent()

- ### Anti-Vm
Checks if the machine's mac is the same as the standard vms mac.

- ### Anti-Sandbox
                                                                                                                                         
- Sleep-Acceleration

Some sandboxes speed up sleep, this function checks if nothing out of the ordinary has occurred.

- Sandbox in Process

Checks if have any sandbox in running processes

- Display-Prompt

Shows a message, if the user interact with the pop up, the malware will be executed.

- Idle-Time

Sleeps for a while and proceed. Some sandboxes wait for a while and stop running, that tries to bypass this.

- Check-Click

If the user does not click the number of times necessary the malware not will be executed.

- Check-Cursor-Pos

If the user not move the mouse in a seted time the malware not be executed.
