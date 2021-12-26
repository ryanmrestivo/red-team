import hashlib
import os
import random
import string

import bcrypt

from empire.server.common import bypasses
from empire.server.common.config import empire_config
from empire.server.database import models

database_config = empire_config.yaml.get('database', {}).get('defaults', {})


def get_default_hashed_password():
    password = database_config.get('password', 'password123')
    password = bytes(password, 'UTF-8')
    return bcrypt.hashpw(password, bcrypt.gensalt())


def get_default_user():
    return models.User(username=database_config.get('username', 'empireadmin'),
                       password=get_default_hashed_password(),
                       enabled=True,
                       admin=True)


def get_default_config():
    # Calculate the install path. We know the project directory will always be two levels up of the current directory.
    # Any modifications of the folder structure will need to be applied here.
    install_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    return models.Config(staging_key=get_staging_key(),
                         install_path=install_path,
                         ip_whitelist=database_config.get('ip-whitelist', ''),
                         ip_blacklist=database_config.get('ip-blacklist', ''),
                         autorun_command="",
                         autorun_data="",
                         rootuser=True,
                         obfuscate=database_config.get('obfuscate', False),
                         obfuscate_command=database_config.get('obfuscate-command', r'Token\All\1'))


def get_default_functions():
    return [
        models.Function(keyword='Invoke_Empire',
                        replacement=''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(5))),
        models.Function(keyword='Invoke_Mimikatz',
                        replacement=''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(5)))
    ]


def get_default_bypasses():
    return [
        models.Bypass(name="mattifestation", code=bypasses.mattifestation_amsibypass()),
        models.Bypass(name="liberman", code=bypasses.liberman_amsibypass()),
        models.Bypass(name="rastamouse", code=bypasses.rastamouse_amsibypass()),
        models.Bypass(name="scriptblocklog", code=bypasses.scriptBlockLogBypass()),
        models.Bypass(name="etw", code=bypasses.ETWBypass())
    ]


def get_staging_key():
    # Staging Key is set up via environmental variable or config.yaml. By setting RANDOM a randomly selected password
    # will automatically be selected.
    staging_key = os.getenv('STAGING_KEY') or database_config.get('staging-key', 'BLANK')
    punctuation = '!#%&()*+,-./:;<=>?@[]^_{|}~'
    if staging_key == "BLANK":
        choice = input("\n [>] Enter server negotiation password, enter for random generation: ")
        if choice != "" and choice != "RANDOM":
            return hashlib.md5(choice.encode('utf-8')).hexdigest()

    print('\x1b[1;34m[*] Generating random staging key\x1b[0m')
    return ''.join(random.sample(string.ascii_letters + string.digits + punctuation, 32))
