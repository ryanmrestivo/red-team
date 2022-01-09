import os
import importlib
import time

def ascii_img():
	return """
.____                         
|    |   _____ ___  _______   
|    |   \\__  \\  \\/ /\\__  \\  
|    |___ / __ \\   /  / __ \\_
|_______ (____  /\\_/  (____  /
        \\/    \\/           \\/ 
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

  """


def help_func():
	print("""
		banner\t\t\t--->\tprint ascii art banner
		clear/clean\t\t--->\tclear the screen
		list/ls\t\t\t--->\tprints all the modules and categories
		exec [module_name]\t--->\texecutes a module
		exec [module_name] ?\t--->\tprints help of a module
		az [rest of command]\t--->\tdirectly runs azure command
		help\t\t\t--->\tprints this help screen
		exit\t\t\t--->\texits lava

		informational commands:
		whoami\t\t\t--->\tprints info about current subscription
		rgroups\t\t\t--->\tprints info about resource groups 
		""")

def azure_direct(command):
	inj_chars = ["&", "|", ";", "`", "$", ">", "<"]
	for c in inj_chars:
		if(c in command):
			print("since i work at a security company i couldn't bring myself to just not parse direct syscall input")
			return
	os.system(command)

def clean_screen():
	os.system("clear")

def banner():
	print(ascii_img())

def show_modules():
	print("------------------------")
	print("ACTIVE DIRECTORY MODULES")
	print("------------------------")
	print("\t ad_user_list")
	print("\t ad_group_list")
	print("------------------------")
	print("VM/VMSS MODULES")
	print("------------------------")
	print("\t vm_list")
	print("\t vm_rce")
	print("\t vmss_list")
	print("\t vmss_rce")
	print("------------------------")
	print("STORAGE ACCOUNT MODULES")
	print("------------------------")
	print("\t stg_acct_list")
	print("\t stg_blob_scan")
	print("\t stg_file_scan")
	print("\t stg_get_keys")
	print("\t stg_blob_download")
	print("------------------------")
	print("SQL MODULES")
	print("------------------------")
	print("\t sql_server_list")
	print("\t sql_db_list")
	print("\t sql_backdoor_firewall_rule")
	print("------------------------")
	print("PRIVILEGE ESCALATION MODULES")
	print("------------------------")
	print("\t priv_show")
	print("\t priv_esc")
	print("\t priv_suggest")
	print("\t priv_domain_enum")
	print("------------------------")
	print("NETWORK MODULES")
	print("------------------------")
	print("\t net_nsg_list")
	print("------------------------")
	print("PERSISTENCE MODULES")
	print("------------------------")
	print("\t pers_user_create")
	print("\t pers_backdoor_nsg_rule")
	print("------------------------")
	print("DATA EXFILTRATION MODULES")
	print("------------------------")
	print("\t exfil_passwd_shadow")
	print("\t exfil_file_search")
	print("------------------------")



def exec_module(module_name, *args):
	file_path = os.path.join(os.getcwd(), 'modules', module_name, 'main.py')
	
	if os.path.exists(file_path):
		import_path = 'modules.{}.main'.format(module_name).replace('/', '.').replace('\\', '.')
		mod = importlib.import_module(import_path)

		mod.start(args)
	else:
		print(module_name, " does not exist")


if __name__ == "__main__":
	
	command = ""

	print(ascii_img())

	while command != "exit":
		command = input("Lava $> ")
		user_command = command.split()
		
		if(user_command[0] == "exec"):
			if(len(user_command) > 2 ):
				
				exec_module(user_command[1], user_command[2:])
			else:
				exec_module(user_command[1])
				
		elif(user_command[0] == "list" or user_command[0] == "ls"):
			show_modules()
		elif(user_command[0] == "banner"):
			banner()
		elif(user_command[0] == "clear" or user_command[0] == "clean"):
			clean_screen()
		elif(user_command[0] == "whoami"):
			exec_module("whoami")
		elif(user_command[0] == "rgroups"):
			exec_module("rgroups")
		elif(user_command[0] == "help"):
			help_func()
		elif(user_command[0] == "az"):
			azure_direct(command)
		elif(user_command[0] == 'exit'):
			print("bye!")
			exit()
		else:
			print(user_command[0], "not recognized")



