# Exnoscan

![Exnoscan](https://ctrla1tdel.files.wordpress.com/2021/01/image-3.png)

## About

Exnoscan is a simple bash script that can help you identify gaps. We often monitor what we know, so Exnoscan aims to identify what you don’t. Exnoscan uses a bunch of tools to complete the job which are listed below:

- Sublist3r: https://github.com/aboul3la/Sublist3r.git
- Dirsearch: https://github.com/maurosoria/dirsearch.git
- Nmap: https://nmap.org/
- Nmap Parser: https://github.com/laconicwolf/Nmap-Scan-to-CSV.git
- TheHarvester: https://github.com/laramies/theHarvester


## Dependencies

- Python 3.7+
- Nmap
- Git
- Netcat

Optional: TheHarvester [https://github.com/laramies/theHarvester/wiki/Installation]
I personally run on a kali linux box as most come pre-installed.


## How To Run
Simply run the bash script. This will generate the files. Once done, populate ./scan/domains.txt and re-run. This is the bare minimum. 
If you want to customize, please see: https://securethelogs.com/2021/01/12/exnoscan/
