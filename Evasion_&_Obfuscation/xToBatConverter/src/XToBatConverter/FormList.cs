using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Windows.Forms;

namespace XToBatConverter
{
    public partial class FormList : Form
    {

        public List<fileInfo> files;
        public struct fileInfo
        {
            public string filename;
            public string path;
            public string droppath;
            public Boolean exec;
            public long size;
        }

        public FormList()
        {
            InitializeComponent();
            files = new List<fileInfo>();
        }

        public void actualizeList()
        {
            listView1.Items.Clear();
            foreach (fileInfo element in files)
            {
                string[] row = { element.filename, element.size.ToString(), element.path, element.droppath, "" };
                if (element.exec) row[4] = "x";
                var listViewItem = new ListViewItem(row);
                listView1.Items.Add(listViewItem);
            }
        }

        public string genBat()
        {
            StringBuilder builder = new StringBuilder();
            builder.AppendLine("@ echo off");
            foreach (fileInfo element in files)
            {
                Byte[] bytes = File.ReadAllBytes(element.path);
                builder.AppendLine(genCert(bytes, element.droppath, element.filename));
                if (element.exec) builder.AppendLine("start " + element.droppath + element.filename);
            }

            return builder.ToString();
        }

        public string genCert(Byte[] file, string drop, string filename)
        {
            StringBuilder builder = new StringBuilder();
            builder.AppendLine("echo -----BEGIN CERTIFICATE-----");
            builder.AppendLine(Convert.ToBase64String(file, Base64FormattingOptions.InsertLineBreaks));
            builder.AppendLine("-----END CERTIFICATE-----");
            string s2 = builder.ToString().Replace("\n", "\necho ");
            s2 = "(\n" + s2 + "\n) >>" + drop + "_" + filename + "_.b64" + "\ncertutil -decode " + drop +
                 "_" + filename + "_.b64 \"" + drop + filename + "\"\ndel " + drop + "*_.b64";
            return s2;
        }

        private void addToolStripMenuItem_Click(object sender, EventArgs e)
        {
            addForm addNewFile = new addForm(this);
            addNewFile.Show();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            if (sfdBatchFile.ShowDialog() == DialogResult.OK)
            {
                File.AppendAllText(sfdBatchFile.FileName, genBat());
            }
        }

        private void deleteToolStripMenuItem_Click(object sender, EventArgs e)
        {
            foreach (fileInfo element in files)
            {
                if (string.Equals(element.path, listView1.SelectedItems[0].SubItems[2].Text))
                {
                    files.Remove(element);
                    actualizeList();
                    break;
                }
            }
        }
    }
}
