#!/usr/bin/env python

__description__ = 'Decompiler for EXEs produced with py2exe Python 3 version'
__author__ = 'Didier Stevens'
__version__ = '0.0.2'
__date__ = '2018/07/09'
__copyright__ = 'Copyright 2016-2018 NVISO'
__license__ = """
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

"""
https://www.nviso.be

History:
  2016/12/08: start
  2016/12/14: continue
  2018/07/09: 0.0.2 update for version uncompyle6 3.

Todo:
Check if running under Python 3
except importerror for uncompyle6 and pefile
exe version (pyinstaller)
"""

import optparse
import sys
import os
import textwrap
import marshal
import dis
import zipfile
from io import StringIO

try:
    from uncompyle6.main import decompile
except:
    print('Missing uncompyle6 Python module, please check if it is installed.')
    exit()

try:
    import pefile
    import peutils
except:
    print('Missing pefile and/or peutils Python module, please check if it is installed.')
    exit()

def PrintManual():
    manual = '''
Manual:

Decompiler for EXEs produced with py2exe Python 3 version
'''
    for line in manual.split('\n'):
        print(textwrap.fill(line, 79))

#Convert 2 Bytes If Python 3
def C2BIP3(string):
    if sys.version_info[0] > 2:
        return bytes([ord(x) for x in string])
    else:
        return string

def Decompilepy2exe(data, pythonversion):
    data = data[0x010:]
    offset = data.find(b"\x00")
    if offset == -1:
        return
    pythoncode = marshal.loads(data[offset + 1:])

    oStringIO = StringIO()
    decompile(pythonversion, pythoncode[-1], oStringIO)
    print(oStringIO.getvalue())

def GetPythonVersion(data):
    if data[0:6] == b'PYTHON' and data[8:] == b'.DLL':
        return data[6] - 0x30 + (data[7] - 0x30) / 10.0
    else:
        return 0.0

def ProcessPy2exe(data, options):
    try:
        oPE = pefile.PE(data=data)
    except Exception as e:
        print('Error analyzing PE file: %s' % str(e))
        return

    pythonversion = 0.0
    pythonscript = None
    if hasattr(oPE, 'DIRECTORY_ENTRY_RESOURCE'):
        for resource_type in oPE.DIRECTORY_ENTRY_RESOURCE.entries:
            if resource_type.name is not None:
                if pythonversion == 0.0:
                    pythonversion = GetPythonVersion(resource_type.name.string)
                if resource_type.name.string == b'PYTHONSCRIPT':
                    if hasattr(resource_type, 'directory'):
                        for resource_id in resource_type.directory.entries:
                            if hasattr(resource_id, 'directory'):
                                for resource_lang in resource_id.directory.entries:
                                    if hasattr(resource_lang, 'data'):
                                        pythonscript = oPE.get_data(resource_lang.data.struct.OffsetToData, resource_lang.data.struct.Size)

    if pythonscript == None:
        print('Unable to find Python code (no resource PYTHONSCRIPT)')
        return
    if pythonversion == 0.0:
        print('Unable to detect Python version')
        return
    if pythonscript[0:4] != b'\x12\x34\x56\x78':
        print('Header (0x12345678) for py2exe not found')
        return

    Decompilepy2exe(pythonscript, pythonversion)

def ProcessFile(filename, options):
        if filename == '':
            data = sys.stdin.buffer.read()
        elif filename.lower().endswith('.zip'):
            try:
                oZipfile = zipfile.ZipFile(filename, 'r')
                oZipContent = oZipfile.open(oZipfile.infolist()[0], 'r', C2BIP3(options.password))
                data = oZipContent.read()
                oZipContent.close()
                oZipfile.close()
            except Exception as e:
                print('Error opening file: %s' % str(e))
                return
        else:
            try:
                fIn = open(filename, 'rb')
                data = fIn.read()
                fIn.close()
            except Exception as e:
                print('Error opening file: %s' % str(e))
                return

        ProcessPy2exe(data, options)

def Main():
    moredesc = '''

Copyright 2016-2018 NVISO
Apache License, Version 2.0
https://www.nviso.be'''

    oParser = optparse.OptionParser(usage='usage: %prog [options] [file]\n' + __description__ + moredesc, version='%prog ' + __version__)
    oParser.add_option('-m', '--man', action='store_true', default=False, help='Print manual')
    oParser.add_option('-p', '--password', default='infected', help='The ZIP password to be used (default infected)')
    (options, args) = oParser.parse_args()

    if options.man:
        oParser.print_help()
        PrintManual()
        return

    if len(args) == 0:
        ProcessFile('', options)
    elif len(args) == 1:
        ProcessFile(args[0], options)
    else:
        oParser.print_help()

if __name__ == '__main__':
    Main()
