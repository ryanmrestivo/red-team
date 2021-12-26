# L33tLinked

Hello dear reader! 

Welcome to my modification of CrossLinked (Can be found here: https://github.com/m8r0wn/CrossLinked ). Crosslink/L33tLinked is a LinkedIn scraping tool that utilizes both Google and Bing to grab LinkedIn profiles. Whats the use for this? Well, collecting all known employees in a comapny can be used on a red-team op for searching for employees that are involved in Data Breaches. It's simple enough to take the info you'll recieve here and run the info through the Dehashed/Have I Been Pwned API to determine if the user was affected by a data breach!

## Setup
```bash
git clone https://github.com/Sq00ky/L33tLinked.git
cd LeetLinked
pip3 install -r requirements.txt
```

## Sample Syntax
```bash
python3 leetlinked.py microsoft -e microsoft.com -f 1


 /$$                             /$$     /$$       /$$           /$$                       /$$
| $$                            | $$    | $$      |__/          | $$                      | $$
| $$        /$$$$$$   /$$$$$$  /$$$$$$  | $$       /$$ /$$$$$$$ | $$   /$$  /$$$$$$   /$$$$$$$
| $$       /$$__  $$ /$$__  $$|_  $$_/  | $$      | $$| $$__  $$| $$  /$$/ /$$__  $$ /$$__  $$
| $$      | $$$$$$$$| $$$$$$$$  | $$    | $$      | $$| $$  \ $$| $$$$$$/ | $$$$$$$$| $$  | $$
| $$      | $$_____/| $$_____/  | $$ /$$| $$      | $$| $$  | $$| $$_  $$ | $$_____/| $$  | $$
| $$$$$$$$|  $$$$$$$|  $$$$$$$  |  $$$$/| $$$$$$$$| $$| $$  | $$| $$ \  $$|  $$$$$$$|  $$$$$$$
|________/ \_______/ \_______/   \___/  |________/|__/|__/  |__/|__/  \__/ \_______/ \_______/

Based off of https://github.com/m8r0wn/CrossLinked
Modified by Ronnie Bartwitz and @Horshark on Github

Email format jsmith@company.xyz chosen

Scrape Complete!
```

## Help Menu
```bash
python3 leetlinked.py --help
positional arguments:
  company_name          Target company name

optional arguments:
  -h, --help            show this help message and exit
  -t TIMEOUT            Timeout [seconds] for search threads (Default: 25)
  -j JITTER             Jitter for scraping evasion (Default: 0)
  -s, --safe            Only parse names with company in title (Reduces false positives)
  -e EMAIL_DOMAIN, --email-domain EMAIL_DOMAIN
                        Include the email domain for email-generation (Example: microsoft.com)
  -p HIBP, --hibp HIBP  Runs all of the emails through HaveIBeenPwned's API and will list pwned accounts, API key is a required argument.
  -f EMAIL_FORMAT, --email-format EMAIL_FORMAT
                        Generates emails based on various formats, 1=jsmith 2=johnsmith 3=johns 4=smithj 5=john.smith 6=smith.john 7=smith
```

## Todo:

- [x] Implement more email formats, lastnamef, firstlast, fl, etc. (Pls create issues to request more)
- [x] Implement HIBP API - Finished
- [ ] Implement DeHashed API - (It's going to cost a fair bit of money to do this because dehash costs $ per query...)
- [ ] Completely re-write tool so it's not based on someone elses

Modified by Ronnie Bartwitz / Ronald Bartwitz // @Horshark
