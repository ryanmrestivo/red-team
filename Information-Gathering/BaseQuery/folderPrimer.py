from __future__ import print_function
import os
import time

"""
Author Github:   https://github.com/g666gle      
Author Twitter:  https://twitter.com/g666gle1
Date:            1/29/2019
Description:     This file creates a triple nested [A-Z] and [0-9] directories so the data from the databases are easily 
                 accessible. The reason to do this before instead of while pysort.py is placing all the files is due to 
                 the fact that creating directories is slightly time consuming and by creating them all at once instead 
                 of on the fly. We can expect to see a small efficiency improvement. Also.... organization 
Usage:           python3 folderPrimer.py
Version:	     1.0.0
Python Version:  3.6.7
"""

path = os.getcwd()


def folder_spam():
    """
    This function creates all the nested files needed to store the data. [A-Z][0-9]
    :return: N/A
    """
    first_nest =  ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't','u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
    second_nest = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't','u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
    third_nest =  ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't','u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
    #  Creating the first nesting of the folders
    for char in first_nest:
        if not os.path.isdir(path + "/data/" + char.strip()):
            os.makedirs(path + "/data/" + char.strip())
    #  Creating the second nesting of the folders
    for char in first_nest:
        for char2 in second_nest:
            if not os.path.isdir(path + "/data/" + char.strip() + "/" + char2.strip()):
                os.makedirs(path + "/data/" + char.strip() + "/" + char2.strip())
    #  Creating the third nesting of the folders
    for char in first_nest:
        for char2 in second_nest:
            for char3 in third_nest:
                if not os.path.isdir(path + "/data/" + char.strip() + "/" + char2.strip() + "/" + char3.strip()):
                    os.makedirs(path + "/data/" + char.strip() + "/" + char2.strip() + "/" + char3.strip())


def main():
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    NC = '\033[0m'  # No Color

    print()
    print(GREEN + "[+]" + NC + "Priming the data directory")
    start_time = time.time()
    folder_spam()
    end_time = time.time()
    print(GREEN + "[+]" + NC + " Data directory finished being primed!")
    print(YELLOW + "[!]" + NC + " Action took " + str(int(end_time - start_time)) + " seconds")
    print()

main()
