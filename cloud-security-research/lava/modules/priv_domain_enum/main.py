import subprocess
import json
import pprint

def start(args):
	
	help_str = "usage:\n\texec priv_domain_enum ---> will attempt to enumerate all users in domain and dump their permissions"

	if(len(args)>0):
		if(args[0][0] == "?"):
			print(help_str)
			return

	print("[+] getting users in domain [+]")
	user_list = subprocess.run(['az','ad', 'user', 'list', '--query', '[].{upn: userPrincipalName}'], stdout=subprocess.PIPE)
	user_list_json = json.loads(user_list.stdout.decode('utf-8'))

	upn_list = []

	for user in user_list_json:
		upn_list.append(user['upn'])

	for upn in upn_list:

		print("[+] getting roles for upn:", upn, "[+]")

		role_resp = subprocess.run(['az', 'role', 'assignment', 'list', '--assignee', upn, '--query', '[].{roleName:roleDefinitionName}'], stdout=subprocess.PIPE)
		role_json_obj = json.loads(role_resp.stdout.decode('utf-8'))

		role_list = []
		for role in role_json_obj:
			role_list.append(role["roleName"])

		if(len(role_list) == 0):
			print("[-] no roles found for upn:",upn, " [-]")
			continue

		print("[+] getting definitions for each role found for upn:",upn," [+]")
		for role in role_list:
			print(role.upper())
			role_show = subprocess.run(['az', 'role', 'definition', 'list', '--name', role, '--query', '[].{actions:permissions[].actions, dataActions:permissions[].dataActions, notActions:permissions[].notActions, notDataActions:permissions[].NotDataActions}'], stdout=subprocess.PIPE)
			role_show_json = json.loads(role_show.stdout.decode('utf-8'))
			pprint.pprint(role_show_json)

	
	