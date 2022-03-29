# This Repository is sole property of Linux Choice... but somehow it remained on mine account.
# EvilOffice v1.0
## Author: github.com/srnframe/eviloffice
## Twitter: twitter.com/linux_choice
### Read the license before using any part from this code :) 

Win python script to inject Macro and DDE code into Excel and Word documents (reverse shell)

![eo](https://user-images.githubusercontent.com/34893261/79132849-63fd0180-7d81-11ea-80db-69f9ea44c0b2.jpg)

### Features:
#### Inject malicious Macro on formats: docm, dotm, xlsm, xltm
#### Inject malicious DDE code on formats: doc, docx, dot, xls, xlsx, xlt, xltx
#### Python2/Python3 Compatible
#### Tested: Win10 (MS Office 14.0)

### Requirements:
#### Microsoft Office (Word/Excel)
#### pywin32: python -m pip install -r requirements.txt 
### Forwarding requirements:
#### Ngrok Authtoken (for TCP Tunneling): Sign up at: https://ngrok.com/signup
#### Your authtoken is available on your dashboard: https://dashboard.ngrok.com
#### Install your auhtoken: ./ngrok authtoken <YOUR_AUTHTOKEN>

## Legal disclaimer:

Usage of EvilOffice for attacking targets without prior mutual consent is illegal. It's the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program 

### Usage:

```
git clone https://github.com/srnframe/eviloffice
cd eviloffice
python -m pip install -r requirements.txt
python eviloffice.py
```

### Donate!
Pay me a coffee:
### Paypal:
https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=CLKRT5QXXFJY4&source=url
