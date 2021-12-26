#!/usr/bin/python3.6
# -*- coding: utf-8 -*-
import random, re, time, os
from scripts.tokenizer import Tokenizer
from scripts.strgen import generate_rand_str
from pygments.token import Token
from scripts.io import read_file, write_file
from scripts.logger import Log
from scripts.packer import *


class Obfuscator:
    def __init__(self, **args):
        # Logger
        self.logger = Log(log_name=f"pyobfx_log-{time.strftime('%X')}.txt", active=args['silent']) if not args['no_log'] else Log(active=args['silent'])
        self.logger.log('Starting obfuscator')
        # Strgen type
        self.strgen_type = {'jp':3, 'ch':4, 'in':5}[args['str_gen']] if args['str_gen'] and args['str_gen'] in ['jp', 'ch', 'in'] else 1
        # Header for obfuscated file
        self.obfx_header = "# Obfuscated with PyObfx #"
        # Escape placeholder
        self.escape_placeholder = "#escaped_char#"
        # Obfx arguments
        self.args = args
        # File name and content
        self.file_name = self.args['file']
        self.file_content = read_file(self.file_name)
        # Length constant for random string
        self.obf_len_constant = 2
        # Quote character distance from string (max)
        self.quote_dist_constant = 5
        # Imports obfuscation
        self.import_dict, self.import_content = self._prepare_imports() # warn: change self.file_content variable
        # Escape chars in file
        self.escaped_file = self._escape_file(self.file_content)
        # Tokenize the source and retrieve tokenizer object
        self.tokenizer = Tokenizer(self.escaped_file)
        self.has_handled = set()
        self.build_in_func = ['exit', ''] #过滤python内建函数
        # Random integers for obfuscation
        self.ints = [random.randint(1, 5) for _ in range(3)]
        # Deobfuscator declarations
        self.deobfuscators = {
            1: "lambda n: (n - ({} % {})) - {}".format(*self.ints[::-1]),
            2: "lambda n: (n ^ {}) / {}".format(*self.ints[:2]),
            3: "lambda n: n - sum({})".format(str(self.ints)),
            4: "lambda n: (n + ({} + {})) / {}".format(*self.ints[::-1]),
            5: "lambda n: (n + {}) / ({} + {})".format(*self.ints)
        }
        # New file extension for obfuscated file
        self.obfx_ext = "_obfx.py"
        # Randomized deobfuscator function names
        self.deobfuscator_name = generate_rand_str(self.strgen_type, 10)
        self.str_deobfuscator_name = generate_rand_str(self.strgen_type, 10)
        # Quote list
        self.quotes = ["'", '"', '"""']
        # Boolean value list
        self.boolean_val = ['True', 'False']
        # Escape Sequences
        self.escapes = [('\a', '\\a'), ('\b', '\\b'), \
        ('\f', '\\f'), ('\n', '\\n'), ('\r', '\\r'), \
         ('\t', '\\t'), ('\v', '\\v')]

    # str.format with int deobfuscator name
    string_deobfuscator = "lambda s: ''.join(chr(int({}(ord(c)))) for c in s)"

    # Obfuscator methods
    def obfuscation1(self, n):
        return (n + self.ints[0]) + (self.ints[2] % self.ints[1])
    def obfuscation2(self, n):
        return (n * self.ints[1]) ^ self.ints[0]
    def obfuscation3(self, n):
        return n + sum(self.ints)
    def obfuscation4(self, n):
        return (n * self.ints[0]) - (self.ints[2] + self.ints[1])
    def obfuscation5(self, n):
        return (n * (self.ints[0] + self.ints[1])) - self.ints[2]
    # Escape string
    def _escape(self, s):
        s = s.replace('"', r'\"').replace("'", r"\'")
        for escape in self.escapes:
            s = s.replace(escape[0], escape[1])
        return s

    # Escape file
    # (eg.: Replace '\' with placeholder)
    def _escape_file(self, file_content):
        # Double quote
        file_content = file_content.replace("\\\"", "\\d")
        # Single quote
        file_content = file_content.replace("\\\'", "\\s")
        file_content = file_content.replace("\\", self.escape_placeholder)
        self.logger.log('Escaped source file.')
        return file_content

    # Unescape string using placeholder
    def _unescape_str(self, s):
        for escape in self.escapes:
            s = s.replace(self.escape_placeholder+escape[1].replace("\\", ""), escape[0])
        s = s.replace(self.escape_placeholder, '\\')
        # Single quote
        s = s.replace('\\s', '\'')
        # Double quote
        s = s.replace('\\d', '\"')
        return s

    def _obfuscate_names(self, token_type):
        self.logger.log("Obfuscating " + str(token_type).split('.')[-1] + "s...")
        # Iterate through the tokens and check if
        # token type is Token.Name
        try:
            for t_index, token in enumerate(self.tokenizer.TOKENS):
                # Get the name value
                name_value = token[2]
                if token[1][0] == token_type and token[0] not in self.has_handled \
                    and name_value not in self.build_in_func:

                    if name_value.startswith('__') and name_value.endswith('__'):
                        continue
                    # Obfuscate the name string
                    obf_var_name = generate_rand_str(self.strgen_type, len(name_value) * self.obf_len_constant)
                    # Fix imports
                    if name_value in list(self.import_dict.keys()):
                        obf_var_name = self.import_dict[name_value]
                    else:
                        # Continue if current token is part of a function
                        # (eg.: random.randint)
                        if self.tokenizer.TOKENS[t_index+1][1][0] == Token.Operator or \
                            self.tokenizer.TOKENS[t_index-1][1][0] == Token.Operator:
                            continue
                    # Find usages for current name with find_index_by_id method
                    token_index = self.tokenizer.find_index_by_id(token[0])
                    # Iterate through the indexes and change current value with
                    # new obfuscated value
                    self.has_handled.add(token[0])
                    for index in token_index:
                        # Check if token is a function
                        # https://github.com/PyObfx/PyObfx/issues/61
                        if self.tokenizer.TOKENS[index-1][1][0] == Token.Operator:
                           continue
                        current_token = self.tokenizer.TOKENS[index]
                        # Change list element
                        self.tokenizer.TOKENS[index] = (current_token[0],
                            (Token.Name, obf_var_name), obf_var_name)

        except Exception as ex:
            self.logger.log(f'{type(ex).__name__} has occured while obfuscating names \n[{ex}]', state='error')
        else:
            self.logger.log(str(token_type).split('.')[-1] + " obfuscation done.")


    def _obfuscate_vars(self, obfuscator, token_type):
        # Inner function for type casting
        # [can be simplified]
        def cast(token):
            if token_type == Token.Literal.Number.Integer:
                return int(token)
            elif token_type == Token.Literal.Number.Float:
                return float(token)
            elif token_type == Token.Keyword.Constant:
                return bool(token)
        # Iterate through the tokens and check if
        # token type equals token_type
        self.logger.log("Obfuscating " + str(token_type).split('.')[-1] + "s...")
        try:
            for token in self.tokenizer.TOKENS:
                if token[1][0] == token_type and token[0] not in self.has_handled:
                    # Cast and obfuscate the value
                    obf_val = obfuscator(cast(token[2]))
                    # Find usages for current token
                    token_index = self.tokenizer.find_index_by_id(token[0])
                    # Update old values with new obfuscated values
                    # If obfuscation type is a boolean obfuscation
                    # don't forget to add casting to new string
                    self.has_handled.add(token[0])
                    for index in token_index:
                        # Get token
                        current_token = self.tokenizer.TOKENS[index]
                        # Check boolean obfuscation
                        if token_type == Token.Keyword.Constant and \
                        current_token[2] in self.boolean_val:
                            # Add boolean casting [bool(...)]
                            # Update TOKENS
                            self.tokenizer.TOKENS[index] = (
                            current_token[0], current_token[1],
                            f'bool(int({self.deobfuscator_name}({obf_val})))')
                        else:
                            # Update TOKENS
                            if token_type == Token.Literal.Number.Float:
                                self.tokenizer.TOKENS[index] = (
                                current_token[0], current_token[1],
                                f'{self.deobfuscator_name}({obf_val})')
                            elif token_type == Token.Literal.Number.Integer:
                                self.tokenizer.TOKENS[index] = (
                                current_token[0], current_token[1],
                                f'int({self.deobfuscator_name}({obf_val}))')

        except Exception as ex:
            self.logger.log(f'{type(ex).__name__} has occured while obfuscating variables \n[{ex}]', state='error')
        else:
            self.logger.log(str(token_type).split('.')[-1] + " obfuscation done.")

    def _obfuscate_strings(self, obfuscator):
        # Iterate through the tokens and make sure
        # current token is string and not an unnecessary
        # char (quote)
        self.logger.log('Obfuscating strings...')
        try:
            for key, token in enumerate(self.tokenizer.TOKENS):
                if token[1][0] == Token.Literal.String.Double and not token[2] in self.quotes or \
                token[1][0] == Token.Literal.String.Single and not token[2] in self.quotes \
                        and token[0] not in self.has_handled:
                    # Don't touch multi line strings
                    try:
                        if self.tokenizer.TOKENS[key-1][2] == self.quotes[2] or \
                        self.tokenizer.TOKENS[key+1][2] == self.quotes[2]:
                            continue
                    except: pass
                    # only handle one string ,such as "123" or '123'
                    # other not handle
                    try:
                        if token[1][0] != self.tokenizer.TOKENS[key-1][1][0]:
                            continue
                        if token[1][0] != self.tokenizer.TOKENS[key+1][1][0]:
                            continue
                        if token[1][0] == self.tokenizer.TOKENS[key-2][1][0]:
                            continue
                        if token[1][0] == self.tokenizer.TOKENS[key+2][1][0]:
                            continue
                        if self.tokenizer.TOKENS[key-2][1][0] == Token.Literal.String.Interpol:
                            continue
                        if self.tokenizer.TOKENS[key+2][1][0] == Token.Literal.String.Interpol:
                            continue
                        if self.tokenizer.TOKENS[key-3][1][0] == Token.Literal.String.Interpol:
                            continue
                        if self.tokenizer.TOKENS[key+3][1][0] == Token.Literal.String.Interpol:
                            continue
                    except: pass
                    # String value
                    string_value = self._unescape_str(token[2])
                    # String obfuscation procedure
                    obfuscated = ''
                    # Obfuscate chars in string
                    for c in string_value:
                        obfuscated += ''.join(chr(obfuscator(ord(c))))
                    # Create obfuscated string
                    # (eg.: <deobfuscator_name>('<obfuscated_string>'))
                    obf_string = self.str_deobfuscator_name + "(\"" + self._escape(obfuscated) + "\")"
                    # Find usages for current token
                    token_index = self.tokenizer.find_index_by_id(token[0])
                    # Iterate through the indexes and change current value with
                    # new obfuscated value
                    self.has_handled.add(token[0])
                    for index in token_index:
                        current_token = self.tokenizer.TOKENS[index]
                        self.tokenizer.TOKENS[index] = (current_token[0], 
                            (Token.Name, obf_string), obf_string)
                        # Pop unnecessary escape characters
                        # (eg.: print("deobf("test")") -> Quote is unnecessary)
                        for n_index in range(self.quote_dist_constant):
                            if self.tokenizer.TOKENS[index-n_index][2] in self.quotes:
                                self.tokenizer.TOKENS.pop(index-n_index)
                                self.tokenizer.TOKENS.pop(index)
        except Exception as ex:
            self.logger.log(f'{type(ex).__name__} has occured while obfuscating strings \n[{ex}]', state='error')
        else:
            self.logger.log("String obfuscation done.")

    def obfuscate(self, obfuscation=random.randint(1, 5)):
        self.logger.log('Obfuscation started')
        # Declare obfuscator
        obfuscators = {1: self.obfuscation1, 2: self.obfuscation2, 3: self.obfuscation3, 4: self.obfuscation4, 5: self.obfuscation5}
        # Select obfuscator
        obfuscator = obfuscators[obfuscation]
        self.deobfuscator = self.deobfuscators[obfuscation]
        # Variable Name Obfuscation
        try:
            self._obfuscate_names(Token.Name)
        except Exception as ex:
            self.logger.log(f'{type(ex).__name__} has occured while obfuscating variable names \n[{ex}]', 'error')
        else:
            self.logger.log(f'Obfuscated variable names')
        # Function Name Obfuscation
        try:
            self._obfuscate_names(Token.Name.Function)
            pass
        except Exception as ex:
            self.logger.log(f'{type(ex).__name__} has occured while obfuscating function names \n[{ex}]', 'error')
        else:
            self.logger.log(f'Obfuscated function names')
        try:
            # Integer Obfuscation
            self._obfuscate_vars(obfuscator,
                Token.Literal.Number.Integer)
            # Float Obfuscation
            if obfuscation != 2: # sadly, ^ operator doesn't work on floats
                self._obfuscate_vars(obfuscator,
                    Token.Literal.Number.Float)
            # # Boolean Obfuscation
            self._obfuscate_vars(obfuscator,
                Token.Keyword.Constant)
            # String Obfuscation
            self._obfuscate_strings(obfuscator)
            pass
        except Exception as ex:
            self.logger.log(f'{type(ex).__name__} has occured while obfuscating values \n[{ex}]', 'error')
        else:
            self.logger.log(f'Obfuscated values')
        # Save file
        self._save_obfuscated_file()

    def _pack(self, file_content):
        try:
            # Packer functions
            packer_dispatcher = {
                'bz2': bz2_pack(file_content),
                'gz': gz_pack(file_content),
                'lzma': lzma_pack(file_content)
            }
            # Pack file if -p argument is provided and packer type is valid
            try:
                file_content = self.obfx_header + '\n' + packer_dispatcher[self.args['pack']]
                self.logger.log('File packed. (' + self.args['pack'] + ')')
            except KeyError:
                pass
        except Exception as ex:
            self.logger.log(f'{type(ex).__name__} has occured while packing the obfuscated file \n[{ex}]', state='error')
        return file_content

    def _prepare_imports(self):
        self.logger.log('Extracting imports...')
        # for the content to be obfuscated
        replaced = ""
        # for the  remaining content except import parts
        other_content = ""
        obf_dict = {}
        enter = False
        file_content_ln = self.file_content.split('\n')
        try:
            # Drafts
            draft1 = '^from\s+(.+)\s+import\s+(.*)'
            draft2 = '^import\s+(.+)'
            for num, line in enumerate(file_content_ln):
                #-------------------------------#
                que1 = re.search('as\s+([^:]+)$', line) # import .. as ..
                if que1:
                    # same for the next 4 steps
                    # Get random variable name
                    obf_name = generate_rand_str(self.strgen_type, len(line.split(' as ')[1]) * self.obf_len_constant)
                    real_namespace = line.split(' as ')[1]
                    obf_dict[real_namespace] = obf_name
                    replaced += line.split(' as ')[0] + ' as ' + obf_name + '\n'
                    continue
                #-------------------------------#
                que2 = re.search(draft1, line) 
                if que2:
                    if que2.group(2).strip() == '*':
                        obf_dict[que2.group(2).strip()] = que2.group(2).strip()
                        replaced += line + '\n'
                        continue
                    # from x import (y, z, t)
                    re_imp = re.search('\((.+)\)', line)
                    if re_imp: #re_imp: x,y,z
                        for namespace in re_imp.group(1).split(','):
                            # routine
                            obf_name = generate_rand_str(self.strgen_type, len(namespace.strip()) * self.obf_len_constant)
                            real_namespace = namespace.strip()
                            obf_dict[real_namespace] = obf_name

                            replaced += f"from {que2.group(1)} import {namespace} as {obf_name}\n"
                        continue
                    #----------------------------#

                    if '(' in que2.group(2) and not ')' in que2.group(2):
                        
                        # from x import (
                        #   y,z,a,
                        #   b,c,d
                        #   )

                        # this code block is for catching the 
                        # namespaces between '(' and ')'
                        enter = True
                        index = 1
                        tmp = ""
                        while True:
                            new_ln = file_content_ln[num + index]
                            tmp += new_ln
                            index += 1
                            if ')' in new_ln:
                                break   
                        
                        tmp = tmp.replace(')','')
                        namesp_list = [i.strip() for i in tmp.split(',')]
                        
                        for namesp in namesp_list:
                            # routine
                            obf_name = generate_rand_str(self.strgen_type, len(namesp.strip()) * self.obf_len_constant)
                            real_namespace = namesp.strip()
                            obf_dict[real_namespace] = obf_name
                            
                            replaced += f"from {que2.group(1)} import {namesp} as {obf_name}\n"
                            continue
                    # ------------------------------ #
                    if ',' in que2.group(2):
                        for namespace in que2.group(2).split(','): # from x import y,z,t
                            obf_name = generate_rand_str(self.strgen_type, len(namespace.strip()) * self.obf_len_constant)
                            real_namespace = namespace.strip()
                            obf_dict[real_namespace] = obf_name

                            replaced += f"from {que2.group(1)} import {namespace} as {obf_name}\n"

                        continue
                    # ---------------------------- #

                    if not ',' in que2.group(2) and not '(' in que2.group(2): # from x import y (single)
                        obf_name = generate_rand_str(self.strgen_type, len(que2.group(2)) * self.obf_len_constant)
                        real_namespace = que2.group(2)
                        obf_dict[real_namespace] = obf_name

                        replaced += re.sub(draft1, line + f' as {obf_name}\n', line)
                        
                        continue
                # ------------------------- #
                que3 = re.search(draft2, line)
                if que3:
                    if ',' in que3.group(1):
                        for namespace in que3.group(1).split(','): # import x,y,z
                            obf_name = generate_rand_str(self.strgen_type, len(namespace.strip()) * self.obf_len_constant)
                            real_namespace = namespace.strip()
                            obf_dict[real_namespace] = obf_name

                            replaced += f'import {namespace} as {obf_name}\n'
                        continue
                    # -------------------- #
                    else:
                        obf_name = generate_rand_str(self.strgen_type, len(que3.group(1)) * self.obf_len_constant)
                        real_namespace = que3.group(1)
                        obf_dict[real_namespace] = obf_name

                        replaced += f"import {real_namespace} as {obf_name}\n"
                    
                        continue
                # --------------------- #
                # Escape other import things
                if enter:
                    if '(' in line:
                        enter = True
                    continue
                
                # all contents except import
                other_content += line + '\n'

            # eleminate the class variable from import parts
            self.file_content = other_content    
        except Exception as ex:
            self.logger.log(f'{type(ex).__name__} has occured while extracting the imports \n[{ex}]', state='critical')
        else:
            self.logger.log('Imports extracted from source.')
        return (obf_dict, replaced)

    def _save_obfuscated_file(self):
            try:
                path_for_output = "./" if not self.args["out"] else self.args["out"] + "/"
                new_file_content = ''
                # Shebang check & fix
                for index, token in enumerate(self.tokenizer.TOKENS[:4]):
                    if token[2].startswith('#') or token[2] == '\n':
                        new_file_content += token[2]
                        self.tokenizer.TOKENS.pop(0)
                # New file name
                new_file_name = self.file_name.replace(
                    "." + self.file_name.split('.')[len(self.file_name.split('.'))-1],
                    self.obfx_ext)
                if "\\" in new_file_name: new_file_name = new_file_name.split('\\')[-1]
                if "/" in new_file_name: new_file_name = new_file_name.split('/')[-1]
                # Add header
                new_file_content += self.obfx_header + '\n'
                new_file_content += self.import_content + '\n'
                # Write deobfuscator functions
                new_file_content += f'{self.deobfuscator_name} = {self.deobfuscator}\n{self.str_deobfuscator_name} = {self.string_deobfuscator.format(self.deobfuscator_name)}\n'
                # Create new file content from tokens 
                for token in self.tokenizer.TOKENS:
                    new_file_content += token[2]
                # Pack
                new_file_content = self._pack(new_file_content)
                # Write file
                write_file(path_for_output + new_file_name, new_file_content)
            except Exception as ex:
                self.logger.log(f'{type(ex).__name__} has occured while saving the obfuscated file \n[{ex}]', state='error')
            else:
                self.logger.log("Successfully obfuscated.")
                self.logger.log("Saved to \"" + new_file_name + "\"")
                # print("\n\n" + new_file_content)  # testing
