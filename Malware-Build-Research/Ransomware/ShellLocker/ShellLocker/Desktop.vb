Public Class Desktop
    Private Declare Function FindWindow Lib "user32.dll" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Int32
    Private Declare Function ShowWindow Lib "user32.dll" (ByVal hwnd As IntPtr, ByVal nCmdShow As Int32) As Int32
    Private Const SW_HIDE As Int32 = 0
    Private Const SW_RESTORE As Int32 = 9
    Public Shared Sub DesktopIconsHide()
        Dim hWnd As IntPtr

        hWnd = FindWindow(vbNullString, "Program Manager")
        If Not hWnd = 0 Then
            ShowWindow(hWnd, SW_HIDE)
        End If
    End Sub
    Public Shared Sub DesktopIconsShow()
        Dim hWnd As IntPtr
        hWnd = FindWindow(vbNullString, "Program Manager")
        If Not hWnd = 0 Then
            ShowWindow(hWnd, SW_RESTORE)
        End If
    End Sub
End Class
