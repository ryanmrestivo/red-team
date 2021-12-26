import fnmatch
import importlib.util
import os
from typing import Dict

import yaml

info_keys = {
    'Name': 'name',
    'Author': 'authors',
    'Description': 'description',
    'Software': 'software',
    'Techniques': 'techniques',
    'Background': 'background',
    'OutputExtension': 'output_extension',
    'NeedsAdmin': 'needs_admin',
    'OpsecSafe': 'opsec_safe',
    'Language': 'language',
    'MinLanguageVersion': 'min_language_version',
    'Comments': 'comments',
}


def represent_none(self, _):
    return self.represent_scalar('tag:yaml.org,2002:null', '')


def format_info(info: Dict) -> Dict:
    ordered_dict = {}

    for old, new in info_keys.items():
        ordered_dict[new] = info[old]

    return ordered_dict


def format_options(options: Dict) -> Dict:
    option_list = []

    for key, value in options.items():
        option_list.append({
            'name': key,
            'description': value['Description'],
            'required': value['Required'],
            'value': value['Value']  # todo should value really be defaultValue?
        })

    return {'options': option_list}


if __name__ == '__main__':
    yaml.add_representer(type(None), represent_none)
    root_path = f"../../modules/python"
    pattern = '*.py'
    count = 0
    for root, dirs, files in os.walk(root_path):
        for filename in fnmatch.filter(files, pattern):
            file_path = os.path.join(root, filename)
            print(file_path)

            # if 'eventvwr' not in file_path and 'seatbelt' not in file_path and 'logonpasswords' not in file_path \
            #         and 'invoke_assembly' not in file_path.lower() and 'sherlock' not in file_path and 'kerberoast' not in file_path \
            #         and 'watson' not in file_path and 'message.py' not in file_path and 'rick_astley' not in file_path \
            #         and 'portscan' not in file_path and 'say.py' not in file_path and 'prompt' not in file_path and 'screenshot' not in file_path\
            #         and 'clipboard' not in file_path:
            #     continue

            if count > 10:
                break

            if os.path.exists(file_path[:-3] + ".yaml"):
                continue

            # don't load up any of the templates
            if fnmatch.fnmatch(filename, '*template.py'):
                continue

            module_name = file_path.split(root_path)[-1][0:-3]

            with open(file_path, 'r') as stream:
                spec = importlib.util.spec_from_file_location(module_name + ".py", file_path[:-3] + ".py")
                imp_mod = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(imp_mod)
                my_module = imp_mod.Module(None)

                info: Dict = format_info(my_module.info)
                options = format_options(my_module.options)

                info.update(options)

                with open(file_path[:-3] + ".yaml", 'a') as out:
                    yaml.dump(info, out, sort_keys=False)
                    count += 1
