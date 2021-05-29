# Nitro Ransomware - Proof of Concept
Uses Discord nitro gift subscription as ransom. C# Ransomware for educational purposes only
 
 ## About
 Ransomware is a type of malware that prevents or limits users from accessing their files in their sysem. It locks the user's files until the ransom is paid, in this case, 
 a Discord nitro subscription. If a user wants to unlock their files, a decryption key is needed. The ransomware asks for the ransom in exchange for the decryption key. 
 
## Disclaimer
This Ransomware should not be used to harm/threat/hurt others.
Its purpose is only to share knowledge and awareness about Malware/Cryptography/Operating Systems/Programming.
NitroRansomware is an academic ransomware made for learning and spreading awareness about how security/cryptography can be used maliciously.
 
 ## How it works
 When the .exe file is run, it encrypts the user's Documents, Desktop, and Pictures folder. It then recursively checks for any nested folders in the folders, and encrypts all of its
 contents. In order to decrypt the files, the user has to paste a valid Discord nitro gift subscription and submit it. The program checks if it is valid, and if it is, it is
 sent to your webhook. The user receives the decryption key which allows them to decrypt the encrypted files. If it is not, the decrypion key will not be sent, and the user wil not be able to 
 open their files.
 
 This program should only be used for educational purposes only. Do not use this on others maliciously.
 
 ## Preview
 ###### Webhook Preview
 ![Picture](https://i.ibb.co/107VhDh/Screenshot-420.png)
 
 ###### Ransomware 
 ![Picture1](https://i.ibb.co/0Dwkf7M/Screenshot-422.png)
 ## Features
 - AES Encryption/ Decryption
 - Adds to startup registry
 - Grabs user's PC username, name, and uuid
 - Discord Nitro Checker 
 - Token Grabber
 - IP Grabber
 - Discord Webhook Logs

## Usage
1. Make sure you have Visual Studio 2019 with C# installed. (.NET Desktop Development) 
2. Open ```NitroRansomware.sln```, then open ```Program.cs```. 
3. Pase your webhook link next to ```WEBHOOK```.
4. You can change the decryption key too, if you want. ```DECRYPT_PASSWORD```
5. Click on release, then build the solution. Do NOT run it, because it is malware and may encrypt your files.
6. You can now test it in a protected environment such as a virtual machine.
