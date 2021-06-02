using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.AccessControl;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Hosting;
using System.Web.Security;

namespace NxCommandAndControl.App_Start.Masterpassword
{
    /// <summary>
    /// Manager Class for Master Password. The Master Password is Protected using 2 Layers of Encryption. First Using a Machine Key and Second with HardCoded Key
    /// </summary>
    public class MasterPasswordManager
    {
        /// <summary>
        /// Check if the Master Password File Exists
        /// </summary>
        /// <returns></returns>
        public bool Exists()
        {
            string fileAddress = this.GetPath();
            return File.Exists(fileAddress);
        }

        public string GetPath()
        {
            return HostingEnvironment.MapPath(Constants.MASTER_PASSWORD_FILE_LOCATION);
        }

        /// <summary>
        /// Generates a New Fresh MasterPassword
        /// </summary>
        /// <param name="userName"></param>
        /// <param name="password"></param>
        /// <returns></returns>
        public string Generate(string userName, string password)
        {
            string input = userName + Constants.MASTER_SEED + password;
            string result = "";

            using (SHA512 shaEngine = SHA512.Create())
            {
                result = Convert.ToBase64String(shaEngine.ComputeHash(Encoding.ASCII.GetBytes(userName)));
            }

            return result;
        }

        /// <summary>
        /// Save Master Password into the Destination File
        /// </summary>
        /// <param name="masterPassword"></param>
        public void Save(string masterPassword)
        {
            byte[] toFile = CryptoHelper.EncryptWithHardCodedKey(Encoding.ASCII.GetBytes(masterPassword));

            if (Constants.USE_MACHINE_KEY_ENCRYPTION)
            {
                toFile = MachineKey.Protect(toFile);
            }

            using (FileStream file = File.Create(this.GetPath(), 256))
            {
                file.Write(toFile, 0, toFile.Length);
                file.Flush();
            }
        }

        /// <summary>
        /// Recovery the Master Password from File
        /// </summary>
        /// <returns></returns>
        public string Open()
        {
            byte[] fileData;

            using (FileStream file = File.OpenRead(this.GetPath()))
            {
                fileData = new byte[file.Length];
                file.Read(fileData, 0, fileData.Length);
            }

            byte[] result;

            if (Constants.USE_MACHINE_KEY_ENCRYPTION)
            {
                result = MachineKey.Unprotect(fileData);
                result = CryptoHelper.DecryptWithHardCodedKey(result);
            } 
            else
            {
                result = CryptoHelper.DecryptWithHardCodedKey(fileData);
            }

            return Encoding.ASCII.GetString(result);
        }

        /// <summary>
        /// Validate Login
        /// </summary>
        /// <param name="userName"></param>
        /// <param name="password"></param>
        /// <returns></returns>
        public bool Validade(string userName, string password)
        {
            string generatedData = this.Generate(userName, password);
            string current = this.Open();

            return generatedData.Equals(current, StringComparison.Ordinal);
        }
    }
}