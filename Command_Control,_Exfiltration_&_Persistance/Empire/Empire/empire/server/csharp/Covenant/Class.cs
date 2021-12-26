// Author: Jake Krasnov (@_Hubbl3)
// Project: Empire (https://github.com/BC-SECURITY/Empire)
//

using System;
using System.Collections.Generic;
using System.Linq;
using System;
using System.Net;
using System.Net.Sockets;
using System.Text;

using Covenant.Core;
using Covenant.Core.Empire;
using Covenant.Models.Grunts;

namespace Covenant
{
    public class Start
    {
        public static void Main()
        {
            EmpireService service2 = new EmpireService();
            StartServer(service2);

        }
        //Use this for starting the server
        public static void StartServer(EmpireService service)
        {

            DbInitializer.Initialize(service);
            List<GruntTask> tsks = service.GetEmpire().gruntTasks;


            //arbitrary buffer size. This may need to change in the future
            byte[] buffer = new byte[10000000];
            IPEndPoint localEndPoint = new IPEndPoint(IPAddress.Parse("127.0.0.1"), 2012);
            Socket listener = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

                listener.Bind(localEndPoint);
                listener.Listen(100);

                while (true)
                {
                    Console.WriteLine("Compiler ready");
                    Socket socket = listener.Accept();
                    int bytesRec = socket.Receive(buffer);
                    //interpret the message
                    var data = Encoding.ASCII.GetString(buffer, 0, bytesRec);
                    string[] recMessage = data.Split(",");
                    //Data is sent with the TaskName first and then
                    var bytesTaskName = Convert.FromBase64String(recMessage[0]);
                    var bytesYAML = Convert.FromBase64String(recMessage[1]);
                    string strTaskName = Encoding.UTF8.GetString(bytesTaskName);
                    string strYAML = Encoding.UTF8.GetString(bytesYAML);
                    // Initialize the task from the passed YAML
                    DbInitializer.IngestTask(service, strYAML);
                    tsks = service.GetEmpire().gruntTasks;

                    try
                    {
                        if (strTaskName != "close")
                        {
                            GruntTask tsk = tsks.First(tk => tk.Name == strTaskName);
                            var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
                            var stringChars = new char[5];
                            var random = new Random();
                            for (int i = 0; i < stringChars.Length; i++)
                            {
                                stringChars[i] = chars[random.Next(chars.Length)];
                            }
                            var randNew = new String(stringChars);
                            tsk.Name = tsk.Name + "_" + randNew;
                            tsk.Compile();
                            string message = "FileName:" + tsk.Name;
                            var msgBytes = Encoding.ASCII.GetBytes(message);
                            socket.Send(msgBytes);
                        }
                        else
                        {
                            socket.Close();
                            break;
                        }
                    }
                    catch (Exception e)
                    {
                        string message = "Compile failed";
                        var msgBytes = Encoding.ASCII.GetBytes(message);
                        socket.Send(msgBytes);
                        Console.WriteLine(e.ToString());
                    }
                }

        }
    }
}
