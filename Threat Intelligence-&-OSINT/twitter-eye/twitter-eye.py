#!/usr/bin/env/python3
# This Python file uses the following encoding: utf-8

# ===== #
# ▀█████████▄     ▄████████         Websites: HackingPassion.com | Bullseye0.com
#   ███    ███   ███    ███         Author: Jolanda de Koff | Bulls Eye
#   ███    ███   ███    █▀          GitHub: https://github.com/BullsEye0
#  ▄███▄▄▄██▀   ▄███▄▄▄             linkedin: https://www.linkedin.com/in/jolandadekoff
# ▀▀███▀▀▀██▄  ▀▀███▀▀▀             Facebook Group: https://www.facebook.com/groups/hack.passion/
#   ███    ██▄   ███    █▄          Facebook: https://www.facebook.com/profile.php?id=100069546190609
#   ███    ███   ███    ███         Twitter: https://twitter.com/bulls__eye
# ▄█████████▀    ██████████         LBRY: https://lbry.tv/$/invite/@hackingpassion:9
# ===== #

# ===== #
# Created December 2021 | Copyright (c) 2021 Jolanda de Koff.
# ===== #

########################################################################

# A notice to all nerds and n00bs...
# If you will copy the developer's work it will not make you a hacker..!
# Respect all developers, we doing this because it's fun...

########################################################################


import twint
import sys
import time


def banner():
    print(""" \033[1;34m


88888888888            d8b 888    888                         8888888888                  
    888                Y8P 888    888                         888                         
    888                    888    888                         888                         
    888  888  888  888 888 888888 888888 .d88b.  888d888      8888888   888  888  .d88b.  
    888  888  888  888 888 888    888   d8P  Y8b 888P"        888       888  888 d8P  Y8b 
    888  888  888  888 888 888    888   88888888 888          888       888  888 88888888 
    888  Y88b 888 d88P 888 Y88b.  Y88b. Y8b.     888          888       Y88b 888 Y8b.     
    888   "Y8888888P"  888  "Y888  "Y888 "Y8888  888          8888888888 "Y88888  "Y8888  
                                                                             888          
                                                                        Y8b d88P          
                                                                         "Y88P"    V.1       
                                                                                   

            \033[1;m
             \033[34mTwitter Eye - Twitter Information Gathering Tool \033[0m
             \033[34mAuthor: Jolanda de Koff aka Bulls Eye \033[0m
             \033[34mGithub:  https://github.com/BullsEye0 \033[0m
             \033[34mWebsite: https://hackingpassion.com \033[0m

              Hi there, Shall we play a game..? 😃 """)


def menu():
    print("\n\033[1;34m[+] 1. Search - Fetch Tweets using the search filters\033[1;m")
    print("\033[1;34m[+] 2. Email - Fetch Tweets with Email Adress\033[1;m")
    print("\033[1;34m[x] 0. Exit\033[1;m\n")


def b00m():
    choice = ("1")
    banner()

    while choice != ("12"):
        menu()
        choice = input("\033[1;34m[+]\033[1;m \033[1;91mEnter your choice:\033[1;m ")

        if choice == ("1"):
            search = input("\n[~] \033[34mTwitter Search: \033[0m ")
            output = input("\n[~] \033[34mGive the file a name: \033[0m ")
            try:
                c = twint.Config()
                c.Search = search
                c.User_full = True
                c.Profile_full = True
                c.Replies = True
                c.Show_hashtags = True
                c.Stats = True
                c.Get_replies = True
                c.Store_csv = True
                c.Output = output + ".csv"

                twint.run.Search(c)

            except KeyboardInterrupt:
                print("\n")
                print("\033[1;91m[!] User Interruption Detected..!\033[0")
                time.sleep(0.5)
                print("\n\n\t\033[1;91m[!] I like to See Ya, Hacking \033[0m😃\n\n")
                time.sleep(0.5)

        elif choice == ("2"):
            search = input("\n[~] \033[34mUserName: \033[0m ")
            output = input("\n[~] \033[34mGive the file a Name: \033[0m ")
            try:
                c = twint.Config()
                c.Username = search
                c.User_full = True
                c.Email = True
                c.Store_csv = True
                c.Output = output + ".csv"

                twint.run.Search(c)

            except KeyboardInterrupt:
                print("\n")
                print("\033[1;91m[!] User Interruption Detected..!\033[0")
                time.sleep(0.5)
                print("\n\n\t\033[1;91m[!] I like to See Ya, Hacking \033[0m😃\n\n")
                time.sleep(0.5)

        elif choice == ("0"):
            time.sleep(1)
            print(
                "\n\t\033[34mTwit Eye\033[0m DONE... Exiting... \033[34m[!] I like to See Ya, Hacking \033[0m😃\n\n\033[0m\n")
            sys.exit()

        else:
            os.system("reset")
            print("\033[1;31m[-] Invalid option..! \033[1;m")


# =====# Main #===== #
if __name__ == "__main__":
    b00m()
