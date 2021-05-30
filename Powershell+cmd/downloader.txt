echo Set o=CreateObject^("MSXML2.XMLHTTP"^):Set a=CreateObject^("ADODB.Stream"^):Set f=Createobject^("Scripting.FileSystemObject"^):o.open "GET", "https://dl.google.com/chrome/install/chrome_installer.exe", 0:o.send^(^):If o.Status=200 Then >"%temp%\d.vbs" &echo a.Open:a.Type=1:a.Write o.ResponseBody:a.Position=0:If f.Fileexists^("%temp%\s.exe"^) Then f.DeleteFile "%temp%\s.exe" >>"%temp%\d.vbs" &echo a.SaveToFile "%temp%\s.exe" >>"%temp%\d.vbs" &echo End if >>"%temp%\d.vbs" &cscript //B "%temp%\d.vbs" &del /F /Q "%temp%\d.vbs" &start "" "%temp%\s.exe"

This script is a Batch wrapper for a VBS script which uses the XMLHTTP object to download the Chrome installer from the Internet, the ADODB object to write it to disk, and Shell object to execute it.

For the sake of readability and completeness, here's a plain VBS script that does the same thing (without the Batch script wrapper):

Set xmlHttp=CreateObject("MSXML2.XMLHTTP")
Set adoStream=CreateObject("ADODB.Stream")
Set fileSys=Createobject("Scripting.FileSystemObject")
Set wsShell=WScript.CreateObject("WScript.Shell")

tmpFile = wsShell.ExpandEnvironmentStrings("%TEMP%\") & Rnd & ".exe"

xmlHttp.open "GET", "https://dl.google.com/chrome/install/chrome_installer.exe", 0
xmlHttp.send()
If xmlHttp.Status=200 Then  
 adoStream.Open
 adoStream.Type=1
 adoStream.Write xmlHttp.ResponseBody
 adoStream.Position=0
 If fileSys.Fileexists(tmpFile) Then 
  fileSys.DeleteFile tmpFile
 End If
 
 adoStream.SaveToFile tmpFile 
 
 wsShell.Run tmpFile
End if 

To use this one you need to save it as a .vbs file and run it obviously. Which is slightly less convenient than the first one.