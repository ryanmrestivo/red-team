import threading
import tabulate
import argparse
import requests
import urllib3
import getpass
import shlex
import json
import cmd2
import time
import re
import os

from modules import common
from modules import helpers
from modules import constants

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class NessusTerminal(common.SubTerminalBase):
    """To interact with nessus instance"""

    CMD_CAT_NESSUS = "Nessus Commands"
    policyChoices = {}

    allow_cli_args = False

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.prompt = 'nessus'
        self.nessus = Nessus()
        self.userPolcies = []
        self.defaultTemplates = []

    @cmd2.with_category(CMD_CAT_NESSUS)
    def do_login(self, inp):
        '''Authenticate and retreive session'''
        success = self.nessus.promptUserForCredentials()
        if success:
            self.pfeedback("Successfully authenticated with Nessus")
        else:
            self.perror("Failed to authenticate with Nessus")

    @cmd2.with_category(CMD_CAT_NESSUS)
    def do_scans(self, inp):
        '''List scans from nessus'''
        try:
            self.nessus.ensureSessionValid()
            self.poutput(tabulate.tabulate([scan.getSummary() for scan in self.nessus.getScans()], headers=['ID', 'Scan Name', 'Status'], tablefmt="github"))
        except NessusAuthError:
            self.perror("Nessus authentication failed")

    @cmd2.with_category(CMD_CAT_NESSUS)
    def do_create(self, inp):
        '''Create a new nessus scan\n
        Usage: create [options] [policy] [folder] [name]
          -u / --user-policy\tIf specified, create new scan based off user defined policy else use built-in template
          [policy]\tThe name of the nessus policy to use (tab complete)
          [folder]\tThe name of the nessus folder to store scan (tab complete)
          [name]\tThe name for the new scan'''
        self.nessus.ensureSessionValid()
        userPolicy = '-u' in inp.arg_list or '--user-policy' in inp.arg_list
        options = inp.arg_list
        if (len(options) == 3 and not userPolicy) or (len(options) == 4 and userPolicy):
            scanName = options[-1].replace('"','')
            folderName = options[-2].replace('"','')
            policyName = options[-3].replace('"','')
            success = self.nessus.createScan(scanName, policyName, folderName, self.getUserSettings())
            if(success):
                self.pfeedback("Successfully created scan: " + policyName)
            else:
                self.pfeedback("Failed to create scan: " + policyName)
        else:
            self.perror("Invalid arguments supplied, run 'help create' to see usage")
    
    # Enable tab completion for policy name
    def complete_create(self, text, line, begidx, endidx):
        userPolicy = '-u' in line
        curCmd = 'create'
        if(curCmd not in line):
            return [text]
        trailingSpace = line[-1] == ' '
        options = [option for option in self.splitInput(line, curCmd) if '-u' not in option]
        # Only try complete if less than 4 options as this should be the max specified:
        # E.g. ['policyName', 'folderName', 'scanName']
        optLen = len(options)
        if(optLen >= 4):
            return [text]
        else:
            if(not self.nessus.checkSessionValid()):
                self.perror("Invalid session, please login")
                return [text]
            self.nessus.ensurePoliciesLoaded()
            # If setting policy
            if(optLen == 0 or (not trailingSpace and optLen == 1)):
                if(userPolicy):
                    return [policy.name for policy in self.nessus.userPolicies if policy.name.lower().startswith(text.lower())]
                else:
                    return [template.title for template in self.nessus.defaultPolicies if template.title.lower().startswith(text.lower())]
            # If setting folder name
            elif(optLen == 1 or (not trailingSpace and optLen == 2)):
                return [folder.name for folder in self.nessus.folders if folder.name.lower().startswith(text.lower())]
            else:
                return [text]
                
    @cmd2.with_category(CMD_CAT_NESSUS)
    def do_download_folder(self, inp):
        '''Download all nessus scans in folder\n
        Usage: download_folder [folder] [format] [output_directory]
          [folder]\tThe name of the nessus folder to download (tab complete)
          [format]\tOutput format to download (tab complete)
          [output_directory]\tThe location to download the scan to'''
        self.nessus.ensureSessionValid()
        options = inp.arg_list
        if len(options) == 3:
            folderName = options[0].replace('"','')
            exportFormat = options[1].replace('"','')
            outputDirectory = options[2].replace('"','')
            success = self.nessus.downloadFolder(folderName, exportFormat, outputDirectory)
            if(success):
                self.pfeedback("Successfully downloaded folder: " + folderName)
            else:
                self.pfeedback("Failed to download folder: " + folderName)
        else:
            self.perror("Invalid arguments supplied, run 'help download_folder' to see usage")
    
    # Enable tab completion for policy name
    def complete_download_folder(self, text, line, begidx, endidx):
        curCmd = 'download_folder'
        if(curCmd not in line):
            return [text]
        trailingSpace = line[-1] == ' '
        options = self.splitInput(line, curCmd)
        # Only try complete if less than 4 options as this should be the max specified:
        # E.g. ['folder', 'format', 'output_directory']
        optLen = len(options)
        if(optLen >= 4):
            return [text]
        else:
            if(not self.nessus.checkSessionValid()):
                self.perror("Invalid session, please login")
                return [text]
            # If setting policy
            if(optLen == 0 or (not trailingSpace and optLen == 1)):
                return [folder.name for folder in self.nessus.folders if folder.name.lower().startswith(text.lower())]
            # If setting folder name
            elif(optLen == 1 or (not trailingSpace and optLen == 2)):
                return [exportType for exportType in constants.EXPORT_FORMATS if exportType.lower().startswith(text.lower())]
            else:
                try:
                    return self.path_complete(text, line, begidx, endidx, path_filter=os.path.isdir)
                except:
                    return [text]

    @cmd2.with_category(CMD_CAT_NESSUS)
    def do_download(self, inp):
        '''Download a nessus scan\n
        Usage: download [format] [scan] [output_directory]
          [format]\tOutput format to download (tab complete)
          [scan]\tThe name of the nessus scan to download (tab complete)
          [output_directory]\tThe location to download the scan to'''
        self.nessus.ensureSessionValid()
        options = inp.arg_list
        if len(options) == 3:
            exportFormat = options[0].replace('"','')
            scanName = options[1].replace('"','')
            outputDirectory = options[2].replace('"','')
            success = self.nessus.downloadScan(scanName, exportFormat, outputDirectory)
            if(success):
                self.pfeedback("Successfully downloaded scan (%s) to: %s" % (scanName, outputDirectory))
            else:
                self.pfeedback("Failed to download scan: " + scanName)
        else:
            self.perror("Invalid arguments supplied, run 'help download' to see usage")
    
    def complete_download(self, text, line, begidx, endidx):
        curCmd = 'download'
        if(curCmd not in line):
            return [text]
        trailingSpace = line[-1] == ' '
        options = self.splitInput(line, curCmd)
        # Only try complete if less than 4 options as this should be the max specified:
        # E.g. ['format', 'scan', 'output_dir']
        optLen = len(options)
        if(optLen >= 4):
            return [text]
        else:
            if(not self.nessus.checkSessionValid()):
                self.perror("Invalid session, please login")
                return [text]
            self.nessus.ensurePoliciesLoaded()
            # If setting export type
            if(optLen == 0 or (not trailingSpace and optLen == 1)):
                return [exportType for exportType in constants.EXPORT_FORMATS if exportType.lower().startswith(text.lower())]
            # If setting scan name
            elif(optLen == 1 or (not trailingSpace and optLen == 2)):
                return [scan.name for scan in self.nessus.getScans() if scan.name.lower().startswith(text.lower())]
            else:
                try:
                    return self.path_complete(text, line, begidx, endidx, path_filter=os.path.isdir)
                except:
                    return [text]

    def getUserSettings(self):
        userSettings = {}

        filters = self.getFilters()
        hosts = self.nmapOutput.getHosts(filters)
        portIds = self.nmapOutput.getUniquePortIds(filters=filters, hosts=hosts)

        userSettings['text_targets'] = "\n".join([host.ip for host in hosts])
        if(len(portIds) > 0):
            userSettings['portscan_range'] = ",".join([str(portId) for portId in portIds])
            userSettings["unscanned_closed"] = "yes"

        userSettings['ssl_prob_ports'] = "All ports"

        return userSettings

class Nessus():
    headers = {'Content-Type': 'application/json'}
    baseUrl = "https://localhost:8834"
    defaultPolicies = []
    userPolicies = []
    userScans = []
    folders = []

    lastRetrievedScans = 0

    def __init__(self):
        self.sessionToken = None

    def promptUserForCredentials(self):
        username = input("Nessus Username: ")
        password = getpass.getpass("Nessus Password: ")
        tmpNessusUrl = input("Nessus URL [%s]: " % self.baseUrl)
        if(len(tmpNessusUrl.strip()) > 0):
            self.baseUrl = tmpNessusUrl.strip()
        return self.login(username, password)

    def login(self, username, password):
        try:
            response = requests.post(self.baseUrl + '/session', headers=self.headers, data='{"username":"%s", "password":"%s"}' % (username, password), verify=False)
            if(response.status_code == 200):
                match = re.match(r'.*token":"([^"]+)"}\s*', response.text)
                if match:
                    self.sessionToken = match.group(1)
                    self.headers['X-Cookie'] = "token=" + self.sessionToken
                    
                    apiTokenThread = threading.Thread(target=self.getApiToken)
                    loadPolicyThread = threading.Thread(target=self.loadAllPolicies)
                    loadFoldersThread = threading.Thread(target=self.loadFolders)
                    
                    apiTokenThread.start() 
                    loadPolicyThread.start()
                    loadFoldersThread.start()
                    return True
            else:
                return False
        except Exception:
            #print("Failed to connect to or authenticate with nessus instance")
            return False
        return True

    def getApiToken(self):
        '''Retreive the nessus API token required to add scans'''
        response = self.get('/nessus6.js')
        match = re.search(r'key:"getApiToken",value:function\(\)\{return"([^"]+)', response.text)
        if(match):
            self.headers["X-API-Token"] = match.groups(1)[0]

    def ensureSessionValid(self):
        if self.sessionToken == None or not self.checkSessionValid():
            self.promptUserForCredentials()
    
    def checkSessionValid(self):
        try:
            response = self.get('/folders')
            if response.status_code == 200:
                return True
            else:
                self.sessionToken = None
                return False
        except NessusAuthError:
            return False

    def ensurePoliciesLoaded(self):
        if(len(self.defaultPolicies) == 0):
            self.loadAllPolicies()

    def loadAllPolicies(self):
        self.loadDefaultPolicies()
        self.loadUserPolicies()
    
    def loadDefaultPolicies(self):
        self.defaultPolicies.clear()
        templatesJson = self.getJsonValue('/editor/scan/templates', 'templates')
        for templateJson in templatesJson:
            self.defaultPolicies.append(NessusTemplate(templateJson))
        self.defaultPolicies.sort(key=lambda x: x.name)
    
    def loadUserPolicies(self):
        self.userPolicies.clear()
        userPoliciesJson = self.getJsonValue('/policies', 'policies')
        for policyJson in userPoliciesJson:
            tmpPolicy = NessusScanPolicyMetaData(policyJson)
            self.userPolicies.append(tmpPolicy)
        self.userPolicies.sort(key=lambda x: x.name)

    def loadFolders(self):
        self.folders.clear()
        foldersJson = self.getJsonValue('/folders', 'folders')
        for folderJson in foldersJson:
            tmpFolder = NessusFolder(folderJson)
            self.folders.append(tmpFolder)
        self.folders.sort(key=lambda x: x.name)

    def downloadFolder(self, folderName, exportFormat, outputDirectory):
        folderId = self.getFolderIdByName(folderName)
        if folderId == None:
            raise NessusInvalidFolderError()
        
        for scan in self.userScans:
            if scan.folder_id == folderId:
                helpers.hprint("Downloading %s" % scan.name)
                self.downloadScan(scan.name, exportFormat, outputDirectory)

        return True

    def downloadScan(self, scanName, exportFormat, outputDirectory):
        scanId = None
        for scan in self.userScans:
            if(scan.name.lower() == scanName.lower()):
                scanId = scan.id
                break
        if scanId == None:
            raise NessusInvalidScanError()

        requestDownloadUrl = "/scans/%s/export" % scanId
        jsonData = {"format":exportFormat}
        if(exportFormat in [constants.EXPORT_HTML, constants.EXPORT_PDF]):
            jsonData["chapters"] = "vuln_by_plugin"
        response = self.post(requestDownloadUrl, json.dumps(jsonData))

        if(response.status_code != 200):
            return False

        # Example response.text:
        #   {"token":"949359591a2d68815b5db75ca1481e650047312d4acbf00f20306a59938fd131","file":1381771953}
        
        # Extract token from response
        jsonData = json.loads(response.text)
        token = jsonData['token']

        # Download the file
        success = self.download('/tokens/%s/download' % token, outputDirectory)        
        return success

    def createFolder(self, folderName):
        jsonData = {}
        jsonData["name"] = folderName
        response = self.post("/folders", json.dumps(jsonData))
        if(response.status_code == 200):
            self.loadFolders()
            return self.getFolderIdByName(folderName)
        else:
            raise NessusInvalidFolderError()

    def getFolderIdByName(self, folderName):
        for folder in self.folders:
            if(folder.name.lower() == folderName.lower()):
                return folder.id
        return None

    def createScan(self, scanName, policyName, folderName, userSettings):
        templateId = None
        policyId = None
        if(policyName.lower() in [policy.name.lower() for policy in self.userPolicies]):
            for policy in self.userPolicies:
                if(policy.name.lower() == policyName.lower()):
                    templateId = 'ab4bacd2-05f6-425c-9d79-3ba3940ad1c24e51e1f403febe40' # ID for custom scan
                    policyId = policy.id
                    break
        else:
            for policy in self.defaultPolicies:
                if(policy.title.lower() == policyName.lower()):
                    templateId = policy.uuid
                    break
        if templateId == None:
            raise NessusInvalidPolicyError()

        folderId = self.getFolderIdByName(folderName)
        # Attempt to create folder if not exists
        if folderId == None:
            folderId = self.createFolder(folderName)
        if folderId == None:
            raise NessusInvalidFolderError()
                
        jsonData = {}
        jsonData["uuid"] = templateId
        
        settings = jsonData["settings"] = {}
        # Set defaults
        settings["attach_report"] = "no"
        settings["emails"] = ""
        settings["filter_type"] = "and"
        settings["filters"] = []
        settings["launch_now"] = False
        settings["enabled"] = False
        settings["live_results"] = ""
        settings["file_targets"] = ""
        settings["scanner_id"] = "1"
        settings["description"] = ""

        # Set main
        settings["name"] = scanName
        settings["folder_id"] = folderId
        if(policyId != None):
            settings["policy_id"] = policyId

        # Set scan settings
        for setting in userSettings:
            settings[setting] = userSettings[setting]
        # The above loop will set all additional settings
        # including text_targets and if applicable portRange
        
        response = self.post("/scans", json.dumps(jsonData))
        return response.status_code == 200

    def getScans(self):
        # Only download scans again if they have not been updated in last 10 seconds
        # Used to make tab completes more responsive and reduce requests
        if(int(time.time()) - self.lastRetrievedScans < 10):
            return self.userScans
        self.lastRetrievedScans = int(time.time())
        scans = []
        for scan in self.getJsonValue('/scans', 'scans'):
            scans.append(NessusScanMetaData(scan))
        self.userScans = scans
        return scans
    
    # Parse response output and return specified value
    def getJsonValue(self, url, value):
        response = self.get(url)
        jsonData = json.loads(response.text)
        return jsonData[value]

    def get(self, url):
        if(self.sessionToken == None):
            raise NessusAuthError("Session Token not set") 
        fullUrl = self.baseUrl + url
        response = requests.get(fullUrl, headers=self.headers, verify=False)
        return response

    def post(self, url, json):
        if(self.sessionToken == None):
            raise NessusAuthError("Session Token not set") 
        fullUrl = self.baseUrl + url
        response = requests.post(fullUrl, headers=self.headers, data=json, verify=False)
        return response

    def download(self, url, outputDirectory):
        try:
            # Wait until file has generated
            response = None
            while True:
                response = self.get(url)
                if 'Content-Disposition' in response.headers:
                    break
                else:
                    time.sleep(0.5)
            contentDisposition = response.headers.get('Content-Disposition')
            matches = re.findall("filename=(.+)", contentDisposition)
            fileName = matches[0].replace('"','').replace("'",'')
            fullFileName = os.path.join(outputDirectory, fileName)
            # Write response contents to file
            open(fullFileName, 'wb').write(response.content)
        except:
            return False
        return True

class NessusInvalidScanError(Exception):
    pass

class NessusInvalidFolderError(Exception):
    pass

class NessusInvalidPolicyError(Exception):
    pass
    
class NessusAuthError(Exception):
    pass

class NessusTemplate():
    def __init__(self, jsonData):
        self.unsupported = helpers.getJsonValue(jsonData, "unsupported")
        self.desc = helpers.getJsonValue(jsonData, "desc")
        self.subscription_only = helpers.getJsonValue(jsonData, "subscription_only")
        self.title = helpers.getJsonValue(jsonData, "title")
        self.is_agent = helpers.getJsonValue(jsonData, "is_agent")
        self.uuid = helpers.getJsonValue(jsonData, "uuid")
        self.manager_only = helpers.getJsonValue(jsonData, "manager_only")
        self.name = helpers.getJsonValue(jsonData, "name")

class NessusScanPolicyMetaData():
    def __init__(self, jsonData):
        self.is_scap = helpers.getJsonValue(jsonData, "is_scap")
        self.has_credentials = helpers.getJsonValue(jsonData, "has_credentials")
        self.no_target = helpers.getJsonValue(jsonData, "no_target")
        self.template_uuid = helpers.getJsonValue(jsonData, "template_uuid")
        self.description = helpers.getJsonValue(jsonData, "description")
        self.name = helpers.getJsonValue(jsonData, "name")
        self.owner = helpers.getJsonValue(jsonData, "owner")
        self.visibility = helpers.getJsonValue(jsonData, "visibility")
        self.shared = helpers.getJsonValue(jsonData, "shared")
        self.user_permissions = helpers.getJsonValue(jsonData, "user_permissions")
        self.last_modification_date = helpers.getJsonValue(jsonData, "last_modification_date")
        self.creation_date = helpers.getJsonValue(jsonData, "creation_date")
        self.owner_id = helpers.getJsonValue(jsonData, "owner_id")
        self.id = helpers.getJsonValue(jsonData, "id")

class NessusScanMetaData():
    def __init__(self, jsonData):
        self.folder_id = helpers.getJsonValue(jsonData, "folder_id")
        self.type = helpers.getJsonValue(jsonData, "type")
        self.read = helpers.getJsonValue(jsonData, "read")
        self.last_modification_date = helpers.getJsonValue(jsonData, "last_modification_date")
        self.creation_date = helpers.getJsonValue(jsonData, "creation_date")
        self.status = helpers.getJsonValue(jsonData, "status")
        self.uuid = helpers.getJsonValue(jsonData, "uuid")
        self.shared = helpers.getJsonValue(jsonData, "shared")
        self.user_permissions = helpers.getJsonValue(jsonData, "user_permissions")
        self.owner = helpers.getJsonValue(jsonData, "owner")
        self.timezone = helpers.getJsonValue(jsonData, "timezone")
        self.rrules = helpers.getJsonValue(jsonData, "rrules")
        self.starttime = helpers.getJsonValue(jsonData, "starttime")
        self.enabled = helpers.getJsonValue(jsonData, "enabled")
        self.control = helpers.getJsonValue(jsonData, "control")
        self.live_results = helpers.getJsonValue(jsonData, "live_results")
        self.name = helpers.getJsonValue(jsonData, "name")
        self.id = helpers.getJsonValue(jsonData, "id")
    
    def getSummary(self):
        return [self.id, self.name, self.status]

class NessusFolder():
    def __init__(self, jsonData):
        self.unread_count = helpers.getJsonValue(jsonData, "unread_count")
        self.custom = helpers.getJsonValue(jsonData, "custom")
        self.default_tag = helpers.getJsonValue(jsonData, "default_tag")
        self.type = helpers.getJsonValue(jsonData, "type")
        self.name = helpers.getJsonValue(jsonData, "name")
        self.id = helpers.getJsonValue(jsonData, "id")