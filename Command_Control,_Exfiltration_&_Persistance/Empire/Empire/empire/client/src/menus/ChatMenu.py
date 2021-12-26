import socketio.exceptions

from empire.client.src.EmpireCliState import state
from empire.client.src.MenuState import menu_state
from empire.client.src.menus.Menu import Menu
from empire.client.src.utils import print_util
from empire.client.src.utils.autocomplete_util import position_util
from empire.client.src.utils.cli_util import register_cli_commands


@register_cli_commands
class ChatMenu(Menu):
    def __init__(self):
        super().__init__(display_name='chat', selected='')
        self.my_username = ''
        state.chat_cache = []

    def autocomplete(self):
        return self._cmd_registry + super().autocomplete()

    def get_completions(self, document, complete_event, cmd_line, word_before_cursor):
        if position_util(cmd_line, 1, word_before_cursor):
            yield from super().get_completions(document, complete_event, cmd_line, word_before_cursor)

    def get_prompt(self) -> str:
        return f"<b><ansigreen>{state.me['username']}</ansigreen></b>: "

    def on_connect(self):
        state.sio.on('chat/join', self.on_chat_join)
        state.sio.on('chat/leave', self.on_chat_leave)
        state.sio.on('chat/message', self.on_chat_message)
        state.sio.emit('chat/history')
        state.sio.emit('chat/join')

    def on_disconnect(self):
        if state.sio is not None:
            try:
                state.sio.emit('chat/leave')
            except socketio.exceptions.BadNamespaceError:
                print(print_util.color("[!] Unable to reach server"))

    def on_enter(self):
        print(print_util.color('[*] Exit Chat Menu with Ctrl+C'))
        self.my_username = state.me['username']

        for message in state.chat_cache:
            print(message)

        state.chat_cache = []

        return True

    @staticmethod
    def is_chat_active():
        return menu_state.current_menu_name == 'ChatMenu'

    def on_chat_join(self, data):
        message = print_util.color('[+] ' + data['message'])
        if self.is_chat_active() == 'ChatMenu':
            print(message)
        else:
            state.chat_cache.append(message)

    def on_chat_leave(self, data):
        message = print_util.color('[+] ' + data['message'])
        if self.is_chat_active():
            print(message)
        else:
            state.chat_cache.append(message)

    def on_chat_message(self, data):
        if data['username'] != state.me['username'] or data.get('history') is True:
            if data['username'] == state.me['username']:
                message = print_util.color(data['username'], 'green') + ': ' + data['message']
                if self.is_chat_active():
                    print(message)
                else:
                    state.chat_cache.append(print_util.color(message))
            else:
                message = print_util.color(data['username'], 'red') + ': ' + data['message']
                if self.is_chat_active():
                    print(message)
                else:
                    state.chat_cache.append(message)

    def send_chat(self, text):
        state.sio.emit('chat/message', {'message': text})


chat_menu = ChatMenu()
