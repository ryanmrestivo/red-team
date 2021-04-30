import os
import pyautogui

def functionclear():
    if os.name == "nt":
        os.system("cls")
    else:
        os.system("clear")
functionclear()

screenshot = pyautogui.screenshot()
screenshot.save("image.jpg")

print('''
+——— Message ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Screenshot captured!                                                                                                                       |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————+

+——— Help ———————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| crowbar - Goes back to the Crowbar main menu.                                                                                              |
| clear - Clears the screen.                                                                                                                 |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
''')

def main():
    while True:
        userinput = input(f"\n({os.getcwd()})\n  |==> ")
        if userinput == "crowbar":
            os.system("py main.py")
        elif userinput == "clear":
            os.system("cls")
        else:
            print("Wrong Command!")
main()