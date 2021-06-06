using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace BaphometDecrypt
{
    public class Decrypt
    {
        //Recorro directorio por directorio para recuperar la data
        public void directoryRoad(string targetPath, string password)
        {

            var extensionCheck = new[] { ".Baphomet" };
            
            string[] files = Directory.GetFiles(targetPath);
            string[] subDirs = Directory.GetDirectories(targetPath);

            for (int i = 0; i < files.Length; i++)
            {
                var extension = Path.GetExtension(files[i]);
                if (extensionCheck.Contains(extension))
                {
                    decryptFileData(files[i], password);
                }
            }

            for (int i = 0; i < subDirs.Length; i++)
            {
                directoryRoad(subDirs[i], password);
            }

        }

        static void decryptFileData(string file, string password)
        {

            byte[] bytesToBeDecrypted = File.ReadAllBytes(file);
            byte[] passwordBytes = Encoding.UTF8.GetBytes(password);
            passwordBytes = SHA256.Create().ComputeHash(passwordBytes);

            byte[] bytesDecrypted = decryptFileByte(bytesToBeDecrypted, passwordBytes);

            File.WriteAllBytes(file, bytesDecrypted);
            var extension = Path.GetExtension(file);
            var result = file.Substring(0, file.Length - extension.Length);
            System.IO.File.Move(file, result);
        }


        static byte[] decryptFileByte(byte[] bytesToBeDecrypted, byte[] passwordBytes)
        {
            byte[] decryptedBytes = null;
            byte[] saltBytes = new byte[] { 1, 2, 3, 4, 5, 6, 7, 8 };

            using (MemoryStream ms = new MemoryStream())
            {
                using (SymmetricAlgorithm aes = new AesManaged())
                {
                    aes.KeySize = 256;
                    aes.BlockSize = 128;

                    var key = new Rfc2898DeriveBytes(passwordBytes, saltBytes, 1000);
                    aes.Key = key.GetBytes(aes.KeySize / 8);
                    aes.IV = key.GetBytes(aes.BlockSize / 8);

                    aes.Mode = CipherMode.CBC;
                    using (var cs = new CryptoStream(ms, aes.CreateDecryptor(), CryptoStreamMode.Write))
                    {
                        cs.Write(bytesToBeDecrypted, 0, bytesToBeDecrypted.Length);
                        cs.Close();
                    }
                    decryptedBytes = ms.ToArray();

                }
            }
            return decryptedBytes;
        }
    }
}
