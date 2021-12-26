from __future__ import print_function

from empire.server.common.plugins import Plugin
import empire.server.common.helpers as helpers

import os
import subprocess
import time
import socket
import base64
import websockify

class Plugin(Plugin):
    description = "Empire websockify server plugin."

    def onLoad(self):
        print(helpers.color("[*] Loading websockify server plugin"))
        self.main_menu = None
        self.csharpserver_proc = None
        self.info = {
                        'Name': 'websockify',

                        'Author': ['@Cx01N'],

                        'Description': ('Websockify server for TCP proxy/bridge to connect applications. For example: '
                                        'run the websockify server to connect the VNC server to noVNC.'),

                        'Software': '',

                        'Techniques': ['T1090'],

                        'Comments': ['https://github.com/novnc/websockify']
                    },

        self.options = {
            'SourceHost': {
                'Description': 'Address of the source host.',
                'Required': True,
                'Value': '0.0.0.0'
            },
            'SourcePort': {
                'Description': 'Port on source host.',
                'Required': True,
                'Value': '5910'
            },
            'TargetHost': {
                'Description': 'Address of the target host.',
                'Required': True,
                'Value': ''
            },
            'TargetPort': {
                'Description': 'Port on target host.',
                'Required': True,
                'Value': '5900'
            },
            'Status': {
                'Description': 'Start/stop the Empire C# server.',
                'Required': True,
                'Value': 'start',
                'SuggestedValues': ['start', 'stop'],
                'Strict': True
            }
        }

    def execute(self, command):
        # This is for parsing commands through the api
        try:
            self.websockify_proc = None
            # essentially switches to parse the proper command to execute
            self.status = self.options['Status']['Value']
            results = self.do_websockify('')
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
        mainMenu.__class__.do_websockify = self.do_websockify
        self.installPath = mainMenu.installPath
        self.main_menu = mainMenu

    def do_websockify(self, *args):
        """
        Check if the Empire C# server is already running.
        """
        if self.websockify_proc:
            self.enabled = True
        else:
            self.enabled = False

        if self.status == "status":
            if self.enabled:
                self.main_menu.plugin_socketio_message(self.info[0]['Name'], "[+] Websockify server is currently running")
            else:
                self.main_menu.plugin_socketio_message(self.info[0]['Name'], "[!] Websockify server is currently stopped")

        elif self.status == "stop":
            if self.enabled:
                self.reverseshell_proc.kill()
                self.main_menu.plugin_socketio_message(self.info[0]['Name'], "[!] Stopped Websockify server")
            else:
                self.main_menu.plugin_socketio_message(self.info[0]['Name'], "[!] Websockify server is already stopped")

        elif self.status == "start":
            source_host = self.options['SourceHost']['Value']
            source_port = int(self.options['SourcePort']['Value'])
            target_host = self.options['TargetHost']['Value']
            target_port = int(self.options['TargetPort']['Value'])


            self.main_menu.plugin_socketio_message(self.info[0]['Name'], "[*] Websockify server is currently starting...")
            server = websockify.LibProxyServer(target_host=target_host, target_port=target_port, listen_host=source_host, listen_port=source_port)
            self.websockify_proc = helpers.KThread(target=server.serve_forever)
            self.websockify_proc.daemon = True
            self.websockify_proc.start()
            self.main_menu.plugin_socketio_message(self.info[0]['Name'], "[+] Websockify server succesfully started")

    def shutdown(self):
        try:
            self.websockify_proc.kill()
        except:
            pass
        return
