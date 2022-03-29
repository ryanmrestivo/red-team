from empire.client.src.EmpireCliState import state
from empire.client.src.menus.Menu import Menu
from empire.client.src.utils import table_util
from empire.client.src.utils.autocomplete_util import position_util
from empire.client.src.utils.cli_util import register_cli_commands, command


@register_cli_commands
class PluginMenu(Menu):
    def __init__(self):
        super().__init__(display_name='plugins', selected='')

    def autocomplete(self):
        return self._cmd_registry + super().autocomplete()

    def get_completions(self, document, complete_event, cmd_line, word_before_cursor):
        if position_util(cmd_line, 1, word_before_cursor):
            yield from super().get_completions(document, complete_event, cmd_line, word_before_cursor)

    def on_enter(self):
        self.list()
        return True

    @command
    def list(self) -> None:
        """
        Get active plugins

        Usage: list
        """
        plugins_list = list(map(
            lambda x: [x['Name'], x['Description']], state.get_active_plugins().values()))
        plugins_list.insert(0, ['Name', 'Description'])

        table_util.print_table(plugins_list, 'Plugins')


plugin_menu = PluginMenu()
