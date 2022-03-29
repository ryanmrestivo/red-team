# zipcrack

Usage: python zipcrack.py -f <file> -w <wordlist>

options and arguments:
-f          --file        : select a password protected zip file to crack
-w          --wordlist    : select a wordlist/password list to try all passwords
  
The script currently only supports Python2.7, no additional modules are required this will work on an out the box Python2.7 install. If you call the script correctly. You will see it trying each and every line in the wordlist/password file provided.

python zipcrack.py -f /Users/Ed/Desktop/TEST.zip -w /Users/Ed/Downloads/rockyou.txt

[+] Trying baby06

The script will overwrite the same line with each attempt, so don't worry your terminal won't fill up, however the script is threaded so expect to see your CPU ramp up. If successful the script will print your password.

python zipcrack.py -f /Users/Ed/Desktop/TEST.zip -w /Users/Ed/Downloads/rockyou.txt

[+] Brute Force Successful: letmein1!
