from __future__ import print_function
import os
import sys
import time
import mmap

"""
Author Github:   https://github.com/g666gle      
Author Twitter:  https://twitter.com/g666gle1
Date:            1/29/2019
Description:     Takes in one file at a time as command line input. processes each line in the file and places the
                 information into the correct subdirectory of the data folder.
Usage:           python3 pysort.py file.txt
Version:	     1.0.0
Python Version:  3.6.7
"""

args = sys.argv

# TODO fix bug where spaces in import files 
# TODO make another log file for usage
# TODO make an option for counting the number of files
# TODO Add zstd to compress the files once all of the files are imported
# TODO Add support for SQL vbull CSV Json


# FIXED
#           - Bug where password:email files were being imputed as email:password
#           - in run.sh fixed and added SimplyEmail as an option for harvesting email addresses


def check_duplicate(full_file_path, line):
    """
    This function takes in a path to the file and the specific line we want to check for duplicates with. First the file
    is checked to make sure it isn't empty, then the file is opened as a binary so we can store the lines as a mmap obj.
    Next if the line is a duplicate then False is returned else True
    :param full_file_path: Path to the file
    :param line: The line being checked
    :return: True if the line should be written to the file; else False
    """
    #  Check to see if the file is not empty
    if not os.stat(full_file_path).st_size == 0:
        #  Open the file as a binary file and store it in a mmap obj
        with open(full_file_path, 'rb', 0) as fp, mmap.mmap(fp.fileno(), 0, access=mmap.ACCESS_READ) as s:
            #  Check to see if the line already exists in the file
            if s.find(str.encode(line.strip())) != -1:
                return False  # string is in file so do not re-write it
            return True  # string is not in file so write it to the file
    return True  # Write to the file


def place_data(line, path):
    """
    This function takes in the line of the current file and the root path to the BaseQuery directory. Checks the format
    of the file to make sure each line is in the email:password format. Then determines the depth of the correct characters
    ex) ex|ample@gmail.com  ---> would result in a depth of 2.  Then checking each directory to see if it already exists
    the username:password combo is correctly placed into a easy to query file. If a invalid character is determined in the
    first 4 chars then it will be put in a '0UTLIERS.txt' file.
    :param line: email:password
    :param path: full path to file
    :return: Either a 1 or a 0 depending on if a line has been written or not
    """
    if line[0] == ":":
        line = line[1:]
    emailPaswd = line.split(':', 2)

    #  Checks to see if the users format is "Password:Username" instead of "Username:Password"
    if len(emailPaswd) >= 2 and '@' in emailPaswd[1] and '.' in emailPaswd[1]:
        #  Switches the position of the username and password
        temp = emailPaswd[0]
        emailPaswd[0] = emailPaswd[1].lower()
        emailPaswd[1] = temp
    else:
        #  Change all of the email usernames to be lowercase; to be uniform
        emailPaswd[0] = emailPaswd[0].lower()

    try:
        #  check to see if you have a valid email address and the username is >= 4; also checks if there is a '@' in the username
        if '@' in emailPaswd[0].strip() and len(emailPaswd[0].strip().split('@')[0]) >= 4 and len(emailPaswd) >= 2 and emailPaswd[0].strip().count('@') == 1:
            first_letter =  emailPaswd[0][0]
            second_letter = emailPaswd[0][1]
            third_letter =  emailPaswd[0][2]
            fourth_letter = emailPaswd[0][3]

            #  Check to see if the username has an invalid character and at what spot
            if str(first_letter).isalnum():
                folder_depth = 1
                if str(second_letter).isalnum():
                    folder_depth = 2
                    if str(third_letter).isalnum():
                        folder_depth = 3
                        if str(fourth_letter).isalnum():
                            folder_depth = 4
            else:
                folder_depth = 0


            #  Check to see if the first letter doesn't have a directory
            if not os.path.isdir(path + "/data/" + first_letter):
                #  Check to see if we start with at least one valid char
                if folder_depth >= 1:
                    #  Make the directory
                    os.makedirs(path + "/data/" + first_letter)
                else:
                    #  If the outlier dir doesn't exist; make it and start the file
                    if not os.path.isdir(path + "/data/0UTLIERS"):
                        os.makedirs(path + "/data/0UTLIERS")
                        #  Don't need to check for duplicates because its a new file
                        with open(path + "/data/0UTLIERS/0utliers.txt", 'a') as fp:
                            length = len(emailPaswd)
                            #  Iterate through each index of the list and write it to the file
                            for index in range(length):
                                if index != length - 1:
                                    fp.write(emailPaswd[index] + ":")
                                else:  # Don't add a ':' at the end of the line
                                    fp.write(emailPaswd[index])
                            fp.write("\n")
                        return 1
                    else:  # If the outlier dir already exists append the line to the file
                        if check_duplicate(path + "/data/0UTLIERS/0utliers.txt", line):
                            # Checks to see if there are duplicates already in the file, returns true if there isn't
                            with open(path + "/data/0UTLIERS/0utliers.txt", 'a') as fp:
                                length = len(emailPaswd)
                                #  Iterate through each index of the list and write it to the file
                                for index in range(length):
                                    if index != length - 1:
                                        fp.write(emailPaswd[index] + ":")
                                    else:  # Don't add a ':' at the end of the line
                                        fp.write(emailPaswd[index])
                                fp.write("\n")
                            return 1
                    return 0
            else:  # The directory already exists
                if folder_depth == 0:  # There is not at least one consecutive valid char
                    #  If the outlier dir doesn't exist; make it and start the file
                    if not os.path.isdir(path + "/data/0UTLIERS"):
                        os.makedirs("mkdir " + path + "/data/0UTLIERS")
                        with open(path + "/data/0UTLIERS/0utliers.txt", 'a') as fp:
                            length = len(emailPaswd)
                            #  Iterate through each index of the list and write it to the file
                            for index in range(length):
                                if index != length - 1:
                                    fp.write(emailPaswd[index] + ":")
                                else:  # Don't add a ':' at the end of the line
                                    fp.write(emailPaswd[index])
                            fp.write("\n")
                        return 1
                    else:  # If the outlier dir already exists append the line to the file
                        if check_duplicate(path + "/data/0UTLIERS/0utliers.txt", line):
                            with open(path + "/data/0UTLIERS/0utliers.txt", 'a') as fp:
                                length = len(emailPaswd)
                                #  Iterate through each index of the list and write it to the file
                                for index in range(length):
                                    if index != length - 1:
                                        fp.write(emailPaswd[index] + ":")
                                    else:  # Don't add a ':' at the end of the line
                                        fp.write(emailPaswd[index])
                                fp.write("\n")
                            return 1
                    return 0

            #  Check to see if the second letter doesn't have a directory
            if not os.path.isdir(path + "/data/" + first_letter + "/" + second_letter):
                #  Check to see if we start with at least two valid char
                if folder_depth >= 2:
                    #  Make the directory
                    os.makedirs(path + "/data/" + first_letter + "/" + second_letter)
                else:
                    #  If the outlier dir doesn't exist; make it and start the file
                    if not os.path.isdir(path + "/data/" + first_letter + "/0UTLIERS"):
                        os.makedirs(path + "/data/" + first_letter + "/0UTLIERS")
                        with open(path + "/data/" + first_letter + "/0UTLIERS/0utliers.txt", 'a') as fp:
                            length = len(emailPaswd)
                            #  Iterate through each index of the list and write it to the file
                            for index in range(length):
                                if index != length - 1:
                                    fp.write(emailPaswd[index] + ":")
                                else:  # Don't add a ':' at the end of the line
                                    fp.write(emailPaswd[index])
                            fp.write("\n")
                        return 1
                    else:
                        #  Check for duplicates
                        if check_duplicate(path + "/data/" + first_letter + "/0UTLIERS/0utliers.txt", line):
                            with open(path + "/data/" + first_letter + "/0UTLIERS/0utliers.txt", 'a') as fp:
                                length = len(emailPaswd)
                                #  Iterate through each index of the list and write it to the file
                                for index in range(length):
                                    if index != length - 1:
                                        fp.write(emailPaswd[index] + ":")
                                    else:  # Don't add a ':' at the end of the line
                                        fp.write(emailPaswd[index])
                                fp.write("\n")
                            return 1
                    return 0
            else:  # The directory already exists
                if folder_depth <= 1:  # There is not at least two consecutive valid char
                    #  If the outlier dir doesn't exist; make it and start the file
                    if not os.path.isdir(path + "/data/" + first_letter + "/0UTLIERS"):
                        os.makedirs(path + "/data/" + first_letter + "/0UTLIERS")
                        with open(path + "/data/" + first_letter + "/0UTLIERS/0utliers.txt", 'a') as fp:
                            length = len(emailPaswd)
                            #  Iterate through each index of the list and write it to the file
                            for index in range(length):
                                if index != length - 1:
                                    fp.write(emailPaswd[index] + ":")
                                else:  # Don't add a ':' at the end of the line
                                    fp.write(emailPaswd[index])
                            fp.write("\n")
                        return 1
                    else:  # If the outlier dir already exists append the line to the file
                        if check_duplicate(path + "/data/" + first_letter + "/0UTLIERS/0utliers.txt", line):
                            with open(path + "/data/" + first_letter + "/0UTLIERS/0utliers.txt", 'a') as fp:
                                length = len(emailPaswd)
                                #  Iterate through each index of the list and write it to the file
                                for index in range(length):
                                    if index != length - 1:
                                        fp.write(emailPaswd[index] + ":")
                                    else:  # Don't add a ':' at the end of the line
                                        fp.write(emailPaswd[index])
                                fp.write("\n")
                            return 1
                    return 0

            #  Check to see if the third letter doesn't have a directory
            if not os.path.isdir(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter):
                #  Check to see if we start with at least three valid char
                if folder_depth >= 3:
                    #  Make the directory
                    os.makedirs(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter)
                else:
                    if not os.path.isdir(path + "/data/" + first_letter + "/" + second_letter + "/0UTLIERS"):
                        os.makedirs(path + "/data/" + first_letter + "/" + second_letter + "/0UTLIERS")
                        with open(path + "/data/" + first_letter + "/" + second_letter + "/0UTLIERS/0utliers.txt", 'a') as fp:
                            length = len(emailPaswd)
                            #  Iterate through each index of the list and write it to the file
                            for index in range(length):
                                if index != length - 1:
                                    fp.write(emailPaswd[index] + ":")
                                else:  # Don't add a ':' at the end of the line
                                    fp.write(emailPaswd[index])
                            fp.write("\n")
                        return 1
                    else:  # If the outlier dir already exists append the line to the file
                        if check_duplicate(path + "/data/" + first_letter + "/" + second_letter + "/0UTLIERS/0utliers.txt", line):
                            with open(path + "/data/" + first_letter + "/" + second_letter + "/0UTLIERS/0utliers.txt", 'a') as fp:
                                length = len(emailPaswd)
                                #  Iterate through each index of the list and write it to the file
                                for index in range(length):
                                    if index != length - 1:
                                        fp.write(emailPaswd[index] + ":")
                                    else:  # Don't add a ':' at the end of the line
                                        fp.write(emailPaswd[index])
                                fp.write("\n")
                            return 1
                    return 0
            else:  # The directory already exists
                if folder_depth <= 2:  # There is not at least three consecutive valid char
                    #  If the outlier dir doesn't exist; make it and start the file
                    if not os.path.isdir(path + "/data/" + first_letter + "/" + second_letter + "/0UTLIERS"):
                        os.makedirs(path + "/data/" + first_letter + "/" + second_letter + "/0UTLIERS")
                        with open(path + "/data/" + first_letter + "/" + second_letter + "/0UTLIERS/0utliers.txt", 'a') as fp:
                            length = len(emailPaswd)
                            #  Iterate through each index of the list and write it to the file
                            for index in range(length):
                                if index != length - 1:
                                    fp.write(emailPaswd[index] + ":")
                                else:  # Don't add a ':' at the end of the line
                                    fp.write(emailPaswd[index])
                            fp.write("\n")
                        return 1
                    else:  # If the outlier dir already exists append the line to the file
                        if check_duplicate(path + "/data/" + first_letter + "/" + second_letter + "/0UTLIERS/0utliers.txt", line):
                            with open(path + "/data/" + first_letter + "/" + second_letter + "/0UTLIERS/0utliers.txt", 'a') as fp:
                                length = len(emailPaswd)
                                #  Iterate through each index of the list and write it to the file
                                for index in range(length):
                                    if index != length - 1:
                                        fp.write(emailPaswd[index] + ":")
                                    else:  # Don't add a ':' at the end of the line
                                        fp.write(emailPaswd[index])
                                fp.write("\n")
                            return 1
                    return 0

            #  Checks to see if the file in the third directory doesn't exists
            if not os.path.isfile(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter + "/" + fourth_letter + ".txt"):
                if folder_depth == 4:  # The file doesn't exist in the third dir but there is 4 valid chars
                    #  Make the file
                    with open(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter + "/" + fourth_letter + ".txt", 'a') as output_file:
                        length = len(emailPaswd)
                        #  Iterate through each index of the list and write it to the file
                        for index in range(length):
                            if index != length-1:
                                output_file.write(emailPaswd[index] + ":")
                            else:  # Don't add a ':' at the end of the line
                                output_file.write(emailPaswd[index])
                        output_file.write("\n")
                        return 1
                elif folder_depth == 3:  # Check to see if the fourth letter is an outlier EX) exa!mple@example.com
                    if not os.path.isdir(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter + "/0UTLIERS"):
                        os.makedirs(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter + "/0UTLIERS")
                    #  Make the 0UTLIERS file
                    with open(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter + "/0UTLIERS/0utliers.txt", 'a') as output_file:
                        if check_duplicate(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter + "/0UTLIERS/0utliers.txt", line):
                            length = len(emailPaswd)
                            #  Iterate through each index of the list and write it to the file
                            for index in range(length):
                                if index != length - 1:
                                    output_file.write(emailPaswd[index] + ":")
                                else:  # Dont add a ':' at the end of the line
                                    output_file.write(emailPaswd[index])
                            output_file.write("\n")
                            return 1
                return 0
            else:  # The file exists
                if folder_depth == 4:  # The file does exist in the third dir but there is 4 valid chars
                    if check_duplicate(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter + "/" + fourth_letter + ".txt", line):
                        #  Append the file
                        with open(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter + "/" + fourth_letter + ".txt", 'a') as output_file:
                            length = len(emailPaswd)
                            #  Iterate through each index of the list and write it to the file
                            for index in range(length):
                                if index != length - 1:
                                    output_file.write(emailPaswd[index] + ":")
                                else:  # Dont add a ':' at the end of the line
                                    output_file.write(emailPaswd[index])
                            output_file.write("\n")
                        return 1
                    return 0
                elif folder_depth == 3:  # The file does exist in the third dir but there is only 3 valid chars
                    #  Check to see if you need to make the 0UTLIERS dir
                    if not os.path.isdir(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter + "/0UTLIERS"):
                        os.makedirs(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter + "/0UTLIERS")
                    #  Check for duplicates and then write to the file
                    if check_duplicate(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter + "/0UTLIERS/0utliers.txt", line):
                        #  Append the 0UTLIERS file
                        with open(path + "/data/" + first_letter + "/" + second_letter + "/" + third_letter + "/0UTLIERS/0utliers.txt", 'a') as output_file:
                            length = len(emailPaswd)
                            #  Iterate through each index of the list and write it to the file
                            for index in range(length):
                                if index != length - 1:
                                    output_file.write(emailPaswd[index] + ":")
                                else:  # Dont add a ':' at the end of the line
                                    output_file.write(emailPaswd[index])
                            output_file.write("\n")
                        return 1
                    return 0

        # NOT a valid email address or the username is NOT >= 4; or there is more than one '@' in the username
        else:
            if not os.path.isdir(path + "/data/NOTVALID"):
                os.makedirs(path + "/data/NOTVALID/")
                with open(path + "/data/NOTVALID/FAILED_TEST.txt", 'a') as fp:
                    length = len(emailPaswd)
                    #  Iterate through each index of the list and write it to the file
                    for index in range(length):
                        if index != length - 1:
                            fp.write(emailPaswd[index] + ":")
                        else:  # Don't add a ':' at the end of the line
                            fp.write(emailPaswd[index])
                    fp.write("\n")
                return 1
            else:  # The directory already exists
                if line != "":
                    if check_duplicate(path + "/data/NOTVALID/FAILED_TEST.txt", line):
                        #  Open the file; check if it's a duplicate and write to the file
                        with open(path + "/data/NOTVALID/FAILED_TEST.txt", 'a') as fp:
                            length = len(emailPaswd)
                            #  Iterate through each index of the list and write it to the file
                            for index in range(length):
                                if index != length - 1:
                                    fp.write(emailPaswd[index] + ":")
                                else:  # Don't add a ':' at the end of the line
                                    fp.write(emailPaswd[index])
                            fp.write("\n")
                        return 1
            return 0
    except OSError:
        raise
    return 0


def main():
    start_time = time.time()
    total_lines = 0  # The amount of lines that are not white-space
    written_lines = 0  # The amount of lines written

    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    NC = '\033[0m'  # No Color

    #  Check to see if the arguments are correct
    if len(args) == 2 and args[1] != "":
        path = os.getcwd()
        print(GREEN + "[+]" + NC + " Attempting to open file " + GREEN + args[1] + NC)
        #  Directory guaranteed to exist from previous check in Import.sh
        with open(path + "/PutYourDataBasesHere/" + args[1], 'r') as fp:
            try:
                for line in fp:
                    if total_lines % 10000 == 0 and total_lines != 0:
                        print(GREEN + "[+]" + NC + " Processing line number: " + str(total_lines) + "\nLine: " + line)
                    if line.strip() != "":
                        written_lines += place_data(line.strip(), path)
                        total_lines += 1
            except Exception as e:
                print(RED + "Exception: " + str(e) + NC)
    else:
        print(YELLOW + "[!]" + NC + " Invalid arguments provided")
    stop_time = time.time()
    print()
    print(GREEN + "[+]" + NC + " Total time: " + str(("%.2f" % (stop_time - start_time)) + " seconds"))
    print(GREEN + "[+]" + NC + " Total lines: " + str(("%.2f" % total_lines)))
    print(GREEN + "[+]" + NC + " Written lines: " + str(("%.2f" % written_lines)))


main()
