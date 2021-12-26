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
        
        script_path = params['ScriptPath']
        script_cmd = params['ScriptCmd']
        script = ''

        if script_path != '':
            try:
                f = open(script_path, 'r')
            except:
                return handle_error_message("[!] Could not read script source path at: " + str(script_path))

            script = f.read()
            f.close()
            script += '\n'

        script += "%s" % script_cmd

        if obfuscate:
            script = helpers.obfuscate(main_menu.installPath, psScript=script, obfuscationCommand=obfuscation_command)
        script = data_util.keyword_obfuscation(script)

        return script
