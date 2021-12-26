using System;
using System.IO;
using System.Security;
using System.Security.Cryptography;
using System.Runtime.InteropServices;
using System.Text;
using System.Net;
using System.Collections.Generic;
using System.Reflection;

namespace PSAttack.Utils
{
    class CryptoUtils
    {
        public static string GetKey()
        {
            Assembly assembly = Assembly.GetExecutingAssembly();
            StreamReader keyReader = new StreamReader(assembly.GetManifestResourceStream("PSAttack.Modules.key.txt"));
            string key = keyReader.ReadToEnd();
            return key;
        }
        
        public static string DecryptString(string text)
        {
            string key = GetKey();
            byte[] keyBytes;
            keyBytes = Encoding.Unicode.GetBytes(key);

            Rfc2898DeriveBytes derivedKey = new Rfc2898DeriveBytes(key, keyBytes);

            RijndaelManaged rijndaelCSP = new RijndaelManaged();
            rijndaelCSP.Key = derivedKey.GetBytes(rijndaelCSP.KeySize / 8);
            rijndaelCSP.IV = derivedKey.GetBytes(rijndaelCSP.BlockSize / 8);

            ICryptoTransform decryptor = rijndaelCSP.CreateDecryptor();
            string originalValue = text.Replace("_", "/");
            byte[] inputbuffer = Convert.FromBase64String(originalValue);
            byte[] outputBuffer = decryptor.TransformFinalBlock(inputbuffer, 0, inputbuffer.Length);
            return Encoding.Unicode.GetString(outputBuffer);
        }

        public static MemoryStream DecryptFile(Stream inputStream)
        {
            string key = GetKey();
            byte[] keyBytes = Encoding.Unicode.GetBytes(key);

            Rfc2898DeriveBytes derivedKey = new Rfc2898DeriveBytes(key, keyBytes);

            RijndaelManaged rijndaelCSP = new RijndaelManaged();
            rijndaelCSP.Key = derivedKey.GetBytes(rijndaelCSP.KeySize / 8);
            rijndaelCSP.IV = derivedKey.GetBytes(rijndaelCSP.BlockSize / 8);
            ICryptoTransform decryptor = rijndaelCSP.CreateDecryptor();

            CryptoStream decryptStream = new CryptoStream(inputStream, decryptor, CryptoStreamMode.Read);
            byte[] inputFileData = new byte[(int)inputStream.Length];
            string contents = new StreamReader(decryptStream).ReadToEnd();
            byte[] unicodes = Encoding.Unicode.GetBytes(contents);

            MemoryStream outputMemoryStream = new MemoryStream(unicodes);
            rijndaelCSP.Clear();

            decryptStream.Close();
            inputStream.Close();
            return outputMemoryStream;
        }
    }
}
