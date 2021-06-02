Public Class Form1



    Private Sub Form1_KeyDown(ByVal sender As Object, ByVal e As System.Windows.Forms.KeyEventArgs) Handles Me.KeyDown
        If e.KeyData = Keys.Alt + Keys.F4 Then
            MessageBox.Show("You Are Under Control", "", MessageBoxButtons.OK, MessageBoxIcon.Hand)
            e.Handled = True
        End If

    End Sub
    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load        
        Form2.Show()


    End Sub

    Private Sub Timer1_Tick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Timer1.Tick

        Me.Close()




    End Sub
End Class
