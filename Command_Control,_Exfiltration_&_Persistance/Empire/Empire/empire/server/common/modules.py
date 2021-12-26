"""
Module handling functionality for Empire.
"""
from __future__ import absolute_import
from __future__ import print_function

import fnmatch
import importlib.util
import os
from builtins import object
from os import path
from typing import Dict, Optional, Tuple

import base64
import yaml
from sqlalchemy import and_

from empire.server.common.hooks import hooks
from empire.server.utils import data_util
from empire.server.common.config import empire_config
from empire.server.common.converter.load_covenant import _convert_covenant_to_empire
from empire.server.common.module_models import PydanticModule, LanguageEnum
from empire.server.database import models
from empire.server.database.base import Session
from . import helpers


class Modules(object):

    def __init__(self, main_menu, args):

        self.main_menu = main_menu
        self.args = args

        self.modules: Dict[str, PydanticModule] = {}

        self._load_modules()

    def get_module(self, module_name: str) -> Optional[PydanticModule]:
        """
        Get a loaded module from in memory
        :param module_name: name
        :return: Optional[PydanticModule]
        """
        return self.modules.get(module_name)

    def execute_module(self, module: PydanticModule, params: Dict, user_id: int) \
            -> Tuple[Optional[Dict], Optional[str]]:
        """
        Execute the module.
        :param module: PydanticModule
        :param params: the execution parameters
        :param user_id: the user executing the module
        :return: tuple with the response and an error message (if applicable)
        """
        if not module.enabled:
            return None, 'Cannot execute disabled module'

        cleaned_options, err = self._validate_module_params(module, params)

        if err:
            return None, err

        module_data = self._generate_script(module, cleaned_options, self.main_menu.obfuscate, self.main_menu.obfuscateCommand)
        if isinstance(module_data, tuple):
            (module_data, err) = module_data
        else:
            # Not all modules return a tuple. If they just return a single value,
            # we don't want to throw an unpacking error.
            err = None
        if not module_data or module_data == "":
            return None, err or 'module produced an empty script'
        if not module_data.isascii():
            return None, 'module source contains non-ascii characters'

        if module.language == LanguageEnum.powershell:
            module_data = helpers.strip_powershell_comments(module_data)

        # check if module is external
        if 'Agent' not in params.keys():
            msg = f"tasked external module: {module.name}"
            # return success but no task_id for external modules
            return {'success': True, 'taskID': None, 'msg': msg}, None

        session_id = params['Agent']
        task_command = ""
        if module.language == LanguageEnum.csharp:
            task_command = "TASK_CSHARP"
        # build the appropriate task command and module data blob
        elif module.background:
            # if this module should be run in the background
            extension = module.output_extension
            if extension and extension != "":
                # if this module needs to save its file output to the server
                #   format- [15 chars of prefix][5 chars extension][data]
                save_file_prefix = module.name.split("/")[-1]
                module_data = save_file_prefix.rjust(15) + extension.rjust(5) + module_data
                task_command = "TASK_CMD_JOB_SAVE"
            else:
                task_command = "TASK_CMD_JOB"

        else:
            # if this module is run in the foreground
            extension = module.output_extension
            if module.output_extension and module.output_extension != "":
                # if this module needs to save its file output to the server
                #   format- [15 chars of prefix][5 chars extension][data]
                save_file_prefix = module.name.split("/")[-1][:15]
                module_data = save_file_prefix.rjust(15) + extension.rjust(5) + module_data
                task_command = "TASK_CMD_WAIT_SAVE"
            else:
                task_command = "TASK_CMD_WAIT"

        # set the agent's tasking in the cache
        task_id = self.main_menu.agents.add_agent_task_db(session_id, task_command, module_data,
                                                          module_name=module.name,
                                                          uid=user_id)

        task = Session().query(models.Tasking).filter(and_(models.Tasking.id == task_id,
                                                           models.Tasking.agent_id == session_id)).first()
        hooks.run_hooks(hooks.AFTER_TASKING_HOOK, task)

        # update the agent log
        msg = f"tasked agent {session_id} to run module {module.name}"
        self.main_menu.agents.save_agent_log(session_id, msg)

        if empire_config.yaml.get('modules',{}).get('retain-last-value', True):
            self._set_default_values(module, cleaned_options)

        return {'success': True, 'taskID': task_id, 'msg': msg}, None

    @staticmethod
    def change_module_state(main, module_list: list, module_state: bool):
        for module_name in module_list:
            try:
                module = Session().query(models.Module).filter(models.Module.name == module_name).first()
                module.enabled = module_state
                main.modules.modules[module_name].enabled = module_state
            except:
                # skip if module name is not found
                pass
        Session().commit()

    def _validate_module_params(self, module: PydanticModule, params: Dict[str, str]) -> Tuple[Optional[Dict[str, str]], Optional[str]]:
        """
        Given a module and execution params, validate the input and return back a clean Dict for execution.
        :param module: PydanticModule
        :param params: the execution parameters
        :return: tuple with options and the error message (if applicable)
        """
        options = {}

        for option in module.options:
            if option.name in params:
                if option.strict and params[option.name] not in option.suggested_values:
                    return None, f'{option.name} must be set to one of the suggested values.'
                if option.name_in_code:
                    options[option.name_in_code] = params[option.name]
                else:
                    options[option.name] = params[option.name]
            elif option.required:
                return None, f'required module option missing: {option.name}'

        if module.name == 'generate_agent':
            return options, None

        session_id = params['Agent']
        agent = self.main_menu.agents.get_agent_db(session_id)

        if not self.main_menu.agents.is_agent_present(session_id):
            return None, 'invalid agent name'

        if not agent:
            return None, 'invalid agent name'

        module_version = float(module.min_language_version or 0)
        agent_version = float(agent.language_version or 0)
        # check if the agent/module PowerShell versions are compatible
        if module_version > agent_version:
            return None, f"module requires PS version {module_version} but agent running PS version {agent_version}"

        if module.needs_admin:
            # if we're running this module for all agents, skip this validation
            if not agent.high_integrity:
                return None, 'module needs to run in an elevated context'

        return options, None

    @staticmethod
    def _set_default_values(module: PydanticModule, params: Dict):
        """
        Change the default values for the module loaded into memory.
        This is to retain the old empire behavior (and the behavior of stagers and listeners).
        :param module:
        :param params: cleaned param dictionary
        :return:
        """
        for option in module.options:
            if params.get(option.name):
                option.value = params[option.name]

    def _generate_script(self, module: PydanticModule, params: Dict, obfuscate=False, obfuscate_command='') -> \
            Tuple[Optional[str], Optional[str]]:
        """
        Generate the script to execute
        :param module: the execution parameters (already validated)
        :param params: the execution parameters
        :param obfuscate:
        :param obfuscate_command:
        :return: tuple containing the generated script and an error if it exists
        """
        if module.advanced.custom_generate:
            return module.advanced.generate_class.generate(self.main_menu, module, params, obfuscate, obfuscate_command)
        elif module.language == LanguageEnum.powershell:
            return self._generate_script_powershell(module, params, obfuscate, obfuscate_command)
        elif module.language == LanguageEnum.python:
            return self._generate_script_python(module, params)
        elif module.language == LanguageEnum.csharp:
            return self._generate_script_csharp(module, params)

    @staticmethod
    def _generate_script_python(module: PydanticModule, params: Dict) -> Tuple[Optional[str], Optional[str]]:
        if module.script_path:
            with open(module.script_path, 'r') as stream:
                script = stream.read()
        else:
            script = module.script


        for key, value in params.items():
            if key.lower() != "agent" and key.lower() != "computername":
                script = script.replace('{{ ' + key + ' }}', value).replace('{{' + key + '}}', value)

        return script, None

    def _generate_script_powershell(self, module: PydanticModule, params: Dict, obfuscate=False, obfuscate_command='') \
            -> Tuple[Optional[str], Optional[str]]:
        if module.script_path:
            # Get preobfuscated module code
            if obfuscate:
                data_util.obfuscate_module(moduleSource=module.script_path, obfuscationCommand=obfuscate_command)
                module_source = module.script_path.replace("module_source", "obfuscated_module_source")
                with open(module_source, 'r') as stream:
                    script = stream.read()
            else:
                with open(module.script_path, 'r') as stream:
                    script = stream.read()
        else:
            script = module.script

        script_end = f" {module.script_end} "
        option_strings = []
        # This is where the code goes for all the modules that do not have a custom generate function.
        for key, value in params.items():
            if key.lower() not in ["agent", "computername", "outputfunction"]:
                if value and value != '':
                    if value.lower() == "true":
                        # if we're just adding a switch
                        # wannabe mustache templating.
                        # If we want to get more advanced, we can import a library for it.
                        this_option = module.advanced.option_format_string_boolean \
                            .replace('{{ KEY }}', str(key)) \
                            .replace('{{KEY}}', str(key))
                        option_strings.append(f'{this_option}')
                    else:
                        this_option = module.advanced.option_format_string \
                            .replace('{{ KEY }}', str(key)) \
                            .replace('{{KEY}}', str(key)) \
                            .replace('{{ VALUE }}', str(value)) \
                            .replace('{{VALUE}}', str(value))
                        option_strings.append(f'{this_option}')

        script_end = script_end \
            .replace('{{ PARAMS }}', ' '.join(option_strings)) \
            .replace('{{PARAMS}}', ' '.join(option_strings)) \
            .replace('{{ OUTPUT_FUNCTION }}', params.get('OutputFunction', 'Out-String')) \
            .replace('{{OUTPUT_FUNCTION}}', params.get('OutputFunction', 'Out-String'))

        script += script_end

        if obfuscate:
            script = helpers.obfuscate(self.main_menu.installPath, psScript=script, obfuscationCommand=obfuscate_command)
        script = data_util.keyword_obfuscation(script)

        return script, None

    def _generate_script_csharp(self, module: PydanticModule, params: Dict) -> Tuple[Optional[str], Optional[str]]:
        try:
            compiler = self.main_menu.loadedPlugins.get("csharpserver")
            if not compiler.status == 'ON':
                return None, 'csharpserver plugin not running'
            file_name = compiler.do_send_message(module.compiler_yaml, module.name)
            if file_name == "failed":
                return None, 'module compile failed'

            script_file = self.main_menu.installPath + "/csharp/Covenant/Data/Tasks/CSharp/Compiled/" +\
                (params["DotNetVersion"]).lower() + "/" + file_name + ".compiled"
            param_string = ''
            for key, value in params.items():
                if key.lower() not in ['agent', 'computername', 'dotnetversion']:
                    if value and value != '':
                        param_string += "," + value

            return f"{script_file}|{param_string}", None

        except Exception as e:
            print(e)
            msg = f"[!] Compile Error"
            print(helpers.color(msg))
            return None, msg

    def _load_modules(self, root_path=''):
        """
        Load Empire modules from a specified path, default to
        installPath + "/modules/*"
        """
        if root_path == '':
            root_path = f"{self.main_menu.installPath}/modules/"

        print(helpers.color(f"[*] Loading modules from: {root_path}"))
         
        for root, dirs, files in os.walk(root_path):
            for filename in files:
                if not filename.lower().endswith('.yaml') and not filename.lower().endswith('.yml'):
                    continue

                file_path = os.path.join(root, filename)

                # don't load up any of the templates
                if fnmatch.fnmatch(filename, '*template.yaml'):
                    continue

                # instantiate the module and save it to the internal cache
                try:
                    with open(file_path, 'r') as stream:
                        if file_path.lower().endswith('.covenant.yaml'):
                            yaml2 = yaml.safe_load(stream)
                            for covenant_module in yaml2:
                                # remove None values so pydantic can apply defaults
                                yaml_module = {k: v for k, v in covenant_module.items() if v is not None}
                                self._load_module(yaml_module, root_path, file_path)
                        else:
                            yaml2 = yaml.safe_load(stream)
                            yaml_module = {k: v for k, v in yaml2.items() if v is not None}
                            self._load_module(yaml_module, root_path, file_path)
                except Exception as e:
                    print(e)

        Session().commit()

    def _load_module(self, yaml_module, root_path, file_path: str):
        # extract just the module name from the full path
        module_name = file_path.split(root_path)[-1][0:-5]

        #if root_path != f"{self.main_menu.installPath}/modules/":
        #    module_name = f"external/{module_name}"

        if file_path.lower().endswith('.covenant.yaml'):
            my_model = PydanticModule(**_convert_covenant_to_empire(yaml_module, file_path))
            module_name = f"{module_name[:-9]}/{my_model.name}"
        else:
            my_model = PydanticModule(**yaml_module)

        if my_model.advanced.custom_generate:
            if not path.exists(file_path[:-4] + "py"):
                raise Exception("No File to use for custom generate.")
            spec = importlib.util.spec_from_file_location(module_name + ".py", file_path[:-5] + ".py")
            imp_mod = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(imp_mod)
            my_model.advanced.generate_class = imp_mod.Module()
        elif my_model.script_path:
            if not path.exists(my_model.script_path):
                raise Exception("File provided in script_path does not exist.")
        elif my_model.script:
            pass
        else:
            raise Exception("Must provide a valid script, script_path, or custom generate function")

        mod = Session().query(models.Module).filter(models.Module.name == module_name).first()

        if not mod:
            mod = models.Module(name=module_name, enabled=True)
            Session().add(mod)

        self.modules[module_name] = my_model
        self.modules[module_name].enabled = mod.enabled
