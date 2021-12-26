from typing import Dict, Optional

import requests
import socketio

from empire.client.src.MenuState import menu_state
from empire.client.src.menus import Menu
from empire.client.src.utils import print_util
from prompt_toolkit import HTML, ANSI


class EmpireCliState(object):
    def __init__(self):
        self.host = ''
        self.port = ''
        self.token = ''
        self.sio: Optional[socketio.Client] = None
        self.connected = False
        self.menus = []

        # These are cached values that can be used for autocompletes and other things.
        # When switching menus, refresh these cached values by calling their respective 'get' functions.
        # In the future, maybe we'll set a scheduled task to refresh this every n seconds/minutes?
        self.listeners = {}
        self.listener_types = []
        self.stagers = {}
        self.modules = {}
        self.agents = {}
        self.plugins = {}
        self.me = {}
        self.profiles = {}
        self.bypasses = {}
        self.credentials = {}
        self.empire_version = ''
        self.cached_plugin_results = {}
        self.chat_cache = []

        # { session_id: { task_id: 'output' }}
        self.cached_agent_results = {}


    def register_menu(self, menu: Menu):
        self.menus.append(menu)

    def notify_connected(self):
        print(print_util.color('[*] Calling connection handlers.'))
        for menu in self.menus:
            menu.on_connect()

    def notify_disconnected(self):
        for menu in self.menus:
            menu.on_disconnect()

    def connect(self, host, port, socketport, username, password):
        self.host = host
        self.port = port
        try:
            response = requests.post(url=f'{host}:{port}/api/admin/login',
                                     json={'username': username, 'password': password},
                                     verify=False)
        except Exception as e:
            return e

        if response.status_code == 200:
            self.token = response.json()['token']
            self.connected = True

            self.sio = socketio.Client(ssl_verify=False, reconnection_attempts=3)
            self.sio.connect(f'{host}:{socketport}?token={self.token}')

            # Wait for version to be returned
            self.empire_version = self.get_version()['version']

            self.init()
            self.init_handlers()
            self.notify_connected()
            print_util.title(self.empire_version, len(self.modules), len(self.listeners), len(self.active_agents))
            return response

        elif response.status_code == 401:
            return response

    def init(self):
        self.get_listeners()
        self.get_listener_types()
        self.get_stagers()
        self.get_modules()
        self.get_agents()
        self.get_active_agents()
        self.get_active_plugins()
        self.get_user_me()
        self.get_malleable_profile()
        self.get_bypasses()
        self.get_credentials()

    def init_handlers(self):
        if self.sio:
            self.sio.on('listeners/new',
                        lambda data: [print(print_util.color('[+] Listener ' + data['name'] + ' successfully started')),
                                      self.get_listeners()])
            self.sio.on('agents/new',
                        lambda data: [print(print_util.color('[+] New agent ' + data['name'] + ' checked in')),
                                      self.get_agents()])

            # Multiple checkin messages or a single one?
            self.sio.on('agents/stage2', lambda data: print(
                print_util.color('[*] Sending agent (stage 2) to ' + data['name'] + ' at ' + data['external_ip'])))

            # Todo: need to only display results from the current agent and user. Otherwise there will be too many
            #  returns when you add more users self.sio.on('agents/task', lambda data: print(data['data']))

    def disconnect(self):
        self.host = ''
        self.port = ''
        self.token = ''
        self.connected = False
        self.notify_disconnected()

        if self.sio:
            self.sio.disconnect()

    def shutdown(self):
        self.disconnect()

    def add_to_cached_results(self, data) -> None:
        """
        When tasking results come back, we will display them if the current menu is the InteractMenu.
        Otherwise, we will ad them to the agent result dictionary and display them when the InteractMenu
        is loaded.
        :param data: the tasking object
        :return:
        """
        session_id = data['agent']
        if not self.cached_agent_results.get(session_id):
            self.cached_agent_results[session_id] = {}

        if menu_state.current_menu_name == 'InteractMenu' and menu_state.current_menu.selected == session_id:
            if data['results'] is not None:
                print(print_util.color('[*] Task ' + str(data['taskID']) + " results received"))
                for line in data['results'].split('\n'):
                    print(print_util.color(line))
        else:
            self.cached_agent_results[session_id][data['taskID']] = data['results']

    def add_plugin_cache(self, data) -> None:
        """
        When plugin results come back, we will display them if the current menu is for the plugin.
        Otherwise, we will ad them to the plugin result dictionary and display them when the plugin menu
        is loaded.
        :param data: the plugin object
        :return:
        """
        plugin_name = data['plugin_name']
        if not self.cached_plugin_results.get(plugin_name):
            self.cached_plugin_results[plugin_name] = {}

        if menu_state.current_menu_name == 'UsePluginMenu' and menu_state.current_menu.selected == plugin_name:
            if data['message'] is not None:
                print(print_util.color(data['message']))
        else:
            self.cached_plugin_results[plugin_name][data['message']] = data['message']

    def bottom_toolbar(self):
        if self.connected:
            agent_tasks = list(self.cached_agent_results.keys())
            plugin_tasks = list(self.cached_plugin_results.keys())

            toolbar_text = [("bold", f'Connected: ')]
            toolbar_text.append(("bg:#FF0000 bold", f'{self.host}:{self.port} '))
            toolbar_text.append(("bold", f'| '))
            toolbar_text.append(("bg:#FF0000 bold", f'{len(state.agents)} '))
            toolbar_text.append(("bold", f'agent(s) | '))
            toolbar_text.append(("bg:#FF0000 bold", f'{len(state.chat_cache)} '))
            toolbar_text.append(("bold", f'unread message(s) '))

            agent_text = ''
            for agents in agent_tasks:
                if self.cached_agent_results[agents]:
                    agent_text += f' {agents}'
            if agent_text:
                toolbar_text.append(("bold", '| Agent(s) received task results:'))
                toolbar_text.append(("bg:#FF0000 bold", f'{agent_text} '))

            plugin_text = ''
            for plugins in plugin_tasks:
                if self.cached_plugin_results[plugins]:
                    plugin_text += f' {plugins}'
            if plugin_text:
                toolbar_text.append(("bold", f'| Plugin(s) received task result(s):'))
                toolbar_text.append(("bg:#FF0000 bold", f'{plugin_text} '))

            return toolbar_text

        else:
            return ''

    # I think we we will break out the socketio handler and http requests to new classes that the state imports.
    # This will do for this iteration.
    def get_listeners(self):
        response = requests.get(url=f'{self.host}:{self.port}/api/listeners',
                                verify=False,
                                params={'token': self.token})

        self.listeners = {x['name']: x for x in response.json()['listeners']}

        return self.listeners

    def validate_listener(self, listener_type: str, options: Dict):
        response = requests.post(url=f'{self.host}:{self.port}/api/listeners/{listener_type}/validate',
                                 json=options,
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def get_version(self):
        response = requests.get(url=f'{self.host}:{self.port}/api/version',
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def set_admin_options(self, options: Dict):
        response = requests.post(url=f'{self.host}:{self.port}/api/admin/options',
                                 json=options,
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def kill_listener(self, listener_name: str):
        response = requests.delete(url=f'{self.host}:{self.port}/api/listeners/{listener_name}',
                                   verify=False,
                                   params={'token': self.token})
        self.get_listeners()
        return response.json()

    def disable_listener(self, listener_name: str):
        response = requests.put(url=f'{self.host}:{self.port}/api/listeners/{listener_name}/disable',
                                verify=False,
                                params={'token': self.token})
        self.get_listeners()
        return response.json()

    def enable_listener(self, listener_name: str):
        response = requests.put(url=f'{self.host}:{self.port}/api/listeners/{listener_name}/enable',
                                verify=False,
                                params={'token': self.token})
        self.get_listeners()
        return response.json()

    def edit_listener(self, listener_name: str, option_name, option_value):
        response = requests.put(url=f'{self.host}:{self.port}/api/listeners/{listener_name}/edit',
                                json={'option_name': option_name, 'option_value': option_value},
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def get_listener_types(self):
        response = requests.get(url=f'{self.host}:{self.port}/api/listeners/types',
                                verify=False,
                                params={'token': self.token})

        self.listener_types = response.json()['types']

        return self.listener_types

    def get_listener_options(self, listener_type: str):
        response = requests.get(url=f'{self.host}:{self.port}/api/listeners/options/{listener_type}',
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def create_listener(self, listener_type: str, options: Dict):
        response = requests.post(url=f'{self.host}:{self.port}/api/listeners/{listener_type}',
                                 json=options,
                                 verify=False,
                                 params={'token': self.token})

        # todo push to state array or just call get_listeners() to refresh cache??

        return response.json()

    def get_stagers(self):
        # todo need error handling in all api requests
        response = requests.get(url=f'{self.host}:{self.port}/api/stagers',
                                verify=False,
                                params={'token': self.token})

        self.stagers = {x['Name']: x for x in response.json()['stagers']}

        return self.stagers

    def create_stager(self, stager_name: str, options: Dict):
        options['StagerName'] = stager_name
        response = requests.post(url=f'{self.host}:{self.port}/api/stagers',
                                 json=options,
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def get_agents(self):
        response = requests.get(url=f'{self.host}:{self.port}/api/agents',
                                verify=False,
                                params={'token': self.token})

        self.agents = {x['name']: x for x in response.json()['agents']}

        # Whenever agents are refreshed, add socketio listeners for taskings.
        for name, agent in self.agents.items():
            session_id = agent['session_id']
            self.sio.on(f'agents/{session_id}/task', self.add_to_cached_results)

        return self.agents

    def get_active_agents(self):
        response = requests.get(url=f'{self.host}:{self.port}/api/agents/active',
                                verify=False,
                                params={'token': self.token})

        self.active_agents = {x['name']: x for x in response.json()['agents']}
        return self.active_agents

    def get_modules(self):
        response = requests.get(url=f'{self.host}:{self.port}/api/modules',
                                verify=False,
                                params={'token': self.token})

        self.modules = {x['Name']: x for x in response.json()['modules'] if x['Enabled']}

        return self.modules

    def execute_module(self, module_name: str, options: Dict):
        response = requests.post(url=f'{self.host}:{self.port}/api/modules/{module_name}',
                                 json=options,
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def kill_agent(self, agent_name: str):
        response = requests.post(url=f'{self.host}:{self.port}/api/agents/{agent_name}/kill',
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def remove_agent(self, agent_name: str):
        response = requests.delete(url=f'{self.host}:{self.port}/api/agents/{agent_name}',
                                   verify=False,
                                   params={'token': self.token})

        return response.json()

    def remove_stale_agents(self):
        response = requests.delete(url=f'{self.host}:{self.port}/api/agents/stale',
                                   verify=False,
                                   params={'token': self.token})

        return response.json()

    def update_agent_comms(self, agent_name: str, listener_name: str):
        response = requests.put(url=f'{self.host}:{self.port}/api/agents/{agent_name}/update_comms',
                                json={'listener': listener_name},
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def update_agent_killdate(self, agent_name: str, kill_date: str):
        response = requests.put(url=f'{self.host}:{self.port}/api/agents/{agent_name}/killdate',
                                json={'kill_date': kill_date},
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def update_agent_proxy(self, agent_name: str, options: list):
        response = requests.put(url=f'{self.host}:{self.port}/api/agents/{agent_name}/proxy',
                                json={'proxy': options},
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def get_proxy_info(self, agent_name: str):
        response = requests.get(url=f'{self.host}:{self.port}/api/agents/{agent_name}/proxy',
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def update_agent_working_hours(self, agent_name: str, working_hours: str):
        response = requests.put(url=f'{self.host}:{self.port}/api/agents/{agent_name}/workinghours',
                                json={'working_hours': working_hours},
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def clear_agent(self, agent_name: str):
        response = requests.post(url=f'{self.host}:{self.port}/api/agents/{agent_name}/clear',
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def rename_agent(self, agent_name: str, new_agent_name: str):
        response = requests.post(url=f'{self.host}:{self.port}/api/agents/{agent_name}/rename',
                                 json={'newname': new_agent_name},
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def agent_shell(self, agent_name, shell_cmd: str):
        response = requests.post(url=f'{self.host}:{self.port}/api/agents/{agent_name}/shell',
                                 json={'command': shell_cmd},
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def agent_script_import(self, agent_name, script_location: str):
        response = requests.post(url=f'{self.host}:{self.port}/api/agents/{agent_name}/script_import',
                                 json={'script': script_location},
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def agent_script_command(self, agent_name, script_command: str):
        response = requests.post(url=f'{self.host}:{self.port}/api/agents/{agent_name}/script_command',
                                 json={'script': script_command},
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def scrape_directory(self, agent_name):
        response = requests.post(url=f'{self.host}:{self.port}/api/agents/{agent_name}/directory',
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def get_directory(self, agent_name):
        response = requests.get(url=f'{self.host}:{self.port}/api/agents/{agent_name}/directory',
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def get_task_result(self, agent_name, task_id):
        response = requests.get(url=f'{self.host}:{self.port}/api/agents/{agent_name}/task/{task_id}',
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def get_agent_tasks(self, agent_name, num_results):
        response = requests.get(url=f'{self.host}:{self.port}/api/agents/{agent_name}/task',
                                verify=False,
                                params={'token': self.token, 'num_results': num_results})

        return response.json()

    def get_agent_tasks_slim(self, agent_name):
        response = requests.get(url=f'{self.host}:{self.port}/api/agents/{agent_name}/task/slim',
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def get_agent_task(self, agent_name, task_id):
        response = requests.get(url=f'{self.host}:{self.port}/api/agents/{agent_name}/task/{task_id}',
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def get_agent_result(self, agent_name):
        response = requests.get(url=f'{self.host}:{self.port}/api/agents/{agent_name}/results',
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def get_credentials(self):
        response = requests.get(url=f'{self.host}:{self.port}/api/creds',
                                verify=False,
                                params={'token': self.token})

        self.credentials = {str(x['ID']): x for x in response.json()['creds']}

        return response.json()['creds']

    def get_credential(self, cred_id):
        response = requests.get(url=f'{self.host}:{self.port}/api/creds/{cred_id}',
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def edit_credential(self, cred_id, cred_options: Dict):
        response = requests.put(url=f'{self.host}:{self.port}/api/creds/{cred_id}',
                                verify=False,
                                json=cred_options,
                                params={'token': self.token})

        return response.json()

    def add_credential(self, cred_options):
        response = requests.post(url=f'{self.host}:{self.port}/api/creds',
                                 json=cred_options,
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def remove_credential(self, cred_id):
        response = requests.delete(url=f'{self.host}:{self.port}/api/creds/{cred_id}',
                                verify=False,
                                params={'token': self.token})

        return response.json()


    def generate_report(self):
        response = requests.get(url=f'{self.host}:{self.port}/api/reporting/generate',
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def get_active_plugins(self):
        response = requests.get(url=f'{self.host}:{self.port}/api/plugins/active',
                                verify=False,
                                params={'token': self.token})

        self.plugins = {x['Name']: x for x in response.json()['plugins']}
        for name, plugin in self.plugins.items():
            plugin_name = plugin['Name']
            self.sio.on(f'plugins/{plugin_name}/notifications', self.add_plugin_cache)

        return self.plugins

    def get_plugin(self, plugin_name):
        response = requests.get(url=f'{self.host}:{self.port}/api/plugins/{plugin_name}',
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def execute_plugin(self, plugin_name, options: Dict):
        response = requests.post(url=f'{self.host}:{self.port}/api/plugins/{plugin_name}',
                                 json=options,
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def update_agent_notes(self, agent_name: str, notes: str):
        response = requests.post(url=f'{self.host}:{self.port}/api/agents/{agent_name}/notes',
                                 json=notes,
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def agent_upload_file(self, agent_name: str, file_name: str, file_data: bytes):
        response = requests.post(url=f'{self.host}:{self.port}/api/agents/{agent_name}/upload',
                                 json={'filename': file_name, 'data': file_data},
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def agent_download_file(self, agent_name: str, file_name: str):
        response = requests.post(url=f'{self.host}:{self.port}/api/agents/{agent_name}/download',
                                 json={'filename': file_name},
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def agent_sleep(self, agent_name: str, delay: int, jitter: float):
        response = requests.put(url=f'{self.host}:{self.port}/api/agents/{agent_name}/sleep',
                                 json={'delay': delay, 'jitter': jitter},
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def update_user_notes(self, username: str, notes: str):
        response = requests.post(url=f'{self.host}:{self.port}/api/users/{username}/notes',
                                 json=notes,
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def get_users(self):
        response = requests.get(url=f'{self.host}:{self.port}/api/users',
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def create_user(self, new_user):
        response = requests.post(url=f'{self.host}:{self.port}/api/users',
                                 json=new_user,
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def disable_user(self, user_id: str, account_status: str):
        response = requests.put(url=f'{self.host}:{self.port}/api/users/{user_id}/disable',
                                json=account_status,
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def get_user(self, user_id: str):
        response = requests.get(url=f'{self.host}:{self.port}/api/users/{user_id}',
                                verify=False,
                                params={'token': self.token})

        return response.json()

    def get_user_me(self):
        response = requests.get(url=f'{self.host}:{self.port}/api/users/me',
                                verify=False,
                                params={'token': self.token})

        self.me = response.json()
        return response.json()

    def get_malleable_profile(self):
        response = requests.get(url=f'{self.host}:{self.port}/api/malleable-profiles',
                                verify=False,
                                params={'token': self.token})

        self.profiles = {x['name']: x for x in response.json()['profiles']}

        return self.profiles

    def get_bypasses(self):
        response = requests.get(url=f'{self.host}:{self.port}/api/bypasses',
                                verify=False,
                                params={'token': self.token})

        self.bypasses = {x['name']: x for x in response.json()['bypasses']}

        return self.bypasses

    def add_malleable_profile(self, profile_name: str, profile_category: str, profile_data: str):
        response = requests.post(url=f'{self.host}:{self.port}/api/malleable-profiles',
                                 json={'profile_name': profile_name, 'profile_category': profile_category,
                                       'data': profile_data},
                                 verify=False,
                                 params={'token': self.token})

        return response.json()

    def delete_malleable_profile(self, profile_name: str):
        response = requests.delete(url=f'{self.host}:{self.port}/api/malleable-profiles/{profile_name}',
                                   verify=False,
                                   params={'token': self.token})

        return response.json()


state = EmpireCliState()
