using System;
using System.IO;

namespace NitroRansomware
{
    class Logs
    {
        private string save;
        private string filename;
        private string config;
        private int type;
        public Logs(string configType, int outType)
        {
            save = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
            filename = "\\logs.txt";
            config = configType;
            type = outType; 
        }
        private void Write(string append, string message)
        {
            if (type == 1)
            {
                using (StreamWriter w = File.AppendText(save + filename))
                {
                    string intro = String.Format("{0} {1} - ", DateTime.Now.ToString("[hh:mm:ss]"), append);
                    w.Write(intro + message);
                    w.Write("\n");
                }
            }
            else if (type == 0)
            {
                string intro = String.Format("{0} {1} - ", DateTime.Now.ToString("[hh:mm:ss]"), append);
                Console.Write(intro + message);
                Console.Write("\n");
            }
            else {
                using (StreamWriter w = File.AppendText(save + filename))
                {
                    string intro = String.Format("{0} {1} - ", DateTime.Now.ToString("[hh:mm:ss]"), append);
                    w.Write(intro + message);
                    w.Write("\n");
                }
                string consoleIntro = String.Format("{0} {1} - ", DateTime.Now.ToString("[hh:mm:ss]"), append);
                Console.Write(consoleIntro + message);
                Console.Write("\n");
            }
        }
        public void Debug(string message)
        {
            if (config == "DEBUG")
            {
                Write("DEBUG", message);
            }
        }
        public void Info(string message)
        {
            if (config == "DEBUG")
            {
                Write("INFO", message);
            }

            else if (config == "INFO")
            {
                Write("INFO", message);
            }
        }
        public void Warning(string message)
        {
            if (config != "ERROR")
            {
                Write("WARNING", message);
            }
        }
        public void Error(string message)
        {
            Write("ERROR", message);
        }
    }
}
