.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\wininet.inc
include \masm32\include\user32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\wininet.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\masm32.lib
FTPit       PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ThePort                   equ     21
.data
   szAgent      db "FTPit 1.0",0
   Theoutput  db   ' __________________________________________________',13,10
              db   '|                        FTPit 1.0                 |',13,10
              db   '|                      Coded In MASM               |',13,10
              db   '|             by illwill  - xillwillx@yahoo.com    |',13,10
              db   '|__________________________________________________|',13,10,0
   szParams   db   '                          USAGE:',13,10
              db   'FTPit.exe <site> <user> <pass> <localfile> <remotefile>',13,10
              db   'ex: FTPit 192.168.1.1 open sesame c:\boot.ini public_html/boot.ini',13,10,13,10,0
   Connecting db   '          Connecting.............',13,10,13,10,0           
   SiteFail   db   '          Error connecting to site.',13,10,13,10,0
   Connected  db   '          Connected to site.',13,10,13,10,0
   Success    db   '          File Successfully Transfered.',13,10,13,10,0
   Failed     db   '          Error transferring file.',13,10,13,10,0      

.data?
   ftpsite    db 128 dup(?)
   Username   db 128 dup(?)
   Password   db 128 dup(?)
   TheFile    db 128 dup(?)
   TheFile2   db 128 dup(?)
.code

start:
         invoke GetCL, 1, addr ftpsite 
         invoke lstrlen,addr ftpsite
           .IF eax>200
             invoke ExitProcess,1
           .ELSEIF eax==0
            invoke StdOut,addr Theoutput
            invoke StdOut,addr szParams 
            invoke ExitProcess,0
           .ENDIF
         invoke GetCL, 2, addr Username
         invoke lstrlen,addr Username
           .IF eax==0
            invoke StdOut,addr Theoutput
            invoke StdOut,addr szParams 
            invoke ExitProcess,0
           .ENDIF
         invoke GetCL, 3, addr Password
         invoke lstrlen,addr Password
           .IF eax==0
            invoke StdOut,addr Theoutput
            invoke StdOut,addr szParams 
            invoke ExitProcess,0
           .ENDIF
         invoke GetCL, 4, addr TheFile
         invoke lstrlen,addr TheFile
           .IF eax==0
            invoke StdOut,addr Theoutput
            invoke StdOut,addr szParams 
            invoke ExitProcess,0
           .ENDIF
         invoke GetCL, 5, addr TheFile2
         invoke lstrlen,addr TheFile2
           .IF eax==0
            invoke StdOut,addr Theoutput
            invoke StdOut,addr szParams 
            invoke ExitProcess,0
           .ENDIF
     invoke FTPit, addr ftpsite,addr Username,addr Password, addr TheFile,addr TheFile2
     invoke ExitProcess, 0
FTPit PROC FTPserver:DWORD, lpszUser:DWORD, lpszPass:DWORD, lpszFile:DWORD, lpRemoteFile:DWORD
    local hInternet:DWORD
    local ftpHandle:DWORD
    local context:DWORD
    local InternetStatusCallback:DWORD
   invoke StdOut,addr Theoutput
   invoke StdOut,addr Connecting
   invoke InternetOpen,addr szAgent,INTERNET_OPEN_TYPE_PRECONFIG,NULL,NULL,0
     mov hInternet, eax
   invoke InternetConnect,hInternet,FTPserver,ThePort ,\   ;or use INTERNET_DEFAULT_FTP_PORT  
                      lpszUser,lpszPass,INTERNET_SERVICE_FTP,\
                     INTERNET_FLAG_PASSIVE,ADDR context
           .IF eax==0
            invoke StdOut,addr SiteFail
            jmp err
           .ELSE
            mov ftpHandle,eax
            invoke StdOut,addr Connected
           .ENDIF         
   invoke FtpPutFile,ftpHandle,lpszFile,lpRemoteFile,FTP_TRANSFER_TYPE_BINARY,NULL
           .IF eax==0
            invoke StdOut,addr Failed
            jmp err
           .ELSE
            invoke StdOut,addr Success
           .ENDIF
err:
   invoke InternetCloseHandle,ftpHandle
   invoke InternetCloseHandle, hInternet
    ret
FTPit endp
end start
