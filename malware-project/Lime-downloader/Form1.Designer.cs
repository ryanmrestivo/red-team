namespace LimeDownloader
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && ( components != null ))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPage1 = new System.Windows.Forms.TabPage();
            this.urlListView = new System.Windows.Forms.ListView();
            this.columnHeader1 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.columnHeader2 = ((System.Windows.Forms.ColumnHeader)(new System.Windows.Forms.ColumnHeader()));
            this.contextMenuStrip1 = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.removeToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.btnAddLink = new System.Windows.Forms.Button();
            this.tabPage5 = new System.Windows.Forms.TabPage();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label9 = new System.Windows.Forms.Label();
            this.txtPayloadName = new System.Windows.Forms.TextBox();
            this.cbInstallFolder = new System.Windows.Forms.ComboBox();
            this.label10 = new System.Windows.Forms.Label();
            this.chkEnableInstall = new System.Windows.Forms.CheckBox();
            this.tabPage2 = new System.Windows.Forms.TabPage();
            this.btnRandom = new System.Windows.Forms.Button();
            this.btnClone = new System.Windows.Forms.Button();
            this.assemblyPrivatePart = new System.Windows.Forms.NumericUpDown();
            this.assemblyBuildPart = new System.Windows.Forms.NumericUpDown();
            this.assemblyMinorVersion = new System.Windows.Forms.NumericUpDown();
            this.assemblyMajorVersion = new System.Windows.Forms.NumericUpDown();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.txtProduct = new System.Windows.Forms.TextBox();
            this.txtCompany = new System.Windows.Forms.TextBox();
            this.txtDescription = new System.Windows.Forms.TextBox();
            this.txtTrademark = new System.Windows.Forms.TextBox();
            this.txtCopyright = new System.Windows.Forms.TextBox();
            this.txtTitle = new System.Windows.Forms.TextBox();
            this.tabPage3 = new System.Windows.Forms.TabPage();
            this.pictureIcon = new System.Windows.Forms.PictureBox();
            this.s = new System.Windows.Forms.Button();
            this.label8 = new System.Windows.Forms.Label();
            this.txtIcon = new System.Windows.Forms.TextBox();
            this.tabPage4 = new System.Windows.Forms.TabPage();
            this.labelBuild = new System.Windows.Forms.Label();
            this.btnBuild = new System.Windows.Forms.Button();
            this.tabControl1.SuspendLayout();
            this.tabPage1.SuspendLayout();
            this.contextMenuStrip1.SuspendLayout();
            this.tabPage5.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.tabPage2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.assemblyPrivatePart)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.assemblyBuildPart)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.assemblyMinorVersion)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.assemblyMajorVersion)).BeginInit();
            this.tabPage3.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureIcon)).BeginInit();
            this.tabPage4.SuspendLayout();
            this.SuspendLayout();
            // 
            // tabControl1
            // 
            this.tabControl1.Appearance = System.Windows.Forms.TabAppearance.FlatButtons;
            this.tabControl1.Controls.Add(this.tabPage1);
            this.tabControl1.Controls.Add(this.tabPage5);
            this.tabControl1.Controls.Add(this.tabPage2);
            this.tabControl1.Controls.Add(this.tabPage3);
            this.tabControl1.Controls.Add(this.tabPage4);
            this.tabControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControl1.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.tabControl1.Location = new System.Drawing.Point(0, 0);
            this.tabControl1.Margin = new System.Windows.Forms.Padding(2);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(477, 202);
            this.tabControl1.TabIndex = 0;
            // 
            // tabPage1
            // 
            this.tabPage1.Controls.Add(this.urlListView);
            this.tabPage1.Controls.Add(this.btnAddLink);
            this.tabPage1.Location = new System.Drawing.Point(4, 27);
            this.tabPage1.Margin = new System.Windows.Forms.Padding(2);
            this.tabPage1.Name = "tabPage1";
            this.tabPage1.Padding = new System.Windows.Forms.Padding(2);
            this.tabPage1.Size = new System.Drawing.Size(469, 171);
            this.tabPage1.TabIndex = 0;
            this.tabPage1.Text = "Links";
            this.tabPage1.UseVisualStyleBackColor = true;
            // 
            // urlListView
            // 
            this.urlListView.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.urlListView.Columns.AddRange(new System.Windows.Forms.ColumnHeader[] {
            this.columnHeader1,
            this.columnHeader2});
            this.urlListView.ContextMenuStrip = this.contextMenuStrip1;
            this.urlListView.Dock = System.Windows.Forms.DockStyle.Top;
            this.urlListView.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.urlListView.FullRowSelect = true;
            this.urlListView.HeaderStyle = System.Windows.Forms.ColumnHeaderStyle.Nonclickable;
            this.urlListView.Location = new System.Drawing.Point(2, 2);
            this.urlListView.Margin = new System.Windows.Forms.Padding(2);
            this.urlListView.Name = "urlListView";
            this.urlListView.Size = new System.Drawing.Size(465, 137);
            this.urlListView.TabIndex = 4;
            this.urlListView.UseCompatibleStateImageBehavior = false;
            this.urlListView.View = System.Windows.Forms.View.Details;
            // 
            // columnHeader1
            // 
            this.columnHeader1.Text = "URL";
            this.columnHeader1.Width = 200;
            // 
            // columnHeader2
            // 
            this.columnHeader2.Text = "Test";
            this.columnHeader2.Width = 72;
            // 
            // contextMenuStrip1
            // 
            this.contextMenuStrip1.ImageScalingSize = new System.Drawing.Size(24, 24);
            this.contextMenuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.removeToolStripMenuItem});
            this.contextMenuStrip1.Name = "contextMenuStrip1";
            this.contextMenuStrip1.Size = new System.Drawing.Size(118, 26);
            // 
            // removeToolStripMenuItem
            // 
            this.removeToolStripMenuItem.Name = "removeToolStripMenuItem";
            this.removeToolStripMenuItem.Size = new System.Drawing.Size(117, 22);
            this.removeToolStripMenuItem.Text = "Remove";
            this.removeToolStripMenuItem.Click += new System.EventHandler(this.removeToolStripMenuItem_Click);
            // 
            // btnAddLink
            // 
            this.btnAddLink.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.btnAddLink.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnAddLink.Location = new System.Drawing.Point(2, 148);
            this.btnAddLink.Margin = new System.Windows.Forms.Padding(2);
            this.btnAddLink.Name = "btnAddLink";
            this.btnAddLink.Size = new System.Drawing.Size(465, 21);
            this.btnAddLink.TabIndex = 3;
            this.btnAddLink.Text = "Add Link";
            this.btnAddLink.UseVisualStyleBackColor = true;
            this.btnAddLink.Click += new System.EventHandler(this.btnAddLink_Click);
            // 
            // tabPage5
            // 
            this.tabPage5.Controls.Add(this.groupBox1);
            this.tabPage5.Controls.Add(this.chkEnableInstall);
            this.tabPage5.Location = new System.Drawing.Point(4, 27);
            this.tabPage5.Margin = new System.Windows.Forms.Padding(2);
            this.tabPage5.Name = "tabPage5";
            this.tabPage5.Size = new System.Drawing.Size(469, 171);
            this.tabPage5.TabIndex = 4;
            this.tabPage5.Text = "Install";
            this.tabPage5.UseVisualStyleBackColor = true;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label9);
            this.groupBox1.Controls.Add(this.txtPayloadName);
            this.groupBox1.Controls.Add(this.cbInstallFolder);
            this.groupBox1.Controls.Add(this.label10);
            this.groupBox1.Location = new System.Drawing.Point(8, 24);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(248, 100);
            this.groupBox1.TabIndex = 1;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Install";
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(16, 31);
            this.label9.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(60, 15);
            this.label9.TabIndex = 3;
            this.label9.Text = "File Name";
            // 
            // txtPayloadName
            // 
            this.txtPayloadName.Enabled = false;
            this.txtPayloadName.Location = new System.Drawing.Point(92, 27);
            this.txtPayloadName.Margin = new System.Windows.Forms.Padding(2);
            this.txtPayloadName.Name = "txtPayloadName";
            this.txtPayloadName.Size = new System.Drawing.Size(143, 23);
            this.txtPayloadName.TabIndex = 2;
            this.txtPayloadName.Text = "Payload.exe";
            // 
            // cbInstallFolder
            // 
            this.cbInstallFolder.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cbInstallFolder.Enabled = false;
            this.cbInstallFolder.FormattingEnabled = true;
            this.cbInstallFolder.Location = new System.Drawing.Point(92, 63);
            this.cbInstallFolder.Margin = new System.Windows.Forms.Padding(2);
            this.cbInstallFolder.Name = "cbInstallFolder";
            this.cbInstallFolder.Size = new System.Drawing.Size(143, 23);
            this.cbInstallFolder.TabIndex = 4;
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(16, 65);
            this.label10.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(40, 15);
            this.label10.TabIndex = 3;
            this.label10.Text = "Folder";
            // 
            // chkEnableInstall
            // 
            this.chkEnableInstall.AutoSize = true;
            this.chkEnableInstall.Location = new System.Drawing.Point(11, 6);
            this.chkEnableInstall.Margin = new System.Windows.Forms.Padding(2);
            this.chkEnableInstall.Name = "chkEnableInstall";
            this.chkEnableInstall.Size = new System.Drawing.Size(95, 19);
            this.chkEnableInstall.TabIndex = 1;
            this.chkEnableInstall.Text = "Enable Install";
            this.chkEnableInstall.UseVisualStyleBackColor = true;
            this.chkEnableInstall.CheckedChanged += new System.EventHandler(this.chkINS_CheckboxChanged);
            // 
            // tabPage2
            // 
            this.tabPage2.Controls.Add(this.btnRandom);
            this.tabPage2.Controls.Add(this.btnClone);
            this.tabPage2.Controls.Add(this.assemblyPrivatePart);
            this.tabPage2.Controls.Add(this.assemblyBuildPart);
            this.tabPage2.Controls.Add(this.assemblyMinorVersion);
            this.tabPage2.Controls.Add(this.assemblyMajorVersion);
            this.tabPage2.Controls.Add(this.label4);
            this.tabPage2.Controls.Add(this.label3);
            this.tabPage2.Controls.Add(this.label2);
            this.tabPage2.Controls.Add(this.label7);
            this.tabPage2.Controls.Add(this.label6);
            this.tabPage2.Controls.Add(this.label5);
            this.tabPage2.Controls.Add(this.label1);
            this.tabPage2.Controls.Add(this.txtProduct);
            this.tabPage2.Controls.Add(this.txtCompany);
            this.tabPage2.Controls.Add(this.txtDescription);
            this.tabPage2.Controls.Add(this.txtTrademark);
            this.tabPage2.Controls.Add(this.txtCopyright);
            this.tabPage2.Controls.Add(this.txtTitle);
            this.tabPage2.Location = new System.Drawing.Point(4, 27);
            this.tabPage2.Margin = new System.Windows.Forms.Padding(2);
            this.tabPage2.Name = "tabPage2";
            this.tabPage2.Padding = new System.Windows.Forms.Padding(2);
            this.tabPage2.Size = new System.Drawing.Size(469, 171);
            this.tabPage2.TabIndex = 1;
            this.tabPage2.Text = "Assembly";
            this.tabPage2.UseVisualStyleBackColor = true;
            // 
            // btnRandom
            // 
            this.btnRandom.Location = new System.Drawing.Point(315, 140);
            this.btnRandom.Margin = new System.Windows.Forms.Padding(2);
            this.btnRandom.Name = "btnRandom";
            this.btnRandom.Size = new System.Drawing.Size(70, 27);
            this.btnRandom.TabIndex = 3;
            this.btnRandom.Text = "Random";
            this.btnRandom.UseVisualStyleBackColor = true;
            this.btnRandom.Click += new System.EventHandler(this.btnRandom_Click);
            // 
            // btnClone
            // 
            this.btnClone.Location = new System.Drawing.Point(389, 140);
            this.btnClone.Margin = new System.Windows.Forms.Padding(2);
            this.btnClone.Name = "btnClone";
            this.btnClone.Size = new System.Drawing.Size(70, 27);
            this.btnClone.TabIndex = 2;
            this.btnClone.Text = "Clone...";
            this.btnClone.UseVisualStyleBackColor = true;
            this.btnClone.Click += new System.EventHandler(this.btnClone_Click);
            // 
            // assemblyPrivatePart
            // 
            this.assemblyPrivatePart.Location = new System.Drawing.Point(430, 95);
            this.assemblyPrivatePart.Margin = new System.Windows.Forms.Padding(2);
            this.assemblyPrivatePart.Name = "assemblyPrivatePart";
            this.assemblyPrivatePart.Size = new System.Drawing.Size(31, 23);
            this.assemblyPrivatePart.TabIndex = 1;
            // 
            // assemblyBuildPart
            // 
            this.assemblyBuildPart.Location = new System.Drawing.Point(392, 95);
            this.assemblyBuildPart.Margin = new System.Windows.Forms.Padding(2);
            this.assemblyBuildPart.Name = "assemblyBuildPart";
            this.assemblyBuildPart.Size = new System.Drawing.Size(31, 23);
            this.assemblyBuildPart.TabIndex = 1;
            // 
            // assemblyMinorVersion
            // 
            this.assemblyMinorVersion.Location = new System.Drawing.Point(354, 95);
            this.assemblyMinorVersion.Margin = new System.Windows.Forms.Padding(2);
            this.assemblyMinorVersion.Name = "assemblyMinorVersion";
            this.assemblyMinorVersion.Size = new System.Drawing.Size(31, 23);
            this.assemblyMinorVersion.TabIndex = 1;
            // 
            // assemblyMajorVersion
            // 
            this.assemblyMajorVersion.Location = new System.Drawing.Point(318, 95);
            this.assemblyMajorVersion.Margin = new System.Windows.Forms.Padding(2);
            this.assemblyMajorVersion.Name = "assemblyMajorVersion";
            this.assemblyMajorVersion.Size = new System.Drawing.Size(31, 23);
            this.assemblyMajorVersion.TabIndex = 1;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(11, 135);
            this.label4.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(49, 15);
            this.label4.TabIndex = 1;
            this.label4.Text = "Product";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(11, 97);
            this.label3.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(59, 15);
            this.label3.TabIndex = 1;
            this.label3.Text = "Company";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(11, 61);
            this.label2.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(67, 15);
            this.label2.TabIndex = 1;
            this.label2.Text = "Description";
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(249, 97);
            this.label7.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(45, 15);
            this.label7.TabIndex = 1;
            this.label7.Text = "Version";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(249, 61);
            this.label6.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(63, 15);
            this.label6.TabIndex = 1;
            this.label6.Text = "Trademark";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(249, 27);
            this.label5.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(60, 15);
            this.label5.TabIndex = 1;
            this.label5.Text = "Copyright";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(11, 27);
            this.label1.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(30, 15);
            this.label1.TabIndex = 1;
            this.label1.Text = "Title";
            // 
            // txtProduct
            // 
            this.txtProduct.Location = new System.Drawing.Point(87, 133);
            this.txtProduct.Margin = new System.Windows.Forms.Padding(2);
            this.txtProduct.Name = "txtProduct";
            this.txtProduct.Size = new System.Drawing.Size(143, 23);
            this.txtProduct.TabIndex = 0;
            // 
            // txtCompany
            // 
            this.txtCompany.Location = new System.Drawing.Point(87, 95);
            this.txtCompany.Margin = new System.Windows.Forms.Padding(2);
            this.txtCompany.Name = "txtCompany";
            this.txtCompany.Size = new System.Drawing.Size(143, 23);
            this.txtCompany.TabIndex = 0;
            // 
            // txtDescription
            // 
            this.txtDescription.Location = new System.Drawing.Point(87, 59);
            this.txtDescription.Margin = new System.Windows.Forms.Padding(2);
            this.txtDescription.Name = "txtDescription";
            this.txtDescription.Size = new System.Drawing.Size(143, 23);
            this.txtDescription.TabIndex = 0;
            // 
            // txtTrademark
            // 
            this.txtTrademark.Location = new System.Drawing.Point(318, 57);
            this.txtTrademark.Margin = new System.Windows.Forms.Padding(2);
            this.txtTrademark.Name = "txtTrademark";
            this.txtTrademark.Size = new System.Drawing.Size(143, 23);
            this.txtTrademark.TabIndex = 0;
            // 
            // txtCopyright
            // 
            this.txtCopyright.Location = new System.Drawing.Point(318, 23);
            this.txtCopyright.Margin = new System.Windows.Forms.Padding(2);
            this.txtCopyright.Name = "txtCopyright";
            this.txtCopyright.Size = new System.Drawing.Size(143, 23);
            this.txtCopyright.TabIndex = 0;
            // 
            // txtTitle
            // 
            this.txtTitle.Location = new System.Drawing.Point(87, 23);
            this.txtTitle.Margin = new System.Windows.Forms.Padding(2);
            this.txtTitle.Name = "txtTitle";
            this.txtTitle.Size = new System.Drawing.Size(143, 23);
            this.txtTitle.TabIndex = 0;
            // 
            // tabPage3
            // 
            this.tabPage3.Controls.Add(this.pictureIcon);
            this.tabPage3.Controls.Add(this.s);
            this.tabPage3.Controls.Add(this.label8);
            this.tabPage3.Controls.Add(this.txtIcon);
            this.tabPage3.Location = new System.Drawing.Point(4, 27);
            this.tabPage3.Margin = new System.Windows.Forms.Padding(2);
            this.tabPage3.Name = "tabPage3";
            this.tabPage3.Size = new System.Drawing.Size(469, 171);
            this.tabPage3.TabIndex = 2;
            this.tabPage3.Text = "Icon";
            this.tabPage3.UseVisualStyleBackColor = true;
            // 
            // pictureIcon
            // 
            this.pictureIcon.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pictureIcon.Location = new System.Drawing.Point(87, 50);
            this.pictureIcon.Margin = new System.Windows.Forms.Padding(2);
            this.pictureIcon.Name = "pictureIcon";
            this.pictureIcon.Size = new System.Drawing.Size(64, 64);
            this.pictureIcon.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pictureIcon.TabIndex = 4;
            this.pictureIcon.TabStop = false;
            // 
            // s
            // 
            this.s.Location = new System.Drawing.Point(382, 17);
            this.s.Margin = new System.Windows.Forms.Padding(2);
            this.s.Name = "s";
            this.s.Size = new System.Drawing.Size(69, 32);
            this.s.TabIndex = 1;
            this.s.Text = "Browse ...";
            this.s.UseVisualStyleBackColor = true;
            this.s.Click += new System.EventHandler(this.btnIconOpen_Click);
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(11, 27);
            this.label8.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(57, 15);
            this.label8.TabIndex = 3;
            this.label8.Text = "Icon Path";
            // 
            // txtIcon
            // 
            this.txtIcon.Location = new System.Drawing.Point(87, 23);
            this.txtIcon.Margin = new System.Windows.Forms.Padding(2);
            this.txtIcon.Name = "txtIcon";
            this.txtIcon.Size = new System.Drawing.Size(282, 23);
            this.txtIcon.TabIndex = 2;
            this.txtIcon.TextChanged += new System.EventHandler(this.txtIcon_TextChanged);
            // 
            // tabPage4
            // 
            this.tabPage4.Controls.Add(this.labelBuild);
            this.tabPage4.Controls.Add(this.btnBuild);
            this.tabPage4.Location = new System.Drawing.Point(4, 27);
            this.tabPage4.Margin = new System.Windows.Forms.Padding(2);
            this.tabPage4.Name = "tabPage4";
            this.tabPage4.Size = new System.Drawing.Size(469, 171);
            this.tabPage4.TabIndex = 3;
            this.tabPage4.Text = "Build";
            this.tabPage4.UseVisualStyleBackColor = true;
            // 
            // labelBuild
            // 
            this.labelBuild.AutoSize = true;
            this.labelBuild.Location = new System.Drawing.Point(11, 29);
            this.labelBuild.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.labelBuild.Name = "labelBuild";
            this.labelBuild.Size = new System.Drawing.Size(16, 15);
            this.labelBuild.TabIndex = 2;
            this.labelBuild.Text = "...";
            // 
            // btnBuild
            // 
            this.btnBuild.Location = new System.Drawing.Point(5, 141);
            this.btnBuild.Margin = new System.Windows.Forms.Padding(2);
            this.btnBuild.Name = "btnBuild";
            this.btnBuild.Size = new System.Drawing.Size(461, 32);
            this.btnBuild.TabIndex = 1;
            this.btnBuild.Text = "Build";
            this.btnBuild.UseVisualStyleBackColor = true;
            this.btnBuild.Click += new System.EventHandler(this.btnBuild_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(477, 202);
            this.Controls.Add(this.tabControl1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(2);
            this.Name = "Form1";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Lime Downloader v4.2";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.tabControl1.ResumeLayout(false);
            this.tabPage1.ResumeLayout(false);
            this.contextMenuStrip1.ResumeLayout(false);
            this.tabPage5.ResumeLayout(false);
            this.tabPage5.PerformLayout();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.tabPage2.ResumeLayout(false);
            this.tabPage2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.assemblyPrivatePart)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.assemblyBuildPart)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.assemblyMinorVersion)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.assemblyMajorVersion)).EndInit();
            this.tabPage3.ResumeLayout(false);
            this.tabPage3.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureIcon)).EndInit();
            this.tabPage4.ResumeLayout(false);
            this.tabPage4.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.TabControl tabControl1;
        private System.Windows.Forms.TabPage tabPage1;
        private System.Windows.Forms.TabPage tabPage2;
        private System.Windows.Forms.NumericUpDown assemblyPrivatePart;
        private System.Windows.Forms.NumericUpDown assemblyBuildPart;
        private System.Windows.Forms.NumericUpDown assemblyMinorVersion;
        private System.Windows.Forms.NumericUpDown assemblyMajorVersion;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtProduct;
        private System.Windows.Forms.TextBox txtCompany;
        private System.Windows.Forms.TextBox txtDescription;
        private System.Windows.Forms.TextBox txtTrademark;
        private System.Windows.Forms.TextBox txtCopyright;
        private System.Windows.Forms.TextBox txtTitle;
        private System.Windows.Forms.TabPage tabPage3;
        private System.Windows.Forms.TabPage tabPage4;
        private System.Windows.Forms.PictureBox pictureIcon;
        private System.Windows.Forms.Button s;
        private System.Windows.Forms.Label label8;
        private System.Windows.Forms.TextBox txtIcon;
        private System.Windows.Forms.Button btnBuild;
        private System.Windows.Forms.Button btnAddLink;
        private System.Windows.Forms.ListView urlListView;
        private System.Windows.Forms.ColumnHeader columnHeader1;
        private System.Windows.Forms.ColumnHeader columnHeader2;
        private System.Windows.Forms.ContextMenuStrip contextMenuStrip1;
        private System.Windows.Forms.ToolStripMenuItem removeToolStripMenuItem;
        private System.Windows.Forms.Button btnRandom;
        private System.Windows.Forms.Button btnClone;
        private System.Windows.Forms.Label labelBuild;
        private System.Windows.Forms.TabPage tabPage5;
        private System.Windows.Forms.ComboBox cbInstallFolder;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.TextBox txtPayloadName;
        private System.Windows.Forms.CheckBox chkEnableInstall;
        private System.Windows.Forms.Label label10;
        private System.Windows.Forms.GroupBox groupBox1;
    }
}

