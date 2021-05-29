InnoSetup Portable Edition 5.1.8.0 RC 1
=======================================
Copyright (C) 2004-2005 John T. Haller
Copyright (C) 2006 OTBSoft

Website: http://software.otbsupport.com/portableapps/innosetuppe

This software is OSI Certified Open Source Software.
OSI Certified is a certification mark of the Open Source Initiative.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


ABOUT INNOSETUP PORTABLE EDITION
================================
InnoSetup Portable Edition allows you to run InnoSetup from a removable drive whose letter changes as you move it to another computer.  InnoSetup is a high quality, opensource peer-to-peer application based on the popular LimeWire Gnutella client.  The program can be entirely self-contained on the drive and then used on any Windows computer.


LICENSE
=======
This code is released under the GPL.  The full code is included with this package as InnoSetupPE.nsi.


INSTALLATION / DIRECTORY STRUCTURE
==================================
By default, the program expects one of 4 directory structures:

-\ <--- Directory with InnoSetupPE.exe
  +\InnoSetup\
  +\settings\

OR

-\ <--- Directory with InnoSetupPE.exe
  +\InnoSetupPE\
    +\InnoSetup\
    +\settings\

OR

-\ <--- Directory with InnoSetupPE.exe
  +\PortableApps\
    +\InnoSetupPE\
      +\InnoSetup\
      +\settings\

OR

-\ <--- Directory with InnoSetupPE.exe (PortableApps, for instance)
  +\Apps\
    +\InnoSetupPE\
      +\InnoSetup\
  +\Data\
    +\InnoSetupPE\
      +\settings\

It can be used in other directory configurations by including the InnoSetupPE.ini file in the same directory as InnoSetupPE.exe and configuring it as details in the INI file section below.  The INI file may also be placed in a subdirectory of the directory containing InnoSetupPE.exe called InnoSetupPE or 2 directories deep in PortableApps\InnoSetupPE or Data\InnoSetupPE.  All paths in the INI should remain relative to the EXE and not the INI.


InnoSetupPE.INI CONFIGURATION
=========================
InnoSetupPE will look for an ini file called InnoSetupPE.ini.  If you are happy with the default options, it is not necessary, though.  The INI file is formatted as follows:

[InnoSetupPE]
InnoSetupDirectory=InnoSetup
SettingsDirectory=settings
AdditionalParameters=
InnoSetupExecutable=InnoSetup.exe
DisableSplashScreen=false

The InnoSetupDirectory and SettingsDirectory entries should be set to the *relative* path to the appropriate directories from the current directory.  All must be a subdirectory (or multiple subdirectories) of the directory containing InnoSetupPE.exe.  The default entries for these are described in the installation section above.

The AdditionalParameters entry allows you to pass additional commandline parameter entries to InnoSetup.exe.  Whatever you enter here will be appended to the call to InnoSetup.exe.

The InnoSetupExecutable entry allows you to set InnoSetupPE to use an alternate EXE call to launch InnoSetup.  This is helpful if you are using a machine that is set to deny InnoSetup.exe from running.  You'll need to rename the InnoSetup.exe file and then enter the name you gave it on the InnoSetupExecutable= line of the INI.

The DisableSplashScreen entry allows you to run InnoSetupPE without the splash screen showing up.  The default is false.


PROGRAM HISTORY / ABOUT THE AUTHORS
===================================
John T. Haller was the original author of Portable VLC, from which most of this code was copied.  Daniel J. Griffiths and/or other OTBSoft personnel customized the original code to make it compatible with this release.