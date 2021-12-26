using System;

namespace Reconerator
{
    class Recon
    {

        static void doLdap(string[] args) {

            if (args.Length==4) {
                // Do the LDAP query
                string dn = args[1];
                string filter = args[2];
                string limit = args[3];

                Console.Out.WriteLine("\r\n=========== LDAP QUERY ===========");
                LDAP l = new LDAP();
                l.LDAPQuery(dn, filter, Int32.Parse(limit));
            } else {
                Console.Out.WriteLine("Error parsing parameters");
            }

        }

        static void doIndexSearch(string[] args)
        {
            Basic b = new Basic();
            b.IndexSearch(args[1]);
        }

        static void doResolveHost(string[] args)
        {
            Basic b = new Basic();
            b.ResolveHost(args[1]);
        }

        static void doProxyCheck(string[] args)
        {
            Basic b = new Basic();
            b.GetProxyInformation(args[1]);
        }

        static void doPrivescCheck(string[] args)
        {
            PrivescCheck p = new PrivescCheck();

            Boolean showall = false;
            if (args.Length != 2)
            {
                Console.Out.WriteLine("Error parsing parameters.");
                return;
            }

            string req = args[1];

            if (String.Compare(req, "all", ignoreCase: true) == 0)
            {
                showall = true;
            }

            if (showall == true || String.Compare(req, "alwaysinstallelevated", ignoreCase: true) == 0)
            {
                Console.Out.WriteLine("\r\n=========== AlwaysInstallElevated ===========");
                p.AlwaysInstallElevated();
            }

            if (showall == true || String.Compare(req, "unquotedservicepaths", ignoreCase: true) == 0)
            {
                Console.Out.WriteLine("\r\n=========== Unquoted Service Paths ===========");
                p.UnquotedServicePath();
            }


        }

        static void doBasic(string[] args) {

            Boolean showall = false;
            if (args.Length!= 2) {
                Console.Out.WriteLine("Error parsing parameters.");
                return;
            }

            Basic b = new Basic();
            string req = args[1];

            if (String.Compare(req, "all", ignoreCase: true) == 0) { 
                showall = true;

                // Add a proxy check in this
                Console.Out.WriteLine("\r\n=========== PROXY CHECKER (https://www.google.com) ===========");
                string[] fakeargs = { "proxycheck", "https://www.google.com" };
                doProxyCheck(fakeargs);
            }

            // Environment variables
            if (showall == true || String.Compare(req, "env", ignoreCase: true)==0) {
                // Dump out the environment variables
                Console.Out.WriteLine("\r\n=========== ENVIRONMENT VARIABLES ===========");
                b.GetEnvironmentVariables();
            }

            // Dump out the IP information 
            if (showall == true || String.Compare(req, "info", ignoreCase: true) == 0)
            { 
                Console.Out.WriteLine("\r\n=========== HOST INFORMATION ===========");
                b.GetIPInformation();
                b.GetHostInformation();
            }

            // Dump out the MRU
            if (showall == true || String.Compare(req, "mru", ignoreCase: true) == 0)
            { 
                Console.Out.WriteLine("\r\n=========== MRU INFORMATION ===========");
                b.GetMRUInformation();
            }

            // Favourites
            if (showall == true || String.Compare(req, "favourites", ignoreCase: true) == 0)
            { 
                Console.Out.WriteLine("\r\n=========== URL BOOKMARKS ===========");
                b.GetFavourites();
            }

            // IE History
            if (showall == true || String.Compare(req, "iehistory", ignoreCase: true) == 0)
            {
                Console.Out.WriteLine("\r\n=========== INTERNET EXPLORER HISTORY ===========");
                b.GetIEHistory();
            }

            // Interesting Data
            if (showall == true || String.Compare(req, "interestingdata", ignoreCase: true) == 0)
            {
                Console.Out.WriteLine("\r\n=========== INTERESTING FILES & DATA ===========");
                b.GetInterestingData();
            }

            // Mapped Drives
            if (showall == true || String.Compare(req, "mappeddrives", ignoreCase: true) == 0)
            { 
                Console.Out.WriteLine("\r\n=========== MAPPED DRIVES ===========");
                b.GetMappedDrives();
            }

            // OneDrive
            if (showall == true || String.Compare(req, "onedrive", ignoreCase: true) == 0)
            {
                Console.Out.WriteLine("\r\n=========== ONEDRIVE ===========");
                b.GetOneDriveInformation();
            }

            // Installed Applications
            if (showall == true || String.Compare(req, "installedapplications", ignoreCase: true) == 0)
            {
                Console.Out.WriteLine("\r\n=========== INSTALLED APPLICATIONS ===========");
                b.GetInstalledApplications();
            }

        }

        static void Main(string[] args)
        {
#if !DEBUG
            try
            {
#endif

                if (args == null || args.Length < 2)
                {
                    string[] fakeargs = { "basic", "all" };
                    doBasic(fakeargs);
                    // Assume we're doing BASIC ALL
                }
                else
                {

                    if (String.Compare(args[0], "basic", ignoreCase: true) == 0)
                        doBasic(args);

                    else if (String.Compare(args[0], "ldap", ignoreCase: true) == 0)
                        doLdap(args);

                    else if (String.Compare(args[0], "indexsearch", ignoreCase: true) == 0)
                        doIndexSearch(args);

                    else if (String.Compare(args[0], "proxycheck", ignoreCase: true) == 0)
                        doProxyCheck(args);

                    else if (String.Compare(args[0], "resolvehost", ignoreCase: true) == 0)
                        doResolveHost(args);

                    else if (String.Compare(args[0], "privesccheck", ignoreCase: true) == 0)
                        doPrivescCheck(args);
            }
#if !DEBUG
        }

    
        catch (Exception e)
            {
                Console.Out.WriteLine("Exception: " + e.Message);
            }

#endif
#if DEBUG
                Console.ReadLine(); // Stop the box auto-closing - DEBUG ONLY  
#endif
        }
    }

}