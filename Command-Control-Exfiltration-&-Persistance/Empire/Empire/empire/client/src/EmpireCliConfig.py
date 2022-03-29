import sys
from typing import Dict
from empire.client.src.utils import print_util

import yaml


class EmpireCliConfig(object):
    def __init__(self):
        self.yaml: Dict = {}
        if '--config' in sys.argv:
            location = sys.argv[sys.argv.index('--config') + 1]
            print(f'Loading config from {location}')
            self.set_yaml(location)
        if len(self.yaml.items()) == 0:
            print(print_util.color('[*] Loading default config'))
            self.set_yaml("./empire/client/config.yaml")

    def set_yaml(self, location: str):
        try:
            with open(location, 'r') as stream:
                self.yaml = yaml.safe_load(stream)
        except yaml.YAMLError as exc:
            print(exc)
        except FileNotFoundError as exc:
            print(exc)


empire_config = EmpireCliConfig()
