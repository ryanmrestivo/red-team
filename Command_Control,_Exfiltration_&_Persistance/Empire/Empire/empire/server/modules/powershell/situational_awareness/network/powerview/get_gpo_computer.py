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
        # read in the common powerview.ps1 module source code
        module_source = main_menu.installPath + "/data/module_source/situational_awareness/network/powerview.ps1"

        try:
            f = open(module_source, 'r')
        except:
            return handle_error_message("[!] Could not read module source path at: " + str(module_source))

        module_code = f.read()
        f.close()

        # get just the code needed for the specified function
        script = helpers.strip_powershell_comments(module_code)

        script += "\nGet-DomainOU "

        for option, values in params.items():
            if option.lower() != "agent" and option.lower() != "guid" and option.lower() != "outputfunction":
                if values and values != '':
                    if values.lower() == "true":
                        # if we're just adding a switch
                        script += " -" + str(option)
                    else:
                        script += " -" + str(option) + " " + str(values)

        script += "-GPLink " + str(params['GUID']) + " | %{ Get-DomainComputer -SearchBase $_.distinguishedname"

        for option, values in params.items():
            if option.lower() != "agent" and option.lower() != "guid" and option.lower() != "outputfunction":
                if values and values != '':
                    if values.lower() == "true":
                        # if we're just adding a switch
                        script += " -" + str(option)
                    else:
                        script += " -" + str(option) + " " + str(values)

        outputf = params.get("OutputFunction", "Out-String")
        script += f"}} | {outputf}  | " + '%{$_ + \"`n\"};"`n' + str(module.name.split("/")[-1]) + ' completed!"'
        if obfuscate:
            script = helpers.obfuscate(main_menu.installPath, psScript=script, obfuscationCommand=obfuscation_command)
        script = data_util.keyword_obfuscation(script)

        return script
