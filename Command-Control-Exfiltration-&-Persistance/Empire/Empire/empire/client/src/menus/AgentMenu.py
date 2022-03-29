import string

from prompt_toolkit.completion import Completion

from empire.client.src.EmpireCliState import state
from empire.client.src.menus.Menu import Menu
from empire.client.src.utils import table_util, print_util, date_util
from empire.client.src.utils.autocomplete_util import filtered_search_list, position_util
from empire.client.src.utils.cli_util import register_cli_commands, command


@register_cli_commands
class AgentMenu(Menu):
    def __init__(self):
        super().__init__(display_name='agents', selected='')

    def autocomplete(self):
        return self._cmd_registry + super().autocomplete()

    def get_completions(self, document, complete_event, cmd_line, word_before_cursor):
        if cmd_line[0] in ['kill'] and position_util(cmd_line, 2, word_before_cursor):
            for agent in filtered_search_list(word_before_cursor, state.agents.keys()):
                yield Completion(agent, start_position=-len(word_before_cursor))
            yield Completion('all', start_position=-len(word_before_cursor))
            yield Completion('stale', start_position=-len(word_before_cursor))
        elif cmd_line[0] in ['clear', 'rename'] and position_util(cmd_line, 2, word_before_cursor):
            for agent in filtered_search_list(word_before_cursor, state.agents.keys()):
                yield Completion(agent, start_position=-len(word_before_cursor))
        elif position_util(cmd_line, 1, word_before_cursor):
            yield from super().get_completions(document, complete_event, cmd_line, word_before_cursor)

    def on_enter(self):
        self.list()
        return True

    @command
    def list(self) -> None:
        """
        Get running/available agents

        Usage: list
        """
        agent_list = []
        agent_formatting = []
        for agent in state.get_agents().values():
            agent_list.append([str(agent['ID']),
                               agent['name'],
                               agent['language'],
                               agent['internal_ip'],
                               print_util.text_wrap(agent['username']),
                               print_util.text_wrap(agent['process_name'], width=20),
                               agent['process_id'],
                               str(agent['delay']) + '/' + str(agent['jitter']),
                               print_util.text_wrap(date_util.humanize_datetime(agent['lastseen_time']), width=25),
                               agent['listener']])
            agent_formatting.append([agent['stale'], agent['high_integrity']])

        agent_formatting.insert(0, ['Stale', 'High Integrity'])
        agent_list.insert(0, ['ID', 'Name', 'Language', 'Internal IP', 'Username', 'Process',
                              'PID', 'Delay', 'Last Seen', 'Listener'])
        table_util.print_agent_table(agent_list, agent_formatting, 'Agents')

    @command
    def kill(self, agent_name: str) -> None:
        """
        Kills and removes specified agent [agent_name, stale, or all].

        Usage: kill <agent_name>
        """
        choice = input(print_util.color(f"[>] Are you sure you want to kill { agent_name }? [y/N] ", "red"))
        if choice.lower() == "y":
            if agent_name == 'all':
                for agent_name in state.get_agents().keys():
                    self.kill_agent(agent_name)
            elif agent_name == 'stale':
                for agent_name, agent in state.get_agents().items():
                    if agent['stale'] == True:
                        self.kill_agent(agent_name)
            else:
                self.kill_agent(agent_name)
        else:
            return

    @command
    def clear(self, agent_name: str) -> None:
        """
        Clear tasks for selected listener

        Usage: clear <agent_name>
        """
        state.clear_agent(agent_name)

    @command
    def rename(self, agent_name: str, new_agent_name: str) -> None:
        """
        Rename selected listener

        Usage: rename <agent_name> <new_agent_name>
        """
        state.rename_agent(agent_name, new_agent_name)

    @staticmethod
    def kill_agent(agent_name: str) -> None:
        kill_response = state.kill_agent(agent_name)
        if 'success' in kill_response.keys():
            print(print_util.color('[*] Kill command sent to agent ' + agent_name))
            remove_response = state.remove_agent(agent_name)
            if 'success' in remove_response.keys():
                print(print_util.color('[*] Removed agent ' + agent_name + ' from list'))
            elif 'error' in remove_response.keys():
                print(print_util.color('[!] Error: ' + remove_response['error']))
        elif 'error' in kill_response.keys():
            print(print_util.color('[!] Error: ' + kill_response['error']))


def trunc(value: str = '', limit: int = 1) -> str:
    if value:
        if len(value) > limit:
            return value[:limit - 2] + '..'
        else:
            return value
    return ''


agent_menu = AgentMenu()
