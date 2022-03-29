![XML-RPC Bruteforce Attacks](images/xmlrpc-bruteforcer_logo.jpg)
# xmlrpc-bruteforcer
[![Language](https://img.shields.io/badge/Lang-Python-blue.svg)](https://www.python.org)
[![License](https://img.shields.io/badge/License-Apache%202.0-red.svg)](https://opensource.org/licenses/Apache-2.0)

## Bruteforcing CMS users' passwords via the XMLRPC interface.
This script is a PoC for the "Brute Force Amplification Attack" exploit against XMLRPC interfaces enabling the *system.multicall()* method (enabled by default). 

The *system.multicall()* method allows multiple calls to be sent within a single HTTP request. Using this "wrapper", malicious attackers can carry out a large number of login attempts (bruteforce) with a minimal network impact, consequently making them stealthier and more efficient.

At the moment, the maximum number of calls which can be encapsulated within the *system.multicall()* method without triggering a networking error is 1999 calls meaning that for each HTTP request sent 1999 different login attempts are performed.

More information about the bruteforce amplification attack can be found at:

<https://blog.cloudflare.com/a-look-at-the-new-wordpress-brute-force-amplification-attack/>

## Vulnerable CMS 
Script sucessfully tested against WordPress versions **< 4.4**

## Installation
```
$ git clone https://github.com/AresS31/xmlrpc-bruteforcer
$ cd xmlrpc-bruteforcer
$ pip install -r requirements.txt
```

## Docker
```
$ git clone https://github.com/AresS31/xmlrpc-bruteforcer && cd xmlrpc-bruteforcer
$ docker build -t xmlrpc-bruteforcer .
$ docker run --rm -v $(pwd):/wordlists xmlrpc-bruteforcer -u admin -w /wordlists/wordlist.txt -t 3 -x https://wordpress.local/xmlrpc.php
```

## Usage
```
$ python3 xmlrpc-bruteforce.py -u [username] -w [wordlist] -x [xmlrpc_intf] -t [threads_number] -c [chunks_size] -v [verbose] -h [help]
[-u]: username of the targeted user, required
[-w]: wordlist containing the passwords to try, required
[-x]: xmlrpc interface to attack, required
[-t]: number of threads to run, optional, default value: 5 
[-c]: number of calls to encapsulate within a system.mullticall() call, optional, default value: 1999
[-v]: print debugging information, optional, default value: False
[-h]: print help
```

## Dependencies
### Third-party libraries
#### colorama 0.3.7:
The *python3-colorama* package is required. 

<https://pypi.python.org/pypi/colorama>

#### tqdm 4.8.4: 
The *python3-tqdm* package is required. 

<https://pypi.python.org/pypi/tqdm>  

## Possible Improvements
- [ ] Debug the tqdm, sys.stdout printing issues.
- [ ] Improve the source code quality.

## License
   Copyright (C) 2016 Alexandre Teyar

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
   limitations under the License. 
