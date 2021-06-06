using System;
using System.IO;

namespace BaphometDecrypt
{
    class Program
    {
        static void Main()
        {
            Decrypt decrypt = new Decrypt();

            var userName = Environment.UserName;
            //Directorios cifrados("Desktop","Documents","Pictures" etc)
            //debemos tener los mismos directorios que colocamos en el proyecto Baphomet
            var Dirs = new[] { "\\Downloads" };
            var userDir = Path.Combine("C:\\Users\\",userName);
            var password = Message();

            for (int d = 0; d < Dirs.Length; d++)//recorro cada uno de los dirs validos
            {
                var decryp_targetPath = userDir + Dirs[d];
                decrypt.directoryRoad(decryp_targetPath, password);
            }
        }

        //Aqui pediremos la llave con la que ciframos los archivos.
        static string Message()
        {
            Console.BackgroundColor = ConsoleColor.DarkRed;
            Console.WriteLine("Enter your key here:");
            string password = Console.ReadLine();
            return password;
        }//</message>
    }
}
