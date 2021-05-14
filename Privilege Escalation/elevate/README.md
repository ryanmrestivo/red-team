#elevate

**Run elevated commands from a regular Windows Command Prompt (no need to Run As AdministratEver)**

Ever wanted to quickly run a command that requires elevation without leaving your current Command Prompt window?  Jealous of your Linux friends who have sudo and su?  Well, this isn't anywhere near as good as either of those, but it's a step in the right direction!  Using one of the elevate batch commands will open a new *elevated* PowerShell window so you can quickly run a simple command or even a batch file or PowerShell (PS1) script.

Note that this will, however, activate the protected User Account Control (UAC) window to confirm the action, but pressing left-arrow followed by Enter will quickly confirm the action.

Run any of the batch files without arguments to simply open an elevated PowerShell window where arbitrary commands can be run.

Follow an elevate command with a file path<sup>1</sup> to an executable, batch file, PowerShell command or PowerShell script, or just an  arbitrary command (with arguments) and it will be run in an elevated PowerShell window.

##elevate.bat
Captures the results and outputs them to the initial command window.

##elevatep.bat
Pauses (does not capture any results) after completion.

##elevatex.bat
Keeps the PowerShell window open for more work after completion.

###Example:
`elevate dir C:\users\some_user_you_dont_normally_have_access_to`

<sup>1</sup> All file paths must be fully qualified since the PowerShell window opens as Administrator in the C:\Windows\System32 folder.  Check out [%~dp0 and other similar batch expansions](http://stackoverflow.com/questions/5034076/what-does-dp0-mean-and-how-does-it-work) to work with current path.
