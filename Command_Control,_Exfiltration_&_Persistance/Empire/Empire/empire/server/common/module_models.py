from enum import Enum
from typing import Any, List, Optional

from pydantic import BaseModel, validator


class LanguageEnum(str, Enum):
    python = 'python'
    powershell = 'powershell'
    csharp = 'csharp'


class PydanticModuleAdvanced(BaseModel):
    option_format_string: str = "-{{ KEY }} \"{{ VALUE }}\""
    option_format_string_boolean: str = "-{{ KEY }}"
    custom_generate: bool = False
    generate_class: Any = None


class PydanticModuleOption(BaseModel):
    name: str
    name_in_code: Optional[str]
    description: str = ''
    required: bool = False
    value: str = ''
    suggested_values: List[str] = []
    strict: bool = False


class PydanticModule(BaseModel):
    name: str
    authors: List[str] = []
    description: str = ''
    software: str = ''
    techniques: List[str] = []
    background: bool = False
    output_extension: Optional[str] = None
    needs_admin: bool = False
    opsec_safe: bool = False
    language: LanguageEnum
    min_language_version: Optional[str]
    comments: List[str] = []
    options: List[PydanticModuleOption] = []
    script: Optional[str] = None
    script_path: Optional[str] = None
    script_end: str = ' {{ PARAMS }}'
    enabled: bool = True
    advanced: PydanticModuleAdvanced = PydanticModuleAdvanced()
    compiler_yaml: Optional[str]
