import os

from empire.server.common.helpers import is_obfuscated, color, obfuscate
from empire.server.database import models
from empire.server.database.base import Session


def keyword_obfuscation(data):
    functions = Session().query(models.Function).all()

    for function in functions:
        data = data.replace(function.keyword, function.replacement)

    return data


def get_config(fields):
    """
    Helper to pull common database config information outside of the
    normal menu execution.

    Fields should be comma separated.
        i.e. 'version,install_path'
    """
    results = []
    config = Session().query(models.Config).first()

    for field in fields.split(','):
        results.append(config[field.strip()])

    return results


def get_listener_options(listener_name):
    """
    Returns the options for a specified listenername from the database outside
    of the normal menu execution.
    """
    try:
        listener_options = Session().query(models.Listener.options).filter(models.Listener.name == listener_name).first()
        return listener_options

    except Exception:
        return None


def obfuscate_module(moduleSource, obfuscationCommand="", forceReobfuscation=False):
    if is_obfuscated(moduleSource) and not forceReobfuscation:
        return

    try:
        f = open(moduleSource, 'r')
    except:
        print(color("[!] Could not read module source path at: " + moduleSource))
        return ""

    moduleCode = f.read()
    f.close()

    # Get the random function name generated at install and patch the stager with the proper function name

    moduleCode = keyword_obfuscation(moduleCode)


    # obfuscate and write to obfuscated source path
    path = os.path.abspath('server.py').split('server.py')[0] + "/"
    obfuscatedCode = obfuscate(path, moduleCode, obfuscationCommand)
    obfuscatedSource = moduleSource.replace("module_source", "obfuscated_module_source")
    try:
        f = open(obfuscatedSource, 'w')
    except:
        print(color("[!] Could not read obfuscated module source path at: " + obfuscatedSource))
        return ""
    f.write(obfuscatedCode)
    f.close()