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
        # First method: Read in the source script from module_source
        moduleSource = main_menu.installPath + "/data/module_source/situational_awareness/host/Invoke-Seatbelt.ps1"
        if obfuscate:
            data_util.obfuscate_module(moduleSource=moduleSource, obfuscationCommand=obfuscation_command)
            moduleSource = moduleSource.replace("module_source", "obfuscated_module_source")
        try:
            f = open(moduleSource, 'r')
        except:
            return handle_error_message("[!] Could not read module source path at: " + str(moduleSource))

        moduleCode = f.read()
        f.close()

        script = moduleCode
        scriptEnd = 'Invoke-Seatbelt -Command "'

        # Add any arguments to the end execution of the script
        if params['Command']:
            scriptEnd += " " + str(params['Command'])
        if params['Group']:
            scriptEnd += " -group=" + str(params['Group'])
        if params['Computername']:
            scriptEnd += " -computername=" + str(params['Computername'])
        if params['Username']:
            scriptEnd += " -username=" + str(params['Username'])
        if params['Password']:
            scriptEnd += " -password=" + str(params['Password'])
        if params['Full'].lower() == 'true':
            scriptEnd += " -full"
        if params['Quiet'].lower() == 'true':
            scriptEnd += " -q"

        scriptEnd = scriptEnd.replace('" ', '"')
        scriptEnd += '"'

        if obfuscate:
            scriptEnd = helpers.obfuscate(psScript=scriptEnd, installPath=main_menu.installPath, obfuscationCommand=obfuscation_command)
        script += scriptEnd
        script = data_util.keyword_obfuscation(script)

        return script

