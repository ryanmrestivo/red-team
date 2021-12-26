import os, random, re, textwrap
import argparse
import ipaddress
import tabulate

import cmd2
import cmd2_submenu

from cmd2 import Cmd, with_category, argparse_completer, with_argparser
from cmd2.argparse_completer import ACArgumentParser, ACTION_ARG_CHOICES, AutoCompleter
from typing import List

from modules import helpers
from modules import constants
from modules import settings
from modules import nessus
from modules import common
from modules import nmap

from modules.helpers import hprint, sprint, eprint, header

@cmd2_submenu.AddSubmenu(nessus.NessusTerminal(),
    command='nessus',
    aliases=(),
    reformat_prompt = '\n\033[4m\033[1;30mnmap-parse\033[1;30m\033[0m \033[1;30m(\033[0;m\033[1;31m{sub_prompt}\033[0;m\033[1;30m) >\033[0;m ',
    shared_attributes=dict(
        nmapOutput = 'nmapOutput',
        service_filter = 'service_filter',
        port_filter = 'port_filter',
        host_filter = 'host_filter',
        include_ports = 'include_ports',
        have_ports = 'have_ports',
        only_alive = 'only_alive',
        verbose = 'verbose',
        raw = 'raw'
    ))
class InteractivePrompt(common.TerminalBase):
    CMD_CAT_NMAP = "Nmap Commands"

    prompt = '\n\033[4m\033[1;30mnmap-parse\033[1;30m\033[0m\033[1;30m >\033[0;m '
    intro = """\nWelcome to nmap parse! Type ? to list commands
  \033[1;30mTip: You can send output to clipboard using the redirect '>' operator without a filename\033[1;m
  \033[1;30mTip: Set quiet to true to only get raw command output (no headings)\033[1;m"""
    allow_cli_args = False

    def __init__(self, nmapOutput, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.printRandomBanner()
        self.nmapOutput = nmapOutput

    def printRandomBanner(self):
        banners = [  """
                                                       .         .
                            b.             8          ,8.       ,8.                   .8.          8 888888888o
                            888o.          8         ,888.     ,888.                 .888.         8 8888    `88.
                            Y88888o.       8        .`8888.   .`8888.               :88888.        8 8888     `88
                            .`Y888888o.    8       ,8.`8888. ,8.`8888.             . `88888.       8 8888     ,88
                            8o. `Y888888o. 8      ,8'8.`8888,8^8.`8888.           .8. `88888.      8 8888.   ,88'
                            8`Y8o. `Y88888o8     ,8' `8.`8888' `8.`8888.         .8`8. `88888.     8 888888888P'
                            8   `Y8o. `Y8888    ,8'   `8.`88'   `8.`8888.       .8' `8. `88888.    8 8888
                            8      `Y8o. `Y8   ,8'     `8.`'     `8.`8888.     .8'   `8. `88888.   8 8888
                            8         `Y8o.`  ,8'       `8        `8.`8888.   .888888888. `88888.  8 8888
                            8            `Yo ,8'         `         `8.`8888. .8'       `8. `88888. 8 8888

                            8 888888888o      .8.          8 888888888o.     d888888o.   8 8888888888
                            8 8888    `88.   .888.         8 8888    `88.  .`8888:' `88. 8 8888
                            8 8888     `88  :88888.        8 8888     `88  8.`8888.   Y8 8 8888
                            8 8888     ,88 . `88888.       8 8888     ,88  `8.`8888.     8 8888
                            8 8888.   ,88'.8. `88888.      8 8888.   ,88'   `8.`8888.    8 888888888888
                            8 888888888P'.8`8. `88888.     8 888888888P'     `8.`8888.   8 8888
                            8 8888      .8' `8. `88888.    8 8888`8b          `8.`8888.  8 8888
                            8 8888     .8'   `8. `88888.   8 8888 `8b.    8b   `8.`8888. 8 8888
                            8 8888    .888888888. `88888.  8 8888   `8b.  `8b.  ;8.`8888 8 8888
                            8 8888   .8'       `8. `88888. 8 8888     `88. `Y8888P ,88P' 8 888888888888
                        ""","""
                            888b    888
                            8888b   888
                            88888b  888
                            888Y88b 888 88888b.d88b.   8888b.  88888b.
                            888 Y88b888 888 "888 "88b     "88b 888 "88b
                            888  Y88888 888  888  888 .d888888 888  888
                            888   Y8888 888  888  888 888  888 888 d88P
                            888    Y888 888  888  888 "Y888888 88888P"
                                                            888
                                                            888
                                                            888
                                8888888b.
                                888   Y88b
                                888    888
                                888   d88P 8888b.  888d888 .d8888b   .d88b.
                                8888888P"     "88b 888P"   88K      d8P  Y8b
                                888       .d888888 888     "Y8888b. 88888888
                                888       888  888 888          X88 Y8b.
                                888       "Y888888 888      88888P'  "Y8888
                        ""","""
                             /$$   /$$
                            | $$$ | $$
                            | $$$$| $$ /$$$$$$/$$$$   /$$$$$$   /$$$$$$
                            | $$ $$ $$| $$_  $$_  $$ |____  $$ /$$__  $$
                            | $$  $$$$| $$ \\ $$ \\ $$  /$$$$$$$| $$  \\ $$
                            | $$\\  $$$| $$ | $$ | $$ /$$__  $$| $$  | $$
                            | $$ \\  $$| $$ | $$ | $$|  $$$$$$$| $$$$$$$/
                            |__/  \\__/|__/ |__/ |__/ \\_______/| $$____/
                                                            | $$
                                                            | $$
                                                            |__/
                                 /$$$$$$$
                                | $$__  $$
                                | $$  \\ $$ /$$$$$$   /$$$$$$   /$$$$$$$  /$$$$$$
                                | $$$$$$$/|____  $$ /$$__  $$ /$$_____/ /$$__  $$
                                | $$____/  /$$$$$$$| $$  \\__/|  $$$$$$ | $$$$$$$$
                                | $$      /$$__  $$| $$       \\____  $$| $$_____/
                                | $$     |  $$$$$$$| $$       /$$$$$$$/|  $$$$$$$
                                |__/      \\_______/|__/      |_______/  \\_______/
                        """]
        curBanner = textwrap.dedent(random.choice(banners)).replace(os.linesep, os.linesep + "  ")
        maxLen = 0
        for line in curBanner.split('\n'):
            if len(line) > maxLen:
                maxLen = len(line)
        curBanner = ("-" * maxLen) + "\n\033[1;34m" + curBanner + "\033[0;m \n" + ("-" * maxLen)
        print(curBanner)

    @with_category(CMD_CAT_NMAP)
    def do_host(self, inp):
        '''Print details for specified host
        Useage: "host [ip address]'''
        ip = inp.strip()
        if(ip not in self.nmapOutput.Hosts):
            self.perror("Host not found: " + ip)
            return
        curHost = self.nmapOutput.Hosts[ip]
        self.printTextOutput(helpers.getHostDetails(curHost))

    def complete_host(self, text, line, begidx, endidx):
        return [host for host in self.nmapOutput.Hosts if host.startswith(text)]

    @with_category(CMD_CAT_NMAP)
    def do_list(self, inp):
        '''List all IP's matching filter'''
        consoleOutput = helpers.getHostListOutput(self.nmapOutput, includePorts=self.include_ports, filters=self.getFilters())
        self.printTextOutput(consoleOutput)

    def complete_file(self, text, line, begidx, endidx):
        return [file for file in self.nmapOutput.FilesImported if file.startswith(text)]

    @with_category(CMD_CAT_NMAP)
    def do_file(self, inp):
        '''Print details for specified file'''
        file = inp.strip()
        if(file not in self.nmapOutput.FilesImported):
            self.perror("File not found: " + file)
            return

        filters = self.getFilters()
        self.pfeedback(helpers.getNmapFiltersString(filters))
        hosts = self.nmapOutput.getHostsWithinFile(file, filters=filters)

        self.pfeedback(helpers.getHeader("Hosts within file"))
        if self.verbose:
            headers = ['IP', 'Hostname', 'State', 'TCP Ports (count)', 'UDP Ports (count)' ]
            verboseOutput = []
            for host in hosts:
                verboseOutput.append([host.ip, host.getHostname(), host.getState(),
                                        len(host.getUniquePortIds(constants.PORT_OPT_TCP)),
                                        len(host.getUniquePortIds(constants.PORT_OPT_UDP))])
            self.poutput(tabulate.tabulate(verboseOutput, headers=headers, tablefmt="github"))
        else:
            for host in hosts:
                self.poutput(host.ip)

    def complete_Xports(self, text, line, begidx, endidx):
        return self.basic_complete(text, line, begidx, endidx, constants.PORT_OPTIONS)

    @with_category(CMD_CAT_NMAP)
    def do_services(self, inp):
        '''Lists all services (supports verbose output)'''
        consoleOutput = helpers.getServiceListOutput(self.nmapOutput, filters=self.getFilters(), verbose=self.verbose, includePorts = self.include_ports)
        self.printTextOutput(consoleOutput)

    @with_category(CMD_CAT_NMAP)
    def do_ports(self, inp):
        '''Lists unique ports. Usage "ports [default/tcp/udp/combined]"'''
        option = constants.PORT_OPT_DEFAULT
        userOp = inp.strip().lower()
        if(userOp in constants.PORT_OPTIONS):
            option = userOp
        filters = self.getFilters()
        consoleOutput = helpers.getUniquePortsOutput(self.nmapOutput.getHostDictionary(filters), option, filters=filters)
        self.printTextOutput(consoleOutput)

    complete_import = cmd2.Cmd.path_complete

    @with_category(CMD_CAT_NMAP)
    @cmd2.with_argument_list
    def do_import(self, args: List[str]):
        '''Import additional nmap files or directories

        Usage: import [filename/directory]
        '''
        if not args:
            self.perror('import requires a path to a file/directory as an argument')
            return
        allFiles = []
        for file in args:
            allFiles.extend(helpers.getNmapFiles(file, recurse=True))
        self.nmapOutput.parseNmapXmlFiles(allFiles)

    @with_category(CMD_CAT_NMAP)
    def do_import_summary(self, inp):
        '''Displays list of imported files'''

        self.pfeedback(helpers.getHeader("Successfully Imported Files"))
        if(len(self.nmapOutput.FilesImported) > 0):
            if self.verbose:
                headers = ['Filename', 'Hosts Scanned', 'Alive Hosts']
                verboseOutput = []
                filesWithNoHosts = []
                filters = nmap.NmapFilters(defaultBool=False)
                hostsByFile = self.nmapOutput.getHostsByFile(filters)
                for file in self.nmapOutput.FilesImported:
                    if file in hostsByFile:
                        scannedHosts = hostsByFile[file]
                        aliveHostCount = len([host for host in scannedHosts if host.alive])
                        verboseOutput.append([file, len(scannedHosts), aliveHostCount])
                    else:
                        verboseOutput.append([file, 0, 0])
                        filesWithNoHosts.append(file)
                self.poutput(tabulate.tabulate(verboseOutput, headers=headers))
                if(len(filesWithNoHosts) > 0):
                    self.perror("\nThe following file(s) had no hosts:")
                    for file in filesWithNoHosts:
                        self.perror("  - " + file)
            else:
                for file in self.nmapOutput.FilesImported:
                    self.poutput(file)
        else:
            self.perror("No files were imported successfully")
        print()

        if(len(self.nmapOutput.FilesFailedToImport) > 0):
            self.pfeedback( helpers.getHeader("Failed Imports"))
            for file in self.nmapOutput.FilesFailedToImport:
                self.perror(file)


    def complete_unset(self, text, line, begidx, endidx):
        # remove 'unset' from first array slot
        splitText = line.split()[1:]
        if(len(text.strip()) == 0):
            return [option[0] for option in self.userOptions]
        if(len(splitText) == 1):
            return [option[0] for option in self.userOptions if option[0].startswith(splitText[0].lower()) and not (option[0] == splitText[0].lower())]
        return [text]

    @with_category(CMD_CAT_NMAP)
    def do_scanned_hosts(self, inp):
        '''List all hosts scanned'''
        self.pfeedback(helpers.getHeader('Scanned hosts'))

        filters = self.getFilters()
        filters.onlyAlive = False

        for line in [host.ip for host in self.nmapOutput.getHosts(filters=filters)]:
            self.poutput(line)

    @with_category(CMD_CAT_NMAP)
    def do_alive_hosts(self, inp):
        '''List alive hosts'''
        self.pfeedback(helpers.getHeader('Alive hosts'))
        for ip in self.nmapOutput.getAliveHosts(self.getFilters()):
            self.poutput(ip)


