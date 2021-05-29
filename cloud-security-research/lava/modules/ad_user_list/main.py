import subprocess
import json
import pprint

def start(args):
	help_str = "usage:\n\texec ad_user_list ---> lists azure AD user information"
	if(len(args)>0):
		if(args[0][0] == "?"):
			print(help_str)
			return

	print("[+] getting AD users in subscription [+]")

	user_list = subprocess.run(['az','ad', 'user', 'list', '--query', '[].{display_name:displayName, upn: userPrincipalName, object_id: objectId}'], stdout=subprocess.PIPE)
	user_list_json = json.loads(user_list.stdout.decode('utf-8'))

	pprint.pprint(user_list_json)

