from prompt_toolkit import HTML
from prompt_toolkit.completion import Completion

from empire.client.src.EmpireCliState import state
from empire.client.src.menus.Menu import Menu
from empire.client.src.utils import table_util, print_util
from empire.client.src.utils.autocomplete_util import position_util, filtered_search_list
from empire.client.src.utils.cli_util import register_cli_commands, command


@register_cli_commands
class CredentialMenu(Menu):
    def __init__(self):
        super().__init__(display_name='credentials', selected='')

    def autocomplete(self):
        return self._cmd_registry + super().autocomplete()

    def get_completions(self, document, complete_event, cmd_line, word_before_cursor):
        if cmd_line[0] in ['remove'] and position_util(cmd_line, 2, word_before_cursor):
            for cred in filtered_search_list(word_before_cursor, state.credentials.keys()):
                full = state.credentials[cred]
                help_text = print_util.truncate(
                    f"{full.get('username', '')}, {full.get('domain', '')}, {full.get('password', '')}", width=75)
                yield Completion(cred,
                                 display=HTML(f"{full['ID']} <purple>({help_text})</purple>"),
                                 start_position=-len(word_before_cursor))
            yield Completion('all', start_position=-len(word_before_cursor))
        if position_util(cmd_line, 1, word_before_cursor):
            yield from super().get_completions(document, complete_event, cmd_line, word_before_cursor)

    def on_enter(self):
        state.get_credentials()
        self.list()
        return True

    @command
    def list(self) -> None:
        """
        Get running/available agents

        Usage: list
        """
        cred_list = list(map(
            lambda x: [x['ID'], x['credtype'], x['domain'], x['username'], x['host'], x['password'][:50], x['sid'],
                       x['os'], x['notes']],
            state.get_credentials()))
        cred_list.insert(0, ['ID', 'CredType', 'Domain', 'UserName', 'Host', 'Password/Hash', 'SID', 'OS', 'Notes'])

        table_util.print_table(cred_list, 'Credentials')

    @command
    def remove(self, cred_id: str) -> None:
        """
        Removes specified credential ID. if 'all' is provided, all credentials will be removed.

        Usage: remove <cred_id>
        """
        if cred_id == 'all':
            choice = input(print_util.color(f"[>] Are you sure you want to remove all credentials? [y/N] ", "red"))
            if choice.lower() == "y":
                for key in state.credentials.keys():
                    self.remove_credential(key)
        else:
            self.remove_credential(cred_id)

        state.get_credentials()

    @staticmethod
    def remove_credential(cred_id: str):
        remove_response = state.remove_credential(cred_id)
        if 'success' in remove_response.keys():
            print(print_util.color('[*] Credential ' + cred_id + ' removed.'))
        elif 'error' in remove_response.keys():
            print(print_util.color('[!] Error: ' + remove_response['error']))


credential_menu = CredentialMenu()
