using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Data.OleDb;
using System.Text;
using System.Net;  
using Microsoft.Win32;
using System.Text.RegularExpressions;
using System.IO;
using System.Management;

namespace Reconerator
{
    class PrivescCheck
    {

        public void UnquotedServicePath()
        {
            ConnectionOptions options = new ConnectionOptions();
            string providerPath = @"root\CIMv2";
            ManagementScope scope = new ManagementScope(providerPath, options);
            scope.Connect();

            ObjectQuery query = new ObjectQuery("SELECT Started,Name,PathName,Description,ServiceType,StartMode,StartName FROM Win32_Service");
            ManagementObjectSearcher searcher = new ManagementObjectSearcher(scope, query);

            foreach (ManagementObject o in searcher.Get())
            {
                if (o != null && o["PathName"] != null && (string) o["PathName"] != "") {
                    string pathname = o["PathName"].ToString();
                    
                    if (Regex.IsMatch(pathname, "^[^\"].+?\\s.+?\\.exe", RegexOptions.IgnoreCase))
                    {
                        Console.Out.WriteLine("\r\nName: " + o["Name"]);
                        Console.Out.WriteLine("Path: " + o["PathName"]);
                        Console.Out.WriteLine("Description: " + o["Description"]);
                        Console.Out.WriteLine("Start Mode: " + o["StartMode"]);
                        Console.Out.WriteLine("User: " + o["StartName"]);
                        Console.Out.WriteLine("Started: " + o["Started"]);
                    }
                }
            }

        }

        public void AlwaysInstallElevated()
        {
            Boolean hklm = false;
            Boolean hkcu = false;
            
            string basekey = "Software\\Policies\\Microsoft\\Windows\\Installer";
            RegistryKey registryKey = Registry.LocalMachine.OpenSubKey(basekey);
            if (registryKey != null)
            { // This key exists
                var aie = registryKey.GetValue("AlwaysInstallElevated");
                if (aie != null  && String.Compare(aie.ToString(), "1")==0)
                    hklm = true;
            }

            basekey = "Software\\Policies\\Microsoft\\Windows\\Installer";
            registryKey = Registry.CurrentUser.OpenSubKey(basekey);
            if (registryKey != null)
            { // This key exists
                var aie = registryKey.GetValue("AlwaysInstallElevated");
                if (aie != null && String.Compare(aie.ToString(), "1")==0)
                    hkcu = true;
            }

            Console.Out.WriteLine("HKCU: {0}", (hkcu==false)?"Not set/not vulnerable":"ENABLED");
            Console.Out.WriteLine("HKLM: {0}", (hklm == false)?"Not set/not vulnerable" : "ENABLED");
        }
    }
}
