import re
import shlex
import threading
import time
from typing import get_type_hints, Dict, List, Optional

import urllib3
from docopt import docopt
from prompt_toolkit import PromptSession, HTML
from prompt_toolkit.completion import Completer
from prompt_toolkit.history import InMemoryHistory
from prompt_toolkit.patch_stdout import patch_stdout

from empire.arguments import args
from empire.client.src.EmpireCliConfig import empire_config
from empire.client.src.EmpireCliState import state
from empire.client.src.MenuState import menu_state
from empire.client.src.ShortcutHandler import shortcut_handler
from empire.client.src.bindings import bindings
from empire.client.src.menus import Menu
from empire.client.src.menus.AdminMenu import admin_menu
from empire.client.src.menus.AgentMenu import agent_menu
from empire.client.src.menus.ChatMenu import chat_menu
from empire.client.src.menus.CredentialMenu import credential_menu
from empire.client.src.menus.InteractMenu import interact_menu
from empire.client.src.menus.ListenerMenu import listener_menu
from empire.client.src.menus.MainMenu import main_menu
from empire.client.src.menus.PluginMenu import plugin_menu
from empire.client.src.menus.ShellMenu import shell_menu
from empire.client.src.menus.ProxyMenu import proxy_menu
from empire.client.src.menus.EditListenerMenu import edit_listener_menu
from empire.client.src.menus.UseListenerMenu import use_listener_menu
from empire.client.src.menus.UseModuleMenu import use_module_menu
from empire.client.src.menus.UsePluginMenu import use_plugin_menu
from empire.client.src.menus.UseStagerMenu import use_stager_menu
from empire.client.src.menus.UseCredentialMenu import use_credential_menu
from empire.client.src.menus.SponsorsMenu import sponsors_menu
from empire.client.src.utils import print_util


class MyCustomCompleter(Completer):
    def __init__(self, empire_cli):
        self.empire_cli = empire_cli

    def get_completions(self, document, complete_event):
        word_before_cursor = document.get_word_before_cursor(WORD=True)

        try:
            cmd_line = list(map(lambda s: s.lower(), shlex.split(document.current_line)))
            if len(cmd_line) == 0:
                cmd_line.append('')
        except ValueError:
            pass
        else:
            if not state.connected:
                yield from self.empire_cli.menus['MainMenu'].get_completions(document, complete_event, cmd_line,
                                                                             word_before_cursor)
            # These commands should be accessible anywhere.
            elif cmd_line[0] in ['uselistener']:
                yield from self.empire_cli.menus['UseListenerMenu'].get_completions(document, complete_event, cmd_line,
                                                                                    word_before_cursor)
            elif cmd_line[0] in ['usestager']:
                yield from self.empire_cli.menus['UseStagerMenu'].get_completions(document, complete_event, cmd_line,
                                                                                  word_before_cursor)
            elif cmd_line[0] in ['usemodule']:
                yield from self.empire_cli.menus['UseModuleMenu'].get_completions(document, complete_event, cmd_line,
                                                                                  word_before_cursor)
            elif cmd_line[0] in ['interact']:
                yield from self.empire_cli.menus['InteractMenu'].get_completions(document, complete_event, cmd_line,
                                                                                 word_before_cursor)
            elif cmd_line[0] in ['useplugin']:
                yield from self.empire_cli.menus['UsePluginMenu'].get_completions(document, complete_event, cmd_line,
                                                                                  word_before_cursor)
            elif cmd_line[0] in ['usecredential']:
                yield from self.empire_cli.menus['UseCredentialMenu'].get_completions(document, complete_event,
                                                                                      cmd_line,
                                                                                      word_before_cursor)
            else:
                # Menu specific commands
                yield from menu_state.current_menu.get_completions(document, complete_event, cmd_line,
                                                                   word_before_cursor)


class CliExitException(BaseException):
    pass


class EmpireCli(object):
    def __init__(self) -> None:
        self.completer = MyCustomCompleter(self)
        self.menus: Dict[Menu] = {
            'MainMenu': main_menu,
            'ListenerMenu': listener_menu,
            'UseCredentialMenu': use_credential_menu,
            'UseListenerMenu': use_listener_menu,
            'EditListenerMenu': edit_listener_menu,
            'UseStagerMenu': use_stager_menu,
            'AgentMenu': agent_menu,
            'UseModuleMenu': use_module_menu,
            'InteractMenu': interact_menu,
            'ShellMenu': shell_menu,
            'CredentialMenu': credential_menu,
            'PluginMenu': plugin_menu,
            'UsePluginMenu': use_plugin_menu,
            'AdminMenu': admin_menu,
            'ChatMenu': chat_menu,
            'SponsorsMenu': sponsors_menu,
            'ProxyMenu': proxy_menu
        }
        for menu in self.menus.values():
            state.register_menu(menu)

    @staticmethod
    def strip(options):
        return {re.sub('[^A-Za-z0-9 _]+', '', k): v for k, v in options.items()}

    @staticmethod
    def get_autoconnect_server() -> Optional[str]:
        """
        Looks for a server in the yaml marked for autoconnect.
        If one is not found, returns None
        :return: the name of the server to autoconnect
        """
        servers = empire_config.yaml.get('servers', {})
        autoserver = list(filter(lambda x: x[1].get('autoconnect') is True, servers.items()))

        if len(autoserver) > 0:
            return autoserver[0][0]

        return None

    @staticmethod
    def update_in_bg(session: PromptSession):
        while True:
            time.sleep(2)
            session.message = HTML(menu_state.current_menu.get_prompt())
            session.app.invalidate()

    def main(self):
        if empire_config.yaml.get('suppress-self-cert-warning', True):
            urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

        # Create some history first. (Easy for testing.)
        history = InMemoryHistory()
        history.append_string("help")
        history.append_string('uselistener http')
        history.append_string('listeners')
        history.append_string("main")
        history.append_string("connect -c localhost")

        print_util.loading()
        print("\n")
        print("Use the 'connect' command to connect to your Empire server.")
        print("'connect -c localhost' will connect to a local empire instance with all the defaults")
        print("including the default username and password.")

        session = PromptSession(
            key_bindings=bindings,
            history=history,
            completer=self.completer,
            complete_in_thread=True,
            bottom_toolbar=state.bottom_toolbar,
        )
        t = threading.Thread(target=self.update_in_bg, args=[session])
        t.daemon = True
        t.start()

        menu_state.push(main_menu)

        autoserver = self.get_autoconnect_server()
        if autoserver:
            print(print_util.color(f'[*] Attempting to connect to server: {autoserver}'))
            self.menus['MainMenu'].connect(autoserver, config=True)

        if args.resource:
            with open(args.resource) as resource_file:
                print(print_util.color(f"[*] Executing Resource File: {args.resource}"))
                for cmd in resource_file:
                    with patch_stdout(raw=True):
                        try:
                            time.sleep(1)
                            text = session.prompt(accept_default=True, default=cmd.strip())
                            cmd_line = list(shlex.split(text))
                            self.parse_command_line(text, cmd_line, resource_file=True)
                        except CliExitException:
                            return
                        except Exception as e:
                            print(print_util.color(f'[*] Error parsing resource command: ', text))

        while True:
            try:
                with patch_stdout(raw=True):
                    text = session.prompt(HTML(menu_state.current_menu.get_prompt()), refresh_interval=None)
                    # cmd_line = list(map(lambda s: s.lower(), shlex.split(text)))
                    # TODO what to do about case sensitivity for parsing options.
                    cmd_line = list(shlex.split(text))
                    self.parse_command_line(text, cmd_line)
            except KeyboardInterrupt:
                print(print_util.color("[!] Type exit to quit"))
            except ValueError as e:
                print(print_util.color(f'[!] Error processing command: {e}'))
            except EOFError:
                break  # Control-D pressed.
            except CliExitException:
                break

    def parse_command_line(self, text: str, cmd_line: List[str], resource_file=False):
        if len(cmd_line) == 0:
            return
        if not state.connected and not cmd_line[0] == 'connect':
            if cmd_line[0] == 'exit':
                choice = input(print_util.color("[>] Exit? [y/N] ", "red"))
                if choice.lower() == "y":
                    raise CliExitException
                else:
                    return
            else:
                return

        # Switch Menus
        if text.strip() == 'main':
            state.get_modules()
            state.get_listeners()
            print_util.title(state.empire_version, len(state.modules), len(state.listeners),
                             len(state.get_active_agents()))
            menu_state.push(self.menus['MainMenu'])
        elif text.strip() == 'listeners':
            menu_state.push(self.menus['ListenerMenu'])
        elif text.strip() == 'chat':
            menu_state.push(self.menus['ChatMenu'])
        elif menu_state.current_menu_name == 'ChatMenu':
            menu_state.current_menu.send_chat(text)
        elif text.strip() == 'agents':
            menu_state.push(self.menus['AgentMenu'])
        elif text.strip() == 'sponsors':
            menu_state.push(self.menus['SponsorsMenu'])
        elif text.strip() == 'credentials':
            menu_state.push(self.menus['CredentialMenu'])
        elif text.strip() == 'plugins':
            menu_state.push(self.menus['PluginMenu'])
        elif text.strip() == 'admin':
            menu_state.push(self.menus['AdminMenu'])
        elif cmd_line[0] == 'uselistener' and len(cmd_line) > 1:
            if cmd_line[1] in state.listener_types:
                menu_state.push(self.menus['UseListenerMenu'], selected=cmd_line[1])
            else:
                print(f'No listener {cmd_line[1]}')
        elif cmd_line[0] == 'usestager' and len(cmd_line) > 1:
            if cmd_line[1] in state.stagers:
                menu_state.push(self.menus['UseStagerMenu'], selected=cmd_line[1])
            else:
                print(f'No stager {cmd_line[1]}')
        elif cmd_line[0] == 'interact' and len(cmd_line) > 1:
            if cmd_line[1] in state.agents:
                menu_state.push(self.menus['InteractMenu'], selected=cmd_line[1])
            else:
                print(f'No agent {cmd_line[1]}')
        elif cmd_line[0] == 'useplugin' and len(cmd_line) > 1:
            if cmd_line[1] in state.plugins:
                menu_state.push(self.menus['UsePluginMenu'], selected=cmd_line[1])
            else:
                print(f'No plugin {cmd_line[1]}')
        elif cmd_line[0] == 'usecredential' and len(cmd_line) > 1:
            if cmd_line[1] in state.credentials or cmd_line[1] == 'add':
                menu_state.push(self.menus['UseCredentialMenu'], selected=cmd_line[1])
            else:
                print(f'[!] No credential {cmd_line[1]}')
        elif cmd_line[0] == 'usemodule' and len(cmd_line) > 1:
            if cmd_line[1] in state.modules:
                if menu_state.current_menu_name == 'InteractMenu':
                    menu_state.push(self.menus['UseModuleMenu'], selected=cmd_line[1],
                                    agent=menu_state.current_menu.selected)
                else:
                    menu_state.push(self.menus['UseModuleMenu'], selected=cmd_line[1])
            else:
                print(f'No module {cmd_line[1]}')
        elif cmd_line[0] == 'editlistener' and len(cmd_line) > 1:
            if menu_state.current_menu_name == 'ListenerMenu':
                if cmd_line[1] in state.listeners:
                    menu_state.push(self.menus['EditListenerMenu'], selected=cmd_line[1])
            else:
                print(f'No listener {cmd_line[1]}')
        elif text.strip() == 'shell':
            if menu_state.current_menu_name == 'InteractMenu':
                menu_state.push(self.menus['ShellMenu'], selected=menu_state.current_menu.selected)
            else:
                pass
        elif menu_state.current_menu_name == 'ShellMenu':
            if text == 'exit':
                menu_state.push(self.menus['InteractMenu'], selected=menu_state.current_menu.selected)
            else:
                menu_state.current_menu.shell(menu_state.current_menu.selected, text)
        elif text.strip() == 'proxy':
            if menu_state.current_menu_name == 'InteractMenu':
                if menu_state.current_menu.agent_options['language'] not in ['python', 'ironpython']:
                    print(print_util.color(f'[!] Agent proxies are not available in {menu_state.current_menu.agent_options["language"]} agents'))
                    pass
                elif state.listeners[menu_state.current_menu.agent_options['listener']]['module'] not in ['http', 'http_hop', 'redirector']:
                    print(print_util.color(f"[!] Agent proxies are not available in {state.listeners[menu_state.current_menu.agent_options['listener']]['module']} listeners"))
                else:
                    menu_state.push(self.menus['ProxyMenu'], selected=menu_state.current_menu.selected)
            else:
                pass
        elif text.strip() == 'back':
            menu_state.pop()
        elif text.strip() == 'exit':
            if resource_file:
                raise CliExitException
            choice = input(print_util.color("[>] Exit? [y/N] ", "red"))
            if choice.lower() == "y":
                raise CliExitException
            else:
                pass
        else:
            func = None
            try:
                func = getattr(menu_state.current_menu if hasattr(menu_state.current_menu, cmd_line[0]) else self,
                               cmd_line[0])
            except:
                pass

            if func:
                try:
                    # If the command is set, wrap the value in quotes so docopt
                    # doesn't interpret it as a parameter. Also concatenate all the words
                    # after the 3rd word for easier autofilling with suggested values that have spaces
                    # There may be a better way to do this.
                    if cmd_line[0] == 'set':
                        cmd_line[2] = f'"{" ".join(cmd_line[2:])}"'
                        del cmd_line[3:]
                    args = self.strip(docopt(
                        func.__doc__,
                        argv=cmd_line[1:]
                    ))
                    new_args = {}
                    # todo casting for type hinted values?
                    for key, hint in get_type_hints(func).items():
                        # if args.get(key) is not None:
                        if key != 'return':
                            new_args[key] = args[key]
                    # print(new_args)
                    func(**new_args)
                except Exception as e:
                    print(e)
                    pass
                except SystemExit as e:
                    pass
            elif not func and menu_state.current_menu_name == 'InteractMenu':
                if cmd_line[0] in shortcut_handler.get_names(self.menus['InteractMenu'].agent_language):
                    menu_state.current_menu.execute_shortcut(cmd_line[0], cmd_line[1:])


def start():
    try:
        empire = EmpireCli()
        empire.main()
    finally:
        state.shutdown()
