# This is a quick egress test PowerShell script to see what ports (1-1024) are open from your network to the outside world
# The results get exported to a file called openports.txt that will get dropped in the same folder the script is run from
# Source: Black Hills Infosec (https://www.blackhillsinfosec.com/poking-holes-in-the-firewall-egress-testing-with-allports-exposed/)
#
1..1024 | % {$test= new-object system.Net.Sockets.TcpClient; $wait = $test.beginConnect("allports.exposed",$_,$null,$null); ($wait.asyncwaithandle.waitone(250,$false)); if($test.Connected){echo "$_ open"}else{echo "$_ closed"}} | select-string " " > openports.txt
