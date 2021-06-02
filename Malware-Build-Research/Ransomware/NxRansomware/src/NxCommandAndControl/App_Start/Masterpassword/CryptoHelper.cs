using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Security;

namespace NxCommandAndControl.App_Start.Masterpassword
{
    /// <summary>
    /// Helper for Crypto ;)
    /// </summary>
    public class CryptoHelper
    {
        public static byte[] KeyBuffer { get; private set; }

        public static byte[] IvBuffer { get; private set; }

        static CryptoHelper()
        {
            // Initialize Local Hardcoded Keys
            KeyBuffer = Initialize(Constants.HARD_CODED_KEY, 32);
            IvBuffer = Initialize(Constants.HARD_CODED_IV, 16);
        }

        private static byte[] Initialize(string seed, int size)
        {
            byte[] r;
            byte[] result;

            using (SHA512 sha = SHA512.Create())
            {
                r = sha.ComputeHash(Encoding.ASCII.GetBytes(seed));
            }

            result = Subset(r, size);

            return result;
        }


        /// <summary>
        /// Return a Source Array Subset
        /// </summary>
        /// <param name="source"></param>
        /// <param name="size"></param>
        /// <returns></returns>
        private static byte[] Subset(byte[] source, int size)
        {
            byte[] result = new byte[size];

            Array.Copy(source, result, size);

            return result;
        }

        public static byte[] EncryptWithHardCodedKey(byte[] source)
        {
            return Encrypt(source, KeyBuffer, IvBuffer);
        }

        public static byte[] Encrypt(byte[] source, byte[] key, byte[] iv)
        {
            byte[] result;

            using (Aes aesEngine = Aes.Create())
            {
                aesEngine.Mode = CipherMode.CBC;
                aesEngine.Padding = PaddingMode.PKCS7;

                using (ICryptoTransform transform = aesEngine.CreateEncryptor(key,iv))
                {
                    result = transform.TransformFinalBlock(source, 0, source.Length);
                }
            }

            return result;
        }


        public static byte[] Decrypt(byte[] source, byte[] key, byte[] iv)
        {
            byte[] result;

            using (Aes aesEngine = Aes.Create())
            {
                aesEngine.Mode = CipherMode.CBC;
                aesEngine.Padding = PaddingMode.PKCS7;

                using (ICryptoTransform transform = aesEngine.CreateDecryptor(key, iv))
                {
                    result = transform.TransformFinalBlock(source, 0, source.Length);
                }
            }

            return result;
        }

        public static byte[] DecryptWithHardCodedKey(byte[] source)
        {
            return Decrypt(source, KeyBuffer, IvBuffer);
        }
    }
}