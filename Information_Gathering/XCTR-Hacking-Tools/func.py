import configparser
import os
from time import sleep

import bs4
import random
import re
import requests
import sys
import time
import threading
from queue import Queue
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

configFile = 'settings.cfg'
userAgentList = 'useragent.txt'
proxyList = 'proxy.txt'


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = "\033[1;31m"
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    CBLACK = '\33[30m'
    CRED = '\33[31m'
    CGREEN = '\33[32m'
    CYELLOW = '\33[33m'
    CBLUE = '\33[34m'
    CVIOLET = '\33[35m'
    CBEIGE = '\33[36m'
    CWHITE = '\33[37m'


def keyboardInterruptHandler(signal, frame):
    print("KeyboardInterrupt (ID: {}) has been caught. Cleaning up...".format(signal))
    exit(0)


class fileSettings:
    def __init__(self, fileDirectory=None):
        self.fileDirectory = fileDirectory

    def readSomething(self):
        try:
            lines = [line.rstrip("\n") for line in open(self.fileDirectory, errors='ignore')]
        except IOError as e:
            print("An error: %s" % e.strerror)
            sys.exit(1)
        return lines


class Configuration:

    def __init__(self):
        pass

    @staticmethod
    def changeValue(option, section, value):
        conf = configparser.ConfigParser()
        conf.read(configFile)
        prevValue = conf[option][section]
        conf.set(option, section, value)
        with open(configFile, "w") as cFile:
            conf.write(cFile)
        print(
            "Updated --> {2}{0}{4}: {6}{5}{4} to {3}[{1}]{4}".format(section, value, bcolors.UNDERLINE, bcolors.OKGREEN,
                                                                     bcolors.ENDC, conf[option][section], bcolors.FAIL))
        sleep(3)
        return prevValue

    @staticmethod
    def download(value):
        def clean_files(fileName):
            with open(fileName, "w", errors='ignore') as f:
                f.write("")
            print("Old content deleted for", fileName)

        def user_agent():
            try:
                print("Downloading started...")
                for page in range(1, 12):
                    url = "https://developers.whatismybrowser.com/useragents/explore/software_type_specific/web-browser/{}".format(
                        page)
                    headers = {
                        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148'
                    }
                    req = requests.get(url, headers=headers)
                    soup = bs4.BeautifulSoup(req.content, "lxml")
                    getAgent = soup.find_all("td", attrs={"class": "useragent"})
                    AgentList = []
                    print(page, ". page OK")
                    for agent in getAgent:
                        AgentList.append(agent)
                    try:
                        fileName = "useragent.txt"
                        with open(fileName, "a", errors='ignore') as file:
                            for agent in AgentList:
                                file.writelines(str(agent.text) + "\n")
                    except Exception as err:
                        print(err)
                print("\n Download completed! Check ", fileName,
                      "\n If something went wrong, please delete {}s FILE INSIDE and try again!".format(fileName))
                sleep(1)
            except Exception as err:
                print(err)

        def proxyList():
            urlLink = "https://free-proxy-list.net/"
            try:
                page = requests.get(urlLink)
                soup = bs4.BeautifulSoup(page.content, "html.parser")
                table = soup.find_all('table', attrs={'id': 'proxylisttable'}) and soup.table.find('tbody')
            except Exception as err:
                print("Please check the web site", err)

            data = []
            counter = 0
            for row in table:
                cols = row.find_all('td')
                cols = [x.text.strip() for x in cols]
                data.append([x for x in cols if x])
                del data[counter][2:8]
                data[counter] = ['{}:{}'.format(data[counter][0], data[counter][1])]
                counter += 1
            try:
                fileName = "proxy.txt"
                with open(fileName, "r+") as file:
                    for i in data:
                        i = ''.join(i)
                        file.writelines(str(i) + "\n")
            except Exception as err:
                print(err)
            print(
                "{} proxy found in free-proxy-list.net\nProxies saved to {}  and updated.".format(len(data), fileName))
            sleep(2)
            return data

        if value == "useragent":
            clean_files("useragent.txt")
            user_agent()
        elif value == "proxy":
            proxyList()

    @staticmethod
    def setUrl():
        siteUrl = input("Enter the target url\t: ")
        if re.search(
                '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$',
                siteUrl) or re.search('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*,]|(?:%[0-9a-fA-F][0-9a-fA-F]))',
                                      siteUrl):
            Configuration.changeValue("general", "siteurl", siteUrl)
        else:
            print("Target url should be url or ip address, try again..")
            sleep(3)

    @staticmethod
    def setThreadNum():
        thNo = input("Enter number of threads\t: ")
        if thNo.isnumeric() and (0 < int(thNo) <= int(500)):
            Configuration.changeValue("general", "threadnumber", thNo)
            return True
        else:
            print("Thread number should be 0-500 range. Try again. Turning back to main menu.")
            sleep(3)

    @staticmethod
    def setPort():
        port = input("Enter port number\t: ")
        if port.isnumeric() and (0 < int(port) <= int(9999)):
            Configuration.changeValue("general", "siteport", port)
            return True
        else:
            print("Port number should be 0-9999 range. Try again. Turning back to main menu.")
            sleep(3)

    @staticmethod
    def selectWordlist():
        mainDirectory = os.getcwd()
        c = configparser.ConfigParser()
        c.read("settings.cfg")
        direc = c["general"]["wordlistDirectory"]
        os.chdir(str(direc))
        while True:
            temporary = dict()
            fileDirect = dict()
            print("\n\n\n\n\n\n\n\nCurrent directory\t: ", os.getcwd())
            counter = 0
            fileCounter = 1000
            for i in os.listdir():
                if os.path.isdir(i):
                    counter += 1

                    print(bcolors.OKGREEN, counter, ":", bcolors.ENDC, bcolors.WARNING, bcolors.BOLD, i, bcolors.ENDC)
                    temporary[counter] = "{}/{}".format(os.getcwd(), i)
                    # if is a folder

                elif os.path.isfile(i):
                    fileDirect[fileCounter] = "{}/{}".format(os.getcwd(), i)
                    print(fileCounter, ":", bcolors.OKBLUE, i, bcolors.ENDC)
                    fileCounter += 1

                    # if is a file
                else:
                    pass
                    # if is not!
            print("\n0 : ../\t | 00: Main directory\t | m : Back to main menu\n")
            selectDirect = input("Enter a number from list\t: ")
            if selectDirect == 'm':
                print("Turning back to the main menu..")
                sleep(1)
                break
            elif selectDirect == "0":
                os.chdir("{}/../".format(os.getcwd(), ))

            elif selectDirect == "00":
                os.chdir(str("{}/{}".format(mainDirectory, direc)))
            elif int(selectDirect) >= 1000:
                print(
                    "{} Selected file :{} {}{}{}{} ".format(bcolors.OKGREEN, bcolors.ENDC, bcolors.OKBLUE, bcolors.BOLD,
                                                            fileDirect[int(selectDirect)].split('\\')[-1],
                                                            bcolors.ENDC))
                c.set("general", "cWordlist", fileDirect[int(selectDirect)].replace('\\', '/'))
                print(mainDirectory)
                with open("{}{}".format(mainDirectory + "/", configFile), "w") as clFiles:
                    c.write(clFiles)
                sleep(2)

                # return fileDirect[int(selectDirect)]
            else:
                os.chdir("{}".format(temporary[int(selectDirect)]))
                pass
        os.chdir(mainDirectory)

    @staticmethod
    def isDirectoryExist():
        checkConfig = configparser.ConfigParser()
        checkConfig.read(configFile)
        print("┌──────────────────────────────────────────────────────────────────────────────┐")
        print("   Current project name\t: " + bcolors.UNDERLINE + checkConfig.get('general',
                                                                                  'projectname') + bcolors.ENDC)
        print("└──────────────────────────────────────────────────────────────────────────────┘")
        answ = input("Enter project name\t\t: ")
        if answ.lower() != "" and answ.lower() != checkConfig.get('general', 'projectname'):
            a = Configuration.changeValue('general', 'projectname', answ.lower())
        directory = (
                os.getcwd() + "/" + checkConfig.get('general', 'resultdirectory') + "/" + answ.lower()).replace(
            '\\', '/')
        if os.path.exists(directory) and answ.lower() != "":
            print(bcolors.OKGREEN, "Project found in " + directory), bcolors.ENDC
            sleep(1)
        elif not os.path.exists(directory):
            checkConfig.read(configFile)
            print("\n{3}Directory not found!{2}\nDo you want to create {1}{0}{2} named project directory?".format(
                checkConfig['general']['projectname'], bcolors.UNDERLINE, bcolors.ENDC, bcolors.FAIL))
            answer = input('y/n\t: ')
            if answer.lower() == 'y':
                os.mkdir(directory)
                print("{1}Directory created successfully!\nCheck directory\t: {0}{2}".format(directory, bcolors.OKGREEN,
                                                                                             bcolors.ENDC))
                sleep(2)
            elif answer.lower() == 'n':
                Configuration.changeValue('general', 'projectname', a)
                print("Previous value setted..")
                print("Returning to main menu")
                sleep(2)
            return False


class Tools:
    @staticmethod
    def cleanDuplicated():
        configrator = configparser.ConfigParser()
        configrator.read(configFile)
        try:
            liste = list()
            with open("{}/{}/bingsearch.txt".format(configrator.get('general', 'resultdirectory'),
                                                    configrator.get('general', 'projectname')), "r+",
                      errors='ignore') as file:
                for i in file.readlines():
                    i.replace('\n', '')
                    liste.append(i)
                liste = set(liste)
                file.seek(0)
                for i in liste:
                    file.writelines(i)
                file.truncate()
        except:
            pass

    @staticmethod
    def cleanresults():
        configrator = configparser.ConfigParser()
        configrator.read(configFile)
        try:
            with open("{}/{}/bingsearch.txt".format(configrator.get('general', 'resultdirectory'),
                                                    configrator.get('general', 'projectname')), "w",
                      errors='ignore') as file:
                file.write("")
                print("results cleaned successfully!")
                time.sleep(1)
        except:
            pass

    @staticmethod
    def bingDorkFinder():
        configrator = configparser.ConfigParser()
        configrator.read(configFile)
        answer = input("(Bing) | Enter the word you want to search for\t: ")
        try:
            listPerpage = "+&count=50&first="
            sequence = range(1, 1031, 10)
            counter = 0
            for pageNumber in str(sequence):
                counter += 1
                print("{}. page getting...".format(counter))
                response = requests.get("https://bing.com/search?q=" + answer + listPerpage + pageNumber)
                soup = bs4.BeautifulSoup(response.content, 'lxml')
                baseclass = soup.find_all("li", attrs={"class": "b_algo"})
                file = open("{}/{}/bingsearch.txt".format(configrator.get('general', 'resultdirectory'),
                                                          configrator.get('general', 'projectname')), "a+",
                            errors='ignore')
                for i in baseclass:
                    names = i.a.text
                    urls = i.a['href']
                    file.writelines(urls + "\n")
                    print("{4}Url:{3} {2}{0}{3} {4}\nContent:{3} {5}{1}{3}\n".format(urls, names, bcolors.CVIOLET,
                                                                                     bcolors.CBLUE, bcolors.CBLUE,
                                                                                     bcolors.CVIOLET))

            print("Multiple links are deleting..")
            Tools.cleanDuplicated()
            print("Multiple links deleted!")
            print("Scan completed & saved to results file. Please check..")
            sleep(1)
            file.close()

        except requests.exceptions.RequestException:
            print("There is no connection, please check internet connection")
        except Exception as err:
            print("There is an error occured!", err)

    @staticmethod
    def yandexDorkFinder():
        headers_param = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36"
        }
        configrator = configparser.ConfigParser()
        configrator.read(configFile)
        answer = input("(Yandex) | Enter the word you want to search for\t: ")
        for x in range(0, 20):
            url = ("https://yandex.com.tr/search/?lr=11501&text={}&p={}".format(answer, x))
            istek = requests.get(url, headers=headers_param)
            soup = bs4.BeautifulSoup(istek.content, "lxml")
            for i in soup.findAll("div", {"class": "organic"}):
                urls = i.a['href']
                print("Url found -> ", urls)
                with open("{}/{}/yandexsearch.txt".format(configrator.get('general', 'resultdirectory'),
                                                          configrator.get('general', 'projectname')), "a+",
                          errors='ignore') as f:
                    f.write(urls + "\n")
        print("Results are saved to project directory!")
        sleep(1)

    cf = configparser.ConfigParser()
    cf.read(configFile)

    @staticmethod
    def adminFinder():
        cnf = configparser.ConfigParser()
        cnf.read(configFile)
        siteUrl = input("Press [1] to continue with {}\n(e.g.http://targeturl.com/)\nEnter url or 1\t: ".format(
            cnf.get('general', 'siteurl')))
        if siteUrl.lower() == "1":
            pass
        elif siteUrl != "":
            Configuration.changeValue('general', 'siteurl', siteUrl)
        else:
            print("Try again..")

        updateProxy = input("Do you want to update proxies?(y/n)\t: ")
        if updateProxy.lower() == "y":
            Configuration.download("proxy")
        elif updateProxy.lower() == "n":
            print("Be careful. Proxies will not work. If Admin panel finder doesn't work, please up-to-date proxies...")
        else:
            print("Try again...")

        usersAgents = fileSettings(userAgentList).readSomething()
        proxies2 = fileSettings(proxyList).readSomething()
        dirs = cnf.get('general', 'cwordlist')

        siteWCounter = 0
        conf = configparser.ConfigParser()
        conf.read(configFile)
        with open("{}".format(conf.get('general', 'cwordlist')), "r") as fill:
            for i in fill:
                prx = {"http": "http://{}".format(random.choice(proxies2))}
                headers_param = {"User-Agent": "{}".format(random.choice(usersAgents))}
                url = conf.get('general', 'siteurl') + i.replace('\n','')
                try:
                    session = requests.Session()
                    retry = Retry(connect=3, backoff_factor=0.5)
                    adapter = HTTPAdapter(max_retries=retry)
                    session.mount('http://', adapter)
                    session.mount('https://', adapter)
                    istek = session.get("{}".format(url), headers=headers_param, proxies=prx)
                except Exception as err:
                    print(err)
                    pass
                #print("Proxy: {}\nStatus Code: {}\n Headers: {}\nUrl: {}".format(prx, istek.status_code, headers_param,url))
                if (istek.status_code == 200) or (300 < istek.status_code < 400):
                    print(bcolors.FAIL, "Admin panel found: {}".format(url))
                    with open("{}/{}/adminpanelfinder.txt".format(conf.get('general', 'resultdirectory'),
                                                                  conf.get('general', 'projectname')), 'a+') as fills:
                        if siteWCounter != 1:
                            fills.write("\n\n"
                                                          + '\n------------------------------------------------------------------------\n' + 'Domain:\t' + conf.get('general','siteurl') + '\nWordlist: ' + conf.get('general','cwordlist') +'\t \n------------------------------------------------------------------------')
                            siteWCounter += 1
                        fills.write('\n' + url)
                else:
                    print(bcolors.OKBLUE, "[-]==>Scanning Url: {}".format(url))
        print("\n Scans completed! Please check project folder...")
        sleep(2)
    @staticmethod
    def cmsfinder():
        cpsettings = configparser.ConfigParser()
        cpsettings.read(configFile)
        siteUrl = input(
            "\n\n\n\n\nb: Back\nPress [1] to continue with: [{}]\t(Example: https://targeturl.com)\nEnter url or 1\t:".format(
                cpsettings.get('general', 'siteurl')))
        if siteUrl.lower() == "b":
            pass
        elif siteUrl.lower() == "1":
            siteUrl = cpsettings.get('general', 'siteUrl')
            print(siteUrl)
        elif siteUrl != "":
            Configuration.changeValue('general', 'siteurl', siteUrl)
        else:
            print("Try again..")
        try:
            headers = requests.utils.default_headers()
            headers.update(
                {'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0'})
            r = requests.post(siteUrl, headers)
            a = r.headers
            print("[+]---Php Version  ==>>{}".format((a.get("X-Powered-By"))))
            print("[+]---Server Information ==>>{}".format((a.get("Server"))))
            soup = bs4.BeautifulSoup(r.text, "lxml")
            for i in soup.findAll("meta", {"name": "generator"}):
                print("[+]--Cms version found ==>{}".format(i["content"]))
                with open("{}/{}/cmsversion.txt".format(cpsettings.get('general', 'resultdirectory'),
                                                        cpsettings.get('general', 'projectname')), "a+",
                          errors='ignore') as file:
                    file.write("\n{}".format(cpsettings.get('general', 'siteurl') + "\n" + i['content']))
            sleep(3)
        except Exception as err:
            print(err)

    @staticmethod
    def ipHistory():
        cnf = configparser.ConfigParser()
        cnf.read(configFile)
        usersAgents = fileSettings(userAgentList).readSomething()
        print("e.g: https://google.com")
        siteUrl = input(" Press [1] to continue with {}\nEnter url or 1\t: ".format(cnf.get('general', 'siteurl').replace('https://','').rstrip('/')))
        if siteUrl.lower() == "1":
            pass
        elif siteUrl != "":
            Configuration.changeValue('general', 'siteurl', siteUrl)
        else:
            print("Try again..")
        randomUserAgent = random.choice(usersAgents)
        headers = {
            'User-Agent': '{}'.format(randomUserAgent)
        }
        session = requests.Session()
        retry = Retry(connect=3, backoff_factor=0.5)
        adapter = HTTPAdapter(max_retries=retry)
        session.mount('http://', adapter)
        session.mount('https://', adapter)
        conf = configparser.ConfigParser()
        conf.read(configFile)
        url = "https://viewdns.info/iphistory/?domain={}".format(cnf.get('general', 'siteurl').replace('https://','').rstrip('/'))
        r = requests.get(url, headers=headers)
        soup = bs4.BeautifulSoup(r.text, "lxml")
        findTable = soup.find_all("table", attrs={"border": "1"})
        counter = 4
        siteWCounter = 0
        for i in findTable:
            find_td = i.find_all('td')
            parse_td = [x.text.strip() for x in find_td]
            while counter <= len(find_td):
                res = "{}\t | {}\t | {}".format(parse_td[counter], parse_td[counter + 3], parse_td[counter + 2])
                print("[+]Founds : ", res)
                with open("{}/{}/iphistory.txt".format(conf.get('general', 'resultdirectory'),
                                                       conf.get('general', 'projectname')), 'a+',
                          errors='ignore') as fills:
                    if siteWCounter != 1:
                        fills.write("\n\n" + conf.get('general',
                                                      'siteurl') + '\n------------------------------------------------------------------------\n' + 'Ip\t\t | Last seen IP\t | Owner\n------------------------------------------------------------------------')
                        siteWCounter += 1
                    fills.write('\n' + res)

                counter += 4
                if counter == len(parse_td):
                    break

        print("Scans completed. Results are saved to project directory!..")
        sleep(3)

    @staticmethod
    def reverseIP():
        cnf = configparser.ConfigParser()
        cnf.read(configFile)
        usersAgents = fileSettings(userAgentList).readSomething()
        siteUrl = input(" Enter IP adress:(e.g:123.456.789.012)\t: ")
        if siteUrl != "":
            Configuration.changeValue('general', 'siteurl', siteUrl)
        else:
            print("Try again..")
        randomUserAgent = random.choice(usersAgents)
        headers = {
            'User-Agent': '{}'.format(randomUserAgent)
        }
        session = requests.Session()
        retry = Retry(connect=3, backoff_factor=0.5)
        adapter = HTTPAdapter(max_retries=retry)
        session.mount('http://', adapter)
        session.mount('https://', adapter)
        conf = configparser.ConfigParser()
        conf.read(configFile)
        url = "https://viewdns.info/reverseip/?host={}&t=1".format(conf.get('general', 'siteurl'))
        r = requests.get(url, headers=headers)
        soup = bs4.BeautifulSoup(r.text, "lxml")
        findTable = soup.find_all("table", attrs={"border": "1"})
        counter = 2
        siteWCounter = 0
        for i in findTable:
            find_td = i.find_all('td')
            parse_td = [x.text.strip() for x in find_td]
            while counter <= len(find_td):
                res = "{}\t | {}\t".format(parse_td[counter], parse_td[counter + 1])
                print("[+]Founds : ", res)
                with open("{}/{}/reversip.txt".format(conf.get('general', 'resultdirectory'),
                                                      conf.get('general', 'projectname')), 'a+',
                          errors='ignore') as fills:
                    if siteWCounter != 1:
                        fills.write("\n\n" + conf.get('general',
                                                      'siteurl') + '\n------------------------------------------------------------------------\n' + 'Domain\t\t | Last Resolved Date\n------------------------------------------------------------------------')
                        siteWCounter += 1
                    fills.write('\n' + res)

                counter += 2
                if counter == len(parse_td):
                    break

        print("Scans completed. Results are saved to project directory!..")
        sleep(3)

    @staticmethod
    def proxyList():
        print("Proxy list updating!")
        urlLink = "https://free-proxy-list.net/"
        try:
            page = requests.get(urlLink)
            soup = bs4.BeautifulSoup(page.content, "html.parser")
            table = soup.find_all('table', attrs={'id': 'proxylisttable'}) and soup.table.find('tbody')
        except Exception as err:
            print("Please check the web site", err)

        data = []
        counter = 0
        for row in table:
            cols = row.find_all('td')
            cols = [x.text.strip() for x in cols]
            data.append([x for x in cols if x])
            del data[counter][2:8]
            data[counter] = ['{}:{}'.format(data[counter][0], data[counter][1])]
            counter += 1
        try:
            fileName = "proxy.txt"
            with open(fileName, "r+") as file:
                for i in data:
                    i = ''.join(i)
                    file.writelines(str(i) + "\n")
        except Exception as err:
            print(err)
        print(
            "{} proxy found in free-proxy-list.net\nProxies saved to {}  and updated.".format(len(data), fileName))
        sleep(3)
        return data

    @staticmethod
    def pageview():
        print("This tools requires up-to-date proxy.")
        Tools.proxyList()
        ques = Queue()
        uAgent = fileSettings(userAgentList).readSomething()
        proxies = fileSettings(proxyList).readSomething()
        page_cnf = configparser.ConfigParser()
        page_cnf.read(configFile)

        siteUrl = input(" Press [1] to continue with {}\nEnter url or 1\t: ".format(page_cnf.get('general', 'siteurl')))
        if siteUrl.lower() == "1":
            pass
        elif siteUrl != "":
            Configuration.changeValue('general', 'siteurl', siteUrl)
        else:
            print("Try again..")
        threadNumber = input("Number of thread(Recommend:50 | Max: 500)\t: ")
        if not threadNumber.isnumeric():
            print("Thread number should be numeric. Check and try again.")
            sleep(2)
        elif threadNumber == "":
            Configuration.changeValue("general", "threadnumber", "50")
            print("Thread number is setted : 500")
        elif 0 < int(threadNumber) <= 500:
            Configuration.changeValue("general", "threadnumber", threadNumber)
        else:
            print("Try again..")
            sleep(1)

        def viewer(que):
            while True:
                try:
                    randomUserAgent = random.choice(uAgent)
                    headers = {
                        'User-Agent': '{}'.format(randomUserAgent)
                    }
                    prx = {'https': 'https://{}'.format(que.get())}
                    session = requests.Session()
                    retry = Retry(connect=3, backoff_factor=0.5)
                    adapter = HTTPAdapter(max_retries=retry)
                    session.mount('http://', adapter)
                    session.mount('https://', adapter)
                    conf = configparser.ConfigParser()
                    conf.read(configFile)
                    url = "https://www.younow.com/iremyeniayy"
                    requests.get(url, headers=headers, proxies=prx)


                except Exception as err:
                    que.task_done()
                    # print("Response:" + r.status_code)

        for i in range(int(page_cnf.get('general', 'threadnumber'))):
            thread_new = threading.Thread(target=viewer, args=(ques,), daemon=True)
            thread_new.start()

            print(thread_new.name + ". started")
        print("Wait... This process will take 5-10 minutes..")
        for secilenProxy in proxies:
            ques.put(secilenProxy)

        ques.join()
