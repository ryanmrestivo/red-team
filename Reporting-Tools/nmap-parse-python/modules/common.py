from colorama import Fore, Style
import os, random, re, textwrap
import argparse
import ipaddress
import shlex

import re
import cmd2
import cmd2_submenu
import tabulate

from modules import constants
from modules import settings
from modules import helpers
from modules import nmap

class TextOutput():
    def __init__(self):
        self.entries = []
    
    def addMain(self, text):
        self.entries.append(TextOutputEntry(text, constants.TEXT_NORMAL, Fore.RESET))
    
    def addHumn(self, text):
        self.entries.append(TextOutputEntry(text, constants.TEXT_FRIENDLY, Style.DIM))
    
    def addErrr(self, text):
        self.entries.append(TextOutputEntry(text, constants.TEXT_ERROR, Fore.RED))
    
    def addGood(self, text):
        self.entries.append(TextOutputEntry(text, constants.TEXT_SUCCESS, Fore.GREEN))

    def printToConsole(self):
        for line in self.entries:
            shouldPrint = False
            if(line.output == constants.TEXT_NORMAL or line.output == constants.TEXT_ERROR):
                shouldPrint = True
            elif(settings.printHumanFriendlyText):
                shouldPrint = True
            
            if shouldPrint:
                print(line.getText())

class TextOutputEntry():
    # Output specified the type of output for the text
    #   0 - Main output
    #   1 - Unnecessary but friendly output (e.g. headings)
    #   2 - Error output
    #   3 - Success/Good output
    def __init__(self, text, output, colour):
        self.text = text
        self.output = output
        self.colour = colour

    def getText(self):
        if settings.colourSupported:
            return "%s%s%s" % (self.colour, self.text, Style.RESET_ALL)
        else:
            return self.text
            
class TerminalBase(cmd2.Cmd):
    CMD_CAT_FILTER = "Configure Filters"
    
    service_filter = ''
    port_filter = ''
    host_filter = ''
    include_ports = True
    have_ports = True
    only_alive = True
    verbose = True
    raw = False

    have_ports_changed = False

    nmapOutput = None

    userOptions = [
        [constants.OPT_SERVICE_FILTER, "string", "", "Comma seperated list of services to show, e.g. \"http,ntp\""],
        [constants.OPT_PORT_FILTER, "string", "", "Comma seperated list of ports to show, e.g. \"80,123\""],
        [constants.OPT_HOST_FILTER, "string","", "Comma seperated list of hosts to show, e.g. \"127.0.0.1,127.0.0.2\""],
        [constants.OPT_ALIVE, "bool","True", "When enabled, any hosts which were down will be excluded from output  [ True / False ]"],
        [constants.OPT_HAVE_PORTS, "bool","True", "When enabled, hosts with no open ports are excluded from output  [ True / False ]"],
        [constants.OPT_INCLUDE_PORTS, "bool","True", "Toggles whether ports are included in 'list/services' output  [ True / False ]"],
        [constants.OPT_VERBOSE, "bool", "True", "Shows verbose service information  [ True / False ]"],
        [constants.OPT_RAW, "bool", "False", "Shows raw output (no headings)  [ True / False ]"]
    ]

    userOptionChanged = {
        constants.OPT_SERVICE_FILTER : False,
        constants.OPT_PORT_FILTER: False,
        constants.OPT_HOST_FILTER: False,
        constants.OPT_HAVE_PORTS: False,
        constants.OPT_ALIVE: False,
        constants.OPT_INCLUDE_PORTS: False,
        constants.OPT_VERBOSE: False,
        constants.OPT_RAW: False
    }

    allow_cli_args = False
    
    cmd2.categorize(cmd2.Cmd.do_set, CMD_CAT_FILTER)

    def __init__(self, *args, **kwargs):
        self.setupUserOptions()
        super().__init__(*args, **kwargs)
        self.register_postcmd_hook(self.postCmdHook)

    # Use this to check if the set command was used and do our own internal logic 
    # in addition to cmd2's logic
    def postCmdHook(self, data: cmd2.plugin.PostcommandData) -> cmd2.plugin.PostcommandData:
        if data.statement.command == 'set' and len(data.statement.args.split()) == 2:
            tmpOption = data.statement.args.split()[0] 
            tmpValue = data.statement.args.split()[1]
            for option in self.userOptions:
                if(tmpOption.lower() == option[0]):
                    self.setOption(option[0], tmpValue)
                    break
        return data

    def setupUserOptions(self):
        for userOption in self.userOptions:
            self.settable[userOption[0]] = userOption[3]
    
    def do_exit(self, inp):
        '''Exit the interactive prompt'''
        print("Bye")
        return True

    @cmd2.with_category(CMD_CAT_FILTER)
    def do_unset_all(self, inp):
        '''"unset_all" will reset all user options to default values'''
        consoleOutput = TextOutput()
        for option in [option[0] for option in self.userOptions]:
            if(self.unsetOption(option)):
                consoleOutput.addHumn("Unset [" + option + "] ==> " + str(self.getOption(option)))
            else:
                consoleOutput.addErrr("Failed to unset [%s]" % option)
        self.printTextOutput(consoleOutput)

    @cmd2.with_category(CMD_CAT_FILTER)
    def do_unset(self, inp):
        '''"unset [option]" will unset the specified user option'''
        splitText = inp.split()
        if(len(splitText) != 1):
            print ("Invalid use of unset command")
        else:
            success = self.unsetOption(splitText[0].lower())  
            if(success):
                print("Unset [" + splitText[0].lower() + "] ==> ''")

    def complete_show(self, text, line, begidx, endidx):
        return ['options']

    @cmd2.with_category(CMD_CAT_FILTER)
    def do_show(self, inp):
        '''"show options" will list current user options'''
        self.syncOptions()
        if(inp.lower() == 'options'):
            self.poutput('')
            self.poutput(tabulate.tabulate(self.userOptions, headers=['Setting', "Type", 'Value', 'Description'], tablefmt="github"))
            self.poutput('')
        else:
            self.poutput('"show options" will list current user options')
 
    
    def complete_set(self, text, line, begidx, endidx):
        # remove 'set' from first array slot
        splitText = line.split()[1:]
        if(line.strip() == 'set'):
            return [option for option in self.settable]
        if(len(splitText) == 1):
            return [option for option in self.settable if option.startswith(splitText[0].lower()) and not (option == splitText[0].lower())]
        if(len(splitText) == 2):
            if splitText[0] == constants.OPT_SERVICE_FILTER:
                # need to split this value on comma incase user specified more than one service
                # then use last split. Also remove quotes
                tmpText = splitText[1].replace("\"","")
                tmpServices = tmpText.split(',')
                curService = tmpServices[-1:][0]
                prefix = ''
                if len(tmpServices) > 1:
                    prefix = ','.join(tmpServices[:-1]) + ','
                return self.tryMatchService(curService, prefix)
            elif splitText[0] == constants.OPT_HOST_FILTER:
                # need to split this value on comma incase user specified more than one IP
                # then use last split. Also remove quotes
                tmpText = splitText[1].replace("\"","")
                tmpHosts = tmpText.split(',')
                curHost = tmpHosts[-1:][0]
                prefix = ''
                if len(tmpHosts) > 1:
                    prefix = ','.join(tmpHosts[:-1]) + ','
                return [(prefix + ip) for ip in self.nmapOutput.Hosts if curHost in ip]
        return [text]

    def unsetOption(self, option):
        if(option == constants.OPT_HAVE_PORTS):
            self.have_ports = True
        elif(option == constants.OPT_HOST_FILTER):
            self.host_filter = ''
        elif(option == constants.OPT_PORT_FILTER):
            self.port_filter = ''
        elif(option == constants.OPT_RAW):
            self.raw = False
        elif(option == constants.OPT_SERVICE_FILTER):
            self.service_filter = ''
        elif(option == constants.OPT_VERBOSE):
            self.verbose = True
        elif(option == constants.OPT_INCLUDE_PORTS):
            self.include_ports = True
        elif(option == constants.OPT_ALIVE):
            self.alive = True
        else:
            return False
        return True

    def perror(self, message):
        super(TerminalBase, self).perror(message, traceback_war=False)

    def setOption(self, specifiedOption, value):
        for option in self.userOptions:
            if option[0] == specifiedOption.lower():
                self.userOptionChanged[option[0]] = True
                if (option[1] == "bool"):
                    self.setBoolOption(option, specifiedOption, value)
                elif(option[0] == constants.OPT_HOST_FILTER):
                    self.setHostFilter(option, value.replace('"', ''))
                else:
                    option[2] = value.replace('"', '')

    def setHostFilter(self, option, userFilter):
        tmpHostFilter = helpers.stringToHostFilter(userFilter.replace('"', ''))
        filterString = ','.join([filter.filter for filter in tmpHostFilter])
        option[2] = filterString
        self.host_filter = filterString

    def setBoolOption(self, cmdOption, userOption, value):
        tmpValue = value.lower().strip()
        result = (tmpValue in constants.TRUE_STRINGS)
        cmdOption[2] = str(result)
        if(cmdOption[0] == constants.OPT_RAW):
            settings.printHumanFriendlyText = not result

    def getOptionBool(self, specifiedOption):
        return "True" == self.getOption(specifiedOption)

    def syncOptions(self):
        for option in self.userOptions:
            if(option[0] == constants.OPT_HAVE_PORTS):
                option[2] = self.have_ports
            elif(option[0] == constants.OPT_HOST_FILTER):
                option[2] = self.host_filter
            elif(option[0] == constants.OPT_PORT_FILTER):
                option[2] = self.port_filter
            elif(option[0] == constants.OPT_RAW):
                option[2] = self.raw
            elif(option[0] == constants.OPT_SERVICE_FILTER):
                option[2] = self.service_filter
            elif(option[0] == constants.OPT_VERBOSE):
                option[2] = self.verbose
            elif(option[0] == constants.OPT_INCLUDE_PORTS):
                option[2] = self.include_ports
            elif(option[0] == constants.OPT_ALIVE):
                option[2] = self.only_alive

    def getOption(self, specifiedOption):
        for option in self.userOptions:
            if(option[0] == specifiedOption.lower()):
                return option[2]
    
    def getPortFilter(self):
        portFilter = []
        rawPortFilterString = self.port_filter
        # Check only contains valid chars
        if(re.match(r'^([\d\s,]+)$', rawPortFilterString)):
            # Remove any excess white space (start/end/between commas)
            curPortFilterString = re.sub(r'[^\d,]', '', rawPortFilterString)
            # Split filter on comma, ignore empty entries and assign to filter
            portFilter = [int(port) for port in curPortFilterString.split(',') if len(port) > 0]
        return portFilter
    
    def getHostFilter(self):
        return helpers.stringToHostFilter(self.host_filter)
    
    def getServiceFilter(self):
        return [option for option in self.service_filter.split(',') if len(option.strip()) > 0]
    
    def getFilters(self):
        filters = nmap.NmapFilters()
        filters.services = self.getServiceFilter()
        filters.ports = self.getPortFilter()
        filters.hosts = self.getHostFilter()
        filters.onlyAlive = self.only_alive
        filters.mustHavePorts = self.have_ports
        return filters

    def printTextOutput(self, textOutput):
        for line in textOutput.entries:
            if(line.output == constants.TEXT_NORMAL):
                self.poutput(line.getText())
            elif(line.output == constants.TEXT_ERROR):
                self.perror(line.getText())
            elif (not self.quiet) and (not self.redirecting) and settings.printHumanFriendlyText:
                if(line.output == constants.TEXT_FRIENDLY):
                    self.pfeedback(line.getText())
                elif(line.output == constants.TEXT_SUCCESS):
                    self.pfeedback(line.getText())
                else:
                    self.poutput(line.getText())

    def tryMatchService(self, text, prefix):
        matches = []
        try:
            serviceFiles = ['/usr/share/nmap/nmap-services', '/etc/services', 'C:\\windows\\system32\\drivers\\etc\\services']
            for serviceFile in serviceFiles:
                if(os.path.isfile(serviceFile)):
                    fhServices = open(serviceFile, 'r')
                    tmpRegex = '(' + text + r'\S*)\s+\d+/(?:tcp|udp)'
                    reg = re.compile(tmpRegex)
                    for line in fhServices:
                        matches += [match for match in reg.findall(line) if match not in matches]
                    fhServices.close()
                    break
        except:
            raise
        return [(prefix + match) for match in matches]

    def splitInput(self, line, curCmd):
        splitInput = []
        try:
            splitInput = [option for option in shlex.split(line[line.index(curCmd) + len(curCmd):].strip(), posix=False)]
        except ValueError:
            # Append quote to string to prevent exception
            splitInput = [option for option in shlex.split((line[line.index(curCmd) + len(curCmd):]+'"').strip(), posix=False)]
        return splitInput

class SubTerminalBase(TerminalBase):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
    
    def do_exit(self, inp):
        '''Return to parent prompt'''
        return True
    
    def do_back(self, inp):
        '''Return to parent prompt'''
        return True