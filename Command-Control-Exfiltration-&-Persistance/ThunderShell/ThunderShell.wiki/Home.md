### Requirements

Redis server is required to run ThunderShell.

```
sudo apt install -y mono-mcs redis-server
```

### Installation

```
cd /opt/
git clone https://github.com/Mr-Un1k0d3r/ThunderShell
cd ThunderShell 
sudo pip3 install -r requirements.txt
```

### Configuration

You will need to substitute the IP address in `default.json` with the IP address of your server.

```
{
    "aliases": {
        "myalias": ""
    },
    "callback-url": "http://192.168.1.5:8080",
    "cli-sync-delay": 5,
    "debug-mode": "off",
    "encryption-key": "PppEWCIgXbsepIwnuRIHtQLC",
    "gui-font-family": "\"Trebuchet MS\", Helvetica, sans-serif",
    "gui-font-size": "0.35cm",
    "gui-host": "192.168.1.5",
    "gui-https-cert-path": "cert.pem",
    "gui-https-enabled": "off",
    "gui-port": "13337",
    "http-default-404": "default.html",
    "http-download-path": "cat.png",
    "http-host": "192.168.1.5",
    "http-port": 8080,
    "http-profile": "profile.json",
    "http-server": "Microsoft-IIS/7.5",
    "https-cert-path": "cert.pem",
    "https-enabled": "off",
    "max-output-timeout": 5,
    "notify-email-password": "password",
    "notify-email-server": "smtp.gmail.com",
    "notify-email-server-port": 587,
    "notify-email-server-tls": "on",
    "notify-email-subject": "New Shell Callback",
    "notify-email-username": "",
    "notify-list": [
        "mr.un1k0d3r@gmail.com",
        ""
    ],
    "notify-new-shell": "off",
    "redis-host": "localhost",
    "redis-port": 6379,
    "server-password": "YaWNdpwplLwycqWQDCyruhAFsYjWjnBA"
}
```

The `server-password` and `encryption-key` are generated automatically after the first successful initiation.

### HTTPS configuration

If `https-enabled` is `on`, `https-cert-path` must point to a PEM file with the structure below.

If `gui-https-enabled` is `on`, `gui-https-cert-path` must point to a PEM file with the structure below.
```
-----BEGIN RSA PRIVATE KEY-----
... (private key in base64 encoding) ...
-----END RSA PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
... (certificate in base64 PEM encoding) ...
-----END CERTIFICATE-----
```

### Starting ThunderShell

Start the Redis server.

```
redis-server
```

Split the Terminal horizontally or open a new tab.

```
python3 ThunderShell.py default.json MrUn1k0d3r

             .#"    =[ ThunderShell version 3.1.2 | RingZer0 Team ]=
           .##"
        .###"       __       __    _________    __            __
       ###P        ###|     ###|  ##########|  ###|          ###|
     d########"    ###|     ###|  ###|         ###|          ###|
     ****####"     ###|_____###|  ###|__       ###|          ###|
       .###"       ############|  ######|      ###|          ###|
      .##"         ###|     ###|  ###|         ###|          ###|
     .#"           ###|     ###|  ###|______   ###|_______   ###|_______
    ."             ###|     ###|  ##########|  ###########|  ###########|


        
[*] Current active CLI session UUID is b2aca334-f33e-409b-a44c-a999fdb2cb7b
[*] Web GUI Started: http://192.168.1.5:13337
[*] Web GUI Password: YaWNdpwplLwycqWQDCyruhAFsYjWjnBA
[*] Starting web server on 192.168.1.5 port 8080

(Main)>>>
```

Where:
* `default.json` is the configuration file.
* `MrUn1k0d3r` is the username for the session.

By default, the httpd daemon and web GUI will be launched. The program can also be started without the httpd daemon and the web GUI using the following switches: 
* `-nohttpd` and `-nogui`
