from prompt_toolkit.completion import Completion

from empire.client.src.utils import table_util, print_util
from empire.client.src.utils.autocomplete_util import filtered_search_list
from empire.client.src.utils.cli_util import command


class Menu(object):
    """
    Base Menu object.
    """
    def __init__(self, display_name: str = '', selected: str = ''):
        """
        :param display_name: The display name for the menu. This is used by the default get_prompt method.
        :param selected: The selected item. Applicable for Menus such UseStager or UseListener.
        """
        self.display_name = display_name
        self.selected = selected
        # Gets overwritten by the register_cli_commands decorator.
        # Nice to have here just to stop the warnings
        self._cmd_registry = [] if not self._cmd_registry else self._cmd_registry

    def autocomplete(self):
        """
        The default list of autocomplete commands aka 'the globals'
        A menu should return its own list in addition to these globals.
        :return: list[str]
        """
        return [
            'admin',
            'agents',
            'back',
            'chat',
            'credentials',
            'interact',
            'listeners',
            'main',
            'plugins',
            'sponsors',
            'uselistener',
            'usemodule',
            'useplugin',
            'usestager',
            'usecredential',
            'exit',
        ]

    def get_completions(self, document, complete_event, cmd_line, word_before_cursor):
        """
        The default completion method. A menu should implement its own get_completion method
        for autocompleting its own commands and then use this as a fallback for autocompleting the globals.
        """
        word_before_cursor = document.get_word_before_cursor()
        for word in filtered_search_list(word_before_cursor, self.autocomplete()):
            if word.startswith(word_before_cursor):
                yield Completion(word, start_position=-len(word_before_cursor))

    def on_enter(self, **kwargs) -> bool:
        """
        When a user changes menus, the on_enter method will be called. Returning True means that
        changing menus succeeded. Any initialization that needs to happen should happen here before returning.
        For example: Checking to see that the requested module is available, setting it to self.selected, and then
        printing out its options.
        :param kwargs: A menu can implement with any specific kwargs it needs
        :return: bool
        """
        return True

    def on_leave(self):
        """
        When a user changes menus, the on_leave method will be called. Any cleanup that needs to happen should happen at this point.
        :return:
        """
        pass

    def on_connect(self):
        """
        When the application connects to a server, this function is called.
        """
        pass

    def on_disconnect(self):
        """
        When the application disconnects from a server, this function is called.
        """
        pass

    def get_prompt(self) -> str:
        """
        This is the (HTML-wrapped) string that will be used for the prompt. If it doesn't need to be customized,
        this will display a combination of the menu's display name and the selected item.
        :return:
        """
        joined = '/'.join([self.display_name, self.selected]).strip('/')
        return f"(Empire: <ansiblue>{joined}</ansiblue>) > "

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

        help_list.insert(0, ['Name', 'Description', 'Usage'])
        table_util.print_table(help_list, 'Help Options')
