import json
from typing import List, Dict

from empire.client.src.EmpireCliConfig import empire_config
from empire.client.src.Shortcut import Shortcut
from empire.client.src.utils import print_util


class ShortcutHandler:
    """
    Handler class to get shortcuts.
    """

    def __init__(self):
        shortcuts_raw = empire_config.yaml.get('shortcuts', {})
        python: Dict[str, Shortcut] = {}
        ironpython: Dict[str, Shortcut] = {}
        powershell: Dict[str, Shortcut] = {}
        csharp: Dict[str, Shortcut] = {}
        for key, value in shortcuts_raw['python'].items():
            try:
                value['name'] = key
                python[key] = Shortcut.from_json(json.loads(json.dumps(value)))
            except TypeError as e:
                print(print_util.color(f'Could not parse shortcut: {key}', color_name='red'))
        for key, value in shortcuts_raw['ironpython'].items():
            try:
                value['name'] = key
                ironpython[key] = Shortcut.from_json(json.loads(json.dumps(value)))
            except TypeError as e:
                print(print_util.color(f'Could not parse shortcut: {key}', color_name='red'))
        for key, value in shortcuts_raw['powershell'].items():
            try:
                value['name'] = key
                powershell[key] = Shortcut.from_json(json.loads(json.dumps(value)))
            except TypeError as e:
                print(print_util.color(f'Could not parse shortcut: {key}', color_name='red'))
        for key, value in shortcuts_raw['csharp'].items():
            try:
                value['name'] = key
                csharp[key] = Shortcut.from_json(json.loads(json.dumps(value)))
            except TypeError as e:
                print(print_util.color(f'Could not parse shortcut: {key}', color_name='red'))
        self.shortcuts: Dict[str, Dict[str, Shortcut]] = {'python': python, 'powershell': powershell,
                                                          'ironpython': ironpython, 'csharp': csharp}

    def get(self, language: str, name: str) -> Shortcut:
        return self.shortcuts.get(language, {}).get(name)

    def get_names(self, language: str) -> List[str]:
        return list(self.shortcuts.get(language, {}).keys())


shortcut_handler = ShortcutHandler()
