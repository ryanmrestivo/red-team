#!/usr/bin/python3.6
# -*- coding: utf-8 -*-

from scripts.argparser import cli_arg_parser
from scripts.banner import print_banner
from scripts.obfuscator import Obfuscator


def main():
    print_banner()
    Obfuscator(**cli_arg_parser()).obfuscate()


if __name__ == "__main__":
    main()
