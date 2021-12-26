import sys
import zipfile
import argparse
from threading import Thread


def main():
    parser = argparse.ArgumentParser('usage: zipcracker.py ' + '-f <zipfile> -w <wordlist>')
    parser.add_argument('-f','--file',required=True,dest='zipf',help='specify zip file')
    parser.add_argument('-w','--wordlist',required=True,dest='wordf',help='specify wordlist file')
    args = parser.parse_args()
    if (args.zipf == None) | (args.wordf == None):
        print(parser.usage)
    else:
        zipf = args.zipf
        wordf = args.wordf
    zipf = zipfile.ZipFile(zipf)
    wordf = open(wordf)
    for line in wordf.readlines():
        password = line.strip('\n')
        t = Thread(target=extractFile, args=(zipf, password))
        t.start()

def extractFile(zipf, password):
    try:
        zipf.extractall(pwd=password)
        print('\n[+] Brute Force Successful: ' + password)
        return password
        exit
    except KeyboardInterrupt:
        print('\n[-] CTRL-C Terminated.')
    except:
        space = len(password)
        space = ' ' * space
        sys.stdout.write('[+] Trying ' + password + space + '\r')
        sys.stdout.flush()
        return


if __name__ == '__main__':
    main()
