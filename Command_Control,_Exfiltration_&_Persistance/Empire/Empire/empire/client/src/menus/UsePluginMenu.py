from typing import Dict

from prompt_toolkit.completion import Completion

from empire.client.src.EmpireCliState import state
from empire.client.src.menus.UseMenu import UseMenu
from empire.client.src.utils.autocomplete_util import filtered_search_list, position_util
from empire.client.src.utils import print_util
from empire.client.src.utils.cli_util import register_cli_commands, command


@register_cli_commands
class UsePluginMenu(UseMenu):
    def __init__(self):
        super().__init__(display_name='useplugin', selected='', record_options=None)

    def autocomplete(self):
        return self._cmd_registry + super().autocomplete()

    def get_completions(self, document, complete_event, cmd_line, word_before_cursor):
        if cmd_line[0] == 'useplugin' and position_util(cmd_line, 2, word_before_cursor):
            for plugin in filtered_search_list(word_before_cursor, state.plugins.keys()):
                yield Completion(plugin, start_position=-len(word_before_cursor))
        else:
            yield from super().get_completions(document, complete_event, cmd_line, word_before_cursor)

    def on_enter(self, **kwargs) -> bool:
        if 'selected' not in kwargs:
            return False
        else:
            self.use(kwargs['selected'])
            self.options()
            self.display_cached_results()
            return True

    def display_cached_results(self) -> None:
        """
        Print the plugin results for all the results that have been received for this plugin.
        """
        plugin_results = state.cached_plugin_results.get(self.selected, {})
        for key, value in plugin_results.items():
            print(print_util.color(value))

        state.cached_plugin_results.get(self.selected, {}).clear()

    def use(self, plugin_name: str) -> None:
        """
        Use the selected plugin

        Usage: use <plugin_name>
        """
        state.get_active_plugins()
        if plugin_name in state.plugins:
            self.selected = plugin_name
            self.record = state.plugins[plugin_name]
            self.record_options = state.plugins[plugin_name]['options']

    @command
    def execute(self):
        """
        Run current plugin

        Usage: execute
        """
        post_body = {}
        for key, value in self.record_options.items():
            post_body[key] = self.record_options[key]['Value']

        response = state.execute_plugin(self.selected, post_body)
        if isinstance(response, Dict) and 'error' in response:
            print(print_util.color(response['error']))

    @command
    def generate(self):
        """
        Run current plugin

        Usage: generate
        """
        self.execute()

    @command
    def info(self):
        """
        Info about current plugin (ex: Authors, Description, etc)

        Usage: info
        """
        print(print_util.color('[!] TODO: info to plugins API endpoint'))


use_plugin_menu = UsePluginMenu()
