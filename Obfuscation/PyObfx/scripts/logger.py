#!/usr/bin/python3.6
# -*- coding: utf-8 -*-
from colorama import Fore, Style
import platform, time, os
from scripts.io import append_file

class Log:
    states = {
            'error':('[ERROR]', Fore.RED),
            'critical':('[CRITICAL]',Fore.YELLOW),
            'info': ('[INFO]', Fore.GREEN)
            }
    _RESET = Fore.RESET
    def __init__(self, active=True, log_name=None):
        self.os = platform.system()
        self.active = active
        if log_name:
            os.makedirs('logs', exist_ok=True)
            self.path = os.path.join(os.getcwd(), os.path.join('logs', log_name).
                replace(":", "-")) # [WIN] Filenames must not contain ':'
        else:
            self.path = None

    def _write(self, msg, state):
        content = f"[{time.strftime('%X')}] {self.states[state][0]} {msg}\n"
        append_file(self.path, content)

    def _clear(self):
        try:
            open(self.path, 'w').close()
        except: pass

    def log(self, msg, state='info'):
        if not self.active:
            content = f"{Style.BRIGHT + self.states[state][1] if self.os == 'Linux' else ''}[{time.strftime('%X')}] {self.states[state][0]} {msg}{self._RESET}{Style.RESET_ALL}"
            print(content)
        if self.path:
            self._write(msg=msg, state=state)

