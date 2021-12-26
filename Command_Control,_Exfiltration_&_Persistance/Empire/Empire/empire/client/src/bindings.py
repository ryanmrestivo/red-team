import time

from prompt_toolkit.filters import Condition
from prompt_toolkit.key_binding import KeyBindings
from prompt_toolkit.output import ColorDepth
from prompt_toolkit.shortcuts import ProgressBar
from prompt_toolkit.shortcuts.progress_bar import formatters

from empire.client.src.MenuState import menu_state

bindings = KeyBindings()


@Condition
def ctrl_c_filter():
    if menu_state.current_menu_name == 'ChatMenu' or menu_state.current_menu_name == 'ShellMenu':
        return True
    return False


@bindings.add('c-c', filter=ctrl_c_filter)
def do_ctrl_c(event):
    """
    If ctrl-c is pressed from the chat or shell menus, go back a menu.
    """
    menu_state.pop()


@bindings.add('f1', 'up', 'up', 'down', 'down', 'left', 'right', 'left', 'right', 'b', 'a')
def do_konami(event):
    custom_formatters = [
        formatters.Label(),
        formatters.Text(" "),
        formatters.Rainbow(formatters.Bar()),
        formatters.Text(" left: "),
        formatters.Rainbow(formatters.TimeLeft()),
    ]

    color_depth = ColorDepth.DEPTH_8_BIT
    with ProgressBar(formatters=custom_formatters, color_depth=color_depth) as pb:
        for i in pb(range(1000), label=""):
            time.sleep(0.001)
    print('Downloaded L33t Hax...')
