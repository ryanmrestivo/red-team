from ctypes import *
import sys

def check():
    isDebuggerPresent = windll.kernel32.IsDebuggerPresent()
    if(isDebuggerPresent):
        sys.exit(0)
    else:
        return True