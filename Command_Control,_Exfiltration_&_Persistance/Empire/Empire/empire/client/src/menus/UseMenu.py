from typing import List

from prompt_toolkit import HTML
from prompt_toolkit.completion import Completion

from empire.client.src.EmpireCliState import state
from empire.client.src.menus.Menu import Menu
from empire.client.src.utils import print_util, table_util
from empire.client.src.utils.autocomplete_util import position_util, filtered_search_list, \
    where_am_i
from empire.client.src.utils.cli_util import command


class UseMenu(Menu):
    """
    A base menu object that can be used when needing the typical "use" behavior.
    Such as set, unset, info
    """

    def __init__(self, display_name='', selected='', record=None, record_options=None):
        """
        :param display_name: See Menu
        :param selected:  See Menu
        :param record: The record object
        :param record_options: The options to configure for the current record
        """
        super().__init__(display_name=display_name, selected=selected)
        self.record = record
        self.record_options = record_options

    def get_completions(self, document, complete_event, cmd_line, word_before_cursor):
        """
        Adds autocomplete for the set and unset methods and defers to the base Menu when trying to invoke
        global commands (position 1 commands).
        """
        if cmd_line[0] in ['set', 'unset'] and position_util(cmd_line, 2, word_before_cursor):
            for option in filtered_search_list(word_before_cursor, self.record_options):
                yield Completion(option, start_position=-len(word_before_cursor))
        elif cmd_line[0] == 'set' and len(cmd_line) > 1 and cmd_line[1] == 'bypasses' \
                and 'bypasses' in map(lambda x: x.lower(), self.record_options.keys())\
                and position_util(cmd_line, where_am_i(cmd_line, word_before_cursor), word_before_cursor):
            for suggested_value in filtered_search_list(word_before_cursor, state.bypasses):
                if suggested_value not in cmd_line:
                    yield Completion(suggested_value, start_position=-len(word_before_cursor))
        elif cmd_line[0] == 'set' and position_util(cmd_line, 3, word_before_cursor):
            if len(cmd_line) > 1 and cmd_line[1] == 'listener':
                for listener in filtered_search_list(word_before_cursor, state.listeners.keys()):
                    yield Completion(listener, start_position=-len(word_before_cursor))
            if len(cmd_line) > 1 and cmd_line[1] == 'profile':
                for profile in filtered_search_list(word_before_cursor, state.profiles.keys()):
                    yield Completion(profile, start_position=-len(word_before_cursor))
            if len(cmd_line) > 1 and cmd_line[1] == 'agent':
                for agent in filtered_search_list(word_before_cursor, state.agents.keys()):
                    yield Completion(agent, start_position=-len(word_before_cursor))
            if len(cmd_line) > 1 and cmd_line[1] == 'credid':
                for cred in filtered_search_list(word_before_cursor, state.credentials.keys()):
                    full = state.credentials[cred]
                    help_text = print_util.truncate(f"{full.get('username', '')}, {full.get('domain', '')}, {full.get('password', '')}", width=75)
                    yield Completion(cred,
                                     display=HTML(f"{full['ID']} <purple>({help_text})</purple>"),
                                     start_position=-len(word_before_cursor))

            if len(cmd_line) > 1 and len(self.suggested_values_for_option(cmd_line[1])) > 0:
                for suggested_value in filtered_search_list(word_before_cursor,
                                                            self.suggested_values_for_option(cmd_line[1])):
                    yield Completion(suggested_value, start_position=-len(word_before_cursor))
        elif position_util(cmd_line, 1, word_before_cursor):
            yield from super().get_completions(document, complete_event, cmd_line, word_before_cursor)

    @command
    def set(self, key: str, value: str):
        """
        Set a field for the current record

        Usage: set <key> <value>
        """
        # The value is always sent with additional wrapping quotes due to parsing crap,
        # So we strip the first set of quotes (because there may be another set of quotes that are
        # meant to be sent to the api).
        if value.startswith("\"") and value.endswith("\""):
            value = value[1:-1]
        if key in self.record_options:
            self.record_options[key]['Value'] = value
            print(print_util.color('[*] Set %s to %s' % (key, value)))
        else:
            print(print_util.color(f'Could not find field: {key}'))

    @command
    def unset(self, key: str):
        """
        Unset a record option

        Usage: unset <key>
        """
        if key in self.record_options:
            self.record_options[key]['Value'] = ''
            print(print_util.color('[*] Unset %s' % key))
        else:
            print(print_util.color(f'Could not find field: {key}'))

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

    @command
    def info(self):
        """"
        Print default info on the current record.

        Usage: info
        """
        record_list = []

        for key, values in self.record.items():
            if (key in ['Name', 'Author', 'Comments', 'Description', 'Language', 'Background', 'NeedsAdmin',
                        'OpsecSafe', 'Techniques', 'Software']):
                if isinstance(values, list):
                    if len(values) > 0 and values[0] != '':
                        for i, value in enumerate(values):
                            if key == 'Techniques':
                                value = 'http://attack.mitre.org/techniques/' + value
                            if i == 0:
                                record_list.append(
                                    [print_util.color(key, 'blue'), print_util.text_wrap(value, width=70)])
                            else:
                                record_list.append(['', print_util.text_wrap(value, width=70)])
                elif values != '':
                    if key == 'Software':
                        values = 'http://attack.mitre.org/software/' + values

                    record_list.append([print_util.color(key, 'blue'), print_util.text_wrap(values, width=70)])

        table_util.print_table(record_list, 'Record Info', colored_header=False, no_borders=True)

    def suggested_values_for_option(self, option: str) -> List[str]:
        try:
            lower = {k.lower(): v for k, v in self.record_options.items()}
            return lower.get(option, {}).get('SuggestedValues', [])
        except AttributeError:
            return []
