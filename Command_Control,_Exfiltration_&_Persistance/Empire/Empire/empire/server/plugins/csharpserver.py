from __future__ import print_function

import os

from empire.server.common.plugins import Plugin
import empire.server.common.helpers as helpers

import subprocess
import time
import socket
import base64


class Plugin(Plugin):
    description = "Empire C# server plugin."

    def onLoad(self):
        print(helpers.color("[*] Loading Empire C# server plugin"))
        self.main_menu = None
        self.csharpserver_proc = None
        self.info = {
                        'Name': 'csharpserver',

                        'Author': ['@Cx01N'],

                        'Description': ('Empire C# server for agents.'),

                        'Software': '',

                        'Techniques': [''],

                        'Comments': []
                    },

        self.options = {
            'status': {
                'Description': 'Start/stop the Empire C# server.',
                'Required': True,
                'Value': 'start',
                'SuggestedValues': ['start', 'stop'],
                'Strict': True
            }
        }
        self.tcp_ip = '127.0.0.1'
        self.tcp_port = 2012
        self.status = 'OFF'

    def execute(self, command):
        # This is for parsing commands through the api
        try:
            # essentially switches to parse the proper command to execute
            self.options['status']['Value'] = command['status']
            results = self.do_csharpserver('')
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
        mainMenu.__class__.do_csharpserver = self.do_csharpserver
        self.installPath = mainMenu.installPath
        self.main_menu = mainMenu

    def do_csharpserver(self, *args):
        """
        Check if the Empire C# server is already running.
        """
        if len(args[0]) > 0:
            self.start = args[0]
        else:
            self.start = self.options['status']['Value']

        if not self.csharpserver_proc or self.csharpserver_proc.poll():
            self.status = "OFF"
        else:
            self.status = "ON"

        if not args:
            self.main_menu.plugin_socketio_message(self.info[0]['Name'],
                                                 "[*] Empire C# server is currently: %s" % self.status)
            self.main_menu.plugin_socketio_message(self.info[0]['Name'],
                                                 "[!] Empire C# <start|stop> <port>")

        elif self.start == "stop":
            if self.status == "ON":
                self.csharpserver_proc.kill()
                self.main_menu.plugin_socketio_message(self.info[0]['Name'],
                                                     "[*] Stopping Empire C# server")
                self.status = "OFF"
            else:
                self.main_menu.plugin_socketio_message(self.info[0]['Name'],
                                                     "[!] Empire C# server is already stopped")

        elif self.start == "start":
            if self.status == "OFF":
                # Will need to update this as we finalize the folder structure
                server_dll = self.installPath + "/csharp/Covenant/bin/Debug/netcoreapp3.1/EmpireCompiler.dll"
                # If dll hasn't been built yet
                if not os.path.exists(server_dll):
                    csharp_cmd = ["dotnet", "build", self.installPath + "/csharp/"]
                    self.csharpserverbuild_proc = subprocess.Popen(csharp_cmd)
                    time.sleep(10)
                    self.csharpserverbuild_proc.kill()

                self.main_menu.plugin_socketio_message(self.info[0]['Name'],
                                                     "[*] Starting Empire C# server")
                csharp_cmd = ["dotnet",
                              self.installPath + "/csharp/Covenant/bin/Debug/netcoreapp3.1/EmpireCompiler.dll"]
                self.csharpserver_proc = subprocess.Popen(csharp_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                self.status = "ON"
            else:
                self.main_menu.plugin_socketio_message(self.info[0]['Name'],
                                                       "[!] Empire C# server is already started")

            thread = helpers.KThread(target=self.thread_csharp_responses, args=())
            thread.daemon = True
            thread.start()

    def thread_csharp_responses(self):
        while True:
            output = self.csharpserver_proc.stdout.readline().rstrip()
            if output:
                print(helpers.color('[*] ' + output.decode('UTF-8')))

    def do_send_message(self, compiler_yaml, task_name):
        bytes_yaml = compiler_yaml.encode("UTF-8")
        b64_yaml = base64.b64encode(bytes_yaml)
        bytes_task_name = task_name.encode("UTF-8")
        b64_task_name = base64.b64encode(bytes_task_name)
        deliminator = ",".encode("UTF-8")
        message = b64_task_name + deliminator + b64_yaml
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((self.tcp_ip, self.tcp_port))
        s.send(message)

        recv_message = s.recv(1024)
        recv_message = recv_message.decode("ascii")
        if recv_message.startswith("FileName:"):
            file_name = recv_message.split(":")[1]
        else:
            self.main_menu.plugin_socketio_message(self.info[0]['Name'],
                                                   ("[*] " + recv_message))
            file_name = "failed"
        s.close()

        return file_name

    def do_send_stager(self, stager, task_name):
        bytes_yaml = stager.encode("UTF-8")
        b64_yaml = base64.b64encode(bytes_yaml)
        bytes_task_name = task_name.encode("UTF-8")
        b64_task_name = base64.b64encode(bytes_task_name)
        deliminator = ",".encode("UTF-8")
        message = b64_task_name + deliminator + b64_yaml
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((self.tcp_ip, self.tcp_port))
        s.send(message)

        recv_message = s.recv(1024)
        recv_message = recv_message.decode("ascii")
        if recv_message.startswith("FileName:"):
            file_name = recv_message.split(":")[1]
        else:
            self.main_menu.plugin_socketio_message(self.info[0]['Name'],
                                                   ("[*] " + recv_message))
            file_name = "failed"
        s.close()

        return file_name

    def shutdown(self):
        try:
            b64_yaml = base64.b64encode(("dummy data").encode("UTF-8"))
            b64_task_name = base64.b64encode(("close").encode("UTF-8"))
            deliminator = ",".encode("UTF-8")
            message = b64_task_name + deliminator + b64_yaml
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((self.tcp_ip, self.tcp_port))
            s.send(message)
            s.close()
            self.csharpserverbuild_proc.kill()
            self.csharpserver_proc.kill()
            self.thread.kill()
        except:
            pass
        return
