import subprocess
import json
import pprint

def start(args):
	
	help_str = "usage:\n\texec priv_show ---> will display all attached roles and associated permissions"

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

	print("[+] getting definitions for each role found [+]")
	for role in role_list:
		print(role.upper())
		role_show = subprocess.run(['az', 'role', 'definition', 'list', '--name', role, '--query', '[].{actions:permissions[].actions, dataActions:permissions[].dataActions, notActions:permissions[].notActions, notDataActions:permissions[].NotDataActions}'], stdout=subprocess.PIPE)
		role_show_json = json.loads(role_show.stdout.decode('utf-8'))
		pprint.pprint(role_show_json)

	
	