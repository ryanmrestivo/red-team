    
  SIMPLE UNPACKER
  PoC Tool by Oleksiuk Dmytro (aka Cr4sh), Esage Lab

  http://d-olex.blogspot.com/
  mailto:dmitry@esagelab.com

=================================  

This tool designed for semi-automation unpacking of malware samples, by the following way:

1) Creates malware process with CreateProcess() and PROCESS_DEBUG flag.

2) Dispatching debug events, and setting breakpoints on some APIs, that calls somewhere in unpacked malware body.

3) When breakpoint occurs -- tool performs dumping of unpacked malware executable image.

Of course, to use it you must know what exactly API calls in unpacked malware body, to set breakpoint (unpacking marker) on them.


USAGE:

  > SimpleUnpacker.exe <input_file> --bp <module>!<function>
  
For setting breakpoints on many functions, you can use multipile --bp keys in command line options.
Unpacked binary will be saved in dumped.exe, you can load it into the IDA Pro, or into yor own process (with LoadLibraryEx() + DONT_RESOLVE_DLL_REFERENCES) for further researching.


Exampe of unpacking SpyEye trojan dropper:

-------------------------------------------------------------------

  C:\> SimpleUnpacker.exe dropper.exe --bp kernel32.dll! CreateToolhelp32Snapshot
  
  [+] Breakpoint: kernel32.dll!CreateToolhelp32Snapshot()
  [+] Process command line: "dropper.exe"
  CREATE_PROCESS: ImageBase=0x00400000, StartAddress=0x00420090
  DLL_LOAD: 0x7c900000 "ntdll.dll"
  DLL_LOAD: 0x7c800000 "C:\WINDOWS\system32\kernel32.dll"
  [+] Breakpoint on kernel32.dll!CreateToolhelp32Snapshot() has been set: 0x7c865b1f
  DLL_LOAD: 0x7e410000 "C:\WINDOWS\system32\USER32.dll"
  DLL_LOAD: 0x77f10000 "C:\WINDOWS\system32\GDI32.dll"
  DLL_LOAD: 0x73000000 "C:\WINDOWS\system32\WINSPOOL.DRV"
  DLL_LOAD: 0x77dd0000 "C:\WINDOWS\system32\ADVAPI32.dll"
  DLL_LOAD: 0x77e70000 "C:\WINDOWS\system32\RPCRT4.dll"
  DLL_LOAD: 0x77fe0000 "C:\WINDOWS\system32\Secur32.dll"
  DLL_LOAD: 0x77c10000 "C:\WINDOWS\system32\msvcrt.dll"
  DLL_LOAD: 0x3d930000 "C:\WINDOWS\system32\WININET.dll"
  DLL_LOAD: 0x77f60000 "C:\WINDOWS\system32\SHLWAPI.dll"
  DLL_LOAD: 0x78130000 "C:\WINDOWS\system32\urlmon.dll"
  DLL_LOAD: 0x774e0000 "C:\WINDOWS\system32\ole32.dll"
  DLL_LOAD: 0x77120000 "C:\WINDOWS\system32\OLEAUT32.dll"
  DLL_LOAD: 0x3dfd0000 "C:\WINDOWS\system32\iertutil.dll"
  EXCEPTION_BREAKPOINT at 0x7c90120e
  CREATE_THREAD: StartAddress=0x00000000
  DLL_LOAD: 0x76390000 "C:\WINDOWS\system32\IMM32.DLL"
  DLL_LOAD: 0x773d0000 "C:\WINDOWS\WinSxS\x86_Microsoft.Windows.Common-Controls_65
  95b64144ccf1df_6.0.2600.5512_x-ww_35d4ce83\comctl32.dll"
  CREATE_THREAD: StartAddress=0x7c8106e9
  EXCEPTION_BREAKPOINT at 0x7c865b1f
  [+] Breakpoint occurs: kernel32.dll!CreateToolhelp32Snapshot
  [+] Dumping image 0x00400000 Size=0x0007d000
  Fixing FileAlignment 0x00000200 -> 0x00001000
  Fixing section raw address 0x00000400 -> 0x00001000
  Fixing section raw address 0x00000400 -> 0x00040000
  Fixing section raw address 0x00021600 -> 0x00062000
  [+] Image dumped to "dumped.exe"
  DONE

-------------------------------------------------------------------
