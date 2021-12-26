import base64
import os
import textwrap
from typing import List

from prompt_toolkit.completion import Completion
from prompt_toolkit import HTML

from empire.client.src.EmpireCliState import state
from empire.client.src.Shortcut import Shortcut
from empire.client.src.ShortcutHandler import shortcut_handler
from empire.client.src.menus.Menu import Menu
from empire.client.src.utils import table_util, print_util
from empire.client.src.utils.autocomplete_util import filtered_search_list, position_util
from empire.client.src.utils.cli_util import register_cli_commands, command


@register_cli_commands
class InteractMenu(Menu):
    def __init__(self):
        super().__init__(display_name='', selected='')
        self.agent_options = {}
        self.agent_language = ''
        self.session_id = ''

    def autocomplete(self):
        return self._cmd_registry + \
               super().autocomplete() + \
               shortcut_handler.get_names(self.agent_language)

    def get_completions(self, document, complete_event, cmd_line, word_before_cursor):
        if cmd_line[0] in ['interact'] and position_util(cmd_line, 2, word_before_cursor):
            active_agents = list(map(lambda a: a['name'], filter(lambda a: a['stale'] is not True, state.agents.values())))
            for agent in filtered_search_list(word_before_cursor, active_agents):
                yield Completion(agent, start_position=-len(word_before_cursor))
        elif position_util(cmd_line, 1, word_before_cursor):
            yield from super().get_completions(document, complete_event, cmd_line, word_before_cursor)
        elif cmd_line[0] in ['display'] and position_util(cmd_line, 2, word_before_cursor):
            for property_name in filtered_search_list(word_before_cursor, self.agent_options):
                yield Completion(property_name, start_position=-len(word_before_cursor))
        elif cmd_line[0] in shortcut_handler.get_names(self.agent_language):
            position = len(cmd_line)
            shortcut = shortcut_handler.get(self.agent_language, cmd_line[0])
            params = shortcut.get_dynamic_param_names()
            if position - 1 < len(params):
                if params[position - 1].lower() == 'listener':
                    for listener in filtered_search_list(word_before_cursor, state.listeners.keys()):
                        yield Completion(listener, start_position=-len(word_before_cursor))
                if params[position - 1].lower() == 'agent':
                    for agent in filtered_search_list(word_before_cursor, state.agents.keys()):
                        yield Completion(agent, start_position=-len(word_before_cursor))
        elif cmd_line[0] in ['view']:
            tasks = state.get_agent_tasks_slim(self.session_id)
            tasks = {str(x['taskID']): x for x in tasks['tasks']}

            for task_id in filtered_search_list(word_before_cursor, tasks.keys()):
                full = tasks[task_id]
                help_text = print_util.truncate(
                    f"{full.get('command', '')[:30]}, {full.get('username', '')}", width=75)
                yield Completion(task_id,
                                 display=HTML(f"{full['taskID']} <purple>({help_text})</purple>"),
                                 start_position=-len(word_before_cursor))

    def on_enter(self, **kwargs) -> bool:
        if 'selected' not in kwargs:
            return False
        else:
            self.use(kwargs['selected'])
            self.display_cached_results()
            return True

    def get_prompt(self) -> str:
        joined = '/'.join([self.display_name, self.selected]).strip('/')
        return f"(Empire: <ansired>{joined}</ansired>) > "

    def display_cached_results(self) -> None:
        """
        Print the task results for the all the results that have been received for this agent.
        """
        task_results = state.cached_agent_results.get(self.session_id, {})
        for key, value in task_results.items():
            print(print_util.color('[*] Task ' + str(key) + " results received"))
            print(value)

        state.cached_agent_results.get(self.session_id, {}).clear()

    def use(self, agent_name: str) -> None:
        """
        Use the selected agent

        Usage: use <agent_name>
        """
        state.get_agents()
        if agent_name in state.agents.keys():
            self.selected = agent_name
            self.session_id = state.agents[self.selected]['session_id']
            self.agent_options = state.agents[agent_name]  # todo rename agent_options
            self.agent_language = self.agent_options['language']

    @command
    def shell(self, shell_cmd: str) -> None:
        """
        Tasks an the specified agent to execute a shell command.

        Usage: shell <shell_cmd>
        """
        response = state.agent_shell(self.session_id, shell_cmd)
        print(print_util.color('[*] Tasked ' + self.session_id + ' to run Task ' + str(response['taskID'])))

    @command
    def script_import(self, script_location: str) -> None:
        """
        Imports a PowerShell script from the server and keeps it in memory in the agent.

        Usage: script_import <script_location>
        """
        response = state.agent_script_import(self.session_id, script_location)

        if 'success' in response.keys():
            print(print_util.color(
                '[*] Tasked ' + self.selected + ' to run Task ' + str(response['taskID'])))
        elif 'error' in response.keys():
            print(print_util.color('[!] Error: ' + response['error']))

    @command
    def script_command(self, script_cmd: str) -> None:
        """
        "Execute a function in the currently imported PowerShell script."

        Usage: shell_command <script_cmd>
        """
        response = state.agent_script_command(self.session_id, script_cmd)
        print(print_util.color('[*] Tasked ' + self.session_id + ' to run Task ' + str(response['taskID'])))

    @command
    def upload(self, local_file_directory: str, destination_file_name: str) -> None:
        """
        Tasks an the specified agent to upload a file.

        Usage: upload <local_file_directory> [destination_file_name]
        """
        file_name = os.path.basename(local_file_directory)
        with open(local_file_directory, 'rb') as open_file:
            file_data = base64.b64encode(open_file.read())

        if destination_file_name:
            file_name = destination_file_name

        response = state.agent_upload_file(self.session_id, file_name, file_data.decode('UTF-8'))
        print(print_util.color('[*] Tasked ' + self.selected + ' to run Task ' + str(response['taskID'])))

    @command
    def download(self, file_name: str) -> None:
        """
        Tasks an the specified agent to download a file.

        Usage: download <file_name>
        """
        response = state.agent_download_file(self.session_id, file_name)
        print(print_util.color('[*] Tasked ' + self.selected + ' to run Task ' + str(response['taskID'])))

    @command
    def sleep(self, delay: int, jitter: int) -> None:
        """
        Tasks an the specified agent to update delay (s) and jitter (0.0 - 1.0)

        Usage: sleep <delay> <jitter>
        """
        response = state.agent_sleep(self.session_id, delay, jitter)
        print(print_util.color(f'[*] Tasked agent to sleep delay/jitter {delay}/{jitter}'))
        print(print_util.color('[*] Tasked ' + self.selected + ' to run Task ' + str(response['taskID'])))

    @command
    def info(self) -> None:
        """
        Display agent info.

        Usage: info
        """
        agent_list = []
        for key, value in self.agent_options.items():
            if isinstance(value, int):
                value = str(value)
            if value is None:
                value = ''
            if key not in ['taskings', 'results']:
                temp = [key, '\n'.join(textwrap.wrap(str(value), width=45))]
                agent_list.append(temp)

        table_util.print_table(agent_list, 'Agent Options')

    @command
    def help(self):
        """
        Display the help menu for the current menu

        Usage: help
        """
        help_list = []
        for name in self._cmd_registry:
            try:
                description = print_util.text_wrap(getattr(self, name).__doc__.split('\n')[1].lstrip(), width=35)
                usage = print_util.text_wrap(getattr(self, name).__doc__.split('\n')[3].lstrip()[7:], width=35)
                help_list.append([name, description, usage])
            except:
                continue

        for name, shortcut in shortcut_handler.shortcuts[self.agent_language].items():
            try:
                description = shortcut.get_help_description()
                usage = shortcut.get_usage_string()
                help_list.append([name, description, usage])
            except:
                continue
        help_list.insert(0, ['Name', 'Description', 'Usage'])
        table_util.print_table(help_list, 'Help Options')

    @command
    def update_comms(self, listener_name: str) -> None:
        """
        Update the listener for an agent.

        Usage: update_comms <listener_name>
        """
        response = state.update_agent_comms(self.session_id, listener_name)

        if 'success' in response.keys():
            print(print_util.color('[*] Updated agent ' + self.selected + ' listener ' + listener_name))
        elif 'error' in response.keys():
            print(print_util.color('[!] Error: ' + response['error']))

    @command
    def killdate(self, kill_date: str) -> None:
        """
        Set an agent's killdate (01/01/2020)

        Usage: killdate <kill_date>
        """
        response = state.update_agent_killdate(self.session_id, kill_date)

        if 'success' in response.keys():
            print(print_util.color('[*] Updated agent ' + self.selected + ' killdate to ' + kill_date))
        elif 'error' in response.keys():
            print(print_util.color('[!] Error: ' + response['error']))

    @command
    def workinghours(self, working_hours: str) -> None:
        """
        Set an agent's working hours (9:00-17:00)

        Usage: workinghours <working_hours>
        """
        response = state.update_agent_working_hours(self.session_id, working_hours)

        if 'success' in response.keys():
            print(print_util.color('[*] Updated agent ' + self.selected + ' workinghours to ' + working_hours))
        elif 'error' in response.keys():
            print(print_util.color('[!] Error: ' + response['error']))

    @command
    def proxy(self, agent_name: str) -> None:
        """
        Proxy management menu for configuring agent proxies

        Usage: proxy
        """
        pass

    @command
    def display(self, property_name: str):
        """
        Display an agent property

        Usage: display <property_name>
        """
        if property_name in self.agent_options:
            print(f'{property_name} is {self.agent_options[property_name]}')

    @command
    def history(self, number_tasks: int):
        """
        Display last number of task results received.

        Usage: history [<number_tasks>]
        """
        if not number_tasks:
            number_tasks = 5

        response = state.get_agent_tasks(self.session_id, str(number_tasks))

        if 'agent' in response.keys():
            tasks = response['agent']
            for task in tasks:
                if task.get('results'):
                    print(print_util.color(f'[*] Task {task["taskID"]} results received'))
                    for line in task.get('results', '').split('\n'):
                        print(print_util.color(line))
                else:
                    print(print_util.color(f'[!] Task {task["taskID"]} No tasking results received'))
        elif 'error' in response.keys():
            print(print_util.color('[!] Error: ' + response['error']))

    @command
    def view(self, task_id: str):
        """
        View specific task and result

        Usage: view <task_id>
        """
        task = state.get_agent_task(self.session_id, task_id)
        record_list = []
        for key, value in task.items():
            # If results exceed a certain length they break the table function
            if key != 'results':
                record_list.append([print_util.color(key, 'blue'), value])
        table_util.print_table(record_list, 'View Task', colored_header=False, no_borders=True, end_space=False)
        print(print_util.color(" results", "blue"))
        for line in task['results'].split('\n'):
            print(print_util.color(line))

    def execute_shortcut(self, command_name: str, params: List[str]):
        shortcut: Shortcut = shortcut_handler.get(self.agent_language, command_name)

        if not shortcut:
            return None

        if shortcut.shell:
            self.shell(shortcut.shell)
            return

        if not len(params) == len(shortcut.get_dynamic_param_names()):
            return None  # todo log message

        if shortcut.module not in state.modules:
            print(print_util.color(f'No module named {shortcut.name} found on the server.'))
            return None

        module_options = dict.copy(state.modules[shortcut.module]['options'])
        post_body = {}

        for i, shortcut_param in enumerate(shortcut.get_dynamic_params()):
            if shortcut_param.name in module_options:
                post_body[shortcut_param.name] = params[i]

        # TODO Still haven't figured out other data types. Right now everything is a string.
        #  Which I think is how it is in the old cli
        for key, value in module_options.items():
            if key in shortcut.get_dynamic_param_names():
                continue
            elif key in shortcut.get_static_param_names():
                post_body[key] = str(shortcut.get_param(key).value)
            else:
                post_body[key] = str(module_options[key]['Value'])
        post_body['Agent'] = self.session_id
        response = state.execute_module(shortcut.module, post_body)
        if 'success' in response.keys():
            print(print_util.color(
                '[*] Tasked ' + self.selected + ' to run Task ' + str(response['taskID'])))
        elif 'error' in response.keys():
            print(print_util.color('[!] Error: ' + response['error']))


interact_menu = InteractMenu()
