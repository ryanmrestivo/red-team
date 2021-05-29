import subprocess
import json
import pprint

def start(args):
	help_str = "usage:\n\texec sql_server_list ---> list sql servers in subscription"
	if(len(args)>0):
		if(args[0][0] == "?"):
			print(help_str)
			return
	
	print("[+] getting servers [+]")
	sql_info = subprocess.run(['az', 'sql', 'server', 'list', '--query', '[].{fqdn:fullyQualifiedDomainName, name:name, rgrp: resourceGroup, admin_username:administratorLogin} '], stdout=subprocess.PIPE)
	sql_info_json = json.loads(sql_info.stdout.decode('utf-8'))

	pprint.pprint(sql_info_json)

	
	


