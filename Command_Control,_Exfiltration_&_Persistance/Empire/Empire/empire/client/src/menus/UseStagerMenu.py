import base64
import os
import textwrap

from prompt_toolkit.completion import Completion

from empire.client.src.EmpireCliState import state
from empire.client.src.menus.UseMenu import UseMenu
from empire.client.src.utils import print_util
from empire.client.src.utils.autocomplete_util import filtered_search_list, position_util
from empire.client.src.utils.cli_util import register_cli_commands, command


@register_cli_commands
class UseStagerMenu(UseMenu):
    def __init__(self):
        super().__init__(display_name='usestager', selected='', record=None, record_options=None)

    def autocomplete(self):
        return self._cmd_registry + super().autocomplete()

    def get_completions(self, document, complete_event, cmd_line, word_before_cursor):
        if cmd_line[0] == 'usestager' and position_util(cmd_line, 2, word_before_cursor):
            for stager in filtered_search_list(word_before_cursor, state.stagers.keys()):
                yield Completion(stager, start_position=-len(word_before_cursor))
        else:
            yield from super().get_completions(document, complete_event, cmd_line, word_before_cursor)

    def on_enter(self, **kwargs) -> bool:
        if 'selected' not in kwargs:
            return False
        else:
            state.get_bypasses()
            self.use(kwargs['selected'])
            self.info()
            self.options()
            return True

    def use(self, module: str) -> None:
        """
        Use the selected stager.

        Usage: use <module>
        """
        if module in state.stagers.keys():  # todo rename module?
            self.selected = module
            self.record = state.stagers[module]
            self.record_options = state.stagers[module]['options']

            listener_list = []
            for key, value in self.record_options.items():
                values = list(map(lambda x: '\n'.join(textwrap.wrap(str(x), width=35)), value.values()))
                values.reverse()
                temp = [key] + values
                listener_list.append(temp)

    @command
    def execute(self):
        """
        Execute the stager

        Usage: execute
        """
        # todo validation and error handling
        # Hopefully this will force us to provide more info in api errors ;)
        post_body = {}
        for key, value in self.record_options.items():
            post_body[key] = self.record_options[key]['Value']

        response = state.create_stager(self.selected, post_body)

        if 'error' in response:
            print(print_util.color(response['error']))
            return
        elif response[self.selected].get('OutFile', {}).get('Value'):
            if response[self.selected].get('Output', '') == '':
                # todo stagers endpoint needs to give modules a way to return errors better.
                #  This says if the output is empty then something must have gone wrong.
                print(print_util.color('[!] Stager output empty.'))
                return
            file_name = response[self.selected].get('OutFile').get('Value').split('/')[-1]
            output_bytes = base64.b64decode(response[self.selected]['Output'])
            directory = f"empire/client/generated-stagers/{file_name}"
            with open(directory, 'wb') as f:
                f.write(output_bytes)
            print(print_util.color(f'[+] {file_name} written to {os.path.abspath(os.getcwd())}/{directory}'))
        else:
            print(print_util.color(response[self.selected]['Output']))

    @command
    def generate(self):
        """
        Generate the stager

        Usage: generate
        """
        self.execute()


use_stager_menu = UseStagerMenu()
