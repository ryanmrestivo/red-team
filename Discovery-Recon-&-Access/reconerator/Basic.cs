using System;
using System.Xml;
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
    class Basic
    {

        // Creds bit is from https://gist.github.com/meziantou/10311113
        [DllImport("advapi32.dll", EntryPoint = "CredReadW", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern bool CredRead(string target, CRED_TYPE type, int reservedFlag, out IntPtr credentialPtr);

        [DllImport("netapi32.dll", CharSet = CharSet.Auto)]
        static extern int NetWkstaGetInfo(string server,
            int level,
            out IntPtr info);

        [DllImport("netapi32.dll")]
        static extern int NetApiBufferFree(IntPtr pBuf);

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        class WKSTA_INFO_100
        {
            public int wki100_platform_id;
            [MarshalAs(UnmanagedType.LPWStr)]
            public string wki100_computername;
            [MarshalAs(UnmanagedType.LPWStr)]
            public string wki100_langroup;
            public int wki100_ver_major;
            public int wki100_ver_minor;
        }

        public enum CRED_TYPE : int
        {
            GENERIC = 1,
            DOMAIN_PASSWORD = 2,
            DOMAIN_CERTIFICATE = 3,
            DOMAIN_VISIBLE_PASSWORD = 4,
            MAXIMUM = 5
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        public struct CREDENTIAL
        {
            public int flags;
            public int type;
            [MarshalAs(UnmanagedType.LPWStr)]
            public string targetName;
            [MarshalAs(UnmanagedType.LPWStr)]
            public string comment;
            public FILETIME lastWritten;
            public int credentialBlobSize;
            public IntPtr credentialBlob;
            public int persist;
            public int attributeCount;
            public IntPtr credAttribute;
            [MarshalAs(UnmanagedType.LPWStr)]
            public string targetAlias;
            [MarshalAs(UnmanagedType.LPWStr)]
            public string userName;
        } 


        public void GetEnvironmentVariables()
        {
            // Grab the environment variables for the host
            foreach (System.Collections.DictionaryEntry env in Environment.GetEnvironmentVariables())
            {
                string name = (string)env.Key;
                string value = (string)env.Value;
                Console.Out.WriteLine("{0}={1}", name, value);
            }
        }

        public void GetHostInformation()
        {
            IntPtr pBuffer = IntPtr.Zero;

            WKSTA_INFO_100 info;
            int retval = NetWkstaGetInfo(null, 100, out pBuffer);
            if (retval == 0) { 
                info = (WKSTA_INFO_100)Marshal.PtrToStructure(pBuffer, typeof(WKSTA_INFO_100));
                Console.Out.WriteLine("LAN Group: {0}", info.wki100_langroup);
                Console.Out.WriteLine("Computer Name: {0}", info.wki100_computername);
                Console.Out.WriteLine("Platform ID: {0} ({1}.{2})", info.wki100_platform_id, info.wki100_ver_major, info.wki100_ver_minor);

            }
        }

        public void GetIPInformation() {
            string hostName = Dns.GetHostName(); // Retrive the Name of HOST  
            Console.Out.WriteLine("Hostname: {0}", hostName);  
        }

        public void ResolveHost(string host)
        {
            Console.Out.WriteLine("Resolving " + host);
            IPAddress[] ips = Dns.GetHostAddresses(host);
            int len_results = ips.Length;
            //Console.Out.WriteLine("{0} result{1}", len_results, (len_results!=1)?"s":"");
            foreach (IPAddress ip in ips) {
                Console.Out.WriteLine("Result: " + ip.ToString());
            }


        }
        public void IndexSearch(string searchparam)
        {
            try { 
                var connection = new OleDbConnection(@"Provider=Search.CollatorDSO;Extended Properties=""Application=Windows""");

                // File name search (case insensitive), also searches sub directories
                // @"WHERE scope ='file:C:/' AND System.ItemName LIKE '%Test%'";
                connection.Open();
                var query4 = @"SELECT System.ItemPathDisplay FROM SystemIndex WHERE " + searchparam;
                var command = new OleDbCommand(query4, connection);
                Console.Out.WriteLine("Query: " + query4);

                using (var r = command.ExecuteReader())
                {
                    while (r.Read())
                    {
                        Console.Out.WriteLine(r[0]);
                    }
                }

                connection.Close();
            }
            catch (Exception e)
            {
                Console.Out.WriteLine("Index Search Exception: " + e.Message);
            }
        }

        public void GetFavourites()
        {
            // TODO Make this recurse through directories too
            string[] favs = Directory.GetFiles(Environment.GetFolderPath(Environment.SpecialFolder.Favorites));
            foreach (string fav in favs) 
            {
                using (StreamReader rdr = new StreamReader(fav))
                {
                    string line;
                    string url;
                    while ((line = rdr.ReadLine()) != null)
                    {
                        if (line.StartsWith("URL=", StringComparison.InvariantCultureIgnoreCase))
                        {
                            if (line.Length > 4) {
                                url = line.Substring(4);
                                Console.Out.WriteLine("{0}:{1}", fav, url);
                            }
                            break;                            
                        }
                    }
                }
            }

        }

        public void GetMappedDrives()
        {
            ManagementObjectSearcher searcher = new ManagementObjectSearcher("select * from Win32_MappedLogicalDisk");
            foreach (ManagementObject drive in searcher.Get()) {
                Console.Out.WriteLine("{0} = {1} ({2})", drive["Name"].ToString(), drive["ProviderName"].ToString(), drive["VolumeName"].ToString());
                }
            }

        public void GetProxyInformation(string url)
        {
            IWebProxy wp = WebRequest.GetSystemWebProxy();
            Uri req = new Uri(url);
            Console.Out.WriteLine("URL Requested: " + req.AbsoluteUri);
            Uri proxy = wp.GetProxy(req);
            if (String.Compare(req.AbsoluteUri, proxy.AbsoluteUri) == 0)
            {
                Console.Out.WriteLine("Proxy: DIRECT");
            }
            else
            {
                Console.Out.WriteLine("Proxy: " + proxy.AbsoluteUri);
            }

            if (wp.Credentials != null) {
                NetworkCredential cred = wp.Credentials.GetCredential(req, "basic");
                Console.Out.WriteLine("Proxy Username: " + cred.UserName);
                Console.Out.WriteLine("Proxy Password: " + cred.Password);
                Console.Out.WriteLine("Proxy Domain: " + cred.Domain);
            }
            
            
        }

        private string GetReg(RegistryKey k, string v)
        {
            return (k.GetValue(v) != null) ? k.GetValue(v).ToString() : "";
        }
        public void GetOneDriveInformation()
        {

            // Get a list of the individual IDs to cross reference later
            StringBuilder final = new StringBuilder();                       

            RegistryKey rk = Registry.Users;
            foreach (string uid in rk.GetSubKeyNames())
            {
                StringBuilder sb = new StringBuilder();
                List<string> usedScopeIDs = new List<string>();

                IDictionary<string, Dictionary<string, string>> providerlist = new Dictionary<string, Dictionary<string, string>>();
                string syncengines = @"Software\SyncEngines\Providers\OneDrive";
                RegistryKey registryKey = Registry.Users.OpenSubKey(uid + "\\" + syncengines);
                if (registryKey != null)
                { // This key exists
                    foreach (string rname in registryKey.GetSubKeyNames())
                    {
                        RegistryKey sync = registryKey.OpenSubKey(rname);
                        if (sync != null)
                        {
                            IDictionary<string, string> provider = new Dictionary<string, string>();
                            foreach (string x in new List<string> {"LibraryType","LastModifiedTime","MountPoint","UrlNamespace"}) {
                                provider[x] = GetReg(sync, x);
                            }
                            providerlist[rname] = (Dictionary<string, string>) provider;
                        }
                    }

                } else
                {
                    continue; // If the key doesn't exist, don't wait around
                }

                sb.AppendLine("\r\n[" + uid + "]");

                string basekey = "Software\\Microsoft\\OneDrive\\Accounts";
                registryKey = Registry.Users.OpenSubKey(uid + "\\" + basekey);
                if (registryKey != null)
                { // This key exists
                    foreach (string rname in registryKey.GetSubKeyNames())
                    {
                        RegistryKey accounts = registryKey.OpenSubKey(rname);
                        if (accounts != null)
                        {
                            Boolean IsPersonal = false; 
                            sb.AppendFormat("\r\n---- {0} ({1}) ----\r\n\r\n", rname, GetReg(accounts, "DisplayName"));
                            try
                            {

                                foreach (string x in new List<string> { "Business", "ServiceEndpointUri", "SPOResourceId", "UserEmail", "UserFolder", "UserName" })
                                {
                                    string result = GetReg(accounts, x).Trim();
                                    sb.AppendLine(String.Format("{0,19}: {1}", x, result));
                                    if (x == "Business")
                                    {
                                        IsPersonal = (result == "1") ? false : true;
                                    }
                                }

                                RegistryKey pc = accounts.OpenSubKey("ScopeIdToMountPointPathCache");
                                string[] scopeids;
                                if (IsPersonal == false)
                                    scopeids = pc.GetValueNames();
                                else
                                {
                                    List<string> list = new List<string>();
                                    list.Add("Personal");
                                    scopeids = list.ToArray();
                                }
                                usedScopeIDs.AddRange(scopeids);

                                if (pc != null || scopeids.Length > 0)
                                {
                                    foreach (string vname in scopeids)
                                    {
                                        if (!providerlist.ContainsKey(vname))
                                            continue;
                                        sb.AppendLine("");
                                        Dictionary<string, string> relevant = providerlist[vname];
                                        foreach (string x in new List<string> { "LibraryType", "LastModifiedTime", "MountPoint", "UrlNamespace" })
                                        {
                                            if (x == "LastModifiedTime")
                                            {
                                                DateTime parsedDate;
                                                DateTime.TryParse(relevant[x], out parsedDate);
                                                string formattedDate = parsedDate.ToString("ddd dd MMM yyyy HH:mm:ss");
                                                sb.AppendLine(String.Format(" | {0,16}: {1} [{2}]", x, relevant[x], formattedDate));
                                            }
                                            else
                                            {
                                                sb.AppendLine(String.Format(" | {0,16}: {1}", x, relevant[x]));
                                            }
                                        }
                                    }
                                }
                            }

                            catch (Exception e)
                            {
                                sb.AppendLine(String.Format("Exception: {0}", e.Message));
                            }
                        }
                    }

                }

                // Now check for any unused scopeids
                sb.AppendLine("\r\n\r\n---- Orphaned ----");
                foreach (string allscopes in new List<string>(providerlist.Keys))
                {
                    if (!usedScopeIDs.Contains(allscopes) && providerlist.ContainsKey(allscopes))
                    {
                        sb.AppendLine("");
                        Dictionary<string, string> relevant = providerlist[allscopes];
                        foreach (string x in new List<string> { "LibraryType", "LastModifiedTime", "MountPoint", "UrlNamespace" })
                        {
                            if (x == "LastModifiedTime")
                            {
                                DateTime parsedDate;
                                DateTime.TryParse(relevant[x], out parsedDate);
                                string formattedDate = parsedDate.ToString("ddd dd MMM yyyy HH:mm:ss");
                                sb.AppendLine(String.Format(" {0,16}: {1} [{2}]", x, relevant[x], formattedDate));
                            }
                            else
                            {
                                sb.AppendLine(String.Format(" {0,16}: {1}", x, relevant[x]));
                            }
                        }
                    }
                }

                final.AppendLine(sb.ToString());
            }

            Console.WriteLine(final.ToString());
            }

        public void GetInstalledApplications()
        {

            // Get Installed Applications
            Console.Out.WriteLine("\r\n---- Local Machine ----");
            string basekey = "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall";
            RegistryKey registryKey = Registry.LocalMachine.OpenSubKey(basekey);
            if (registryKey != null)
            { // This key exists
                foreach (string rname in registryKey.GetSubKeyNames())
                {
                    RegistryKey installedapp = registryKey.OpenSubKey(rname);
                    if (installedapp != null)
                    {
                        string displayname = (installedapp.GetValue("DisplayName") != null) ? installedapp.GetValue("DisplayName").ToString() : "";
                        string displayversion = (installedapp.GetValue("DisplayVersion") != null) ? installedapp.GetValue("DisplayVersion").ToString() : "";
                        string helplink = (installedapp.GetValue("HelpLink")!=null)?installedapp.GetValue("HelpLink").ToString():"";

                        if (!(Regex.IsMatch(displayname, "^(Service Pack \\d+|(Definition\\s|Security\\s)?Update) for") && Regex.IsMatch(helplink, "support\\.microsoft")) && displayname != "")
                            if (displayversion != "")
                                Console.Out.WriteLine(displayname + " (" + displayversion + ")");
                            else
                                Console.Out.WriteLine(displayname);
                    }
                }
            }

            Console.Out.WriteLine("\r\n---- Current User ----");
            basekey = "Software\\Microsoft\\Installer\\Products";
            registryKey = Registry.CurrentUser.OpenSubKey(basekey);
            if (registryKey != null)
            { // This key exists
                foreach (string rname in registryKey.GetSubKeyNames())
                {
                    RegistryKey installedapp = registryKey.OpenSubKey(rname);
                    if (installedapp != null)
                    {
                        string displayname = (installedapp.GetValue("ProductName") != null) ? installedapp.GetValue("ProductName").ToString() : "";
                        if (displayname != "")
                            Console.Out.WriteLine(displayname);
                    }
                }
            }

        }

        public void GetIEHistory()
        {

            string basekey = "Software\\Microsoft\\Internet Explorer\\TypedURLs";
            RegistryKey registryKey = Registry.CurrentUser.OpenSubKey(basekey);
            if (registryKey != null)
            { // This key exists
                foreach (string rname in registryKey.GetValueNames())
                {
                    string actual_value = registryKey.GetValue(rname).ToString();
                    Console.Out.WriteLine(rname+":"+actual_value);
                }
            }
        }

        public void GetInterestingData()
        {
            Console.Out.WriteLine("\r\n---- Keepass ----");
            string keepass_file = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Keepass\\Keepass.config.xml");
            if (File.Exists(keepass_file))
            {
                try
                {

                    Console.Out.WriteLine("Found user configuration file: " + keepass_file);
                    XmlDocument xmlDoc = new XmlDocument(); // Create an XML document object
                    xmlDoc.Load(keepass_file); // Load the XML document from the specified file

                    XmlNodeList recently_used = xmlDoc.SelectNodes("/Configuration/Application/LastUsedFile/Path");
                    for (int i = 0; i < recently_used.Count; i++)
                    {
                        XmlNode thisnode = recently_used.Item(i);
                        Console.Out.WriteLine("Last Used File: " + thisnode.InnerText);
                    }

                    recently_used = xmlDoc.SelectNodes("/Configuration/Application/MostRecentlyUsed/Items/ConnectionInfo/Path");
                    for (int i = 0; i < recently_used.Count; i++)
                    {
                        XmlNode thisnode = recently_used.Item(i);
                        Console.Out.WriteLine("Most Recently Used: " + thisnode.InnerText);
                    }

                    recently_used = xmlDoc.SelectNodes("/Configuration/Application/WorkingDirectories/Item");
                    for (int i = 0; i < recently_used.Count; i++)
                    {
                        XmlNode thisnode = recently_used.Item(i);
                        Console.Out.WriteLine("Working Directory: " + thisnode.InnerText);
                    }

                    recently_used = xmlDoc.SelectNodes("/Configuration/Defaults/KeySources/Association");
                    for (int i = 0; i < recently_used.Count; i++)
                    {
                        XmlNode thisnode = recently_used.Item(i);
                        Console.Out.WriteLine("Association: " + thisnode.InnerText);
                    }
                } 
                catch (Exception e)
                {
                    Console.Out.WriteLine("Exception: " + e.Message);
                }

                Console.Out.WriteLine("\r\n---- Terminal Services History ----");
                string basekey = "Software\\Microsoft\\Terminal Server Client\\Servers";
                RegistryKey registryKey = Registry.CurrentUser.OpenSubKey(basekey);
                if (registryKey != null && registryKey.SubKeyCount > 0)
                {
                    foreach (string rname in registryKey.GetSubKeyNames())
                    {
                        string usernamehint = "";
                        RegistryKey specific = registryKey.OpenSubKey(rname);
                        if (specific != null)
                        {
                            if (specific.GetValue("UsernameHint") != null) 
                                usernamehint = specific.GetValue("UsernameHint").ToString();
                            
                        }

                        if (usernamehint == "")
                            Console.Out.WriteLine(rname);
                        else
                            Console.Out.WriteLine(rname + " (" + usernamehint + ")");
                        
                    }
                }

            }
        }

        public void GetMRUInformation()
        {

            // Get Run MRU
            Console.Out.WriteLine("\r\n---- Run MRU ----");
            string basekey = "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\RunMRU";
            RegistryKey registryKey = Registry.CurrentUser.OpenSubKey(basekey);
            if (registryKey != null)
            { // This key exists
                foreach (string rname in registryKey.GetValueNames())
                {
                    string actual_value = registryKey.GetValue(rname).ToString();
                    Console.Out.WriteLine(actual_value);
                }
            }

            // Get recent documents
            Console.Out.WriteLine("\r\n---- Recent Documents ----");
            var recent_folder = Environment.GetFolderPath(Environment.SpecialFolder.Recent);
            Console.Out.WriteLine("Folder Location: {0}", recent_folder);

            string[] office_mru_paths = { 
                "Access\\File MRU", "Access\\Place MRU",
                "Excel\\File MRU", "Excel\\Place MRU",
                "PowerPoint\\File MRU", "PowerPoint\\Place MRU",
                "Word\\File MRU", "Word\\Place MRU",
                "Publisher\\File MRU", "Publisher\\Place MRU",
                "Visio\\File MRU", "Visio\\Place MRU",
            };

            string[] office_trusted_locations = { 
                "Access\\Security\\Trusted Locations", 
                "Excel\\Security\\Trusted Locations", 
                "PowerPoint\\Security\\Trusted Locations", 
                "Word\\Security\\Trusted Locations", 
                "Publisher\\Security\\Trusted Locations", 
                "Visio\\Security\\Trusted Locations", 
            };

            // Handle Office MRU & Trusted Locations
            basekey = "Software\\Microsoft\\Office";
            registryKey = Registry.CurrentUser.OpenSubKey(basekey);
            if (registryKey != null && registryKey.SubKeyCount > 0) { // This key exists

                // Go through the MRU
                Regex r = new Regex("^[0-9]+\\.[0-9]$", RegexOptions.IgnoreCase);
                Regex loc = new Regex("^Location[0-9]+$", RegexOptions.IgnoreCase);
                foreach (string rname in registryKey.GetSubKeyNames()) {
                    if (r.IsMatch(rname) == true) { // The key is in the form xx.x (or xxx.x etc) where x = a number

                        // Go through the MRU paths
                        foreach (string office_mru_path in office_mru_paths) {
                            string relative_key = rname + "\\" + office_mru_path;
                            RegistryKey rk2 = registryKey.OpenSubKey(relative_key);
                            if (rk2 != null) {
                                Console.Out.WriteLine("\r\n---- {0}\\{1} ----", basekey, relative_key);
                                foreach (string value in rk2.GetValueNames()) {
                                    string actual_value = rk2.GetValue(value).ToString();
                                    string sanitised_value = Regex.Replace(actual_value, "^\\[([[A-Z0-9]+\\]){3}\\*", "");
                                    Console.Out.WriteLine("{0}:{1}", value, sanitised_value);
                                }
                            }
                        }

                        // Go through the trusted locations
                        foreach (string office_trusted_location in office_trusted_locations)
                        {
                            string relative_key = rname + "\\" + office_trusted_location;
                            RegistryKey rk2 = registryKey.OpenSubKey(relative_key);
                            if (rk2 != null) {                            
                                Console.Out.WriteLine("\r\n---- {0}\\{1} ----", basekey, relative_key);
                                foreach (string kname in rk2.GetSubKeyNames()) {
                                    if (Regex.IsMatch(kname, "^Location[0-9]+$")) {
                                        RegistryKey rk3 = rk2.OpenSubKey(kname);
                                        Console.Out.WriteLine("{0}", rk3.GetValue("Path"));
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }
    }
}
