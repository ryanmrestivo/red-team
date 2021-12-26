#!/usr/bin/env python3

# original version written by Tim-Christian Mundt (2011):
# https://sourceforge.net/p/pylnk/code/HEAD/tree/trunk/pylnk.py

# converted to python3 by strayge:
# https://github.com/strayge/pylnk

import os
import re
import sys
import time
from datetime import datetime
from io import BytesIO, IOBase
from pprint import pformat
from struct import pack, unpack
from typing import Optional, Union, Tuple, Dict

DEFAULT_CHARSET = 'cp1251'

# ---- constants

_SIGNATURE = b'L\x00\x00\x00'
_GUID = b'\x01\x14\x02\x00\x00\x00\x00\x00\xc0\x00\x00\x00\x00\x00\x00F'
_LINK_INFO_HEADER_DEFAULT = 0x1C
_LINK_INFO_HEADER_OPTIONAL = 0x24

_LINK_FLAGS = (
    'HasLinkTargetIDList',
    'HasLinkInfo',
    'HasName',
    'HasRelativePath',
    'HasWorkingDir',
    'HasArguments',
    'HasIconLocation',
    'IsUnicode',
    'ForceNoLinkInfo',
    # new
    'HasExpString',
    'RunInSeparateProcess',
    'Unused1',
    'HasDarwinID',
    'RunAsUser',
    'HasExpIcon',
    'NoPidlAlias',
    'Unused2',
    'RunWithShimLayer',
    'ForceNoLinkTrack',
    'EnableTargetMetadata',
    'DisableLinkPathTracking',
    'DisableKnownFolderTracking',
    'DisableKnownFolderAlias',
    'AllowLinkToLink',
    'UnaliasOnSave',
    'PreferEnvironmentPath',
    'KeepLocalIDListForUNCTarget',
)

_FILE_ATTRIBUTES_FLAGS = (
    'read_only', 'hidden', 'system_file', 'reserved1',
    'directory', 'archive', 'reserved2', 'normal',
    'temporary', 'sparse_file', 'reparse_point',
    'compressed', 'offline', 'not_content_indexed',
    'encrypted',
)

_MODIFIER_KEYS = ('SHIFT', 'CONTROL', 'ALT')

WINDOW_NORMAL = "Normal"
WINDOW_MAXIMIZED = "Maximized"
WINDOW_MINIMIZED = "Minimized"
_SHOW_COMMANDS = {1: WINDOW_NORMAL, 3: WINDOW_MAXIMIZED, 7: WINDOW_MINIMIZED}
_SHOW_COMMAND_IDS = dict((v, k) for k, v in _SHOW_COMMANDS.items())

DRIVE_UNKNOWN = "Unknown"
DRIVE_NO_ROOT_DIR = "No root directory"
DRIVE_REMOVABLE = "Removable"
DRIVE_FIXED = "Fixed (Hard disk)"
DRIVE_REMOTE = "Remote (Network drive)"
DRIVE_CDROM = "CD-ROM"
DRIVE_RAMDISK = "Ram disk"
_DRIVE_TYPES = {0: DRIVE_UNKNOWN,
                1: DRIVE_NO_ROOT_DIR,
                2: DRIVE_REMOVABLE,
                3: DRIVE_FIXED,
                4: DRIVE_REMOTE,
                5: DRIVE_CDROM,
                6: DRIVE_RAMDISK}
_DRIVE_TYPE_IDS = dict((v, k) for k, v in _DRIVE_TYPES.items())

_KEYS = {
    0x30: '0', 0x31: '1', 0x32: '2', 0x33: '3', 0x34: '4', 0x35: '5', 0x36: '6',
    0x37: '7', 0x38: '8', 0x39: '9', 0x41: 'A', 0x42: 'B', 0x43: 'C', 0x44: 'D',
    0x45: 'E', 0x46: 'F', 0x47: 'G', 0x48: 'H', 0x49: 'I', 0x4A: 'J', 0x4B: 'K',
    0x4C: 'L', 0x4D: 'M', 0x4E: 'N', 0x4F: 'O', 0x50: 'P', 0x51: 'Q', 0x52: 'R',
    0x53: 'S', 0x54: 'T', 0x55: 'U', 0x56: 'V', 0x57: 'W', 0x58: 'X', 0x59: 'Y',
    0x5A: 'Z', 0x70: 'F1', 0x71: 'F2', 0x72: 'F3', 0x73: 'F4', 0x74: 'F5',
    0x75: 'F6', 0x76: 'F7', 0x77: 'F8', 0x78: 'F9', 0x79: 'F10', 0x7A: 'F11',
    0x7B: 'F12', 0x7C: 'F13', 0x7D: 'F14', 0x7E: 'F15', 0x7F: 'F16', 0x80: 'F17',
    0x81: 'F18', 0x82: 'F19', 0x83: 'F20', 0x84: 'F21', 0x85: 'F22', 0x86: 'F23',
    0x87: 'F24', 0x90: 'NUM LOCK', 0x91: 'SCROLL LOCK'
}
_KEY_CODES = dict((v, k) for k, v in _KEYS.items())

ROOT_MY_COMPUTER = 'MY_COMPUTER'
ROOT_MY_DOCUMENTS = 'MY_DOCUMENTS'
ROOT_NETWORK_SHARE = 'NETWORK_SHARE'
ROOT_NETWORK_SERVER = 'NETWORK_SERVER'
ROOT_NETWORK_PLACES = 'NETWORK_PLACES'
ROOT_NETWORK_DOMAIN = 'NETWORK_DOMAIN'
ROOT_INTERNET = 'INTERNET'
RECYCLE_BIN = 'RECYCLE_BIN'
ROOT_CONTROL_PANEL = 'CONTROL_PANEL'
ROOT_USER = 'USERPROFILE'
ROOT_UWP_APPS = 'APPS'

_ROOT_LOCATIONS = {
    '{20D04FE0-3AEA-1069-A2D8-08002B30309D}': ROOT_MY_COMPUTER,
    '{450D8FBA-AD25-11D0-98A8-0800361B1103}': ROOT_MY_DOCUMENTS,
    '{54a754c0-4bf1-11d1-83ee-00a0c90dc849}': ROOT_NETWORK_SHARE,
    '{c0542a90-4bf0-11d1-83ee-00a0c90dc849}': ROOT_NETWORK_SERVER,
    '{208D2C60-3AEA-1069-A2D7-08002B30309D}': ROOT_NETWORK_PLACES,
    '{46e06680-4bf0-11d1-83ee-00a0c90dc849}': ROOT_NETWORK_DOMAIN,
    '{871C5380-42A0-1069-A2EA-08002B30309D}': ROOT_INTERNET,
    '{645FF040-5081-101B-9F08-00AA002F954E}': RECYCLE_BIN,
    '{21EC2020-3AEA-1069-A2DD-08002B30309D}': ROOT_CONTROL_PANEL,
    '{59031A47-3F72-44A7-89C5-5595FE6B30EE}': ROOT_USER,
    '{4234D49B-0245-4DF3-B780-3893943456E1}': ROOT_UWP_APPS,
}
_ROOT_LOCATION_GUIDS = dict((v, k) for k, v in _ROOT_LOCATIONS.items())

TYPE_FOLDER = 'FOLDER'
TYPE_FILE = 'FILE'
_ENTRY_TYPES = {
    0x31: 'FOLDER',
    0x32: 'FILE',
    0x35: 'FOLDER (UNICODE)',
    0x36: 'FILE (UNICODE)',
    # founded in doc, not tested
    0x1f: 'ROOT_FOLDER',
    0x61: 'URI',
    0x71: 'CONTROL_PANEL',
}
_ENTRY_TYPE_IDS = dict((v, k) for k, v in _ENTRY_TYPES.items())

_DRIVE_PATTERN = re.compile(r'(\w)[:/\\]*$')

# ---- read and write binary data


def read_byte(buf):
    return unpack('<B', buf.read(1))[0]


def read_short(buf):
    return unpack('<H', buf.read(2))[0]


def read_int(buf):
    return unpack('<I', buf.read(4))[0]


def read_double(buf):
    return unpack('<Q', buf.read(8))[0]


def read_cunicode(buf):
    s = b""
    b = buf.read(2)
    while b != b'\x00\x00':
        s += b
        b = buf.read(2)
    return s.decode('utf-16-le')


def read_cstring(buf, padding=False):
    s = b""
    b = buf.read(1)
    while b != b'\x00':
        s += b
        b = buf.read(1)
    if padding and not len(s) % 2:
        buf.read(1)  # make length + terminator even
    # TODO: encoding is not clear, unicode-escape has been necessary sometimes
    return s.decode(DEFAULT_CHARSET)


def read_sized_string(buf, string=True):
    size = read_short(buf)
    if string:
        return buf.read(size*2).decode('utf-16-le')
    else:
        return buf.read(size)


def get_bits(value, start, count, length=16):
    mask = 0
    for i in range(count):
        mask = mask | 1 << i
    shift = length - start - count
    return value >> shift & mask


def read_dos_datetime(buf):
    date = read_short(buf)
    time = read_short(buf)
    year = get_bits(date, 0, 7) + 1980
    month = get_bits(date, 7, 4)
    day = get_bits(date, 11, 5)
    hour = get_bits(time, 0, 5)
    minute = get_bits(time, 5, 6)
    second = get_bits(time, 11, 5)
    # fix zeroes
    month = max(month, 1)
    day = max(day, 1)
    return datetime(year, month, day, hour, minute, second)


def write_byte(val, buf):
    buf.write(pack('<B', val))


def write_short(val, buf):
    buf.write(pack('<H', val))


def write_int(val, buf):
    buf.write(pack('<I', val))


def write_double(val, buf):
    buf.write(pack('<Q', val))


def write_cstring(val, buf, padding=False):
    # val = val.encode('unicode-escape').replace('\\\\', '\\')
    val = val.encode(DEFAULT_CHARSET)
    buf.write(val + b'\x00')
    if padding and not len(val) % 2:
        buf.write(b'\x00')


def write_cunicode(val, buf):
    uni = val.encode('utf-16-le')
    buf.write(uni + b'\x00\x00')


def write_sized_string(val, buf, string=True):
    size = len(val)
    write_short(size, buf)
    if string:
        buf.write(val.encode('utf-16-le'))
    else:
        buf.write(val.encode())


def put_bits(bits, target, start, count, length=16):
    return target | bits << (length - start - count)


def write_dos_datetime(val, buf):
    date = time = 0
    date = put_bits(val.year-1980, date, 0, 7)
    date = put_bits(val.month, date, 7, 4)
    date = put_bits(val.day, date, 11, 5)
    time = put_bits(val.hour, time, 0, 5)
    time = put_bits(val.minute, time, 5, 6)
    time = put_bits(val.second, time, 11, 5)
    write_short(date, buf)
    write_short(time, buf)


# ---- helpers

def convert_time_to_unix(windows_time):
    # Windows time is specified as the number of 0.1 nanoseconds since January 1, 1601.
    # UNIX time is specified as the number of seconds since January 1, 1970.
    # There are 134774 days (or 11644473600 seconds) between these dates.
    unix_time = windows_time / 10000000.0 - 11644473600
    try:
        return datetime.fromtimestamp(unix_time)
    except OSError:
        return datetime.now()


def convert_time_to_windows(unix_time):
    if isinstance(unix_time, datetime):
        unix_time = time.mktime(unix_time.timetuple())
    return int((unix_time + 11644473600) * 10000000)


class FormatException(Exception):
    pass


class MissingInformationException(Exception):
    pass


class InvalidKeyException(Exception):
    pass


def guid_from_bytes(bytes):
    if len(bytes) != 16:
        raise FormatException("This is no valid _GUID: %s" % bytes)
    ordered = [
        bytes[3], bytes[2], bytes[1], bytes[0],
        bytes[5], bytes[4], bytes[7], bytes[6],
        bytes[8], bytes[9], bytes[10], bytes[11],
        bytes[12], bytes[13], bytes[14], bytes[15]
    ]
    return "{%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X}" % tuple([x for x in ordered])


def bytes_from_guid(guid):
    nums = [
        guid[1:3], guid[3:5], guid[5:7], guid[7:9],
        guid[10:12], guid[12:14], guid[15:17], guid[17:19],
        guid[20:22], guid[22:24], guid[25:27], guid[27:29],
        guid[29:31], guid[31:33], guid[33:35], guid[35:37]
    ]
    ordered_nums = [
        nums[3], nums[2], nums[1], nums[0],
        nums[5], nums[4], nums[7], nums[6],
        nums[8], nums[9], nums[10], nums[11],
        nums[12], nums[13], nums[14], nums[15],
    ]
    return bytes([int(x, 16) for x in ordered_nums])


def assert_lnk_signature(f):
    f.seek(0)
    sig = f.read(4)
    guid = f.read(16)
    if sig != _SIGNATURE:
        raise FormatException("This is not a .lnk file.")
    if guid != _GUID:
        raise FormatException("Cannot read this kind of .lnk file.")


def is_lnk(f):
    if hasattr(f, 'name'):
        if f.name.split(os.path.extsep)[-1] == "lnk":
            assert_lnk_signature(f)
            return True
        else:
            return False
    else:
        try:
            assert_lnk_signature(f)
            return True
        except FormatException:
            return False


def path_levels(p):
    dirname, base = os.path.split(p)
    if base != '':
        for level in path_levels(dirname):
            yield level
    yield p


def is_drive(data):
    if type(data) not in (str, str):
        return False
    p = re.compile("[a-zA-Z]:\\\\?$")
    return p.match(data) is not None


# ---- data structures

class Flags(object):
    
    def __init__(self, flag_names: Tuple[str, ...], flags_bytes=0):
        self._flag_names = flag_names
        self._flags: Dict[str, bool] = dict([(name, False) for name in flag_names])
        self.set_flags(flags_bytes)
    
    def set_flags(self, flags_bytes):
        for pos, flag_name in enumerate(self._flag_names):
            self._flags[flag_name] = bool(flags_bytes >> pos & 0x1)

    @property
    def bytes(self):
        bytes = 0
        for pos in range(len(self._flag_names)):
            bytes = (self._flags[self._flag_names[pos]] and 1 or 0) << pos | bytes
        return bytes
    
    def __getitem__(self, key):
        if key in self._flags:
            return object.__getattribute__(self, '_flags')[key]
        return object.__getattribute__(self, key)
    
    def __setitem__(self, key, value):
        if key not in self._flags:
            raise KeyError("The key '%s' is not defined for those flags." % key)
        self._flags[key] = value
    
    def __getattr__(self, key):
        if key in self._flags:
            return object.__getattribute__(self, '_flags')[key]
        return object.__getattribute__(self, key)
    
    def __setattr__(self, key, value):
        if '_flags' not in self.__dict__:
            object.__setattr__(self, key, value)
        elif key in self.__dict__:
            object.__setattr__(self, key, value)
        else:
            self.__setitem__(key, value)

    def __str__(self):
        return pformat(self._flags, indent=2)


class ModifierKeys(Flags):
    
    def __init__(self, flags_bytes=0):
        Flags.__init__(self, _MODIFIER_KEYS, flags_bytes)
    
    def __str__(self):
        s = ""
        s += self.CONTROL and "CONTROL+" or ""
        s += self.SHIFT and "SHIFT+" or ""
        s += self.ALT and "ALT+" or ""
        return s


# _ROOT_INDEX = {
#     0x00: 'INTERNET_EXPLORER1',
#     0x42: 'LIBRARIES',
#     0x44: 'USERS',
#     0x48: 'MY_DOCUMENTS',
#     0x50: 'MY_COMPUTER',
#     0x58: 'MY_NETWORK_PLACES',
#     0x60: 'RECYCLE_BIN',
#     0x68: 'INTERNET_EXPLORER2',
#     0x70: 'UNKNOWN',
#     0x80: 'MY_GAMES',
# }


class RootEntry(object):
    
    def __init__(self, root):
        if root is not None:
            # create from text representation
            if root in list(_ROOT_LOCATION_GUIDS.keys()):
                self.root = root
                self.guid = _ROOT_LOCATION_GUIDS[root]
                return

            # from binary
            root_type = root[0]
            index = root[1]
            guid_bytes = root[2:18]
            self.guid = guid_from_bytes(guid_bytes)
            self.root = _ROOT_LOCATIONS.get(self.guid, f"UNKNOWN {self.guid}")
            # if self.root == "UNKNOWN":
            #     self.root = _ROOT_INDEX.get(index, "UNKNOWN")

    @property
    def bytes(self):
        guid = self.guid[1:-1].replace('-', '')
        chars = [bytes([int(x, 16)]) for x in [guid[i:i+2] for i in range(0, 32, 2)]]
        return (
            b'\x1F\x50'
            + chars[3] + chars[2] + chars[1] + chars[0]
            + chars[5] + chars[4] + chars[7] + chars[6]
            + b''.join(chars[8:])
        )

    def __str__(self):
        return "<RootEntry: %s>" % self.root


class DriveEntry(object):
    
    def __init__(self, drive: str):
        if len(drive) == 23:
            # binary data from parsed lnk
            self.drive = drive[1:3]
        else:
            # text representation
            m = _DRIVE_PATTERN.match(drive.strip())
            if m:
                self.drive = m.groups()[0].upper() + ':'
                self.drive = self.drive.encode()
            else:
                raise FormatException("This is not a valid drive: " + str(drive))

    @property
    def bytes(self):
        drive = self.drive
        padded_str = drive + b'\\' + b'\x00' * 19
        return b'\x2F' + padded_str
        # drive = self.drive
        # if isinstance(drive, str):
        #     drive = drive.encode()
        # return b'/' + drive + b'\\' + b'\x00' * 19

    def __str__(self):
        return "<DriveEntry: %s>" % self.drive


class PathSegmentEntry(object):
    
    def __init__(self, bytes=None):
        self.type = None
        self.file_size = None
        self.modified = None
        self.short_name = None
        self.created = None
        self.accessed = None
        self.full_name = None
        if bytes is None:
            return

        buf = BytesIO(bytes)
        self.type = _ENTRY_TYPES.get(read_short(buf), 'UNKNOWN')
        short_name_is_unicode = self.type.endswith('(UNICODE)')
        self.file_size = read_int(buf)
        self.modified = read_dos_datetime(buf)
        unknown = read_short(buf)  # FileAttributesL
        if short_name_is_unicode:
            self.short_name = read_cunicode(buf)
        else:
            self.short_name = read_cstring(buf, padding=True)
        extra_size = read_short(buf)
        extra_version = read_short(buf)
        extra_signature = read_int(buf)
        if extra_signature == 0xBEEF0004:
            # indicator_1 = read_short(buf)  # see below
            # only_83 = read_short(buf) < 0x03
            # unknown = read_short(buf)  # 0x04
            # self.is_unicode = read_short(buf) == 0xBeef
            self.created = read_dos_datetime(buf)  # 4 bytes
            self.accessed = read_dos_datetime(buf)  # 4 bytes
            offset_unicode = read_short(buf)   # offset from start of extra_size
            # only_83_2 = offset_unicode >= indicator_1 or offset_unicode < 0x14
            if extra_version >= 7:
                offset_ansi = read_short(buf)
                file_reference = read_double(buf)
                unknown2 = read_double(buf)
            long_string_size = 0
            if extra_version >= 3:
                long_string_size = read_short(buf)
            if extra_version >= 9:
                unknown4 = read_int(buf)
            if extra_version >= 8:
                unknown5 = read_int(buf)
            if extra_version >= 3:
                self.full_name = read_cunicode(buf)
                if long_string_size > 0:
                    if extra_version >= 7:
                        self.localized_name = read_cunicode(buf)
                    else:
                        self.localized_name = read_cstring(buf)
                version_offset = read_short(buf)

    @classmethod
    def create_for_path(cls, path):
        entry = cls()
        entry.type = os.path.isdir(path) and TYPE_FOLDER or TYPE_FILE
        st = os.stat(path)
        entry.file_size = st.st_size
        entry.modified = datetime.fromtimestamp(st.st_mtime)
        entry.short_name = os.path.split(path)[1]
        entry.created = datetime.fromtimestamp(st.st_ctime)
        entry.accessed = datetime.fromtimestamp(st.st_atime)
        entry.full_name = entry.short_name
        return entry

    def _validate(self):
        if self.type is None:
            raise MissingInformationException("Type is missing, choose either TYPE_FOLDER or TYPE_FILE.")
        if self.file_size is None:
            if self.type.startswith('FOLDER'):
                self.file_size = 0
            else:
                raise MissingInformationException("File size missing")
        if self.created is None:
            self.created = datetime.now()
        if self.modified is None:
            self.modified = datetime.now()
        if self.accessed is None:
            self.accessed = datetime.now()
        # if self.modified is None or self.accessed is None or self.created is None:
        #     raise MissingInformationException("Date information missing")
        if self.full_name is None:
            raise MissingInformationException("A full name is missing")
        if self.short_name is None:
            self.short_name = self.full_name

    @property
    def bytes(self):
        if self.full_name is None:
            return
        self._validate()
        out = BytesIO()
        entry_type = self.type
        short_name_len = len(self.short_name) + 1
        try:
            self.short_name.encode("ascii")
            short_name_is_unicode = False
            short_name_len += short_name_len % 2  # padding
        except (UnicodeEncodeError, UnicodeDecodeError):
            short_name_is_unicode = True
            short_name_len = short_name_len * 2
            self.type += " (UNICODE)"
        write_short(_ENTRY_TYPE_IDS[entry_type], out)
        write_int(self.file_size, out)
        write_dos_datetime(self.modified, out)
        write_short(0x10, out)
        if short_name_is_unicode:
            write_cunicode(self.short_name, out)
        else:
            write_cstring(self.short_name, out, padding=True)
        indicator = 24 + 2 * len(self.short_name)
        write_short(indicator, out)  # size
        write_short(0x03, out)  # version
        write_short(0x04, out)  # signature part1
        write_short(0xBeef, out)  # signature part2
        write_dos_datetime(self.created, out)
        write_dos_datetime(self.accessed, out)
        offset_unicode = 0x14  # fixed data structure, always the same
        write_short(offset_unicode, out)
        offset_ansi = 0  # we always write unicode
        write_short(offset_ansi, out)  # long_string_size
        write_cunicode(self.full_name, out)
        offset_part2 = 0x0E + short_name_len
        write_short(offset_part2, out)
        return out.getvalue()

    def __str__(self):
        return "<PathSegmentEntry: %s>" % self.full_name


class UwpSubBlock:

    block_names = {
        0x11: 'PackageFamilyName',
        # 0x0e: '',
        # 0x19: '',
        0x15: 'PackageFullName',
        0x05: 'Target',
        0x0f: 'Location',
        0x20: 'RandomGuid',
        0x0c: 'Square150x150Logo',
        0x02: 'Square44x44Logo',
        0x0d: 'Wide310x150Logo',
        # 0x04: '',
        # 0x05: '',
        0x13: 'Square310x310Logo',
        # 0x0e: '',
        0x0b: 'DisplayName',
        0x14: 'Square71x71Logo',
        0x64: 'RandomByte',
        0x0a: 'DisplayName',
        # 0x07: '',
    }

    block_types = {
        'string': [0x11, 0x15, 0x05, 0x0f, 0x0c, 0x02, 0x0d, 0x13, 0x0b, 0x14, 0x0a],
    }

    def __init__(self, bytes=None, type=None, value=None):
        self._data = bytes or b''
        self.type = type
        self.value = value
        self.name = None
        if self.type is not None:
            self.name = self.block_names.get(self.type, 'UNKNOWN')
        if not bytes:
            return
        buf = BytesIO(bytes)
        self.type = read_byte(buf)
        self.name = self.block_names.get(self.type, 'UNKNOWN')

        self.value = self._data[1:]  # skip type
        if self.type in self.block_types['string']:
            unknown = read_int(buf)
            probably_type = read_int(buf)
            if probably_type == 0x1f:
                string_len = read_int(buf)
                self.value = read_cunicode(buf)

    def __str__(self):
        string = f'UwpSubBlock {self.name} ({hex(self.type)}): {self.value}'
        return string.strip()

    @property
    def bytes(self):
        out = BytesIO()
        if self.value:
            if isinstance(self.value, str):
                string_len = len(self.value) + 1

                write_byte(self.type, out)
                write_int(0, out)
                write_int(0x1f, out)

                write_int(string_len, out)
                write_cunicode(self.value, out)
                if string_len % 2 == 1:  # padding
                    write_short(0, out)

            elif isinstance(self.value, bytes):
                write_byte(self.type, out)
                out.write(self.value)

        result = out.getvalue()
        return result


class UwpMainBlock:
    magic = b'\x31\x53\x50\x53'

    def __init__(self, bytes=None, guid: Optional[str] = None, blocks=None):
        self._data = bytes or b''
        self._blocks = blocks or []
        self.guid: str = guid
        if not bytes:
            return
        buf = BytesIO(bytes)
        magic = buf.read(4)
        self.guid = guid_from_bytes(buf.read(16))
        # read sub blocks
        while True:
            sub_block_size = read_int(buf)
            if not sub_block_size:  # last size is zero
                break
            sub_block_data = buf.read(sub_block_size - 4)  # includes block_size
            self._blocks.append(UwpSubBlock(sub_block_data))

    def __str__(self):
        string = f'<UwpMainBlock> {self.guid}:\n'
        for block in self._blocks:
            string += f'      {block}\n'
        return string.strip()

    @property
    def bytes(self):
        blocks_bytes = [block.bytes for block in self._blocks]
        out = BytesIO()
        out.write(self.magic)
        out.write(bytes_from_guid(self.guid))
        for block in blocks_bytes:
            write_int(len(block) + 4, out)
            out.write(block)
        write_int(0, out)
        result = out.getvalue()
        return result


class UwpSegmentEntry:
    magic = b'APPS'
    header = b'\x08\x00\x03\x00\x00\x00\x00\x00\x00\x00'

    def __init__(self, bytes=None):
        self._blocks = []
        self._data = bytes
        if bytes is None:
            return
        buf = BytesIO(bytes)
        unknown = read_short(buf)
        size = read_short(buf)
        magic = buf.read(4)  # b'APPS'
        blocks_size = read_short(buf)
        unknown2 = buf.read(10)
        # read main blocks
        while True:
            block_size = read_int(buf)
            if not block_size:  # last size is zero
                break
            block_data = buf.read(block_size - 4)  # includes block_size
            self._blocks.append(UwpMainBlock(block_data))

    def __str__(self):
        string = '<UwpSegmentEntry>:\n'
        for block in self._blocks:
            string += f'    {block}\n'
        return string.strip()

    @property
    def bytes(self):
        blocks_bytes = [block.bytes for block in self._blocks]
        blocks_size = sum([len(block) + 4 for block in blocks_bytes]) + 4   # with terminator
        size = (
            2  # size
            + len(self.magic)
            + 2  # second size
            + len(self.header)
            + blocks_size  # blocks with terminator
        )

        out = BytesIO()
        write_short(0, out)
        write_short(size, out)
        out.write(self.magic)
        write_short(blocks_size, out)
        out.write(self.header)
        for block in blocks_bytes:
            write_int(len(block) + 4, out)
            out.write(block)
        write_int(0, out)  # empty block
        write_short(0, out)  # ??

        result = out.getvalue()
        return result

    @classmethod
    def create(cls, package_family_name, target, location=None, logo44x44=None):
        segment = cls()

        blocks = [
            UwpSubBlock(type=0x11, value=package_family_name),
            UwpSubBlock(type=0x0e, value=b'\x00\x00\x00\x00\x13\x00\x00\x00\x02\x00\x00\x00'),
            UwpSubBlock(type=0x05, value=target),
        ]
        if location:
            blocks.append(UwpSubBlock(type=0x0f, value=location))  # need for relative icon path
        main1 = UwpMainBlock(guid='{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}', blocks=blocks)
        segment._blocks.append(main1)

        if logo44x44:
            main2 = UwpMainBlock(
                guid='{86D40B4D-9069-443C-819A-2A54090DCCEC}',
                blocks=[UwpSubBlock(type=0x02, value=logo44x44)]
            )
            segment._blocks.append(main2)

        return segment


class LinkTargetIDList(object):
    
    def __init__(self, bytes=None):
        self.items = []
        if bytes is not None:
            buf = BytesIO(bytes)
            raw = []
            entry_len = read_short(buf)
            while entry_len > 0:
                raw.append(buf.read(entry_len - 2))  # the length includes the size
                entry_len = read_short(buf)
            self._interpret(raw)
    
    def _interpret(self, raw):
        # if len(raw[0]) == 0x12:
        if raw[0][0] == 0x1F:
            self.items.append(RootEntry(raw[0]))
            if self.items[0].root == ROOT_MY_COMPUTER:
                if not len(raw[1]) == 0x17:
                    raise ValueError("This seems to be an absolute link which requires a drive as second element.")
                self.items.append(DriveEntry(raw[1]))
                items = raw[2:]
            elif self.items[0].root == ROOT_NETWORK_PLACES:
                raise NotImplementedError(
                    "Parsing network lnks has not yet been implemented. "
                    "If you need it just contact me and we'll see..."
                )
            else:
                items = raw[1:]
        else:
            items = raw
        for item in items:
            if item[4:8] == b'APPS':
                self.items.append(UwpSegmentEntry(item))
            else:
                self.items.append(PathSegmentEntry(item))
    
    def get_path(self):
        segments = []
        for item in self.items:
            if type(item) == RootEntry:
                segments.append('%' + item.root + '%')
            elif type(item) == DriveEntry:
                segments.append(item.drive.decode())
            elif type(item) == PathSegmentEntry:
                if item.full_name is not None:
                    segments.append(item.full_name)
            else:
                segments.append(item)
        return '\\'.join(segments)
    
    def _validate(self):
        if type(self.items[0]) == RootEntry:
            if self.items[0].root == ROOT_MY_COMPUTER and type(self.items[1]) != DriveEntry:
                raise ValueError("A drive is required for absolute lnks")

    @property
    def bytes(self):
        self._validate()
        out = BytesIO()
        for item in self.items:
            bytes = item.bytes
            # skip invalid
            if bytes is None:
                continue
            write_short(len(bytes) + 2, out)  # len + terminator
            out.write(bytes)
        out.write(b'\x00\x00')
        return out.getvalue()

    def __str__(self):
        string = '<LinkTargetIDList>:\n'
        for item in self.items:
            string += f'  {item}\n'
        return string.strip()


class LinkInfo(object):

    def __init__(self, lnk=None):
        if lnk is not None:
            self.start = lnk.tell()
            self.size = read_int(lnk)
            self.header_size = read_int(lnk)
            link_info_flags = read_int(lnk)
            self.local = link_info_flags & 1
            self.remote = link_info_flags & 2
            self.offs_local_volume_table = read_int(lnk)
            self.offs_local_base_path = read_int(lnk)
            self.offs_network_volume_table = read_int(lnk)
            self.offs_base_name = read_int(lnk)
            if self.header_size >= _LINK_INFO_HEADER_OPTIONAL:
                print("TODO: read the unicode stuff")  # TODO: read the unicode stuff
            self._parse_path_elements(lnk)
        else:
            self.size = None
            self.header_size = _LINK_INFO_HEADER_DEFAULT
            self.remote = None
            self.offs_local_volume_table = 0
            self.offs_local_base_path = 0
            self.offs_network_volume_table = 0
            self.offs_base_name = 0
            self.drive_type = None
            self.drive_serial = None
            self.volume_label = None
            self.local_base_path = None
            self.network_share_name = None
            self.base_name = None
            self._path = None

    def _parse_path_elements(self, lnk):
        if self.remote:
            # 20 is the offset of the network share name
            lnk.seek(self.start + self.offs_network_volume_table + 20)
            self.network_share_name = read_cstring(lnk)
            lnk.seek(self.start + self.offs_base_name)
            self.base_name = read_cstring(lnk)
        if self.local:
            lnk.seek(self.start + self.offs_local_volume_table + 4)
            self.drive_type = _DRIVE_TYPES.get(read_int(lnk))
            self.drive_serial = read_int(lnk)
            lnk.read(4)  # volume name offset (10h)
            self.volume_label = read_cstring(lnk)
            lnk.seek(self.start + self.offs_local_base_path)
            self.local_base_path = read_cstring(lnk)
            # TODO: unicode
        self.make_path()

    def make_path(self):
        if self.remote:
            self._path = self.network_share_name + self.base_name
        if self.local:
            self._path = self.local_base_path
    
    def write(self, lnk):
        if self.remote is None:
            raise MissingInformationException("No location information given.")
        self.start = lnk.tell()
        self._calculate_sizes_and_offsets()
        write_int(self.size, lnk)
        write_int(self.header_size, lnk)
        write_int((self.local and 1) + (self.remote and 2), lnk)
        write_int(self.offs_local_volume_table, lnk)
        write_int(self.offs_local_base_path, lnk)
        write_int(self.offs_network_volume_table, lnk)
        write_int(self.offs_base_name, lnk)
        if self.remote:
            self._write_network_volume_table(lnk)
            write_cstring(self.base_name, lnk)
        else:
            self._write_local_volume_table(lnk)
            write_cstring(self.local_base_path, lnk, padding=True)
        write_byte(0, lnk)
    
    def _calculate_sizes_and_offsets(self):
        self.size_base_name = 1  # len(self.base_name) + 1  # zero terminated strings
        self.size = 28 + self.size_base_name
        if self.remote:
            self.size_network_volume_table = 20 + len(self.network_share_name) + 1
            self.size += self.size_network_volume_table
            self.offs_local_volume_table = 0
            self.offs_local_base_path = 0
            self.offs_network_volume_table = 28
            self.offs_base_name = self.offs_network_volume_table + self.size_network_volume_table
        else:
            self.size_local_volume_table = 16 + len(self.volume_label) + 1
            self.size_local_base_path = len(self.local_base_path) + 1
            self.size += self.size_local_volume_table + self.size_local_base_path
            self.offs_local_volume_table = 28
            self.offs_local_base_path = self.offs_local_volume_table + self.size_local_volume_table
            self.offs_network_volume_table = 0
            self.offs_base_name = self.offs_local_base_path + self.size_local_base_path
    
    def _write_network_volume_table(self, buf):
        write_int(self.size_network_volume_table, buf)
        write_int(2, buf)  # ?
        write_int(20, buf)  # size of Network Volume Table
        write_int(0, buf)  # ?
        write_int(131072, buf)  # ?
        write_cstring(self.network_share_name, buf)
    
    def _write_local_volume_table(self, buf):
        write_int(self.size_local_volume_table, buf)
        try:
            drive_type = _DRIVE_TYPE_IDS[self.drive_type]
        except KeyError:
            raise ValueError("This is not a valid drive type: %s" % self.drive_type)
        write_int(drive_type, buf)
        write_int(self.drive_serial, buf)
        write_int(16, buf)  # volume name offset
        write_cstring(self.volume_label, buf)

    @property
    def path(self):
        return self._path

    def __str__(self):
        s = "File Location Info:"
        if self._path is None:
            return s + " <not specified>"
        if self.remote:
            s += "\n  (remote)"
            s += "\n  Network Share: %s" % self.network_share_name
            s += "\n  Base Name: %s" % self.base_name
        else:
            s += "\n  (local)"
            s += "\n  Volume Type: %s" % self.drive_type
            s += "\n  Volume Serial Number: %s" % self.drive_serial
            s += "\n  Volume Label: %s" % self.volume_label
            s += "\n  Path: %s" % self.local_base_path
        return s


EXTRA_DATA_TYPES = {
    0xA0000002: 'ConsoleDataBlock',  # size 0x000000CC
    0xA0000004: 'ConsoleFEDataBlock',  # size 0x0000000C
    0xA0000006: 'DarwinDataBlock',  # size 0x00000314
    0xA0000001: 'EnvironmentVariableDataBlock',  # size 0x00000314
    0xA0000007: 'IconEnvironmentDataBlock',  # size 0x00000314
    0xA000000B: 'KnownFolderDataBlock',  # size 0x0000001C
    0xA0000009: 'PropertyStoreDataBlock',  # size >= 0x0000000C
    0xA0000008: 'ShimDataBlock',  # size >= 0x00000088
    0xA0000005: 'SpecialFolderDataBlock',  # size 0x00000010
    0xA0000003: 'VistaAndAboveIDListDataBlock',  # size 0x00000060
}


class ExtraData_Unparsed(object):
    def __init__(self, bytes=None, signature=None, data=None):
        self._signature = signature
        self._size = None
        self.data = data
        # if data:
        #     self._size = len(data)
        if bytes:
            # self._size = len(bytes)
            self.data = bytes
            # self.read(bytes)

    # def read(self, bytes):
    #     buf = BytesIO(bytes)
    #     size = len(bytes)
    #     # self._size = read_int(buf)
    #     # self._signature = read_int(buf)
    #     self.data = buf.read(self._size - 8)

    def bytes(self):
        buf = BytesIO()
        write_int(len(self.data)+8, buf)
        write_int(self._signature, buf)
        buf.write(self.data)
        return buf.getvalue()

    def __str__(self):
        s = 'ExtraDataBlock\n signature %s\n data: %s' % (hex(self._signature), self.data)
        return s


def padding(val, size, byte=b'\x00'):
    return val + (size-len(val)) * byte


class ExtraData_IconEnvironmentDataBlock(object):
    def __init__(self, bytes=None):
        # self._size = None
        # self._signature = None
        self._signature = 0xA0000007
        self.target_ansi = None
        self.target_unicode = None
        if bytes:
            self.read(bytes)

    def read(self, bytes):
        buf = BytesIO(bytes)
        # self._size = read_int(buf)
        # self._signature = read_int(buf)
        self.target_ansi = buf.read(260).decode()
        self.target_unicode = buf.read(520).decode('utf-16-le')

    def bytes(self):
        target_ansi = padding(self.target_ansi.encode(), 260)
        target_unicode = padding(self.target_unicode.encode('utf-16-le'), 520)
        size = 8 + len(target_ansi) + len(target_unicode)
        assert self._signature == 0xA0000007
        assert size == 0x00000314
        buf = BytesIO()
        write_int(size, buf)
        write_int(self._signature, buf)
        buf.write(target_ansi)
        buf.write(target_unicode)
        return buf.getvalue()

    def __str__(self):
        target_ansi = self.target_ansi.replace('\x00', '')
        target_unicode = self.target_unicode.replace('\x00', '')
        s = f'IconEnvironmentDataBlock\n TargetAnsi: {target_ansi}\n TargetUnicode: {target_unicode}'
        return s


def guid_to_str(guid):
    ordered = [guid[3], guid[2], guid[1], guid[0], guid[5], guid[4],
               guid[7], guid[6], guid[8], guid[9], guid[10], guid[11],
               guid[12], guid[13], guid[14], guid[15]]
    res = "{%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X}" % tuple([x for x in ordered])
    # print(guid, res)
    return res


class TypedPropertyValue(object):
    # types: [MS-OLEPS] section 2.15
    def __init__(self, bytes=None, type=None, value=None):
        self.type = type
        self.value = value
        if bytes:
            self.type = read_short(BytesIO(bytes))
            padding = bytes[2:4]
            self.value = bytes[4:]

    def set_string(self, value):
        self.type = 0x1f
        buf = BytesIO()
        write_int(len(value)+2, buf)
        buf.write(value.encode('utf-16-le'))
        # terminator (included in size)
        buf.write(b'\x00\x00\x00\x00')
        # padding (not included in size)
        if len(value) % 2:
            buf.write(b'\x00\x00')
        self.value = buf.getvalue()

    @property
    def bytes(self):
        buf = BytesIO()
        write_short(self.type, buf)
        write_short(0x0000, buf)
        buf.write(self.value)
        return buf.getvalue()

    def __str__(self):
        value = self.value
        if self.type == 0x1F:
            size = value[:4]
            value = value[4:].decode('utf-16-le')
        if self.type == 0x15:
            value = unpack('<Q', value)[0]
        if self.type == 0x13:
            value = unpack('<I', value)[0]
        if self.type == 0x14:
            value = unpack('<q', value)[0]
        if self.type == 0x16:
            value = unpack('<i', value)[0]
        if self.type == 0x17:
            value = unpack('<I', value)[0]
        if self.type == 0x48:
            value = guid_to_str(value)
        if self.type == 0x40:
            # FILETIME (Packet Version)
            stream = BytesIO(value)
            low = read_int(stream)
            high = read_int(stream)
            num = (high << 32) + low
            value = convert_time_to_unix(num)
        return '%s: %s' % (hex(self.type), value)


class PropertyStore:
    def __init__(self, bytes=None, properties=None, format_id=None, is_strings=False):
        self.is_strings = is_strings
        self.properties = []
        self.format_id = format_id
        self._is_end = False
        if properties:
            self.properties = properties
        if bytes:
            self.read(bytes)

    def read(self, bytes_io):
        buf = bytes_io
        size = read_int(buf)
        assert size < len(buf.getvalue())
        if size == 0x00000000:
            self._is_end = True
            return
        version = read_int(buf)
        assert version == 0x53505331
        self.format_id = buf.read(16)
        if self.format_id == b'\xD5\xCD\xD5\x05\x2E\x9C\x10\x1B\x93\x97\x08\x00\x2B\x2C\xF9\xAE':
            self.is_strings = True
        else:
            self.is_strings = False
        while True:
            # assert lnk.tell() < (start + size)
            value_size = read_int(buf)
            if value_size == 0x00000000:
                break
            if self.is_strings:
                name_size = read_int(buf)
                reserved = read_byte(buf)
                name = buf.read(name_size).decode('utf-16-le')
                value = TypedPropertyValue(buf.read(value_size-9))
                self.properties.append((name, value))
            else:
                value_id = read_int(buf)
                reserved = read_byte(buf)
                value = TypedPropertyValue(buf.read(value_size-9))
                self.properties.append((value_id, value))

    @property
    def bytes(self):
        size = 8 + len(self.format_id)
        properties = BytesIO()
        for name, value in self.properties:
            value_bytes = value.bytes
            if self.is_strings:
                name_bytes = name.encode('utf-16-le')
                value_size = 9 + len(name_bytes) + len(value_bytes)
                write_int(value_size, properties)
                name_size = len(name_bytes)
                write_int(name_size, properties)
                properties.write(b'\x00')
                properties.write(name_bytes)
            else:
                value_size = 9 + len(value_bytes)
                write_int(value_size, properties)
                write_int(name, properties)
                properties.write(b'\x00')
            properties.write(value_bytes)
            size += value_size

        write_int(0x00000000, properties)
        size += 4

        buf = BytesIO()
        write_int(size, buf)
        write_int(0x53505331, buf)
        buf.write(self.format_id)
        buf.write(properties.getvalue())

        return buf.getvalue()

    def __str__(self):
        s = ' PropertyStore'
        s += '\n  FormatID: %s' % guid_to_str(self.format_id)
        for name, value in self.properties:
            s += '\n  %3s = %s' % (name, str(value))
        return s.strip()


class ExtraData_PropertyStoreDataBlock(object):
    def __init__(self, bytes=None, stores=None):
        self._size = None
        self._signature = 0xA0000009
        self.stores = []
        if stores:
            self.stores = stores
        if bytes:
            self.read(bytes)

    def read(self, bytes):
        buf = BytesIO(bytes)
        # self._size = read_int(buf)
        # self._signature = read_int(buf)
        # [MS-PROPSTORE] section 2.2
        while True:
            prop_store = PropertyStore(buf)
            if prop_store._is_end:
                break
            self.stores.append(prop_store)

    def bytes(self):
        stores = b''
        for prop_store in self.stores:
            stores += prop_store.bytes
        size = len(stores) + 8 + 4

        assert self._signature == 0xA0000009
        assert size >= 0x0000000C

        buf = BytesIO()
        write_int(size, buf)
        write_int(self._signature, buf)
        buf.write(stores)
        write_int(0x00000000, buf)
        return buf.getvalue()

    def __str__(self):
        s = 'PropertyStoreDataBlock'
        for prop_store in self.stores:
            s += '\n %s' % str(prop_store)
        return s


class ExtraData_EnvironmentVariableDataBlock(object):
    def __init__(self, bytes=None):
        self._signature = 0xA0000001
        self.target_ansi = None
        self.target_unicode = None
        if bytes:
            self.read(bytes)

    def read(self, bytes):
        buf = BytesIO(bytes)
        self.target_ansi = buf.read(260).decode()
        self.target_unicode = buf.read(520).decode('utf-16-le')

    def bytes(self):
        target_ansi = padding(self.target_ansi.encode(), 260)
        target_unicode = padding(self.target_unicode.encode('utf-16-le'), 520)
        size = 8 + len(target_ansi) + len(target_unicode)
        assert self._signature == 0xA0000001
        assert size == 0x00000314
        buf = BytesIO()
        write_int(size, buf)
        write_int(self._signature, buf)
        buf.write(target_ansi)
        buf.write(target_unicode)
        return buf.getvalue()

    def __str__(self):
        target_ansi = self.target_ansi.replace('\x00', '')
        target_unicode = self.target_unicode.replace('\x00', '')
        s = f'EnvironmentVariableDataBlock\n TargetAnsi: {target_ansi}\n TargetUnicode: {target_unicode}'
        return s


EXTRA_DATA_TYPES_CLASSES = {
    'IconEnvironmentDataBlock': ExtraData_IconEnvironmentDataBlock,
    'PropertyStoreDataBlock': ExtraData_PropertyStoreDataBlock,
    'EnvironmentVariableDataBlock': ExtraData_EnvironmentVariableDataBlock,
}


class ExtraData(object):
    # EXTRA_DATA = *EXTRA_DATA_BLOCK TERMINAL_BLOCK
    def __init__(self, lnk=None, blocks=None):
        self.blocks = []
        if blocks:
            self.blocks = blocks
        if lnk is None:
            return
        while True:
            size = read_int(lnk)
            if size < 4:  # TerminalBlock
                break
            signature = read_int(lnk)
            bytes = lnk.read(size-8)
            # lnk.seek(-8, 1)
            block_type = EXTRA_DATA_TYPES[signature]
            if block_type in EXTRA_DATA_TYPES_CLASSES:
                block_class = EXTRA_DATA_TYPES_CLASSES[block_type]
                block = block_class(bytes=bytes)
            else:
                block_class = ExtraData_Unparsed
                block = block_class(bytes=bytes, signature=signature)
            self.blocks.append(block)

    @property
    def bytes(self):
        result = b''
        for block in self.blocks:
            result += block.bytes()
        result += b'\x00\x00\x00\x00'  # TerminalBlock
        return result

    def __str__(self):
        s = ''
        for block in self.blocks:
            s += '\n' + str(block)
        return s


class Lnk(object):
    
    def __init__(self, f=None):
        self.file = None
        if type(f) == str or type(f) == str:
            self.file = f
            try:
                f = open(self.file, 'rb')
            except IOError:
                self.file += ".lnk"
                f = open(self.file, 'rb')
        # defaults
        self.link_flags = Flags(_LINK_FLAGS)
        self.file_flags = Flags(_FILE_ATTRIBUTES_FLAGS)
        self.creation_time = datetime.now()
        self.access_time = datetime.now()
        self.modification_time = datetime.now()
        self.file_size = 0
        self.icon_index = 0
        self._show_command = WINDOW_NORMAL
        self.hot_key = None
        self._link_info = LinkInfo()
        self.description = None
        self.relative_path = None
        self.work_dir = None
        self.arguments = None
        self.icon = None
        self.extra_data = None
        if f is not None:
            assert_lnk_signature(f)
            self._parse_lnk_file(f)
        if self.file:
            f.close()
    
    def _read_hot_key(self, lnk):
        low = read_byte(lnk)
        high = read_byte(lnk)
        key = _KEYS.get(low, '')
        modifier = high and str(ModifierKeys(high)) or ''
        return modifier + key
    
    def _write_hot_key(self, hot_key, lnk):
        if hot_key is None or not hot_key:
            low = high = 0
        else:
            hot_key = hot_key.split('+')
            try:
                low = _KEY_CODES[hot_key[-1]]
            except KeyError:
                raise InvalidKeyException("Cannot find key code for %s" % hot_key[1])
            modifiers = ModifierKeys()
            for modifier in hot_key[:-1]:
                modifiers[modifier.upper()] = True
            high = modifiers.bytes
        write_byte(low, lnk)
        write_byte(high, lnk)

    def _parse_lnk_file(self, lnk):
        # SHELL_LINK_HEADER [LINKTARGET_IDLIST] [LINKINFO] [STRING_DATA] *EXTRA_DATA

        # SHELL_LINK_HEADER
        lnk.seek(20)  # after signature and guid
        self.link_flags.set_flags(read_int(lnk))
        self.file_flags.set_flags(read_int(lnk))
        self.creation_time = convert_time_to_unix(read_double(lnk))
        self.access_time = convert_time_to_unix(read_double(lnk))
        self.modification_time = convert_time_to_unix(read_double(lnk))
        self.file_size = read_int(lnk)
        self.icon_index = read_int(lnk)
        show_command = read_int(lnk)
        self._show_command = _SHOW_COMMANDS[show_command] if show_command in _SHOW_COMMANDS else _SHOW_COMMANDS[1]
        self.hot_key = self._read_hot_key(lnk)
        lnk.read(10)  # reserved (0)

        # LINKTARGET_IDLIST (HasLinkTargetIDList)
        if self.link_flags.HasLinkTargetIDList:
            shell_item_id_list_size = read_short(lnk)
            self.shell_item_id_list = LinkTargetIDList(lnk.read(shell_item_id_list_size))

        # LINKINFO (HasLinkInfo)
        if self.link_flags.HasLinkInfo and not self.link_flags.ForceNoLinkInfo:
            self._link_info = LinkInfo(lnk)
            lnk.seek(self._link_info.start + self._link_info.size)

        # STRING_DATA = [NAME_STRING] [RELATIVE_PATH] [WORKING_DIR] [COMMAND_LINE_ARGUMENTS] [ICON_LOCATION]
        if self.link_flags.HasName:
            self.description = read_sized_string(lnk, self.link_flags.IsUnicode)
        if self.link_flags.HasRelativePath:
            self.relative_path = read_sized_string(lnk, self.link_flags.IsUnicode)
        if self.link_flags.HasWorkingDir:
            self.work_dir = read_sized_string(lnk, self.link_flags.IsUnicode)
        if self.link_flags.HasArguments:
            self.arguments = read_sized_string(lnk, self.link_flags.IsUnicode)
        if self.link_flags.HasIconLocation:
            self.icon = read_sized_string(lnk, self.link_flags.IsUnicode)

        # *EXTRA_DATA
        self.extra_data = ExtraData(lnk)

    def save(self, f: Optional[Union[str, IOBase]] = None, force_ext=False):
        if f is None:
            f = self.file
        if f is None:
            raise ValueError("File (name) missing for saving the lnk")
        is_file = hasattr(f, 'write')
        if not is_file:
            if not type(f) == str and not type(f) == str:
                raise ValueError("Need a writeable object or a file name to save to, got %s" % f)
            if force_ext:
                if not f.lower().endswith('.lnk'):
                    f += '.lnk'
            f = open(f, 'wb')
        self.write(f)
        # only close the stream if it's our own
        if not is_file:
            f.close()
    
    def write(self, lnk):
        lnk.write(_SIGNATURE)
        lnk.write(_GUID)
        write_int(self.link_flags.bytes, lnk)
        write_int(self.file_flags.bytes, lnk)
        write_double(convert_time_to_windows(self.creation_time), lnk)
        write_double(convert_time_to_windows(self.access_time), lnk)
        write_double(convert_time_to_windows(self.modification_time), lnk)
        write_int(self.file_size, lnk)
        write_int(self.icon_index, lnk)
        write_int(_SHOW_COMMAND_IDS[self._show_command], lnk)
        self._write_hot_key(self.hot_key, lnk)
        lnk.write(b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00')  # reserved
        if self.link_flags.HasLinkTargetIDList:
            shell_item_id_list = self.shell_item_id_list.bytes
            write_short(len(shell_item_id_list), lnk)
            lnk.write(shell_item_id_list)
        if self.link_flags.HasLinkInfo:
            self._link_info.write(lnk)
        if self.link_flags.HasName:
            write_sized_string(self.description, lnk, self.link_flags.IsUnicode)
        if self.link_flags.HasRelativePath:
            write_sized_string(self.relative_path, lnk, self.link_flags.IsUnicode)
        if self.link_flags.HasWorkingDir:
            write_sized_string(self.work_dir, lnk, self.link_flags.IsUnicode)
        if self.link_flags.HasArguments:
            write_sized_string(self.arguments, lnk, self.link_flags.IsUnicode)
        if self.link_flags.HasIconLocation:
            write_sized_string(self.icon, lnk, self.link_flags.IsUnicode)
        if self.extra_data:
            lnk.write(self.extra_data.bytes)
        else:
            lnk.write(b'\x00\x00\x00\x00')

    def _get_shell_item_id_list(self):
        return self._shell_item_id_list

    def _set_shell_item_id_list(self, shell_item_id_list):
        self._shell_item_id_list = shell_item_id_list
        self.link_flags.HasLinkTargetIDList = shell_item_id_list is not None
    shell_item_id_list = property(_get_shell_item_id_list, _set_shell_item_id_list)

    def _get_link_info(self):
        return self._link_info

    def _set_link_info(self, link_info):
        self._link_info = link_info
        self.link_flags.ForceNoLinkInfo = link_info is None
        self.link_flags.HasLinkInfo = link_info is not None
    link_info = property(_get_link_info, _set_link_info)

    def _get_description(self):
        return self._description

    def _set_description(self, description):
        self._description = description
        self.link_flags.HasName = description is not None
    description = property(_get_description, _set_description)

    def _get_relative_path(self):
        return self._relative_path

    def _set_relative_path(self, relative_path):
        self._relative_path = relative_path
        self.link_flags.HasRelativePath = relative_path is not None
    relative_path = property(_get_relative_path, _set_relative_path)

    def _get_work_dir(self):
        return self._work_dir

    def _set_work_dir(self, work_dir):
        self._work_dir = work_dir
        self.link_flags.HasWorkingDir = work_dir is not None
    work_dir = working_dir = property(_get_work_dir, _set_work_dir)

    def _get_arguments(self):
        return self._arguments

    def _set_arguments(self, arguments):
        self._arguments = arguments
        self.link_flags.HasArguments = arguments is not None
    arguments = property(_get_arguments, _set_arguments)

    def _get_icon(self):
        return self._icon

    def _set_icon(self, icon):
        self._icon = icon
        self.link_flags.HasIconLocation = icon is not None
    icon = property(_get_icon, _set_icon)
    
    def _get_window_mode(self):
        return self._show_command

    def _set_window_mode(self, value):
        if value not in list(_SHOW_COMMANDS.values()):
            raise ValueError("Not a valid window mode: %s. Choose any of pylnk.WINDOW_*" % value)
        self._show_command = value
    window_mode = show_command = property(_get_window_mode, _set_window_mode)

    @property
    def path(self):
        return self._shell_item_id_list.get_path()

    def specify_local_location(self, path, drive_type=None, drive_serial=None, volume_label=None):
        self._link_info.drive_type = drive_type or DRIVE_UNKNOWN
        self._link_info.drive_serial = drive_serial or ''
        self._link_info.volume_label = volume_label or ''
        self._link_info.local_base_path = path
        self._link_info.local = True
        self._link_info.make_path()
    
    def specify_remote_location(self, network_share_name, base_name):
        self._link_info.network_share_name = network_share_name
        self._link_info.base_name = base_name
        self._link_info.remote = True
        self._link_info.make_path()

    def __str__(self):
        s = "Target file:\n"
        s += str(self.file_flags)
        s += "\nCreation Time: %s" % self.creation_time
        s += "\nModification Time: %s" % self.modification_time
        s += "\nAccess Time: %s" % self.access_time
        s += "\nFile size: %s" % self.file_size
        s += "\nWindow mode: %s" % self._show_command
        s += "\nHotkey: %s\n" % self.hot_key
        s += str(self._link_info)
        if self.link_flags.HasLinkTargetIDList:
            s += "\n%s" % self.shell_item_id_list
        if self.link_flags.HasName:
            s += "\nDescription: %s" % self.description
        if self.link_flags.HasRelativePath:
            s += "\nRelative Path: %s" % self.relative_path
        if self.link_flags.HasWorkingDir:
            s += "\nWorking Directory: %s" % self.work_dir
        if self.link_flags.HasArguments:
            s += "\nCommandline Arguments: %s" % self.arguments
        if self.link_flags.HasIconLocation:
            s += "\nIcon: %s" % self.icon
        if self.link_flags.HasLinkInfo:
            s += "\nUsed Path: %s" % self.shell_item_id_list.get_path()
        if self.extra_data:
            s += str(self.extra_data)
        return s


# ---- convenience functions

def parse(lnk):
    return Lnk(lnk)


def create(f=None):
    lnk = Lnk()
    lnk.file = f
    return lnk


def for_file(target_file, lnk_name=None, arguments=None, description=None, icon_file=None, icon_index=0, work_dir=None):
    lnk = create(lnk_name)
    lnk.link_flags._flags['IsUnicode'] = True
    lnk.link_info = None
    levels = list(path_levels(target_file))
    elements = [RootEntry(ROOT_MY_COMPUTER),
                DriveEntry(levels[0])]
    for level in levels[1:]:
        segment = PathSegmentEntry.create_for_path(level)
        elements.append(segment)
    lnk.shell_item_id_list = LinkTargetIDList()
    lnk.shell_item_id_list.items = elements
    # lnk.link_flags._flags['HasLinkInfo'] = True
    if arguments:
        lnk.link_flags._flags['HasArguments'] = True
        lnk.arguments = arguments
    if description:
        lnk.link_flags._flags['HasName'] = True
        lnk.description = description
    if icon_file:
        lnk.link_flags._flags['HasIconLocation'] = True
        lnk.icon = icon_file
    lnk.icon_index = icon_index
    if work_dir:
        lnk.link_flags._flags['HasWorkingDir'] = True
        lnk.work_dir = work_dir
    if lnk_name:
        lnk.save()
    return lnk


def from_segment_list(data, lnk_name=None):
    """
    Creates a lnk file from a list of path segments.
    If lnk_name is given, the resulting lnk will be saved
    to a file with that name.
    The expected list for has the following format ("C:\\dir\\file.txt"):
    
    ['c:\\',
     {'type': TYPE_FOLDER,
      'size': 0,            # optional for folders
      'name': "dir",
      'created': datetime.datetime(2012, 10, 12, 23, 28, 11, 8476),
      'modified': datetime.datetime(2012, 10, 12, 23, 28, 11, 8476),
      'accessed': datetime.datetime(2012, 10, 12, 23, 28, 11, 8476)
     },
     {'type': TYPE_FILE,
      'size': 823,
      'name': "file.txt",
      'created': datetime.datetime(2012, 10, 12, 23, 28, 11, 8476),
      'modified': datetime.datetime(2012, 10, 12, 23, 28, 11, 8476),
      'accessed': datetime.datetime(2012, 10, 12, 23, 28, 11, 8476)
     }
    ]
    
    For relative paths just omit the drive entry.
    Hint: Correct dates really are not crucial for working lnks.
    """
    if type(data) not in (list, tuple):
        raise ValueError("Invalid data format, list or tuple expected")
    lnk = Lnk()
    entries = []
    if is_drive(data[0]):
        # this is an absolute link
        entries.append(RootEntry(ROOT_MY_COMPUTER))
        if not data[0].endswith('\\'):
            data[0] += "\\"
        drive = data.pop(0).encode("ascii")
        entries.append(DriveEntry(drive))
    for level in data:
        segment = PathSegmentEntry()
        segment.type = level['type']
        if level['type'] == TYPE_FOLDER:
            segment.file_size = 0
        else:
            segment.file_size = level['size']
        segment.short_name = level['name']
        segment.full_name = level['name']
        segment.created = level['created']
        segment.modified = level['modified']
        segment.accessed = level['accessed']
        entries.append(segment)
    lnk.shell_item_id_list = LinkTargetIDList()
    lnk.shell_item_id_list.items = entries
    if data[-1]['type'] == TYPE_FOLDER:
        lnk.file_flags.directory = True
    if lnk_name:
        lnk.save(lnk_name)
    return lnk


def build_uwp(
    package_family_name, target, location=None,logo44x44=None, lnk_name=None,
) -> Lnk:
    """
    :param lnk_name:            ex.: crafted_uwp.lnk
    :param package_family_name: ex.: Microsoft.WindowsCalculator_10.1910.0.0_x64__8wekyb3d8bbwe
    :param target:              ex.: Microsoft.WindowsCalculator_8wekyb3d8bbwe!App
    :param location:            ex.: C:\\Program Files\\WindowsApps\\Microsoft.WindowsCalculator_10.1910.0.0_x64__8wekyb3d8bbwe
    :param logo44x44:           ex.: Assets\\CalculatorAppList.png
    """
    lnk = Lnk()
    lnk.link_flags._flags['HasLinkTargetIDList'] = True
    lnk.link_flags._flags['IsUnicode'] = True
    lnk.link_flags._flags['EnableTargetMetadata'] = True

    lnk.shell_item_id_list = LinkTargetIDList()

    elements = [
        RootEntry(ROOT_UWP_APPS),
        UwpSegmentEntry.create(
            package_family_name=package_family_name,
            target=target,
            location=location,
            logo44x44=logo44x44,
        )
    ]
    lnk.shell_item_id_list.items = elements

    if lnk_name:
        lnk.file = lnk_name
        lnk.save()
    return lnk


def get_prop(obj, prop_queue):
    attr = getattr(obj, prop_queue[0])
    if len(prop_queue) > 1:
        return get_prop(attr, prop_queue[1:])
    return attr


def usage_and_exit():
    usage = """usage: pylnk.py c[reate] TARGETFILE LNKFILE
       pylnk.py p[arse] LNKFILE [PROPERTY[, PROPERTY[, ...]]]"""
    print(usage)
    sys.exit(1)


if __name__ == "__main__":
    # lnk = parse('temp_1.lnk.q')
    # print(lnk)
    # lnk.save('result.lnk.1')
    # lnk = parse('result.lnk.1')
    # print(lnk)
    # exit(0)

    if len(sys.argv) == 1:
        usage_and_exit()
    if sys.argv[1] in ['h', '-h', '--help']:
        usage_and_exit()
    action = sys.argv[1]
    if action not in ['c', 'create', 'p', 'parse', 'd']:
        print("unknown action: " + action)
        usage_and_exit()
    if action.startswith('c'):
        if len(sys.argv) < 4:
            usage_and_exit()
        for_file(sys.argv[2], sys.argv[3])
    elif action.startswith('p'):
        if len(sys.argv) < 3:
            usage_and_exit()
        lnk = parse(sys.argv[2])
        props = sys.argv[3:]
        if len(props) == 0:
            print(lnk)
        else:
            for prop in props:
                print(get_prop(lnk, prop.split('.')))
    elif action.startswith('d'):
        if len(sys.argv) < 3:
            usage_and_exit()
        lnk = parse(sys.argv[2])
        new_filename = sys.argv[3]
        print(lnk)
        lnk.save(new_filename)
        print('saved')
