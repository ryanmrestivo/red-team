using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace XToBatConverter
{
    public partial class addForm : Form
    {
        public FormList.fileInfo newFile;
        public List<FormList.fileInfo> files;
        public FormList formPrincipal;

        public addForm(FormList form)
        {
            InitializeComponent();
            newFile = new FormList.fileInfo();
            formPrincipal = form;
        }

        private void textBox1_Click(object sender, EventArgs e)
        {
            if (opnFileDialog.ShowDialog() == DialogResult.OK)
            {
                tbFile.Text = newFile.path = opnFileDialog.FileName;
                newFile.filename = opnFileDialog.SafeFileName;
                newFile.size = new System.IO.FileInfo(newFile.path).Length;
            }
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            newFile.exec = chboxExec.Checked;
            newFile.droppath = tbDrop.Text;
            formPrincipal.files.Add(newFile);
            formPrincipal.actualizeList();
            this.Close();
        }
    }
}
