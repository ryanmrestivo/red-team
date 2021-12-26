$mycode = @"
//based on : https://blog.brunogarcia.com/2012/10/simple-tcp-forwarder-in-c.html
using System;
using System.Net;
using System.Net.Sockets;
 

    public class TcpForwarder
    {
        private readonly Socket _mainSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        private const int MAX_BYTES=8192;
       public static void StartPortFwd(string localhost, string localport, string remotehost, string remoteport)
        {
            new TcpForwarder().Start(
                 new IPEndPoint(IPAddress.Parse(localhost), int.Parse(localport)),
                 new IPEndPoint(IPAddress.Parse(remotehost), int.Parse(remoteport))
                 );
        }
        public void Start(IPEndPoint local, IPEndPoint remote)
        {
            _mainSocket.Bind(local);
            _mainSocket.Listen(10);
 
            while (true)
            {
                var source = _mainSocket.Accept();
                var destination = new TcpForwarder();
                var state = new State(source, destination._mainSocket);
                destination.Connect(remote, source);
                source.BeginReceive(state.Buffer, 0, state.Buffer.Length, 0, OnDataReceive, state);
            }
        }
 
        private void Connect(EndPoint remoteEndpoint, Socket destination)
        {
            var state = new State(_mainSocket, destination);
            _mainSocket.Connect(remoteEndpoint);
            _mainSocket.BeginReceive(state.Buffer, 0, state.Buffer.Length, SocketFlags.None, OnDataReceive, state);
        }
 
        private static void OnDataReceive(IAsyncResult result)
        {
            var state = (State)result.AsyncState;
            try
            {
                var bytesRead = state.SourceSocket.EndReceive(result);
                if (bytesRead > 0)
                {
                    state.DestinationSocket.Send(state.Buffer, bytesRead, SocketFlags.None);
                    state.SourceSocket.BeginReceive(state.Buffer, 0, state.Buffer.Length, 0, OnDataReceive, state);
                }
            }
            catch
            {
                state.DestinationSocket.Close();
                state.SourceSocket.Close();
            }
        }
 
        private class State
        {
            public Socket SourceSocket { get; private set; }
            public Socket DestinationSocket { get; private set; }
            public byte[] Buffer { get; private set; }
 
            public State(Socket source, Socket destination)
            {
                SourceSocket = source;
                DestinationSocket = destination;
                Buffer = new byte[MAX_BYTES];
            }
        }
    }

"@
Add-Type -TypeDefinition $mycode
#.\portfwd.ps1 127.0.0.1 8080 192.168.1.100 80
# launchable by standard user
Function Invoke-PortFwd {
    Param
    (
        [string]$Lhost,
        [string]$Lport,
        [string]$Rhost,
        [string]$Rport
    )
    [TcpForwarder]::StartPortFwd($Lhost, $Lport, $Rhost, $Rport)
}
