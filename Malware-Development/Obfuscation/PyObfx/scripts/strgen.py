#!/usr/bin/python3.6
# -*- coding utf:8 -*-
import random
import string

py_keywords  = __import__('keyword').kwlist
gen_alphabet = lambda x, y: ''.join(map(chr, range(x, y)))

hindi    = gen_alphabet(0x900, 0x97F)   # Devanagari ( 0900 - 097F )
chinese  = gen_alphabet(0x4E00, 0x9FBF) # CJK Unified Ideographs ( 4E00 - 9FFF )
japanese = gen_alphabet(0x3040, 0x309F) # Hiragana ( 3040 - 309F)

random_types = {
    1: string.ascii_letters,
    2: string.printable[:-6],
    3: japanese,
    4: chinese,
    5: hindi
}

def generate_rand_str(rnd_type, count):
    characters = random_types[rnd_type]
    return ''.join(random.sample(
        characters, 
        count if count < len(characters) else len(characters)
    ))
    