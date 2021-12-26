from prompt_toolkit import HTML
from prompt_toolkit.completion import Completion

from empire.client.src.EmpireCliState import state
from empire.client.src.menus.UseMenu import UseMenu
from empire.client.src.utils import print_util
from empire.client.src.utils.autocomplete_util import filtered_search_list, position_util
from empire.client.src.utils.cli_util import register_cli_commands, command


@register_cli_commands
class UseCredentialMenu(UseMenu):
    def __init__(self):
        super().__init__(display_name='usecredential', selected='', record=None, record_options=None)

    def autocomplete(self):
        return self._cmd_registry + super().autocomplete()

    def get_completions(self, document, complete_event, cmd_line, word_before_cursor):
        if cmd_line[0] in ['usecredential'] and position_util(cmd_line, 2, word_before_cursor):
            for cred in filtered_search_list(word_before_cursor, state.credentials.keys()):
                full = state.credentials[cred]
                help_text = print_util.truncate(
                    f"{full.get('username', '')}, {full.get('domain', '')}, {full.get('password', '')}", width=75)
                yield Completion(cred,
                                 display=HTML(f"{full['ID']} <purple>({help_text})</purple>"),
                                 start_position=-len(word_before_cursor))
            yield Completion('add', start_position=-len(word_before_cursor))
        elif cmd_line[0] in ['set', 'unset'] and position_util(cmd_line, 2, word_before_cursor):
            for option in filtered_search_list(word_before_cursor, self.record_options):
                if option != 'id':
                    yield Completion(option, start_position=-len(word_before_cursor))
        elif cmd_line[0] == 'set' and position_util(cmd_line, 3, word_before_cursor):
            if len(cmd_line) > 1 and cmd_line[1] == 'credtype':
                for option in filtered_search_list(word_before_cursor, ['plaintext', 'hash']):
                    yield Completion(option, start_position=-len(word_before_cursor))
        else:
            yield from super().get_completions(document, complete_event, cmd_line, word_before_cursor)

    def on_enter(self, **kwargs) -> bool:
        self.selected = kwargs['selected']
        if self.selected == 'add':
            self.record_options = {'credtype': {'Value': '', 'Required': 'True',
                                                'Description': 'Must be one of "plaintext" or "hash"'},
                                   'domain': {'Value': '', 'Required': 'True'},
                                   'username': {'Value': '', 'Required': 'True'},
                                   'host': {'Value': '', 'Required': 'True'},
                                   'password': {'Value': '', 'Required': 'True'},
                                   'sid': {'Value': '', 'Required': 'False'},
                                   'os': {'Value': '', 'Required': 'False'},
                                   'notes': {'Value': '', 'Required': 'False'}}
        else:
            temp = state.get_credential(self.selected)
            self.record_options = {}
            for key, val in temp.items():
                self.record_options[key] = {'Value': val,
                                            'Required': 'False' if key in ['sid', 'os', 'notes'] else 'True',
                                            'Description': ''}
            del self.record_options['ID']
        self.options()
        return True

    def info(self):
        """"
        Not needed for this menu. Overriding to stop the default from executing.

        Usage: info
        """
        pass

    @command
    def execute(self):
        """
        Update selected credential

        Usage: execute
        """
        if self.selected == 'add':
            temp = {}
            for key, val in self.record_options.items():
                temp[key] = val['Value']
            response = state.add_credential(temp)
            if 'ID' in response.keys():
                print(print_util.color(f'[*] Credential {response["ID"]} successfully added'))
                state.get_credentials()
            elif 'error' in response.keys():
                if response['error'].startswith('[!]'):
                    msg = response['error']
                else:
                    msg = f"[!] Error: {response['error']}"
                print(print_util.color(msg))
        else:
            temp = {}
            for key, val in self.record_options.items():
                temp[key] = val['Value']
            response = state.edit_credential(self.selected, temp)
            if 'ID' in response.keys():
                print(print_util.color(f'[*] Credential {response["ID"]} successfully updated'))
                state.get_credentials()
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


use_credential_menu = UseCredentialMenu()
