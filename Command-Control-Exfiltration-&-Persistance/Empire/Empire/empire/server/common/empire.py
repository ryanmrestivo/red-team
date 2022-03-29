"""

The main controller class for Empire.

This is what's launched from ./empire.
Contains the Main, Listener, Agents, Agent, and Module
menu loops.

"""
from __future__ import absolute_import
from __future__ import print_function

import fnmatch
from builtins import input
from builtins import str
from typing import Optional
from flask_socketio import SocketIO
from pydispatch import dispatcher

import sys
import cmd
import os
import pkgutil
import threading
import json
import time

# Empire imports
from empire.server.common import hooks_internal
from empire.server.utils import data_util
from . import helpers
from . import messages
from . import agents
from . import listeners
from . import modules
from . import stagers
from . import credentials
from . import users
from . import plugins
from .events import log_event
from prompt_toolkit import PromptSession, HTML
from prompt_toolkit.patch_stdout import patch_stdout
from empire.server.database.base import Session
from empire.server.database import models
from sqlalchemy import or_, func, and_

VERSION = "4.2.0 BC Security Fork"


class MainMenu(cmd.Cmd):
    """
    The main class used by Empire to drive the 'main' menu
    displayed when Empire starts.
    """

    def __init__(self, args=None):

        cmd.Cmd.__init__(self)

        # set up the event handling system
        dispatcher.connect(self.handle_event, sender=dispatcher.Any)

        # globalOptions[optionName] = (value, required, description)
        self.globalOptions = {}

        # currently active plugins:
        # {'pluginName': classObject}
        self.loadedPlugins = {}

        time.sleep(1)

        self.lock = threading.Lock()

        # pull out some common configuration information
        (self.isroot, self.installPath, self.ipWhiteList, self.ipBlackList, self.obfuscate,
         self.obfuscateCommand) = data_util.get_config(
            'rootuser, install_path,ip_whitelist,ip_blacklist,obfuscate,obfuscate_command')

        # change the default prompt for the user
        self.prompt = '(Empire) > '
        self.do_help.__func__.__doc__ = '''Displays the help menu.'''
        self.doc_header = 'Commands'

        # Main, Agents, or
        self.menu_state = 'Main'

        # parse/handle any passed command line arguments
        self.args = args

        # instantiate the agents, listeners, and stagers objects
        self.agents = agents.Agents(self, args=args)
        self.credentials = credentials.Credentials(self, args=args)
        self.stagers = stagers.Stagers(self, args=args)
        self.modules = modules.Modules(self, args=args)
        self.listeners = listeners.Listeners(self, args=args)
        self.users = users.Users(self)

        self.load_malleable_profiles()

        hooks_internal.initialize()

        self.socketio: Optional[SocketIO] = None
        self.resourceQueue = []
        # A hashtable of autruns based on agent language
        self.autoRuns = {}
        self.startup_plugins()

        message = "[*] Empire starting up..."
        signal = json.dumps({
            'print': True,
            'message': message
        })
        dispatcher.send(signal, sender="empire")

    def handle_event(self, signal, sender):
        """
        Whenver an event is received from the dispatcher, log it to the DB,
        decide whether it should be printed, and if so, print it.
        If self.args.debug, also log all events to a file.
        """
        # load up the signal so we can inspect it
        try:
            signal_data = json.loads(signal)
        except ValueError:
            print(helpers.color("[!] Error: bad signal received {} from sender {}".format(signal, sender)))
            return

        # if this is related to a task, set task_id; this is its own column in
        # the DB (else the column will be set to None/null)
        task_id = None
        if 'task_id' in signal_data:
            task_id = signal_data['task_id']

        if 'event_type' in signal_data:
            event_type = signal_data['event_type']
        else:
            event_type = 'dispatched_event'

        # print any signal that indicates we should
        if ('print' in signal_data and signal_data['print']):
            print(helpers.color(signal_data['message']))

        # get a db cursor, log this event to the DB, then close the cursor
        # TODO instead of "dispatched_event" put something useful in the "event_type" column
        log_event(sender, event_type, json.dumps(signal_data), task_id=task_id)

        # if --debug X is passed, log out all dispatcher signals
        if self.args.debug:
            with open('empire.debug', 'a') as debug_file:
                debug_file.write("%s %s : %s\n" % (helpers.get_datetime(), sender, signal))

            if self.args.debug == '2':
                # if --debug 2, also print the output to the screen
                print(" %s : %s" % (sender, signal))

    def startup_plugins(self):
        """
        Load plugins at the start of Empire
        """
        pluginPath = self.installPath + "/plugins"
        print(helpers.color("[*] Searching for plugins at {}".format(pluginPath)))

        # From walk_packages: "Note that this function must import all packages
        # (not all modules!) on the given path, in order to access the __path__
        # attribute to find submodules."
        plugin_names = [name for _, name, _ in pkgutil.walk_packages([pluginPath])]

        for plugin_name in plugin_names:
            if plugin_name.lower() != 'example':
                print(helpers.color("[*] Plugin {} found.".format(plugin_name)))

                message = "[*] Loading plugin {}".format(plugin_name)
                signal = json.dumps({
                    'print': False,
                    'message': message
                })
                dispatcher.send(signal, sender="empire")
                plugins.load_plugin(self, plugin_name)

    def load_malleable_profiles(self):
        """
        Load Malleable C2 Profiles to the database
        """
        malleable_path = self.installPath + "/data/profiles"
        print(helpers.color("[*] Loading malleable profiles from: {}".format(malleable_path)))

        malleable_directories = os.listdir(malleable_path)

        for malleable_directory in malleable_directories:
            for root, dirs, files in os.walk(malleable_path + '/' + malleable_directory):
                for filename in files:
                    if not filename.lower().endswith('.profile'):
                        continue

                    file_path = os.path.join(root, filename)

                    # don't load up any of the templates
                    if fnmatch.fnmatch(filename, '*template.profile'):
                        continue

                    malleable_split = file_path.split(malleable_path)[-1].split('/')
                    profile_category = malleable_split[1]
                    profile_name = malleable_split[2]

                    # Check if module is in database and load new profiles
                    profile = Session().query(models.Profile).filter(models.Profile.name == profile_name).first()
                    if not profile:
                        message = "[*] Loading malleable profile {}".format(profile_name)
                        signal = json.dumps({
                            'print': False,
                            'message': message
                        })
                        dispatcher.send(signal, sender="empire")

                        with open(file_path, 'r') as stream:
                            profile_data = stream.read()
                            Session().add(models.Profile(file_path=file_path,
                                                         name=profile_name,
                                                         category=profile_category,
                                                         data=profile_data,
                                                         ))
        Session().commit()

    def plugin_socketio_message(self, plugin_name, msg):
        """
        Send socketio message to the socket address
        """
        if self.args.debug is not None:
            print(helpers.color(msg))
        self.socketio.emit(f'plugins/{plugin_name}/notifications', {'message': msg, 'plugin_name': plugin_name})

    def check_root(self):
        """
        Check if Empire has been run as root, and alert user.
        """
        try:

            if os.geteuid() != 0:
                if self.isroot:
                    messages.title(VERSION)
                    print(
                        "[!] Warning: Running Empire as non-root, after running as root will likely fail to access prior agents!")
                    while True:
                        a = input(helpers.color("[>] Are you sure you want to continue (y) or (n): "))
                        if a.startswith("y"):
                            return
                        if a.startswith("n"):
                            self.shutdown()
                            sys.exit()
                else:
                    pass
            if os.geteuid() == 0:
                if self.isroot:
                    pass
                if not self.isroot:
                    config = Session().query(models.Config).all()
                    config.rootuser = True
                    Session().commit()
        except Exception as e:
            print(e)

    def shutdown(self):
        """
        Perform any shutdown actions.
        """
        print("\n" + helpers.color("[!] Shutting down..."))

        message = "[*] Empire shutting down..."
        signal = json.dumps({
            'print': True,
            'message': message
        })
        dispatcher.send(signal, sender="empire")

        # enumerate all active servers/listeners and shut them down
        self.listeners.shutdown_listener('all')

        message = "[*] Shutting down plugins..."
        signal = json.dumps({
            'print': True,
            'message': message
        })
        dispatcher.send(signal, sender="empire")
        for plugin in self.loadedPlugins:
            self.loadedPlugins[plugin].shutdown()

    def teamserver(self):
        """
        The main cmdloop logic that handles navigation to other menus.
        """
        session = PromptSession(
            complete_in_thread=True,
            bottom_toolbar=self.bottom_toolbar,
            refresh_interval=5
        )

        while True:
            try:
                with patch_stdout(raw=True):
                    text = session.prompt('Server > ', refresh_interval=None)
                    print(helpers.color('[!] Type exit to quit'))
            except KeyboardInterrupt:
                print(helpers.color("[!] Type exit to quit"))
                continue  # Control-C pressed. Try again.
            except EOFError:
                break  # Control-D pressed.

            if text == 'exit':
                choice = input(helpers.color("[>] Exit? [y/N] ", "red"))
                if choice.lower() == "y":
                    self.shutdown()
                    return True
                else:
                    pass

    def bottom_toolbar(self):
        return HTML(f'EMPIRE TEAM SERVER | ' +
                    str(len(self.agents.agents)) + ' Agent(s) | ' +
                    str(len(self.listeners.activeListeners)) + ' Listener(s) | ' +
                    str(len(self.loadedPlugins)) + ' Plugin(s)')

    ###################################################
    # CMD methods
    ###################################################
    def default(self, line):
        "Default handler."
        pass

    def buildQueue(self, resourceFile, autoRun=False):
        cmds = []
        if os.path.isfile(resourceFile):
            with open(resourceFile, 'r') as f:
                lines = []
                lines.extend(f.read().splitlines())
        else:
            raise Exception("[!] Error: The resource file specified \"%s\" does not exist" % resourceFile)
        for lineFull in lines:
            line = lineFull.strip()
            # ignore lines that start with the comment symbol (#)
            if line.startswith("#"):
                continue
            # read in another resource file
            elif line.startswith("resource "):
                rf = line.split(' ')[1]
                cmds.extend(self.buildQueue(rf, autoRun))
            # add noprompt option to execute without user confirmation
            elif autoRun and line == "execute":
                cmds.append(line + " noprompt")
            else:
                cmds.append(line)

        return cmds

    def substring(self, session, column, delimeter):
        """
        https://stackoverflow.com/a/57763081
        """
        if session.bind.dialect.name == 'sqlite':
            return func.substr(column, func.instr(column, delimeter) + 1)
        elif session.bind.dialect.name == 'mysql':
            return func.substring_index(column, delimeter, -1)

    def run_report_query(self):
        reporting_sub_query = Session() \
            .query(models.Reporting, self.substring(Session(), models.Reporting.name, '/').label('agent_name')) \
            .filter(and_(models.Reporting.name.ilike('agent%'),
                         or_(models.Reporting.event_type == 'task',
                             models.Reporting.event_type == 'checkin'))) \
            .subquery()

        return Session() \
            .query(reporting_sub_query.c.timestamp,
                   reporting_sub_query.c.event_type,
                   reporting_sub_query.c.agent_name,
                   reporting_sub_query.c.taskID,
                   models.Agent.hostname,
                   models.User.username,
                   models.Tasking.input.label('task'),
                   models.Tasking.output.label('results')) \
            .join(models.Tasking, and_(models.Tasking.id == reporting_sub_query.c.taskID,
                                       models.Tasking.agent_id == reporting_sub_query.c.agent_name), isouter=True) \
            .join(models.User, models.User.id == models.Tasking.user_id, isouter=True) \
            .join(models.Agent, models.Agent.session_id == reporting_sub_query.c.agent_name, isouter=True) \
            .all()

    def generate_report(self):
        """
        Produce report CSV and log files: sessions.csv, credentials.csv, master.log
        """
        rows = Session().query(models.Agent.session_id, models.Agent.hostname, models.Agent.username,
                               models.Agent.checkin_time).all()

        print(helpers.color(f"[*] Writing {self.installPath}/data/sessions.csv"))
        try:
            self.lock.acquire()
            with open(self.installPath + '/data/sessions.csv', 'w') as f:
                f.write("SessionID, Hostname, User Name, First Check-in\n")
                for row in rows:
                    f.write(row[0] + ',' + row[1] + ',' + row[2] + ',' + str(row[3]) + '\n')
        finally:
            self.lock.release()

        # Credentials CSV
        rows = Session().query(models.Credential.domain,
                               models.Credential.username,
                               models.Credential.host,
                               models.Credential.credtype,
                               models.Credential.password) \
            .order_by(models.Credential.domain, models.Credential.credtype, models.Credential.host) \
            .all()

        print(helpers.color(f"[*] Writing {self.installPath}/data/credentials.csv"))
        try:
            self.lock.acquire()
            with open(self.installPath + '/data/credentials.csv', 'w') as f:
                f.write('Domain, Username, Host, Cred Type, Password\n')
                for row in rows:
                    # todo vr maybe can replace with
                    #  f.write(f'{row.domain},{row.username},{row.host},{row.credtype},{row.password}\n')
                    row = list(row)
                    for n in range(len(row)):
                        if isinstance(row[n], bytes):
                            row[n] = row[n].decode('UTF-8')
                    f.write(row[0] + ',' + row[1] + ',' + row[2] + ',' + row[3] + ',' + row[4] + '\n')
        finally:
            self.lock.release()

        # Empire Log
        rows = self.run_report_query()

        print(helpers.color(f"[*] Writing {self.installPath}/data/master.log"))
        try:
            self.lock.acquire()
            with open(self.installPath + '/data/master.log', 'w') as f:
                f.write('Empire Master Taskings & Results Log by timestamp\n')
                f.write('=' * 50 + '\n\n')
                for row in rows:
                    # todo vr maybe can replace with
                    #  f.write(f'\n{xstr(row.timestamp)} - {xstr(row.username)} ({xstr(row.username)})> {xstr(row.hostname)}\n{xstr(row.taskID)}\n{xstr(row.results)}\n')
                    row = list(row)
                    for n in range(len(row)):
                        if isinstance(row[n], bytes):
                            row[n] = row[n].decode('UTF-8')
                    f.write('\n' + xstr(row[0]) + ' - ' + xstr(row[3]) + ' (' + xstr(row[2]) + ')> ' + xstr(
                        row[5]) + '\n' + xstr(row[6]) + '\n' + xstr(row[7]) + '\n')
        finally:
            self.lock.release()

        return f'{self.installPath}/data'


def xstr(s):
    """
    Safely cast to a string with a handler for None
    """
    if s is None:
        return ''
    return str(s)
