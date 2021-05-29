/*****************************************************************

    SIMPLE UNPACKER
    PoC Tool by Oleksiuk Dmytro (aka Cr4sh), Esage Lab

    http://d-olex.blogspot.com/
    mailto:dmitry@esagelab.com

    See README.TXT for usage details.

 *****************************************************************/

#include "stdafx.h"

#define ErrMsg DbgMsg

#define IFMT_32 "0x%.8x"
#define IFMT_64 "0x%.16I64x"

#if defined(_X86_)

#define IFMT IFMT_32

#elif defined(_AMD64_)

#define IFMT IFMT_64

#endif

// default name for dumped executable
#define DEFAULT_DUMP_NAME "dumped.exe"

// debugged process execution timeout
#define DEFAULT_TIMEOUT 10 // in seconds

HANDLE m_hLogFile = INVALID_HANDLE_VALUE;
//--------------------------------------------------------------------------------------
char *GetNameFromFullPath(char *lpszPath)
{
    char *lpszName = lpszPath;

    for (size_t i = 0; i < strlen(lpszPath); i++)
    {
        if (lpszPath[i] == '\\' || lpszPath[i] == '/')
        {
            lpszName = lpszPath + i + 1;
        }
    }

    return lpszName;
}
//--------------------------------------------------------------------------------------
void DbgMsg(char *lpszFile, int Line, char *lpszMsg, ...)
{
    va_list mylist;
    va_start(mylist, lpszMsg);

    size_t len = _vscprintf(lpszMsg, mylist) + 0x100;

    char *lpszBuff = (char *)LocalAlloc(LMEM_FIXED, len);
    if (lpszBuff == NULL)
    {
        va_end(mylist);
        return;
    }

    char *lpszOutBuff = (char *)LocalAlloc(LMEM_FIXED, len);
    if (lpszOutBuff == NULL)
    {
        LocalFree(lpszBuff);
        va_end(mylist);
        return;
    }

    vsprintf_s(lpszBuff, len, lpszMsg, mylist);	
    va_end(mylist);

    sprintf_s(
        lpszOutBuff, len, "[%.5d] .\\%s(%d) : %s", 
        GetCurrentProcessId(), GetNameFromFullPath(lpszFile), Line, lpszBuff
    );

    HANDLE hStd = GetStdHandle(STD_OUTPUT_HANDLE);
    if (hStd != INVALID_HANDLE_VALUE)
    {
        DWORD dwWritten = 0;
        WriteFile(hStd, lpszBuff, lstrlenA(lpszBuff), &dwWritten, NULL);    
    }

    if (m_hLogFile != INVALID_HANDLE_VALUE)
    {
        DWORD dwWritten = 0;
        SetFilePointer(m_hLogFile, 0, NULL, FILE_END);
        WriteFile(m_hLogFile, lpszOutBuff, lstrlenA(lpszOutBuff), &dwWritten, NULL);    
        FlushFileBuffers(m_hLogFile);
    }

    LocalFree(lpszOutBuff);
    LocalFree(lpszBuff);
}
//--------------------------------------------------------------------------------------
BOOL LoadPrivileges(char *lpszName)
{
    HANDLE hToken = NULL;
    LUID Val;
    TOKEN_PRIVILEGES tp;
    BOOL bRet = FALSE;

    if (!OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken)) 
    {
        ErrMsg(__FILE__, __LINE__, "OpenProcessToken() fails: error %d\n", GetLastError());
        goto end;
    }

    if (!LookupPrivilegeValueA(NULL, lpszName, &Val))
    {
        ErrMsg(__FILE__, __LINE__, "LookupPrivilegeValue() fails: error %d\n", GetLastError());
        goto end;
    }

    tp.PrivilegeCount = 1;
    tp.Privileges[0].Luid = Val;
    tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

    if (!AdjustTokenPrivileges(hToken, FALSE, &tp, sizeof (tp), NULL, NULL))
    {
        ErrMsg(__FILE__, __LINE__, "AdjustTokenPrivileges() fails: error %d\n", GetLastError());
        goto end;
    }

    bRet = TRUE;

end:
    if (hToken)
    {
        CloseHandle(hToken);
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
BOOL DumpToFile(const char *lpszFileName, PVOID pData, ULONG DataSize)
{
    HANDLE hFile = CreateFile(lpszFileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL);
    if (hFile != INVALID_HANDLE_VALUE)
    {
        DWORD dwWritten;
        WriteFile(hFile, pData, DataSize, &dwWritten, NULL);

        CloseHandle(hFile);

        return TRUE;
    }
    else
    {
        ErrMsg(__FILE__, __LINE__, "Error %d while creating '%s'\n", GetLastError(), lpszFileName);
    }

    return FALSE;
}
//--------------------------------------------------------------------------------------
DWORD GetRemoteModuleSize(DWORD dwProcessId, PVOID ModuleAddress)
{
    HANDLE hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, dwProcessId);
    if (hSnap != INVALID_HANDLE_VALUE)
    {        
        MODULEENTRY32 Module = { 0 };
        Module.dwSize = sizeof(MODULEENTRY32);

        if (Module32First(hSnap, &Module))
        {
            do 
            {
                if (Module.modBaseAddr == ModuleAddress)
                {
                    CloseHandle(hSnap);
                    return Module.modBaseSize;
                }
            }
            while (Module32Next(hSnap, &Module));
        }
        else
        {
            ErrMsg(__FILE__, __LINE__, "Module32First() ERROR %d\n", GetLastError());
        }

        CloseHandle(hSnap);
    }
    else
    {
        ErrMsg(__FILE__, __LINE__, "CreateToolhelp32Snapshot() ERROR %d\n", GetLastError());
    }

    return 0;
}
//--------------------------------------------------------------------------------------
UCHAR SetInt3Breakpoint(HANDLE hProcess, PVOID Address)
{
    UCHAR Byte = 0, Int3 = 0xcc;
    DWORD dwSize = 0;

    // read original byte from location
    if (ReadProcessMemory(hProcess, Address, &Byte, sizeof(BYTE), &dwSize))
    {
        // write 'int 3' instruction
        if (WriteProcessMemory(hProcess, Address, &Int3, sizeof(BYTE), &dwSize))
        {
            return Byte;
        }
        else
        {
            ErrMsg(__FILE__, __LINE__, "WriteProcessMemory() ERROR %d\n", GetLastError());
        }
    }
    else
    {
        ErrMsg(__FILE__, __LINE__, "ReadProcessMemory() ERROR %d\n", GetLastError());
    }

    return 0;
}
//--------------------------------------------------------------------------------------
PVOID SetExportedFunctionBreakpoint(
    HANDLE hProcess,
    const char *lpszModule, const char *lpszProc,
    PVOID RemoteModuleBase)
{
    PVOID Ret = NULL;

    HMODULE hModule = LoadLibrary(lpszModule);
    if (hModule)
    {
        // get local address of the function
        PVOID ProcAddress = GetProcAddress(hModule, lpszProc);
        if (ProcAddress)
        {
            // calculate remote address of the function
            Ret = (PUCHAR)ProcAddress - (PUCHAR)hModule + (PUCHAR)RemoteModuleBase;

            if (SetInt3Breakpoint(hProcess, Ret))
            {
                return Ret;
            }
        }
        else
        {
            ErrMsg(__FILE__, __LINE__, "GetProcAddress() ERROR %d\n", GetLastError());
        }
    }
    else
    {
        ErrMsg(__FILE__, __LINE__, "LoadLibrary() ERROR %d\n", GetLastError());
    }

    return NULL;
}
//--------------------------------------------------------------------------------------
BOOL DumpModule(PPROCESS_INFORMATION ProcessInfo, PVOID ImageAddress, char *lpszFilePath)
{
    BOOL bRet = FALSE;

    // get size of image to dump
    DWORD dwImageSize = GetRemoteModuleSize(ProcessInfo->dwProcessId, ImageAddress);
    if (dwImageSize)
    {
        DbgMsg(__FILE__, __LINE__, "[+] Dumping image "IFMT" Size=0x%.8x\n", ImageAddress, dwImageSize);
    }
    else
    {
        ErrMsg(__FILE__, __LINE__, __FUNCTION__"() ERROR: Can't get module size\n");
        return FALSE;
    }

    // allocate memory for image
    PVOID Image = LocalAlloc(LMEM_FIXED, dwImageSize);
    if (Image)
    {
        DWORD dwReaded = 0;
        if (ReadProcessMemory(ProcessInfo->hProcess, ImageAddress, Image, dwImageSize, &dwReaded))
        {
            PIMAGE_NT_HEADERS32 pHeaders = (PIMAGE_NT_HEADERS32)
                ((PUCHAR)Image + ((PIMAGE_DOS_HEADER)Image)->e_lfanew);

            PIMAGE_SECTION_HEADER pSection = (PIMAGE_SECTION_HEADER)
                (pHeaders->FileHeader.SizeOfOptionalHeader + 
                (PUCHAR)&pHeaders->OptionalHeader);
                       
            DbgMsg(
                __FILE__, __LINE__, "Fixing FileAlignment 0x%.8x -> 0x%.8x\n", 
                pHeaders->OptionalHeader.FileAlignment,
                pHeaders->OptionalHeader.SectionAlignment
            );

            pHeaders->OptionalHeader.FileAlignment = pHeaders->OptionalHeader.SectionAlignment;

            for (DWORD i = 0; i < pHeaders->FileHeader.NumberOfSections; i++)
            {
                DbgMsg(
                    __FILE__, __LINE__, "Fixing section raw address 0x%.8x -> 0x%.8x\n", 
                    pSection->PointerToRawData, pSection->VirtualAddress
                );

                pSection->PointerToRawData = pSection->VirtualAddress;
                pSection += 1;
            }

            if (DumpToFile(lpszFilePath, Image, dwImageSize))
            {
                DbgMsg(__FILE__, __LINE__, "[+] Image dumped to \"%s\"\n", lpszFilePath);
                bRet = TRUE;
            }
        }
        else
        {
            ErrMsg(__FILE__, __LINE__, "ReadProcessMemory() ERROR %d\n", GetLastError());
        }
    }
    else
    {
        ErrMsg(__FILE__, __LINE__, "LocalAlloc() ERROR %d\n", GetLastError());
    }

    return bRet;
}
//--------------------------------------------------------------------------------------
DWORD WINAPI TimeoutWaitThread(LPVOID lpParam)
{
    DWORD dwTimeout = (DWORD)lpParam;
    Sleep(dwTimeout * 1000);

    DbgMsg(__FILE__, __LINE__, "[!] Terminating by timeout (%d seconds)\n", dwTimeout);

    ExitProcess((UINT)-1);

    return 0;
}
//--------------------------------------------------------------------------------------
int _tmain(int argc, _TCHAR* argv[])
{
    if (argc < 2)
    {
        printf("USAGE: SimpleUnpacker.exe <command_line> [--bp module!function]\n");
        return 0;
    }

    #define BREAKPOINTS_LIST std::list<std::pair<std::string, std::string>>
    #define ACTIVE_BREAKPOINTS_LIST std::map<PVOID, std::string>
    BREAKPOINTS_LIST Breakpoints;
    ACTIVE_BREAKPOINTS_LIST ActiveBreakpoints;

    char *lpszDumpFilePath = DEFAULT_DUMP_NAME;
    DWORD dwTimeout = DEFAULT_TIMEOUT;

    if (argc > 2)
    {
        for (int i = 2; i < argc; i++)
        {
            if (!lstrcmp(argv[i], "--bp") && i < argc - 1)
            {
                // parse breakpoint location                
                char szBpInfo[MAX_PATH];
                strcpy_s(szBpInfo, argv[i + 1]);

                char *s = strstr(szBpInfo, "!");
                if (s)
                {
                    *s = '\x00';
                    
                    std::string Module = std::string(strlwr(szBpInfo));
                    std::string Proc = std::string(s + 1);

                    Breakpoints.push_back(std::make_pair(Module, Proc));

                    DbgMsg(
                        __FILE__, __LINE__, "[+] Breakpoint: %s!%s()\n",
                        Module.c_str(), Proc.c_str()
                    );
                }
                else
                {
                    ErrMsg(__FILE__, __LINE__, "[!] Argument for --bp must be in format \"module_name!function_name\"\n");
                    return -1;
                }
            }
            else if (!lstrcmp(argv[i], "--dmpname") && i < argc - 1)
            {
                // alternate path for the dumped binary
                lpszDumpFilePath = argv[i + 1];
            }
            else if (!lstrcmp(argv[i], "--timeout") && i < argc - 1)
            {
                // debugged process execution timeout
                DWORD t = (DWORD)atoi(argv[i + 1]);
                if (t == 0)
                {
                    ErrMsg(__FILE__, __LINE__, "[!] Invalid argument value for --timeout parameter\n");
                    return -1;
                }

                dwTimeout = t;
            }
        }
    }

    DeleteFile(lpszDumpFilePath);

    if (!LoadPrivileges(SE_DEBUG_NAME))
    {
        ErrMsg(__FILE__, __LINE__, "[!] Error while loading debug privileges\n");
        return -1;
    }

    STARTUPINFO si;
    PROCESS_INFORMATION pi;

    ZeroMemory(&pi, sizeof(pi));
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);    

    ErrMsg(__FILE__, __LINE__, "[+] Process command line: \"%s\"\n", argv[1]);

    // execute target process under debugging
    if (!CreateProcess(NULL, argv[1], NULL, NULL, FALSE, DEBUG_PROCESS, NULL, NULL, &si, &pi))  
    {
        ErrMsg(__FILE__, __LINE__, "CreateProcess() ERROR %d\n", GetLastError());
        return -1;
    }  

    HANDLE hThread = CreateThread(NULL, 0, TimeoutWaitThread, (LPVOID)dwTimeout, 0, NULL);
    if (hThread)
    {
        CloseHandle(hThread);
    }
    else
    {
        ErrMsg(__FILE__, __LINE__, "CreateThread() ERROR %d\n", GetLastError());
        return -1;
    }

    BOOL bProcessTerminated = FALSE;
    PVOID BaseOfImage = NULL;

    while (!bProcessTerminated)
    {         
        DWORD dwContinueStatus = DBG_CONTINUE;
        DEBUG_EVENT DebugEv;        

        // Wait for a debugging event to occur
        WaitForDebugEvent(&DebugEv, INFINITE); 

        // Process the debugging event code
        switch (DebugEv.dwDebugEventCode) 
        { 
        case EXCEPTION_DEBUG_EVENT: 
            
            // Process the exception code. When handling 
            // exceptions, remember to set the continuation 
            // status parameter (dwContinueStatus). This value 
            // is used by the ContinueDebugEvent function. 
            switch (DebugEv.u.Exception.ExceptionRecord.ExceptionCode)
            { 
            case EXCEPTION_ACCESS_VIOLATION: 
                
                DbgMsg(
                    __FILE__, __LINE__, "EXCEPTION_ACCESS_VIOLATION at "IFMT"\n",
                    DebugEv.u.Exception.ExceptionRecord.ExceptionAddress
                );

                goto end;

            case EXCEPTION_BREAKPOINT: 
                {
                    DbgMsg(
                        __FILE__, __LINE__, "EXCEPTION_BREAKPOINT at "IFMT"\n", 
                        DebugEv.u.Exception.ExceptionRecord.ExceptionAddress
                    );
                    
                    ACTIVE_BREAKPOINTS_LIST::iterator e = 
                        ActiveBreakpoints.find(DebugEv.u.Exception.ExceptionRecord.ExceptionAddress);

                    // check for our breakpoint
                    if (e != ActiveBreakpoints.end())
                    {
                        DbgMsg(__FILE__, __LINE__,  "[+] Breakpoint occurs: %s\n", (*e).second.c_str());

                        if (BaseOfImage)
                        {
                            DumpModule(&pi, BaseOfImage, lpszDumpFilePath);
                        }

                        goto end;
                    }                

                    break;
                }

            case EXCEPTION_DATATYPE_MISALIGNMENT: 
                
                DbgMsg(
                    __FILE__, __LINE__, "EXCEPTION_DATATYPE_MISALIGNMENT at "IFMT"\n", 
                    DebugEv.u.Exception.ExceptionRecord.ExceptionAddress
                );

                goto end;

            case EXCEPTION_SINGLE_STEP: 
                
                DbgMsg(
                    __FILE__, __LINE__, "EXCEPTION_SINGLE_STEP at "IFMT"\n",
                    DebugEv.u.Exception.ExceptionRecord.ExceptionAddress
                );

                goto end;

            case DBG_CONTROL_C: 
                
                DbgMsg(__FILE__, __LINE__, "DBG_CONTROL_C\n");
                goto end;

            default:

                DbgMsg(
                    __FILE__, __LINE__, "EXCEPTION 0x%.8x at "IFMT"\n", 
                    DebugEv.u.Exception.ExceptionRecord.ExceptionCode,
                    DebugEv.u.Exception.ExceptionRecord.ExceptionAddress
                );

                break;
            } 

        case CREATE_THREAD_DEBUG_EVENT: 
            
            DbgMsg(
                __FILE__, __LINE__, 
                "CREATE_THREAD: StartAddress="IFMT"\n", 
                DebugEv.u.CreateThread.lpStartAddress
            );

            break;

        case CREATE_PROCESS_DEBUG_EVENT: 
            
            DbgMsg(
                __FILE__, __LINE__, 
                "CREATE_PROCESS: ImageBase="IFMT", StartAddress="IFMT"\n", 
                DebugEv.u.CreateProcessInfo.lpBaseOfImage,
                DebugEv.u.CreateProcessInfo.lpStartAddress
            );

            BaseOfImage = DebugEv.u.CreateProcessInfo.lpBaseOfImage;

            break;

        case EXIT_THREAD_DEBUG_EVENT: 
            
            DbgMsg(__FILE__, __LINE__, "EXIT_THREAD: Code=0x%.8x\n", DebugEv.u.ExitThread.dwExitCode);
            break;

        case EXIT_PROCESS_DEBUG_EVENT: 
            
            DbgMsg(__FILE__, __LINE__, "EXIT_PROCESS: Code=0x%.8x\n", DebugEv.u.ExitProcess.dwExitCode);
            bProcessTerminated = TRUE;

            break;

        case LOAD_DLL_DEBUG_EVENT: 
            {
                PVOID pDllPath = NULL;
                PUCHAR DllPath[(MAX_PATH + 1) * sizeof(WCHAR)];
                DWORD dwLen = 0;
                ZeroMemory(DllPath, sizeof(DllPath));

                if (DebugEv.u.LoadDll.lpImageName == NULL)
                {
                    break;
                }

                // read DLL name pointer value
                if (ReadProcessMemory(
                    pi.hProcess,
                    DebugEv.u.LoadDll.lpImageName,
                    &pDllPath, sizeof(PVOID),
                    &dwLen) && pDllPath)
                {
                    dwLen = (DebugEv.u.LoadDll.fUnicode ? MAX_PATH * sizeof(WCHAR) : MAX_PATH);

                    // read DLL name
                    if (ReadProcessMemory(
                        pi.hProcess,
                        pDllPath,
                        DllPath, dwLen,
                        &dwLen))
                    {
                        char szDllPath[MAX_PATH], *lpszDllName = NULL;

                        if (DebugEv.u.LoadDll.fUnicode)
                        {
                            DbgMsg(
                                __FILE__, __LINE__, "DLL_LOAD: "IFMT" \"%ws\"\n",
                                DebugEv.u.LoadDll.lpBaseOfDll, DllPath
                            );

                            WideCharToMultiByte(CP_ACP, 0, (PWSTR)DllPath, -1, szDllPath, MAX_PATH, NULL, NULL);
                        }
                        else
                        {
                            DbgMsg(
                                __FILE__, __LINE__, "DLL_LOAD: "IFMT" \"%s\"\n",
                                DebugEv.u.LoadDll.lpBaseOfDll, DllPath
                            );

                            strcpy_s(szDllPath, (char *)DllPath);
                        }

                        lpszDllName = strlwr(GetNameFromFullPath(szDllPath));

                        // search for avaiting breakpoints for this module
                        BREAKPOINTS_LIST::iterator e;
                        for (e = Breakpoints.begin(); e != Breakpoints.end(); ++e)
                        {
                            if (!strcmp(lpszDllName, (*e).first.c_str()))
                            {
                                PVOID BreakAddr = SetExportedFunctionBreakpoint(
                                    pi.hProcess,
                                    szDllPath, (*e).second.c_str(),
                                    DebugEv.u.LoadDll.lpBaseOfDll
                                );
                                if (BreakAddr)
                                {
                                    DbgMsg(
                                        __FILE__, __LINE__, "[+] Breakpoint on %s!%s() has been set: "IFMT"\n",
                                        lpszDllName, (*e).second.c_str(), BreakAddr
                                    );

                                    ActiveBreakpoints[BreakAddr] = std::string((*e).first + "!" + (*e).second);
                                }
                                else
                                {
                                    DbgMsg(
                                        __FILE__, __LINE__, "[!] Error while setting breakpoint on %s!%s()\n",
                                        lpszDllName, (*e).second.c_str()
                                    );

                                    goto end;
                                }
                            }
                        }
                    }
                    else
                    {
                        ErrMsg(__FILE__, __LINE__, "ReadProcessMemory() ERROR %d\n", GetLastError());
                    }
                }   
                else
                {
                    ErrMsg(__FILE__, __LINE__, "ReadProcessMemory() ERROR %d\n", GetLastError());
                }

                break;
            }            
        } 

        // Resume executing the thread that reported the debugging event. 
        ContinueDebugEvent(
            DebugEv.dwProcessId, 
            DebugEv.dwThreadId, 
            dwContinueStatus
        );
    }

end:

    if (!bProcessTerminated)
    {
        TerminateProcess(pi.hProcess, 0);
    }

    DbgMsg(__FILE__, __LINE__, "DONE\n");

    CloseHandle(pi.hThread);
    CloseHandle(pi.hProcess);
    
	return 0;
}
//--------------------------------------------------------------------------------------
// EoF
