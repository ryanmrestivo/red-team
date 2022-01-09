import subprocess
import json
import pprint

def start(args):
	help_str = "usage:\n\texec ad_group_list ---> lists azure AD group information"
	
	if(len(args)>0):

		if(args[0][0] == "?"):
			print(help_str)
			return

	print("[+] getting AD groups in subscription [+]")
	
	group_list = subprocess.run(['az','ad', 'group', 'list', '--query', '[].{display_name:displayName, description: description, object_id: objectId}'], stdout=subprocess.PIPE)
	group_list_json = json.loads(group_list.stdout.decode('utf-8'))

	pprint.pprint(group_list_json)