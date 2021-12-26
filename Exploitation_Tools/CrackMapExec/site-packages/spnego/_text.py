# Copyright: (c) 2020, Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type  # noqa (fixes E402 for the imports below)

import sys

PY2 = sys.version_info[0] == 2

if PY2:
    binary_type = str
    text_type = unicode
else:
    binary_type = bytes
    text_type = str


def _obj_str(obj, default):
    # First try to get the str() then repr() before falling back to the default value.
    for func in [str, repr]:
        try:
            obj = func(obj)
        except (UnicodeError, TypeError):
            continue
        else:
            return obj
    else:
        return default


def to_bytes(obj, encoding='utf-8', errors='strict', nonstring='str'):
    if isinstance(obj, binary_type):
        return obj
    elif isinstance(obj, text_type):
        return obj.encode(encoding, errors)

    if nonstring == 'str':
        return to_bytes(_obj_str(obj, b""), encoding=encoding, errors=errors)
    elif nonstring == 'passthru':
        return obj
    elif nonstring == 'empty':
        return b''
    else:
        raise ValueError("Invalid nonstring value '%s', expecting str, passthru, or empty" % nonstring)


def to_text(obj, encoding='utf-8', errors='strict', nonstring='str'):
    if isinstance(obj, text_type):
        return obj
    elif isinstance(obj, binary_type):
        return obj.decode(encoding, errors)

    if nonstring == 'str':
        try:
            obj = obj.__unicode__()
        except (AttributeError, UnicodeError):
            obj = _obj_str(obj, u"")

        return to_text(obj, errors=errors, encoding=encoding)
    elif nonstring == 'passthru':
        return obj
    elif nonstring == 'empty':
        return u''
    else:
        raise ValueError("Invalid nonstring value '%s', expecting repr, passthru, or empty" % nonstring)


if PY2:
    to_native = to_bytes
else:
    to_native = to_text
