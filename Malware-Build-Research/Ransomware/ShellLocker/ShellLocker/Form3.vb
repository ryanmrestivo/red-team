Option Strict On
Imports System.Runtime.InteropServices
Imports System.Diagnostics
Imports System.Reflection
Public Class Form3
    Private Structure KBDLLHOOKSTRUCT

        Public key As Keys
        Public scanCode As Integer
        Public flags As Integer
        Public time As Integer
        Public extra As IntPtr
    End Structure

    'System level functions to be used for hook and unhook keyboard input
    Private Delegate Function LowLevelKeyboardProc(ByVal nCode As Integer, ByVal wParam As IntPtr, ByVal lParam As IntPtr) As IntPtr
    <DllImport("user32.dll", CharSet:=CharSet.Auto, SetLastError:=True)>
    Private Shared Function SetWindowsHookEx(ByVal id As Integer, ByVal callback As LowLevelKeyboardProc, ByVal hMod As IntPtr, ByVal dwThreadId As UInteger) As IntPtr
    End Function
    <DllImport("user32.dll", CharSet:=CharSet.Auto, SetLastError:=True)>
    Private Shared Function UnhookWindowsHookEx(ByVal hook As IntPtr) As Boolean
    End Function
    <DllImport("user32.dll", CharSet:=CharSet.Auto, SetLastError:=True)>
    Private Shared Function CallNextHookEx(ByVal hook As IntPtr, ByVal nCode As Integer, ByVal wp As IntPtr, ByVal lp As IntPtr) As IntPtr
    End Function
    <DllImport("kernel32.dll", CharSet:=CharSet.Auto, SetLastError:=True)>
    Private Shared Function GetModuleHandle(ByVal name As String) As IntPtr
    End Function
    <DllImport("user32.dll", CharSet:=CharSet.Auto)>
    Private Shared Function GetAsyncKeyState(ByVal key As Keys) As Short
    End Function

    'Declaring Global objects
    Private ptrHook As IntPtr
    Private objKeyboardProcess As LowLevelKeyboardProc



    Public Sub New()

        Try
            Dim objCurrentModule As ProcessModule = Process.GetCurrentProcess().MainModule
            'Get Current Module
            objKeyboardProcess = New LowLevelKeyboardProc(AddressOf captureKey)
            'Assign callback function each time keyboard process
            ptrHook = SetWindowsHookEx(13, objKeyboardProcess, GetModuleHandle(objCurrentModule.ModuleName), 0)
            'Setting Hook of Keyboard Process for current module
            ' This call is required by the Windows Form Designer.
            InitializeComponent()

            ' Add any initialization after the InitializeComponent() call.

        Catch ex As Exception

        End Try
    End Sub


    Private Function captureKey(ByVal nCode As Integer, ByVal wp As IntPtr, ByVal lp As IntPtr) As IntPtr

        Try
            If nCode >= 0 Then
                Dim objKeyInfo As KBDLLHOOKSTRUCT = DirectCast(Marshal.PtrToStructure(lp, GetType(KBDLLHOOKSTRUCT)), KBDLLHOOKSTRUCT)
                If objKeyInfo.key = Keys.RWin OrElse objKeyInfo.key = Keys.LWin Then
                    ' Disabling Windows keys
                    Return CType(1, IntPtr)
                End If
                If objKeyInfo.key = Keys.ControlKey OrElse objKeyInfo.key = Keys.Escape Then
                    ' Disabling Ctrl + Esc keys
                    Return CType(1, IntPtr)
                End If
                If objKeyInfo.key = Keys.ControlKey OrElse objKeyInfo.key = Keys.Down Then
                    ' Disabling Ctrl + Esc keys
                    Return CType(1, IntPtr)
                End If
                If objKeyInfo.key = Keys.Alt OrElse objKeyInfo.key = Keys.Tab Then
                    ' Disabling Ctrl + Esc keys
                    Return CType(1, IntPtr)
                End If
                If objKeyInfo.key = Keys.F2 Then
                    ' Disabling Ctrl + Esc keys
                    Return CType(1, IntPtr)
                End If
            End If
            Return CallNextHookEx(ptrHook, nCode, wp, lp)
        Catch ex As Exception

        End Try
    End Function
End Class