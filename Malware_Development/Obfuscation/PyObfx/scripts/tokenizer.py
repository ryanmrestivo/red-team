#!/usr/bin/python3.6
# -*- coding: utf-8 -*-
import re
from pygments.lexers import Python3Lexer
from pygments.token import Token
from random import randint
from scripts.logger import Log

class Tokenizer:
    TOKENS = list()

    def __init__(self, data):
        # Logger
        self.logger = Log()
        # Max ID
        self.max_id = 10 * 10 * 10
        # Get tokens
        self.logger.log('Getting tokens from file...')
        self._tokens = list(Python3Lexer().get_tokens(data))
        # Tokenize
        self._tokenize()

    # Get token by id
    def find_by_id(self, _id):
        for token in self.TOKENS:
            if token[0] == _id:
                return token
        return (None, None, None)

    # Get token index(s) by id
    def find_index_by_id(self, _id):
        index_list = list()
        for index, token in enumerate(self.TOKENS):
            if self.TOKENS[index][0] == _id:
                index_list.append(index)
        return index_list

    # Get next token for testing purposes
    def get_next_token(self):
        return next(self._tokens)

    # Generate ID for tokens
    def _generate_id(self):
        while True:
            tok_id = randint(0, self.max_id)
            if tok_id in [i[0] for i in self.TOKENS]:
                continue
            return tok_id

    def _tokenize(self):
        self.logger.log('Tokenizing...')
        self.logger.log('Total token count: ' + str(len(self._tokens)))
        # Create a dict for checking token IDs
        # and assigning unique ID for every token
        check_dict = dict()
        try:
            # Tokenizer loop
            for key, token in enumerate(self._tokens):
                # Get tokens and assign ID for every single token
                current_token = self._tokens[key]
                tok_id = self._generate_id()
                token_value = token[1]
                # Check if function.name token is a string
                # to avoid function name and string type conflicts
                if token[0] == Token.Literal.String.Double or token[0] == Token.Literal.String.Single:
                    self.TOKENS.append((tok_id, current_token, str(token_value)))
                    continue
                # After checking the ID-token dictionary
                # add token to list
                if not str(token_value) in list(check_dict.keys()):
                    check_dict[str(token_value)] = (tok_id, current_token)
                    self.TOKENS.append((tok_id, current_token, str(token_value)))
                else:
                    self.TOKENS.append(
                        (check_dict[token_value][0], check_dict[token_value][1], str(token_value)))
        except Exception as ex:
            self.logger.log(f'{type(ex).__name__} has occured while tokenizing \n[{ex}]', state='critical')
        else:
            self.logger.log("Tokenized successfully.")
        # Delete ID-token dictionary
        del check_dict
