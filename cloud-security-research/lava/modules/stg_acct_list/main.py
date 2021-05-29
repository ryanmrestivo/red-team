import subprocess
import json
import pprint

def start(args):

	help_str = "usage:\n\texec stg_acct_list ---> lists available storage accounts in subscription"
	
	if(len(args)>0):

		if(args[0][0] == "?"):
			print(help_str)
			return
	
	print("[+] getting storage accounts in subscription... [+]")

	stg_list = subprocess.run(['az','storage', 'account', 'list', '--query', '[].{resource_group:resourceGroup, storage_types:primaryEndpoints}'], stdout=subprocess.PIPE)
	stg_list_json = json.loads(stg_list.stdout.decode('utf-8'))

	pprint.pprint(stg_list_json)

