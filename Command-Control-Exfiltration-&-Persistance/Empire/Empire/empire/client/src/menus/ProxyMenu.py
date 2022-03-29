import base64
import os
import textwrap
from typing import List

from prompt_toolkit.completion import Completion
from prompt_toolkit import HTML

from empire.client.src.EmpireCliState import state
from empire.client.src.Shortcut import Shortcut
from empire.client.src.ShortcutHandler import shortcut_handler
from empire.client.src.menus.UseMenu import UseMenu
from empire.client.src.utils import table_util, print_util
from empire.client.src.utils.autocomplete_util import filtered_search_list, position_util
from empire.client.src.utils.cli_util import register_cli_commands, command


@register_cli_commands
class ProxyMenu(UseMenu):
    def __init__(self):
        super().__init__(display_name='', selected='')
        self.stop_threads = False

    def autocomplete(self):
        return self._cmd_registry + super().autocomplete()

    def get_completions(self, document, complete_event, cmd_line, word_before_cursor):
        if cmd_line[0] in ['set', 'unset'] and position_util(cmd_line, 2, word_before_cursor):
            for option in filtered_search_list(word_before_cursor, self.record_options):
                yield Completion(option, start_position=-len(word_before_cursor))
        elif cmd_line[0] == 'set' and position_util(cmd_line, 3, word_before_cursor):
                if len(cmd_line) > 1 and len(self.suggested_values_for_option(cmd_line[1])) > 0:
                    for suggested_value in filtered_search_list(word_before_cursor,
                                                                self.suggested_values_for_option(cmd_line[1])):
                        yield Completion(suggested_value, start_position=-len(word_before_cursor))
        else:
            yield from super().get_completions(document, complete_event, cmd_line, word_before_cursor)

    def on_enter(self, **kwargs) -> bool:
        if 'selected' not in kwargs:
            return False
        else:
            self.use(kwargs['selected'])
            return True

    def get_prompt(self) -> str:
        return f"(Empire: <ansired>{self.selected}</ansired>/<ansiblue>proxy</ansiblue>) > "

    def use(self, agent_name: str) -> None:
        """
        Use proxy

        Usage: proxy
        """
        try:
            self.record = state.get_proxy_info(agent_name)['proxy']
            self.record_options = self.record['options']
            if agent_name in state.agents.keys():
                self.selected = agent_name
                self.session_id = state.agents[self.selected]['session_id']
                self.agent_options = state.agents[agent_name]  # todo rename agent_options
                self.agent_language = self.agent_options['language']
                self.proxy_list = self.agent_options['proxy']
                if not self.proxy_list:
                    self.proxy_list = []
                self.list()
        except:
            print(print_util.color(f'[!] Error: Proxy menu failed to initialize'))

    @command
    def add(self, position: int) -> None:
        """
        Tasks an the specified agent to update proxy chain

        Usage: add_proxy [<position>]
        """
        self.agent_options = state.agents[self.session_id]
        if not self.proxy_list:
            self.proxy_list = []

        if position:
            self.proxy_list.insert(int(position), {'proxytype': self.record_options['Proxy_Type']['Value'],
                            'addr': self.record_options['Address']['Value'],
                            'port': int(self.record_options['Port']['Value'])})
        else:
            self.proxy_list.append({'proxytype': self.record_options['Proxy_Type']['Value'],
                                                   'addr': self.record_options['Address']['Value'],
                                                   'port': int(self.record_options['Port']['Value'])})

        # print table of proxies
        self.list()

    @command
    def delete(self, position: int) -> None:
        """
        Tasks an the specified agent to remove proxy chain

        Usage: delete_proxy <position>
        """
        self.agent_options = state.agents[self.session_id]
        if not self.proxy_list:
            self.proxy_list = []

        self.proxy_list.pop(int(position))

        # print table of proxies
        self.list()

    @command
    def execute(self) -> None:
        """
        Tasks an the specified agent to update its proxy chain

        Usage: execute
        """
        if self.proxy_list:
            response = state.update_agent_proxy(self.session_id, self.proxy_list)
            print(print_util.color(f'[*] Tasked agent to update proxy chain'))
        else:
            print(print_util.color(f'[!] No proxy chain to configure'))

    @command
    def list(self) -> None:
        """
        Display list of current proxy chains

        Usage: list
        """
        proxies = list(map(lambda x: [self.proxy_list.index(x)+1, x['addr'], x['port'], x['proxytype']], self.proxy_list))
        proxies.insert(0, ['Hop', 'Address', 'Port', 'Proxy Type'])

        table_util.print_table(proxies, 'Active Proxies')

    @command
    def options(self):
        """
        Print the current record options

        Usage: options
        """
        record_list = []
        for key, value in self.record_options.items():
            name = key
            record_value = print_util.text_wrap(value.get('Value', ''))
            required = print_util.text_wrap(value.get('Required', ''))
            description = print_util.text_wrap(value.get('Description', ''))
            record_list.append([name, record_value, required, description])

        record_list.insert(0, ['Name', 'Value', 'Required', 'Description'])

        table_util.print_table(record_list, 'Record Options')

    def suggested_values_for_option(self, option: str) -> List[str]:
        try:
            lower = {k.lower(): v for k, v in self.record_options.items()}
            return lower.get(option, {}).get('SuggestedValues', [])
        except AttributeError:
            return []


proxy_menu = ProxyMenu()
