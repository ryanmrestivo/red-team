using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;

namespace SimpleRansoware
{
    /// <summary>
    /// Local File Manager
    /// </summary>
    public sealed class FileManager
    {
        private FileManager() { }

        /// <summary>
        /// Read File
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public static void ReadFile(FileInfo file, ref Byte[] fileData)
        {
            using (FileStream fs = File.OpenRead(file.FullName))
            {
                fileData = new Byte[fs.Length];
                fs.Read(fileData, 0, fileData.Length);
            }
        }
    }
}
