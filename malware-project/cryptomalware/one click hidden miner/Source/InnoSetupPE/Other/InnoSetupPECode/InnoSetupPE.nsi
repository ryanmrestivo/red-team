;Copyright (C) 2004-2005 John T. Haller
;Copyright (C) 2006 OTBSoft

;Website: http://software.otbsupport.com/portableapps/xnresourceeditorpe

;This software is OSI Certified Open Source Software.
;OSI Certified is a certification mark of the Open Source Initiative.

;This program is free software; you can redistribute it and/or
;modify it under the terms of the GNU General Public License
;as published by the Free Software Foundation; either version 2
;of the License, or (at your option) any later version.

;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.

;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

!define NAME "InnoSetupPE"
!define FRIENDLYNAME "InnoSetup Portable Edition"
!define APP "InnoSetup"
!define VER "5.1.8.0"
!define WEBSITE "http://software.otbsupport.com/portableapps/innosetuppe"
!define DEFAULTEXE "Compil32.exe"
!define DEFAULTAPPDIR "InnoSetup"
!define DEFAULTSETTINGSDIR "settings"
!include "Registry.nsh"
!include "GetParameters.nsh"

;=== Program Icon
Icon "${APP}.ico"

;=== Program Details
Name "${NAME}"
OutFile "${NAME}.exe"
Caption "${FRIENDLYNAME}"
VIProductVersion "${VER}"
VIAddVersionKey FileDescription "${FRIENDLYNAME} - Install Builder"
VIAddVersionKey LegalCopyright "GPL"
VIAddVersionKey Comments "Allows ${APP} to be run from a removable drive.  For additional details, visit ${WEBSITE}"
VIAddVersionKey CompanyName "OTBSupport"
VIAddVersionKey OriginalFilename "${NAME}.exe"
VIAddVersionKey FileVersion "${VER}"

;=== Runtime Switches
CRCCheck On
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True

Var ADDITIONALPARAMETERS
Var DISABLESPLASHSCREEN
Var EXECSTRING
Var INIPATH
;Var PLUGINSDIRECTORY
Var PROGRAMDIRECTORY
Var PROGRAMEXECUTABLE
Var SETTINGSDIRECTORY
;Var USERPROFILEDIRECTORY
;Var WAITFORPROGRAM

Section "Main"
        ;=== Find the INI file, if there is one
                IfFileExists "$EXEDIR\${NAME}.ini" "" CheckSubINI
                        StrCpy "$INIPATH" "$EXEDIR\"
                        Goto ReadINI
                          
                CheckSubINI:
                        IfFileExists "$EXEDIR\${NAME}\${NAME}.ini" "" CheckSubSubINI
                                StrCpy "$INIPATH" "$EXEDIR\${NAME}\"
                                Goto ReadINI
                                      
                CheckSubSubINI:
                        IfFileExists "$EXEDIR\PortableApps\${NAME}\${NAME}.ini" "" CheckPortableAppsINI
                                StrCpy "$INIPATH" "$EXEDIR\PortableApps\${NAME}\"
                                Goto ReadINI
                                
                CheckPortableAppsINI:
                        IfFileExists "$EXEDIR\Data\${NAME}\${NAME}.ini" "" NoINI
                                StrCpy "$INIPATH" "$EXEDIR\Data\${NAME}\"
                                Goto ReadINI

                ReadINI:
                        ;=== Read the parameters from the INI file
                        ReadINIStr $0 "$INIPATH\${NAME}.ini" "${NAME}" "${APP}Directory"
                        StrCpy "$PROGRAMDIRECTORY" "$EXEDIR\$0"
                        ReadINIStr $0 "$INIPATH\${NAME}.ini" "${NAME}" "SettingsDirectory"
                        StrCpy "$SETTINGSDIRECTORY" "$EXEDIR\$0"
                        
                        ;=== Check that the above required parameters are present
                        IfErrors NoINI
                        
                        ReadINIStr $0 "$INIPATH\${NAME}.ini" "${NAME}" "AdditionalParameters"
                        StrCpy "$ADDITIONALPARAMETERS" $0
                        ReadINIStr $0 "$INIPATH\${NAME}.ini" "${NAME}" "${APP}Executable"
                        StrCpy "$PROGRAMEXECUTABLE" $0
                        ReadINIStr $0 "$INIPATH\${NAME}.ini" "${NAME}" "DisableSplashScreen"
                        StrCpy "$DISABLESPLASHSCREEN" $0
                        
                CleanUpAnyErrors:
                        ;=== Any missing unrequired INI entries will be an empty string, ignore associated errors
                        ClearErrors
                        
                        ;=== Correct PROGRAMEXECUTABLE if blank
                        StrCmp $PROGRAMEXECUTABLE "" "" EndINI
                                StrCpy "$PROGRAMEXECUTABLE" "${DEFAULTEXE}"
                                Goto EndINI

                NoINI:
                        ;=== No INI file, so we'll use the defaults
                        StrCpy $ADDITIONALPARAMETERS ""
                        StrCpy $PROGRAMEXECUTABLE "${DEFAULTEXE}"
                        StrCpy $DISABLESPLASHSCREEN "true"

                        IfFileExists "$EXEDIR\App\${DEFAULTAPPDIR}\${DEFAULTEXE}" "" CheckPortableProgramDIR
                                StrCpy $PROGRAMDIRECTORY "$EXEDIR\App\${DEFAULTAPPDIR}"
                                StrCpy $SETTINGSDIRECTORY "$EXEDIR\Data\${DEFAULTSETTINGSDIR}"
                                GoTo EndINI
                                
                        CheckPortableProgramDIR:
                                IfFileExists "$EXEDIR\${NAME}\App\${DEFAULTAPPDIR}\${DEFAULTEXE}" "" CheckPortableAppsDIR
                                StrCpy $PROGRAMDIRECTORY "$EXEDIR\${NAME}\App\${DEFAULTAPPDIR}"
                                StrCpy $SETTINGSDIRECTORY "$EXEDIR\${NAME}\Data\${DEFAULTSETTINGSDIR}"
                                GoTo EndINI
                                
                        CheckPortableAppsDIR:
                                IfFileExists "$EXEDIR\PortableApps\${NAME}\App\${DEFAULTAPPDIR}\${DEFAULTEXE}" "" CheckPortableAppsSplitDIR
                                StrCpy $PROGRAMDIRECTORY "$EXEDIR\PortableApps\${NAME}\App\${DEFAULTAPPDIR}"
                                StrCpy $SETTINGSDIRECTORY "$EXEDIR\PortableApps\${NAME}\Data\${DEFAULTSETTINGSDIR}"
                                GoTo EndINI
                                
                        CheckPortableAppsSplitDIR:
                                IfFileExists "$EXEDIR\Apps\${NAME}\${DEFAULTAPPDIR}\${DEFAULTEXE}" "" NoProgramEXE
                                StrCpy $PROGRAMDIRECTORY "$EXEDIR\Apps\${NAME}\${DEFAULTAPPDIR}"
                                StrCpy $SETTINGSDIRECTORY "$EXEDIR\Apps\${NAME}\${DEFAULTSETTINGSDIR}"
                                GoTo EndINI
                                
                EndINI:
                        IfFileExists "$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE" FoundProgramEXE
                                
                NoProgramEXE:
                        ;=== Program executable not where expected
                        MessageBox MB_OK|MB_ICONEXCLAMATION `$PROGRAMEXECUTABLE was not found. Please check your configuration`
                        Abort
                        
                FoundProgramEXE:
                                
                DisplaySplash:
                        ;=== Check for data files
                        StrCmp $DISABLESPLASHSCREEN "true" SkipSplashScreen
                                ;=== Show the splash screen before processing the files
                                InitPluginsDir
                                File /oname=$PLUGINSDIR\splash.jpg "${NAME}.jpg"
                                newadvsplash::show /NOUNLOAD 3000 400 0 -1 /L $PLUGINSDIR\splash.jpg
                                GoTo SkipSplashScreen
                                
                SkipSplashScreen:

                GetPassedParameters:
                        ;=== Get any passed parameters
                        Call GetParameters
                        Pop $0
                        StrCmp "'$0'" "''" "" LaunchProgramParameters
                        
                        ;=== No parameters
                        StrCpy $EXECSTRING `"$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE"`
                        
                LaunchProgramParameters:
                        StrCpy $EXECSTRING `"$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE" $0`

                AdditionalParameters:
                        StrCpy $EXECSTRING `$EXECSTRING $ADDITIONALPARAMETERS`
                        
                LaunchNow:

                        ; Restory the keys
		        ${Registry::RestoreKey} "$SETTINGSDIRECTORY\settings.reg" $R0
	                ; Wait to allow for registration
        		Sleep 700
                        ExecWait $EXECSTRING
                        newadvsplash::stop
                        ; Save and delete the keys
	               	${Registry::SaveKey} "HKEY_CURRENT_USER\SOFTWARE\Jordan Russell" "$SETTINGSDIRECTORY\settings.reg" "/G=1" $R0
	               	${Registry::DeleteKey} "HKEY_CURRENT_USER\SOFTWARE\Jordan Russell" $R0
                        
SectionEnd