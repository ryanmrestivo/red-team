from prompt_toolkit.completion import Completion

from empire.client.src.EmpireCliState import state
from empire.client.src.MenuState import menu_state
from empire.client.src.menus.UseMenu import UseMenu
from empire.client.src.utils import print_util
from empire.client.src.utils.autocomplete_util import filtered_search_list, position_util
from empire.client.src.utils.cli_util import register_cli_commands, command


@register_cli_commands
class UseModuleMenu(UseMenu):
    def __init__(self):
        super().__init__(display_name='usemodule', selected='', record=None, record_options=None)
        self.stop_threads = False

    def autocomplete(self):
        return self._cmd_registry + super().autocomplete()

    def get_completions(self, document, complete_event, cmd_line, word_before_cursor):
        if cmd_line[0] == 'usemodule' and position_util(cmd_line, 2, word_before_cursor):
            for module in filtered_search_list(word_before_cursor, state.modules.keys()):
                yield Completion(module, start_position=-len(word_before_cursor))
        else:
            yield from super().get_completions(document, complete_event, cmd_line, word_before_cursor)

    def on_enter(self, **kwargs) -> bool:
        if 'selected' not in kwargs:
            return False
        else:
            state.get_bypasses()
            self.use(kwargs['selected'])
            self.stop_threads = False

            if 'agent' in kwargs and 'Agent' in self.record_options:
                self.set('Agent', kwargs['agent'])
            self.info()
            self.options()
            state.get_credentials()
            return True

    def on_leave(self):
        self.stop_threads = True

    def use(self, module: str) -> None:
        """
        Use the selected module

        Usage: use <module>
        """
        if module in state.modules.keys():
            self.selected = module
            self.record = state.modules[module]
            self.record_options = state.modules[module]['options']

    @command
    def execute(self):
        """
        Execute the selected module

        Usage: execute
        """
        post_body = {}
        for key, value in self.record_options.items():
            post_body[key] = self.record_options[key]['Value']

        response = state.execute_module(self.selected, post_body)
        if 'success' in response.keys():
            if 'Agent' in post_body.keys():
                print(print_util.color(
                    '[*] Tasked ' + self.record_options['Agent']['Value'] + ' to run Task ' + str(response['taskID'])))
                menu_state.pop()
            else:
                print(print_util.color(
                    '[*] ' + str(response['msg'])))

        elif 'error' in response.keys():
            if response['error'].startswith('[!]'):
                msg = response['error']
            else:
                msg = f"[!] Error: {response['error']}"
            print(print_util.color(msg))

    @command
    def generate(self):
        """
        Execute the selected module

        Usage: generate
        """
        self.execute()


use_module_menu = UseModuleMenu()
