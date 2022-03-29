namespace XToBatConverter
{
    partial class addForm
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
            if (disposing && (components != null))
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
            this.lblPath = new System.Windows.Forms.Label();
            this.btnAdd = new System.Windows.Forms.Button();
            this.tbFile = new System.Windows.Forms.TextBox();
            this.tbDrop = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.opnFileDialog = new System.Windows.Forms.OpenFileDialog();
            this.chboxExec = new System.Windows.Forms.CheckBox();
            this.SuspendLayout();
            // 
            // lblPath
            // 
            this.lblPath.AutoSize = true;
            this.lblPath.Location = new System.Drawing.Point(13, 13);
            this.lblPath.Name = "lblPath";
            this.lblPath.Size = new System.Drawing.Size(23, 13);
            this.lblPath.TabIndex = 0;
            this.lblPath.Text = "file:";
            // 
            // btnAdd
            // 
            this.btnAdd.Location = new System.Drawing.Point(135, 86);
            this.btnAdd.Name = "btnAdd";
            this.btnAdd.Size = new System.Drawing.Size(75, 23);
            this.btnAdd.TabIndex = 1;
            this.btnAdd.Text = "save";
            this.btnAdd.UseVisualStyleBackColor = true;
            this.btnAdd.Click += new System.EventHandler(this.btnAdd_Click);
            // 
            // tbFile
            // 
            this.tbFile.Location = new System.Drawing.Point(62, 10);
            this.tbFile.Name = "tbFile";
            this.tbFile.Size = new System.Drawing.Size(148, 20);
            this.tbFile.TabIndex = 2;
            this.tbFile.Click += new System.EventHandler(this.textBox1_Click);
            // 
            // tbDrop
            // 
            this.tbDrop.Location = new System.Drawing.Point(62, 36);
            this.tbDrop.Name = "tbDrop";
            this.tbDrop.Size = new System.Drawing.Size(148, 20);
            this.tbDrop.TabIndex = 3;
            this.tbDrop.Text = "%cd%\\";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(13, 39);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(43, 13);
            this.label1.TabIndex = 4;
            this.label1.Text = "drop to:";
            // 
            // opnFileDialog
            // 
            this.opnFileDialog.FileName = "openFileDialog1";
            // 
            // chboxExec
            // 
            this.chboxExec.AutoSize = true;
            this.chboxExec.Location = new System.Drawing.Point(16, 62);
            this.chboxExec.Name = "chboxExec";
            this.chboxExec.Size = new System.Drawing.Size(137, 17);
            this.chboxExec.TabIndex = 5;
            this.chboxExec.Text = "execute after extraction";
            this.chboxExec.UseVisualStyleBackColor = true;
            // 
            // addForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(220, 121);
            this.Controls.Add(this.chboxExec);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.tbDrop);
            this.Controls.Add(this.tbFile);
            this.Controls.Add(this.btnAdd);
            this.Controls.Add(this.lblPath);
            this.Name = "addForm";
            this.Text = "addForm";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label lblPath;
        private System.Windows.Forms.Button btnAdd;
        private System.Windows.Forms.TextBox tbFile;
        private System.Windows.Forms.TextBox tbDrop;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.OpenFileDialog opnFileDialog;
        private System.Windows.Forms.CheckBox chboxExec;
    }
}