```
.____                         
|    |   _____ ___  _______   
|    |   \__  \\  \/ /\__  \  
|    |___ / __ \\   /  / __ \_
|_______ (____  /\_/  (____  /
        \/    \/           \/ 
```

# Lava is a Microsoft Azure exploitation framework.

## Background

Inspired by Pacu for AWS by RhinoSecurityLabs, I wanted to create a tool that did not simply do configuration reviews of Azure cloud environments, but one that takes that extra step with useful exploitation modules for penetration testing. The framework was initially developed during my time at MWR InfoSecurity.

Lava was designed with the intent to make the process of adding modules they deem useful as easy as possible for a penetration tester.
## Installation

```bash
git clone https://github.com/mattrotlevi/lava.git
./setup.sh (hit enter for all the prompts)
```

## Usage

```
root@computer# python3 lava.py

.____                         
|    |   _____ ___  _______   
|    |   \__  \  \/ /\__  \  
|    |___ / __ \   /  / __ \_
|_______ (____  /\_/  (____  /
        \/    \/           \/ 
              `  .`           
             -o..o`           
         .-  :o.+/   -        
      `::`-- :o`o``---        
       -+o```-+./ .`-``       
         .+-+.::-:/``.        
          `+o++o:o+/`         
          -sosooooo:          
         .hhhdhyosyy.         
        .hyhhhyhhhdyy.        
       -hhhddydhhdydyh:       
      +dhdhhdhhdddhdhhdo`     
    -ydddyhhddyhdhdhdddhy:    
  .shhhddhddhddhddydhhddyds.  
 -++++++++++++++++++++++++++- 

  
Lava $> 

Lava $> help

		banner			        --->	print ascii art banner
		clear/clean		        --->	clear the screen
		list/ls			        --->	prints all the modules and categories
		exec [module_name]	        --->	executes a module
		exec [module_name] ?	        --->	prints help of a module
		az [rest of command]	        --->	directly runs azure command
		help			        --->	prints this help screen
		exit			        --->	exits lava

		informational commands:
		whoami			        --->	prints info about current subscription
		rgroups			        --->	prints info about resource groups

```

Running ```exec [module_name] ?``` prints that individual module's help string and usage
```
Lava $> exec vm_list ?
usage:
	exec vm_list [-rgrp resource-group] ---> will list all vms and public/private ips

```

The ```exfil_file_search``` module requires a bit of outside setup to work. I provided a small php file that will handle receiving the gzip with sensitive files and will handle writing it to a directory called "/uploads"

I tested the module with [ngrok.io](https://github.com/inconshreveable/ngrok)
 ```
 Installing ngrok.io:
 follow the super easy installation guide at https://ngrok.com/download
 ```
 - Place ngrok in a directory with the exfil.php file and a subdirectory called /uploads (make sure write is enabled)
 - run ```./nrgok```
 - run the exfil data module and supply the ngrok url and data will automatically be exfiltrated



## Contributing
The intent of this project is to help pentesters in an Azure engagement. I specifically attempted to make the framework as easy to add to and extend as possible.

Therefore, if you want to add your own modules please feel free to submit a pull request, clone, or whatever. 

For major changes, please open an issue first to discuss what you would like to change.

## License
https://choosealicense.com/licenses/gpl-3.0/
