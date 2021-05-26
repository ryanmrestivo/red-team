# Refactor in Progress

## Converted to Template Repository

This repo has grown bloated and curly, with too many other side projects growing in it, outside of its original scope. It has been changed to a `Template` Repository, so that new repos can be created from it with the same files structure, without being cloned or forked and carrying over all its messy history.

It will be parted out and the sub-components, issues, and readme documentation will be migrated to their own repositores.

- (Complete) ~~[Migrate TimeFunc PowerShell module to separate repo](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/milestone/2)~~ ► [TimeFunctions](https://github.com/Kerbalnut/TimeFunctions)
- (Complete) ~~[Migrate Documentation automation scripts to separate repo](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/milestone/3)~~ ► [Diagram-Automation](https://github.com/Kerbalnut/Diagram-Automation)
- (Complete) ~~[Migrate Chocolatey and Boxstarter automatic software install helpers](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/milestone/4)~~ ► [Windows-Fresh-Install-Helper-scripts](https://github.com/Kerbalnut/Windows-Fresh-Install-Helper-scripts)
- [Migrate Task Tracker PowerShell module to merge with StackWorkflow module](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/milestone/5)
- (Complete) ~~[Migrate PowerShell demo / practice / hello world module/scripts to separate repo](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/milestone/6)~~ ► [PowerShell-template](https://github.com/Kerbalnut/PowerShell-template)

The following is the original documentation below:

---

# Batch Functions, Templates, Tools, and Scripts

Common tasks that can be accomplished by *.bat files on Windows systems.

These features a lot of structure, organization, and emphasis on functions, or calling other scripts to do the rest.

All code or functions gained from other sources are referenced in place where used with links.

# Table of Contents:
- [Refactor in Progress](#refactor-in-progress)
	- [Converted to Template Repository](#converted-to-template-repository)
- [Batch Functions, Templates, Tools, and Scripts](#batch-functions-templates-tools-and-scripts)
- [Table of Contents:](#table-of-contents)
- [How to use:](#how-to-use)
	- [Quickly assemble new batch script (*.bat) automations:](#quickly-assemble-new-batch-script-bat-automations)
	- [Get started with some unique and useful tools:](#get-started-with-some-unique-and-useful-tools)
		- [File & Folder merge tool](#file--folder-merge-tool)
		- [Boxstarter Helper script](#boxstarter-helper-script)
	- [Folder Contents:](#folder-contents)
		- [Tools >](#tools-)
			- [Tools > CompareTo-Parent.bat](#tools--compareto-parentbat)
			- [Tools > Debug-TroubleshootBatchFile.bat](#tools--debug-troubleshootbatchfilebat)
			- [Tools > Get-Chocolatey.bat](#tools--get-chocolateybat)
			- [Tools > Install-Chocolatey.bat](#tools--install-chocolateybat)
			- [Tools > Install-XPChocolatey.bat](#tools--install-xpchocolateybat)
		- [functions >](#functions-)
			- [functions > Banner.cmd](#functions--bannercmd)
			- [functions > DateMath.cmd](#functions--datemathcmd)
			- [functions > matrix-timer.bat](#functions--matrix-timerbat)
			- [BoxstarterInstall-NetworkingUtilities.bat](#boxstarterinstall-networkingutilitiesbat)
			- [BoxstarterInstall-template.bat](#boxstarterinstall-templatebat)
			- [functions-template.bat](#functions-templatebat)
			- [Install-AllWindowsUpdates.bat](#install-allwindowsupdatesbat)
			- [Update-Java.bat](#update-javabat)
	- [Run As Administrator functions](#run-as-administrator-functions)
- [Work In Progress:](#work-in-progress)
	- [Stuff to Add:](#stuff-to-add)
- [How to contribute:](#how-to-contribute)

---

# How to use:

## Quickly assemble new batch script (*.bat) automations:

Need to write an 'automation.bat' script to fix a recurring problem or add some new functionality to a Windows system? Does the script need to be longer than 10 lines, or use more complicated functionality? Use **functions-template.bat** to get started quickly!

Copy **functions-template.bat** to the place you need it, delete the stuff you don't need, starting with everything in `:Parameters` and `:Main` and prune everything you don't need in `:ExternalFunctions` and `:DefineFunctions`. Use existing functions to accelerate development in :Main and store parameters in :Parameters.

## Get started with some unique and useful tools:

### File & Folder merge tool

**CompareTo-Parent.bat** (located in the **Tools** folder) is a great for merging text documents utilizing [KDiff3](https://chocolatey.org/packages/kdiff3). There are 2 ways to use this tool:

1. **Drag-n-Drop** compatible:
   1. Drag-and-drop the first file onto `CompareTo-Parent.bat`, and a cmd window will pop-up asking for the second file. 
   2. Drag-and-drop the second file onto the cmd window that just appeared. 
   3. Press enter.
2. Edit the file using your favorite text/script/IDE editor, and scroll down to the `:Parameters` tag. There are 2 main parameters that need to be modified:
   1. `_FILE_A` (will always be the first file to be updated)
   2. `_FILE_B`

>**Tips:**
>
> - Hold `Shift + Right Click` on a file, and "Copy as path" will appear in the right-click menu. (Windows Vista and higher)
> - Use the `%UserProfile%` [automatic variable](https://ss64.com/nt/syntax-variables.html) to fill in for "%SystemDrive%\Users\\{username}" E.g. "%UserProfile%\Documents\My File.txt" = "C:\Users\\\<Username>\Documents\My File.txt"

Use it to merge code or lists you may have edited on a flash drive at another computer, back with your source destination. 

E.g. If you created a flash drive "toolbox" with a collection of automation scripts like this, but ended up modifying them in order to fix some bugs, you'll probably want to update the source storage location with your new bugfixes. Use **CompareTo-Parent.bat** to do exactly that, or for frequent updates make a copy of the script and set the Parameters to the two files that need to be maintained as the same.

### [Boxstarter](https://boxstarter.org/) Helper script

Boxstarter is the perfect tool to set up a fresh-out-of-the-box computer with [software](https://chocolatey.org/) and [OS tweaks](https://boxstarter.org/WinConfig), customized to your exact needs. Great for deploying a fleet of computers quickly & automatically; or to help restore your computer after a serious hardware/software crash that requires re-installing the OS & restoring data files from a backup. To backup the installed software on your PC, all that's needed is a copy of your Boxstarter script on the backup drive.

Tools like **Update-Java.bat** and **Install-AllWindowsUpdates.bat** are simple examples of [Boxstarter's](https://boxstarter.org/UsingBoxstarter) power with their 2-line scripts, which are [*Update-Java.txt*](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/blob/master/Update-Java.txt) and [*Install-AllWindowsUpdates.txt*](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/blob/master/Install-AllWindowsUpdates.txt) respectively.

For a more detailed example, **BoxstarterInstall-NetworkingUtilities.bat** contains a list of [software & utilities](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/blob/master/BoxstarterInstall-NetworkingUtilities.txt) great for setting up a Networking Technician's on-site work laptop. This way, if the laptop is connected to an infected network, afterwards it can be completely wiped with a fresh install of Windows, have all of the software re-installed via the Boxstarter script, then data files can be restored via backup drive. Regular wiping also helps protect a client's network from any zero-day infections still unknown to you, possibly gained from being a well-traveled laptop.

A full backup & restoration plan should also include the configuration of applications that were just installed by the Boxstarter script, such as importing bookmarks, setting themes, adding email accounts, etc.; and OS customizations that cannot be performed by Boxstarter, such as customizing the Taskbar, Start Menu, Desktop, etc. For a full Windows Backup & Restoration plan example, see the [Backup and Restore](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/tree/master/Backup%20and%20Restore) folder.

All 4 of these scripts are *Boxstarter helper scripts*; they are practically identical. The only difference is the parameters at the very top of the scripts have been changed: (Use **Tools/CompareTo-Parent.bat** to see for yourself!)

- **BoxstarterInstall-template.bat**
- **BoxstarterInstall-NetworkingUtilities.bat**
- **Install-AllWindowsUpdates.bat**
- **Update-Java.bat**

To create your own, make a copy of **BoxstarterInstall-template.bat** and rename it to fit your project. Edit the file using your favorite text/script/IDE editor, and scroll down to the `:Parameters` tag. There are 2 main parameters that need to be modified:

1. Source of the Boxstarter script to run. Choose either:
   1. [Github-hosted Gist script](https://gist.github.com/)
   2. Path to a locally-accessible .txt script. By default, if you name your your new project script **BoxstarterInstall-MyNewProject.bat** then `%~dpn0.txt` will point to a file named **BoxstarterInstall-MyNewProject.txt** stored in the same folder.
   3. A comma-seperated list of [Chocolatey packages](https://chocolatey.org/packages), e.g. `adobereader,firefox,googlechrome`
2. A multi-line variable for the **Instructions text**. Batch script cannot handle mult-line string variables, so it much be appended to a temporary `_INSTRUCTIONS_FILE`.

---

## Folder Contents:

### Tools >

#### Tools > CompareTo-Parent.bat

Use [Kdiff3](https://chocolatey.org/packages/kdiff3) to merge the changes between 2 (text) files or folders. Supports drag-and-drop of files one-at-a-time.

#### Tools > Debug-TroubleshootBatchFile.bat

Used to troubleshoot batch files that close immediately on error, by keeping last errors open in command prompt for review. Supports drag-and-drop.

#### Tools > Get-Chocolatey.bat

**Recommended** tool to install Chocolatey. `Install-Chocolatey.bat` and `Install-XPChocolatey.bat` need some work.

#### Tools > Install-Chocolatey.bat

#### Tools > Install-XPChocolatey.bat

Can be used to install Chocolatey on Windows XP. Only used once, so it is recommended to double-check each step & review before running.

### functions >

#### functions > Banner.cmd

Displays a text banner across command prompt. Up to 14 characters for Windows 8 and below command prompt width, or up to 21 characters for Windows 10 command prompt width, or PowerShell prompt width on any Windows version.

Compatible characters:

- 0-9
- Hyphen "-"
- Period "."
- Comma ","
- At "@"
- A-Z (Caps only)
- Space " "

#### functions > DateMath.cmd

Add or subtract dates 

#### functions > matrix-timer.bat

Why make a WAIT boring, when you can make it fun? Show some flair the next time you need to add make the user 'wait' for something, or just for flair.

#### BoxstarterInstall-NetworkingUtilities.bat

Uses Boxstarter and Chocolatey to automatically install a suite of software packages, in this case networking utilities for a technician's laptop. 

See `BoxstarterInstall-NetworkingUtilities.txt` for full list of commands.

#### BoxstarterInstall-template.bat

Uses Boxstarter and Chocolatey to automatically install a suite of software packages. Define software packages using [Boxstarter script](https://boxstarter.org/UsingBoxstarter) and Chocolatey commands, or simply a comma-separated list of [chocolatey packages](https://chocolatey.org/packages). Boxstarter scripts can be either a .txt file (preferably with the same name as the script), or uploaded to [gist.github.com](https://gist.github.com/) and referenced via Raw URL.

#### functions-template.bat

A framework for creating organized batch scripts. Also serves as a repository for all internal and external functions, and examples of using them.

Index of external functions: 

1. choco.exe "%_CHOCO_INSTALLED%"
2. PSCP.EXE "%_PSCP_EXE%"
3. kdiff3.exe "%_KDIFF_EXE%"
4. gswin64c.exe (Ghostscript) "%_GSWIN64C_INSTALLED%"
5. CompareTo-Parent.bat "%_COMPARE_FUNC%"
6. Banner.cmd "%_BANNER_FUNC%"
7. fossil.exe "%_FOSSIL_EXE%"

Index of Main:

1. Phase 1: Evaluate Parameters
2. Phase 2: Test :GetIfPathIsDriveRoot
3. Phase 3: Test :GetWindowsVersion
4. Phase 4: Test Banner.cmd (external function)
5. Phase 5: Test :GetTerminalWidth
6. Phase 6: Test :CheckLink
7. Phase 7: Test :GetDate, :ConvertTimeToSeconds, and :ConvertSecondsToTime
8. Phase 8: Test :InitLog and :InitLogOriginal
9. Phase 9: Test :CreateShortcut, :CreateSymbolicLink, and :CreateSymbolicDirLink

Index of functions: 

1. :SampleFunction
2. :DisplayHelp
3. :Wait
4. :ElevateMe
5. :GetAdmin *
6. :Download *
7. :PSDownload *
8. :AddToPATH
9. :RemoveFromPATH *
10. :GetTerminalWidth *
11. :StrLen *
12. :GenerateBlankSpace *
13. :FormatTextLine *
14. :CheckLink
15. :GetWindowsVersion
16. :GetIfPathIsDriveRoot
17. :CreateShortcut *
18. :CreateSymbolicLink *
19. :CreateSymbolicDirLink *
20. :GetDate
21. :ConvertTimeToSeconds
22. :ConvertSecondsToTime
23. :InitLogOriginal
24. :InitLog
25. :SplashLogoKdiff
26. :SplashLogoMerge
27. :SplashLogoMergeComplete

`*` = needs further testing.

#### Install-AllWindowsUpdates.bat

Uses Boxstarter script to download & install all Windows updates. Persistent through reboots. Recommend closing all applications before running.

#### Update-Java.bat

Uses Boxstarter to update Java Runtime Environment.

---

## Run As Administrator functions

There are 2 different Run-As-Administrator functions in use. **#1** uses a `cacls.exe` method to check for permissions. **#2** uses a `FSUTIL` method to check.  Both use `UAC.ShellExecute` command called from a .vbs script to elevate.

**#1** [BatchGotAdmin International-Fix Code](https://sites.google.com/site/eneerge/home/BatchGotAdmin) does not forward any parameters to the elevated script. Always elevates a script when the **:RunAsAdministrator** block is the first code execution added to the top. 

- functions > RunAsAdministrator > BatchGotAdmin International-Fix Code.bat
- Tools > Get-Chocolatey.bat
- Tools > Install-Chocolatey.bat
- Tools > Install-XPChocolatey.bat
- BoxstarterInstall-NetworkingUtilities.bat
- BoxstarterInstall-template.bat
- Install-AllWindowsUpdates.bat
- Update-Java.bat

**#2** [SS64 Run with elevated permissions script (ElevateMe.vbs)](http://ss64.com/vb/syntax-elevate.html) can accept parameters and pass them along to the elevated script. Includes structure to prompt user for elevation, automatically elevate always, or skip elevation always. 

- functions > RunAsAdministrator > SS64 Run with elevated permissions (ElevateMe.vbs).bat
- Tools > CompareTo-Parent.bat
- Tools > Debug-TroubleshootBatchFile.bat
- functions-template.bat

---

# Work In Progress:

1. `functions-template.bat` needs some functions tested, highlighted by an asterisk `*`
2. `Get-Chocolatey.bat` and `Install-Chocolatey.bat` need to be unified.
3. `Install-XPChocolatey.bat` needs some work & more testing, if anybody is willing to put in the work. This will likely just become legacy code, unless anybody really needs chocolatey on Windows XP to deploy a fleet of XP machines.
4. `BoxstarterInstall-template.bat` can be modified to have the reboot prompt overridden to yes or no via variable.
5. `BoxstarterInstall-template.bat` can be modified to accept command-line arguments, so other scripts can call it to install chocolatey packages.
6. **Run As Administrator function > BatchGotAdmin International-Fix Code** can be modified to pass parameters.

Most .txt file notes and short .bat files come from a single use case. They are planned to be updated, tested, and organized under the common theme started in `functions-template.bat` as the next use case arises. That way each function evolves through necessity.

## Stuff to Add:

- Remote Access folder
- Backup and Restore folder
- File in Use folder
- Transferring Files folder
- System Clean-up folder (virus removal & system tune-up utilities)
- MS Exchange folder
- MS Outlook folder
- Find-and-Replace function for all files within a folder and subdirectories. Batch and PowerShell versions

---

# How to contribute:

All contributions are welcome. This section will be updated further, but currently standard GitHub policies like Pull Requests and Issues are the way to do it.

[Fork a Repo](https://help.github.com/en/articles/fork-a-repo)

---
