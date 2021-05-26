#### Index:

- **Full Backup & Restoration Plan: (Example)**
- **Method 1: Windows Image backup**
- **Method 2: Separate Data backup**
- **Windows Installers:**
- **Complete Backup & Restoration Plan steps in order**
- **1. Initial Backup**
- **2. Scheduled Backups**
- **3. Maintain & Verify Backup health**
- **4. Recovery Process**

A full backup & restoration plan should also include the configuration of applications that were just installed by the Boxstarter script, such as importing bookmarks, setting themes, adding email accounts, etc.; and OS customizations that cannot be performed by Boxstarter, such as customizing the Taskbar, Start Menu, Desktop, etc.

[How to Use All of Windows 10’s Backup and Recovery Tools](https://www.howtogeek.com/220986/how-to-use-all-of-windows-10%E2%80%99s-backup-and-recovery-tools/)

[Which Files Should You Back Up On Your Windows PC?](https://www.howtogeek.com/howto/30173/what-files-should-you-backup-on-your-windows-pc/)

### Full Backup & Restoration Plan: (Example)
 
**Note:** It is good practice to choose a new login password after every fresh install, assume the old password has been comprimised.
 
- Windows Installer image: ISO, DVD, Bootable USB
- Windows Product Key, Windows Edition (Take a picture of Product Key stickers early on, since they tend to fade or get rubbed off. Even if that happens, they can still be recovered by 3rd-party software tools like ["The Magical Jelly Bean Keyfinder"](https://chocolatey.org/packages/keyfinder). Just make sure you use tools such as these [at your own risk.](https://www.virustotal.com/gui/file/35e605862069aeb3d8413cd512ae05f2831f21f1f496c9cdb90d1c3b8a3cfb97/detection))
   - Microsoft Office Product Key(s)
   - Other paid-for software Product Keys & Installers. E.g. Adobe Acrobat, Photoshop, etc.
- Connect to Network:
   - Wi-Fi password
   - Join Domain (if applicable)
- BoxstarterInstall-script.txt
   - Download & Install all Windows Updates
   - [Configure OS](https://boxstarter.org/WinConfig) (as much as possible with available Boxstarter tools)
   - Download & Install software via [Chocolatey](https://chocolatey.org/)
   - [Custom Chocolatey packages](https://chocolatey.org/docs/create-packages) (for rare software, or software not listed in the [Chocolatey community repository](https://chocolatey.org/packages))
- App configuration:
   - Internet Browsers
     - Bookmarks
     - Search Engines
     - Add-ons/Plugins/Extensions list
       - NoScript Whitelist
     - Themes: Dark mode
     - Customize: organize toolbars
     - Options
       - General -> Startup -> Restore previous session
       - General -> Tabs -> Ctrl+Tab cycles through tabs in recently used order (If turned On, Ctrl+Shift+Tab has a [different function](https://support.mozilla.org/en-US/kb/keyboard-shortcuts-perform-firefox-tasks-quickly?redirectlocale=en-US&redirectslug=Keyboard+shortcuts#w_windows-tabs))
       - Search -> Search Bar -> Add search bar in toolbar
       - Search -> Default Search Engine
       - Search -> One-Click Search Engines
   - Email Client
     - Email accounts list
     - Message Filters/Rules
   - KeePass
     - Plugins list
   - Notepad++/IDE of choice
     - Theme: (Settings -> Style Configurator -> Select theme: "Obsidian")
- Firmware Updates/Hardware Tweaks
   - Check if things like [TPM firmware](https://support.microsoft.com/en-us/help/4096377/windows-10-update-security-processor-tpm-firmware#firmwareupdates) or BIOS/UEFI firmware requires security updates (services like Windows Message Center, Windows Defender, or your 3rd-party Anti-Virus *should* automatically detect and notify you if necessary, but it is always wise to check for yourself).
- OS customizations:
   - Taskbar
   - Start Menu
   - Desktop
   - Windows 10: Personalize -> Colors -> Choose your default app mode -> Dark
- Data Files:
   - %UserProfile%\\\* (C:\Users\\*{username}*\\*)
   - %UserProfile%\Documents
   - %UserProfile%\Desktop
   - %UserProfile%\Downloads
   - %UserProfile%\Pictures
   - %AppData%\\\* (C:\Users\\*{username}*\AppData\Roaming\\\*)
   - %LocalAppData%\\\* (C:\Users\\*{username}*\AppData\Local\\\*)
   - %AllUsersProfile%\\\* (C:\ProgramData\\\*)
   - D:\\\*

**FYI:** Of course, you can always use the [built-in Windows backup tools](https://support.microsoft.com/en-us/help/17127/windows-back-up-restore) to create a full system image for a backup. 

Some reasons you might want to use this method instead is it is repeatable across practically any type of computer hardware. Say, if your motherboard & CPU had to be replaced, the hardware drivers saved in a **system image** backup might not work with the new hardware. Even if your 32-bit laptop crashed, but if it was backed-up using this method, you could restore your same environment to a 64-bit desktop with completely different hardware, and the correct x64/x86 versions of software installs will be handled automatically by [chocolatey](https://chocolatey.org/). The storage size of backups will be much smaller, and could be scanned for viruses before restoring data from them. With compression, you could store many more copies of backups than with system images.

The cons of this method are: #1 it takes more work to prepare, and more work to maintain. And #2: if you have any legacy applications that **REQUIRE** a certain version of an application to be functional, a *full system image* will restore that. However, keep in mind, Chocolatey has functionality to install specific versions of software, and you have the ability to create custom Chocolatey packages.

**Method 1: Windows Image backup**

Pros | Cons
--- | ---
| Easy & Simple to use. Can be as simple as 1-click to backup. | Large Backup file size. A system image will be close to the size of the used space on the disk. Backup drive should be at least 2x the size capacity of original drive. |
| Built-in Microsoft Windows tool. | Proprietary format. Must use the same tool to restore from backup. |
| Fast recovery time. | Slow backup time. |
|  | Impossible to access backup files individually from a proprietary archive without recovering them to main drive first. |
|  | Difficult or Impossible to recover to a different set of hardware. |
|  | Still requires a Windows Installer ISO/DVD/USB & Product Key backups for severe system failures. |
|  | Corrupted backup files may be impossible to recover any data from. |
|  | Viruses will remain intact in backup files, and will get restored when backup is restored. |

**Method 2: Separate Data backup**

Pros | Cons
--- | ---
| Can recover to any type of hardware. A 32-bit laptop backup can be recovered to a 64-bit desktop. | Boxstarter script must be updated any time new software is installed. |
| [Incremental & Differential](https://www.backup-utility.com/windows-10/incremental-and-differential-backup-windows-10-1128.html) [(2)](https://www.acronis.com/en-us/blog/posts/tips-tricks-better-business-backup-and-recovery-world-backup-day) backups become possible. | If software is not already in the [Chocolatey community repository](https://chocolatey.org/packages), you must [create your own Chocolatey package](https://chocolatey.org/docs/create-packages) if you wish to use that method to install. |
| Any type of file transfer tool can be used to perform backups, e.g. `xcopy`, `robocopy`, [`rsync`](https://chocolatey.org/packages/rsync), [RichCopy](https://social.technet.microsoft.com/Forums/windows/en-US/33971726-eeb7-4452-bebf-02ed6518743e/microsoft-richcopy), etc. | Initial backup takes more time to prepare. Especially if application configuration & customization is considered. |
| Backup files can be inspected & restored individually. | Automated backups are more manual & usually rely on custom scripts to copy, compress, encrypt, & rename backup files. |
| Tough-to-remove Viruses & Malware such as Rootkits and Zero-days get wiped out during recovery by nature of a fresh Windows re-install. | Restoration from backup takes more time & requires more steps due to fresh Windows re-install.
| Backup sizes are much smaller, taking less time to complete & allowing for more backup copies to be stored. |  |
| Backups can still be compressed using Window-native file formats (\*.zip) to save even more file space, & can be inspected while compressed. |  |
| Backup files can be virus-scanned without any special tools or methods. |  |

## Windows Installers:

Unfortunately most new computers do not come with a Windows installer disk anymore. The ISOs of disks are hosted by Microsoft:

[Download Windows 10 ISO](https://www.microsoft.com/en-in/software-download/windows10)

[Download Windows 8.1 ISO](https://www.microsoft.com/en-in/software-download/windows8ISO)

[Download Windows 7 ISO](https://www.microsoft.com/en-in/software-download/windows7)

Keeping a copy of the ISOs on your backup drive works fine, as long as you have more than one PC that can access it.

However it is always more wise to verify your backup solution ASAP, before needing to use it for recovery. Making a DVD or bootable USB drive from that ISO as-soon-as-possible allows you to test and verify you have a working physical installer, before a severe failure happens.

---

# Complete Backup & Restoration Plan steps in order

1. Initial Backup
2. Scheduled Backups
3. Maintain & Verify Backup health
4. Recovery Process

### Initial Backup:

1. **Backup Windows Product Key & Edition.** 
    - Take picture of Product Key sticker, then one or all of the following:
        - Copy picture to backup drive
        - Copy picture to a secure cloud storage location
        - Print out a physical copy of picture (keep physical copy with Windows Installer physical media)
    - If no Product Key sticker exists, you can use a tool like ["The Magical Jelly Bean Keyfinder"](https://chocolatey.org/packages/keyfinder) to retrieve it, but use [at your own risk.](https://www.virustotal.com/gui/file/35e605862069aeb3d8413cd512ae05f2831f21f1f496c9cdb90d1c3b8a3cfb97/detection)
    - Do the same for any other paid-for software you may have Product Keys for. If you purchased the software online, the Keys were probably emailed to you. If you bought a physical copy, the Keys are usually inside the original box/case.
        - Microsoft Office
        - Microsoft Visio
        - Microsoft Project
        - Adobe Acrobat
        - Adobe Photoshop
        - Adobe Illustrator
        - Adobe Premiere Pro
        - etc.
2. **Backup the correct Windows OS Installer on to physical media.** Purchase a copy of a Windows Installer disk, or:
    1. Download ISO from a trusted source.
        - Microsoft:
            - [Windows 10](https://www.microsoft.com/en-in/software-download/windows10)
            - [Windows 8.1](https://www.microsoft.com/en-in/software-download/windows8ISO)
            - [Windows 7](https://www.microsoft.com/en-in/software-download/windows7)
    2. Verify a hash of the ISO against official sources.
        - Hash/checksum tools:
            - [HashTab](https://chocolatey.org/packages/hashtab)
            - [checksum](https://chocolatey.org/packages/checksum)
            - [HashCheck Shell Extention](https://chocolatey.org/packages/hashcheck)
        - Official Sources? ...Unfortunately, it seems that the mammoth company *Microsoft* feels it's best [not to publish any.](https://social.technet.microsoft.com/Forums/en-US/fc3339ab-44c8-4655-993b-a16cce29e8e9/hashes-for-windows-10-isos) There are however, some [unofficial sources](https://www.heidoc.net/php/myvsdump.php) that do keep a record of released Microsoft ISOs, but remember: obtaining a checksum from an *untrusted 3rd-party* to verify that your OS installer disk has not been *corrupted or tampered with* kind of defeats the purpose of checking at all. ***Looking at you, Microsoft.***
    3. Write the ISO image to a DVD or USB drive.
        - Bootable USB drive creation tools:
            - [Rufus](https://chocolatey.org/packages/rufus)
            - [Etcher](https://chocolatey.org/packages/etcher)
        - CD/DVD writing tools:
            - [CDBurnerXP](https://chocolatey.org/packages/cdburnerxp)
            - [PowerISO](https://chocolatey.org/packages/poweriso)
            - [ImgBurn](https://chocolatey.org/packages/imgburn)
    4. Verify the new Windows Installer media was written correctly.
        - If the ISO image tool you're using to write the image to a disk has a "Verify" option, make sure it is enabled when you perform the write.
        - Use the "Verify Against Image File" option of [ImgBurn.](https://chocolatey.org/packages/imgburn)
        - Mount the ISO to a virtual drive, then use a tool such as [WinMerge](https://chocolatey.org/packages/winmerge) to compare the ISO file to the newly-written disk. [(SuperUser Answer)](https://superuser.com/questions/220082/how-to-validate-a-dvd-against-an-iso)
    5. Store the Installer media with the matching Product Key(s) in a secure location like a firesafe, etc.
3. **Set up your backup drive.**
    - Decide what your backup drive is:
        - A single, external drive?
        - A local RAID array, perhaps using the same drive controller as your main array?
        - A network share location, such as a NAS or SAN?
    - Decide if you want to maintain off-site/cold-storage backups. They can be:
        - Another physical location that your company owns, where backup drives must be rotated between the main "hot" site and the "cold" storage site.
        - A cloud storage service. Evaluate if you have or use any secret/sensitive/secure data, if they are a trustworthy service, and if they offer encryption. Many companies will promise that they encrypt their files, but offer no guarantees beyond the marketing materials used on their website to sell you on their service. Encrypting the backups yourself is always an option:
            - [TrueCrypt v7.1a](https://chocolatey.org/packages/truecrypt) - [Is TrueCrypt audited yet?](http://istruecryptauditedyet.com/)
            - [VeraCrypt](https://chocolatey.org/packages/veracrypt) (based on TrueCrypt v7.1a)
        - Although technically not "off-site", a cold-storage location such as a **firesafe** can still help protect your data in event of a natural disaster or fire. At least 2 different backup drives are needed, and they must be rotated on a schedule.
    - If you do decide to rotate backup drives, decide upon a *schedule* that is acceptable to you, and create a *checklist* to reliably rotate the backup drives from "hot" to "cold" (and vice versa).
4. **Backup your Boxstarter script.**
    - If you do not already have a Boxstarter script:
        1. Make a copy of [BoxstarterInstall-template.bat](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/blob/master/BoxstarterInstall-template.bat)
        2. Rename it to something like: *"BoxstarterInstall-MyProject.bat"*
        3. Edit the script's `:Parameters` to point to the Boxstarter script. You can choose a [gist address,](https://gist.github.com/) a local file, or simply a comma-separated list of [Chocolatey packages.](https://chocolatey.org/packages) By default, if you named the file *"BoxstarterInstall-MyProject.bat"* it will point to *"BoxstarterInstall-MyProject.txt"* as the Boxstarter script.
        4. Begin building your [Boxstarter script.](https://boxstarter.org/UsingBoxstarter) Use [BoxstarterInstall-NetworkingUtilities.txt](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/blob/master/BoxstarterInstall-NetworkingUtilities.txt) (used to set up a networking technician's laptop) as an example to help you get started.
            1. Download & Install all Windows Updates: [`Install-WindowsUpdate`](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/blob/master/Install-AllWindowsUpdates.txt)
            2. [Configure OS](https://boxstarter.org/WinConfig) 
            3. Use [Chocolatey commands](https://chocolatey.org/docs/commands-reference) like `cinst` and `cup` (alias for `choco install` and `choco upgrade`) to install software packages from the [community repository.](https://chocolatey.org/packages)
                - If you've already used Chocolatey to install most of your software, the `choco list -lo` command will list all of your installed packages.
            4. If the software you use is not listed in the community feed, you can either:
                - [Create a Chocolatey package](https://chocolatey.org/docs/create-packages) for it, and then possibly [upload it](https://chocolatey.org/docs/create-packages#push-your-package) to the community feed for others to enjoy.
                - Backup the software installer file (`*.exe`, `*.msi`, etc.) separately along with any necessary Product Key(s), then add an extra item in the recovery checklist to install them manually after the Boxstarter script has run.
        5. Once finished, save your script, then copy it to your backup drive.
    - If you do have a Boxstarter script:
        1. Ensure it is up-to-date with any recent software changes. Use `choco list -lo` to get a list of all of your currently installed packages.
        2. Copy it to your backup drive.
5. **Backup application configurations.** Some applications offer tools/config file options for enterprise deployments of their software. These can come in almost every flavor imaginable: special GPOs created in Group Policy for setting the application's behavior via AD; a config file you can create such as `config.json`, `config.ini`, `settings.xml`, etc. that the vanilla installer looks for when it gets run; using the application's own internal backup/restore functionality to export the settings; or sometimes even building a custom installation executable (`*.exe`, `*.msi`, etc.) by re-compiling the application from their source code. They range in difficulty from simple to quite hard, but the simplest method of all (not foolproof by any means) may be to just create a checklist for yourself. Doing so may even help you re-evaluate possible clutter you don't wish to blindly back-up!
    - Internet Browsers
        - Export Bookmarks
        - Add-ons/Plugins/Extensions list
            - Export NoScript Whitelist
        - Options Preferences
            - (Firefox) General -> Startup -> Restore previous session
            - (Firefox) General -> Tabs -> Ctrl+Tab cycles through tabs in recently used order (If turned On, Ctrl+Shift+Tab has a [different function](https://support.mozilla.org/en-US/kb/keyboard-shortcuts-perform-firefox-tasks-quickly?redirectlocale=en-US&redirectslug=Keyboard+shortcuts#w_windows-tabs))
            - (Firefox) Search -> Search Bar -> Add search bar in toolbar
            - (Firefox) Search -> Default Search Engine
            - (Firefox) Search -> One-Click Search Engines
        - [Firefox: Back-up Profile](https://support.mozilla.org/en-US/kb/back-and-restore-information-firefox-profiles) (contains all your personal data, such as bookmarks, passwords, and extensions)
   - Email Client
        - Email accounts login details, credentials list
        - Message Filters/Rules for Email accounts
        - [Thunderbird: Back-up Profile](https://windowsloop.com/backup-restore-thunderbird/) (contains not just all settings, but also **ALL of your emails**. Depending on inbox size & attachments, this folder can be several GB in size. Unless for some reason you still use POP3 instead of IMAP to connect to email accounts, it's not necessary to back-up these emails. With IMAP all the emails remain stored on the server. You can save a lot of time and backup storage space by only backing-up the credentials you use to log-in to the email server.)
   - KeePass
        - Plugins list
   - Notepad++/IDE of choice
        - Theme: (Settings -> Style Configurator -> Select theme: "Obsidian")
6. **Backup Firmware Updates/Hardware Tweaks**
   - If you ever had to update things like [TPM firmware](https://support.microsoft.com/en-us/help/4096377/windows-10-update-security-processor-tpm-firmware#firmwareupdates) or BIOS/UEFI firmware, it is wise to back those up as well. Not only does it help in case you decide to buy the same hardware again, it can also help you keep track of changes and updates you've made to your current hardware in case it begins developing erratic, inconsistent, or elusive problems that require you to either roll-back a firmware update, or trace back your firmware update history. 
7. **Backup OS customizations that could not be automated by Boxstarter**
    - Taskbar
        - Pinned Applications
        - Lock the Taskbar
    - Notification area
        - Select which icons appear on the taskbar
            - Always show all icons in the notification area
    - Start Menu customizations
        - Pinned Applications
            - Control Panel
            - This PC
            - User Profile shortcut
            - Documents
            - Downloads
            - Command Prompt
            - PowerShell
        - Choose which folders appear on Start
    - Windows 10: Personalize -> Colors -> Choose your default app mode -> Dark
        - Desktop -> Right-click -> Personalize
        - Run: `rundll32.exe shell32.dll,Control_RunDLL desk.cpl,,2`
    - Desktop icons
    - Power Settings (Open using any of the following:)
        - Run `powercfg.cpl`
        - Command Prompt `%Windir%\system32\control.exe /name Microsoft.PowerOptions`
        - `Win + X` or Right-click Start Menu:
            - Power Options
8. **Backup Data Files:**
    - %UserProfile%\\\* (C:\Users\\*{username}*\\*)
    - %UserProfile%\Documents
    - %UserProfile%\Desktop
    - %UserProfile%\Downloads
    - %UserProfile%\Pictures
    - %AppData%\\\* (C:\Users\\*{username}*\AppData\Roaming\\\*)
    - %LocalAppData%\\\* (C:\Users\\*{username}*\AppData\Local\\\*)
    - %AllUsersProfile%\\\* (C:\ProgramData\\\*)
    - Other Local drives:
        - D:\\\*
        - E:\\\*
        - etc.

---

### Scheduled Backups:

1. **Backup your Boxstarter script.**
    - Have you installed any new software? If so:
        - If the software was installed via [Chocolatey,](https://chocolatey.org/packages) add it to your Boxstarter script.
            - You can always use the `choco list -lo` command to get a list of all software packages you've installed.
        - If the software was not installed with Chocolatey, you can either:
                - [Create a Chocolatey package](https://chocolatey.org/docs/create-packages) for it, and then possibly [upload it](https://chocolatey.org/docs/create-packages#push-your-package) to the community feed for others to enjoy.
                - Backup the software installer file (`*.exe`, `*.msi`, etc.) separately along with any necessary Product Key(s), then add an extra item in the recovery checklist to install them manually after the Boxstarter script has run.
    - Have you discovered any fun new [Boxstarter](https://boxstarter.org/UsingBoxstarter) commands to [customize the OS?](https://boxstarter.org/WinConfig) if so, add them to the script.
2. **Backup application configurations.** Have you changed any app settings? Found any better ways to deploy certain applications? If so, update your lists & methods, then back them up.
    - Internet Browsers
        - Export Bookmarks
        - Add-ons/Plugins/Extensions list
            - Export NoScript Whitelist
        - Options Preferences
        - [Firefox: Back-up Profile](https://support.mozilla.org/en-US/kb/back-and-restore-information-firefox-profiles) (contains all your personal data, such as bookmarks, passwords, and extensions)
   - Email Client
        - Email accounts login details, credentials list
        - Message Filters/Rules for Email accounts
        - [Thunderbird: Back-up Profile](https://windowsloop.com/backup-restore-thunderbird/) 
   - KeePass
        - Plugins list
   - Notepad++/IDE of choice
        - Theme: (Settings -> Style Configurator -> Select theme: "Obsidian")
3. **Backup Firmware Updates/Hardware Tweaks**
   - Has anything changed? Any new firmware updates applied? Now may also be a good time to check if there are any updates with bugfixes, security fixes, or stability updates.
4. **Backup OS customizations that could not be automated by Boxstarter** Again, has anything changed? Update your lists, then copy them to the backup drive.
    - Taskbar
        - Pinned Applications
    - Start Menu customizations
        - Pinned Applications
        - Choose which folders appear on Start
    - Desktop icons
    - Power Settings
        - Run `powercfg.cpl`
        - Command Prompt `%Windir%\system32\control.exe /name Microsoft.PowerOptions`
        - `Win + X` or Right-click Start Menu:
            - Power Options
5. **Backup Data Files:**
    - %UserProfile%\\\* (C:\Users\\*{username}*\\*)
    - %UserProfile%\Documents
    - %UserProfile%\Desktop
    - %UserProfile%\Downloads
    - %UserProfile%\Pictures
    - %AppData%\\\* (C:\Users\\*{username}*\AppData\Roaming\\\*)
    - %LocalAppData%\\\* (C:\Users\\*{username}*\AppData\Local\\\*)
    - %AllUsersProfile%\\\* (C:\ProgramData\\\*)
    - Other Local drives:
        - D:\\\*
        - E:\\\*
        - etc.
6. **Organize Backup files:**
    - Compress backup
    - Rename & Re-organize backup archives
    - Encrypt backups

---

### Maintain & Verify Backup health:

- Virus scan
- Test recovery

---

### Recovery Process:

1. **Fresh OS install**
    1. Disconnect any attached network cables. That means all LAN/Ethernet/RJ45 cables. See the reasons why in the steps below. (Step 5.)
    2. Grab the OS installer media & Product Key, insert the media & restart the PC.
    3. If there's still an existing OS installation on the main HDD/SSD, and the BIOS/UEFI tries to boot into it instead of the OS installer disk, you'll have to change the boot order settings in the BIOS. [Which key to press](https://www.lifewire.com/bios-setup-utility-access-keys-for-popular-computer-systems-2624463) depends entirely on the manufacturer. Usually the BIOS splash screen will tell you which key, but with SSDs and new high speed systems, you have to be *extremely* quick. It may take several restarts before you get it, and with fast systems you may have to spam the key(s) before the splash screen even appears on-screen. Some newer UEFI systems no longer show a splash screen at all by default. Here are some common keys to  try:
        - Del
        - F8
        - F12
        - F2
        - Esc
        - F1
    4. You can use the installation media to try out some of the available recovery/repair options. If those don't work, or you wish to perform a fresh install regardless, continue on to the next step.
    5. Once you've booted into the OS installation media, choose the install wizard options that will format/wipe the main drive completely. There may be some newer, special install options that will try to preserve your data files and only overwrite/re-install the OS files, but it's up to you if you wish to try them. You shouldn't have to worry about that if you've been making backups & verifying them regularly as outlined in these methods above. Using special install options that don't completely wipe & re-format the drive introduces a greater risk of installation failure & OS corruption. A **completely** fresh install is actually the safest for the stability of the system.
        - Before or during the install, the wizard may give you an opportunity to enter your Product Key. I always recommend skipping this step if it allows you to. Entering a Product Key at this point may trigger calls to a Microsoft Product Activation server. Product Activation can & has failed even with legitamte keys. Right now we want to minimize any chance of errors or failure until *at least* we get the OS completely installed. You can always enter the Product Key later.
        - Same goes for any opportunity to join a network. I recommend you skip any wizard page that invites you to join a Wi-Fi network, connect to a LAN network, or "Download & Install updates now". Wait until you see a blank desktop screen before trying any of that.
        - You may be given the option to create your first User account and set a password either during the OS install, or immediately after. **It is recommended to set a different password for your user account than what it was set to before.** Even if the reason you are recovering a system is due to hardware failure, not a virus/malware outbreak, the potential for Zero-days that anti-virus programs still haven't discovered exists. You may restore a virus that you never even knew you had once you recover your data files. **Right now is the perfect opportunity to make hackers' lives as difficult as possible.**
    6. Once the OS installation is finished, remove your installation media and reboot the PC.
    7. The first boot will usually start with another wizard to set up all the remaining options for the OS. Most of these will be choices for privacy options. Obviously it's up to your personal preferences what you choose, but as a general rule it's recommended to disable as many of these options that collect your personal data, will "phone home" and distribute it back to the "mothership" at Microsoft for them to do whatever they want with it. Keep in mind the type of data Microsoft's new Privacy Policies allow them to collect includes collecting keystrokes (like a keylogger), and capturing screenshots of what you're looking at or working on.
    8. Once you've reached the desktop for the first time after the fresh install, go ahead and connect to the local network by entering Wi-Fi password or connecting a LAN/Ethernet cable.
    9. If applicable, join the computer to the domain.
2. **Install applications using Boxstarter script.**
    1. Copy the Boxstarter script from your backup drive to the computer.
    2. 
3. **Application Configuration.**
4. **Firmware Updates/Hardware Tweaks.** (if applicable)
5. **OS customizations.**
6. **Restore data files from backup.**

---

## How to Contribute:

Just like the rest of this repository, all contributions & corrections are welcome. 

**To make the changes yourself**, the natural Git way to do it is to [fork this repository](https://help.github.com/en/articles/fork-a-repo), make your changes, then [create a pull request](https://help.github.com/en/articles/creating-a-pull-request-from-a-fork) to have your changes pulled into this project for everyone to enjoy.

If you don't already have it installed, a git GUI such as **GitHub Desktop** can be installed [automatically via Chocolately](https://chocolatey.org/packages/github-desktop) or [manually on your own](https://desktop.github.com/).



**To request that somebody else make the changes**, just [submit an issue](https://github.com/Kerbalnut/Batch-Tools-SysAdmin/issues) to this repository and anyone who wants to can assign themselves to take care of it!
