from typing import Optional

from empire.client.src.menus.Menu import Menu


class MenuState:
    """
    Class for managing the applications menus.
    """

    def __init__(self):
        self.current_menu: Optional[Menu] = None
        self.menu_history = []

    @property
    def current_menu_name(self) -> str:
        if self.current_menu:
            return self.current_menu.__class__.__name__
        return ''

    def push(self, menu: Menu, **kwargs):
        if menu.on_enter(**kwargs):
            if self.current_menu:  # will be None when bootstrapping
                self.current_menu.on_leave()
            self.current_menu = menu
            self.menu_history.append(menu)

    def pop(self):
        # Potential bug in old and new implementations? Not calling on_enter
        # and can't call it because we don't have the kwargs.
        if menu_state.current_menu_name != 'MainMenu':
            self.current_menu.on_leave()
            del self.menu_history[-1]
            self.current_menu = self.menu_history[-1]


menu_state = MenuState()
