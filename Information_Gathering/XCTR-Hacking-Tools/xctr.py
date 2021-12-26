import sys
import func
import configparser
from time import sleep

class colors:
    CGREY = '\33[90m'
    CRED2 = '\33[91m'
    CGREEN2 = '\33[92m'
    CYELLOW2 = '\33[93m'
    CBLUE2 = '\33[94m'
    CVIOLET2 = '\33[95m'
    CBEIGE2 = '\33[96m'
    CWHITE2 = '\33[97m'
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def Giris():
    x = """

`8.`8888.      ,8'  ,o888888o.8888888 8888888888 8 888888888o.   
 `8.`8888.    ,8'  8888     `88.    8 8888       8 8888    `88.  
  `8.`8888.  ,8',8 8888       `8.   8 8888       8 8888     `88  
   `8.`8888.,8' 88 8888             8 8888       8 8888     ,88  
    `8.`88888'  88 8888             8 8888       8 8888.   ,88'  
    .88.`8888.  88 8888             8 8888       8 888888888P'   
   .8'`8.`8888. 88 8888             8 8888       8 8888`8b       
  .8'  `8.`8888.`8 8888       .8'   8 8888       8 8888 `8b.     
 .8'    `8.`8888.  8888     ,88'    8 8888       8 8888   `8b.   
.8'      `8.`8888.  `8888888P'      8 8888       8 8888     `88.                                                   
\n"""

    for c in x:
        print(colors.CYELLOW2 + c, end='')
        sys.stdout.flush()
        sleep(0.0025)
    y = "֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎\n\n"
    for c in y:
        print(colors.CRED2 + c, end='')
        sys.stdout.flush()
        sleep(0.0045)
    y = "֎֎                       𝗖𝗔𝗣𝗧𝗨𝗥𝗘 𝗧𝗢𝗢𝗟𝗦                        ֎֎\n\n"
    for c in y:
        print(colors.CWHITE2 + c, end='')
        sys.stdout.flush()
        sleep(0.0045)
    x = "֎֎                 𝐈𝐍𝐒𝐓𝐀𝐆𝐑𝐀𝐌==>𝐜𝐚𝐩𝐭𝐮𝐫𝐞𝐭𝐡𝐞𝐫𝐨𝐨𝐭                 ֎֎\n\n"
    for c in x:
        print(colors.CWHITE2 + c, end='')
        sys.stdout.flush()
        sleep(0.0045)
    z = "֎֎                 𝐂𝐨𝐝𝐞𝐝 𝐁𝐲 ==>𝐇𝐔𝐋𝐘𝐀 𝐊𝐀𝐑𝐀𝐁𝐀𝐆                  ֎֎\n\n"
    for c in z:
        print(colors.CWHITE2 + c, end='')
        sys.stdout.flush()
        sleep(0.0045)
    h = "֎֎                 𝐂𝐨𝐝𝐞𝐝 𝐁𝐲 ==>𝐌𝐄𝐑𝐓 𝐁𝐄𝐘𝐎𝐆𝐋𝐔                   ֎֎\n\n"
    for c in h:
        print(colors.CWHITE2 + c, end='')
        sys.stdout.flush()
        sleep(0.0045)
    y = "֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎֎\n\n"
    for c in y:
        print(colors.CRED2 + c, end='')
        sys.stdout.flush()
        sleep(0.0045)


def settings_menu():
    print("""
       {}{}{}Settings{}
       Download
       \t 1- User Agent
       \t 2- Up-to-Date Proxy
       
       Change
       \t 3- Site url 
       \t 4- Site port 
       \t 5- Number of threads(max:500) 
       \t 6- Current wordlist
       \t 7- Project name
       """.format(colors.BOLD, colors.OKBLUE, colors.UNDERLINE, colors.ENDC))

    choose = input("\nb- Back\nSettings | Choose\t: ")
    if choose == "1":
        func.Configuration.download("useragent")
    elif choose == "2":
        func.Configuration.download("proxy")
    elif choose == "3":
        func.Configuration.setUrl()
    elif choose == "4":
        func.Configuration.setPort()
    elif choose == "5":
        func.Configuration.setThreadNum()
    elif choose == "6":
        func.Configuration.selectWordlist()
    elif choose == "7":
        func.Configuration.isDirectoryExist()
    elif choose == "b":
        pass
    else:
        print("Try again...")
        sleep(1)


def dorkMenu():
    print("""
    {}{}{}Dork Finder{}
    1-) Bing dork finder      
    2-) Yandex dork finder     
    """.format(colors.BOLD,colors.OKBLUE, colors.UNDERLINE, colors.ENDC))
    answer = input("\nb- Back\nDork menu | Choose:")
    if answer == "1":
        func.Tools.bingDorkFinder()
    elif answer == "2":
        func.Tools.yandexDorkFinder()
    elif answer == "b":
        pass
    else:
        print("Wrong choose try again..")
        sleep(1)


def adminMenu():
    wconf = configparser.ConfigParser()
    wconf.read('settings.cfg')
    print("""
    {}{}{}Admin Panel Finder{}
    Current wordlist: [{}]
    
    1- Login
    2- Change wordlist
    3- Update proxies
    
    """.format(colors.BOLD,colors.OKBLUE, colors.UNDERLINE, colors.ENDC, wconf.get('general', 'cwordlist')
               ))
    answer = input("\nb- Back\nAdmin panel menu | Choose:")
    if answer.lower() == "1":
        func.Tools.adminFinder()
    elif answer.lower() == "2":
        func.Configuration.selectWordlist()
    elif answer.lower() == "3":
        func.Tools.proxyList()
    elif answer.lower() == "b":
        print("Turning back to the menu")
        sleep(1)
        pass
    else:
        print("Wrong choose. Try again..")
        sleep(1)


def Menu():
    print(colors.CBLUE2 + "<<<<<<<<<<           𝗪𝗘𝗟𝗖𝗢𝗠𝗘 𝗧𝗢 𝗫𝗖𝗧𝗥 𝗧𝗢𝗢𝗟𝗦            >>>>>>>>>>")
    y = """
   1) Dork Finder
   2) Admin Panel Finder
   3) Cms Finder
   4) Ip History
   5) Reverse Ip
   6) Page Viewer
   7) Proxy Finder
   8) Read Me
   9) Settings
   0) EXIT
    """
    for c in y:
        print(colors.CBEIGE2 + c, end='')
        sys.stdout.flush()
        sleep(0.0015)


def welcomeScreen():
    try:
        while True:
            selection = input("Main menu | Choose: ")
            if selection == "1":
                dorkMenu()
            elif selection == "2":
                adminMenu()
            elif selection == "3":
                func.Tools.cmsfinder()
            elif selection == "4":
                func.Tools.ipHistory()
            elif selection == "5":
                func.Tools.reverseIP()
            elif selection == "6":
                func.Tools.pageview()
            elif selection == "7":
                func.Tools.proxyList()
            elif selection == "8":
                print('Please visit the url:\n https://github.com/capture0x/XCTR-Hacking-Tools')
                sleep(4)
            elif selection == "9":
                settings_menu()
            elif selection == "0":
                print("Exiting...")
                sleep(1)
                print("bye-bye... (:")
                sys.exit(0)

            else:
                print("Try again")
            Menu()
    except Exception as err:
        print(err)
        pass


if __name__ == "__main__":
    Giris()
    func.Configuration.isDirectoryExist()
    Menu()
    welcomeScreen()
