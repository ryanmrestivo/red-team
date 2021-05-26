
*This document applies to Windows 2000/NT and above*

# Company-essential Data Rescue and Backup from Legacy Systems

There are 3 options when it comes to ensuring business critical data remains intact during a proceedure to either backup data from a legacy machine, or migrate that data into a modern system. The 3 different options are as follows:

 - **Backup important files and data to an external hard drive.**
 - **Image the entire drive to an external disk for migration to a modern system.**
 - **Salvage the old PC, and image the entire disk to a backup drive to be used in a modern system.**

These options are listed from highest risk and lowest cost, to lowest risk/highest cost. The decision of which to use depends of the importance of the data to be saved (Useful, Important, Essential, or Mission-Critical) and the budget range available, a decision best left up to the supervisor of the project.

Due to the inherit risk of years-old mechanical magnetic storage subsystems and aging electrical hardware, all 3 options include a cooldown/cleanup period before any operation is started. This increases the stability of the system and reduces the risk of a failed operation. This process includes:

 - **Two-hour cooldown period for all hardware and power supplies**
 - **Case opening/disassembly (if applicable) to vent dust and dirt particles**
 - **Dry-air dusting to remove as many particulates as possible**

## 1. Backup important files and data to an external hard drive.

*Risk of failure:* High

*Cost:* Low

*Necessary Equipment:* 

 - External Hard Drive (with 1.5x necessary storage space) = ~$85

*Procedure:*

 1. **Cooldown and cleanout period (as listed above).**
 2. **Identify list of all important files.**
	 > Because this operation does not image the entire hard drive, the owner and operators of the machine must be present to identify and list out which files and directories contain important information to back up.
 3. **Attach, format, and verify External Drive stability.**
 4. **Copy Operation:**
	 - *Option A:* **Multi-Threaded File Copy:** *RichCopy 4.0 Microsoft*
	 - *Option B:* **Restartable/Repeatable File Copy:** *PowerShell / RoboCopy / RoboMirror*
 5. **Verify Data Integrity (optional):** *checksum / hashes*


## 2. Image the entire drive to an external disk for migration into a modern system.

*Risk of failure:* High

*Cost:* High

*Necessary Equipment:* 

 - External Hard Drive (with 1.5x necessary storage space) = ~$85
 - Modern PC to Migrate data to (Windows or Linux) = $450-$300

*Procedure:*

 1. **Cooldown and cleanout period (as listed above).**
 2. **Attach, format, and verify External Drive stability.**
 3. **Drive Image Operation:**
	 - *Option A:* **Full Drive Image (P2V):** *Disk to VHD Microsoft*
	 - *Option B:* **Multi-Threaded File Copy:** *RichCopy 4.0 Microsoft* \*
	 - *Option C:* **Restartable/Repeatable File Copy:**  *PowerShell / RoboCopy / RoboMirror* \*
 4. **Verify Data Integrity (optional):** *checksum / hashes / bootable VM*


 **\* =** Options B and C will not produce a bootable external disk.  

## 3. Salvage the old PC, and image the entire disk to a backup drive to be used in a modern system. 

*Risk of failure:* Low

*Cost:* High

*Necessary Equipment:* 

 - External Hard Drive (with 1.5x necessary storage space) = ~$85
 - Modern PC to Migrate data to (Windows or Linux) = $450-$300

*Procedure:*

 1. **Remove hard disk from legacy PC.**
 2. **Cooldown and cleanout old hard drive.**
 3. **Connect disk to replacement PC and store in a static-free environment with good ventilation and away from high-traffic areas.**
 4. **Attach, format, and verify External Drive stability.**
 5. **Drive Image Operation:**
	 - *Option A:* **Full Drive Image (P2V):** *Disk to VHD Microsoft*
	 - *Option B:* **Multi-Threaded File Copy:** *RichCopy 4.0 Microsoft*
	 - *Option C:* **Restartable/Repeatable File Copy:**  *PowerShell / RoboCopy / RoboMirror*
 6. **Verify Data Integrity (optional):** *checksum / hashes*

#### End of document ###

*Author: Kerbalnut*

*Last Updated: 2016-06-16*


