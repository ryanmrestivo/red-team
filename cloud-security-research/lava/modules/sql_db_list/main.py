import subprocess
import json
import pprint

def start(args):
	help_str = "usage:\n\texec sql_db_list ---> list DBs per SQL server in subscription"
	if(len(args)>0):
		if(args[0][0] == "?"):
			print(help_str)
			return
	
	print("[+] getting servers [+]")
	sql_info = subprocess.run(['az', 'sql', 'server', 'list', '--query', '[].{name:name, rgrp: resourceGroup} '], stdout=subprocess.PIPE)
	sql_info_json = json.loads(sql_info.stdout.decode('utf-8'))


	servers = []
	rgrps = []
	for info in sql_info_json:
		servers.append(info['name'])
		rgrps.append(info['rgrp'])

	print("[+] getting databases [+]")
	for i in range(len(servers)):
		sql_info = subprocess.run(['az', 'sql', 'db', 'list', '--server', servers[i], '--resource-group', rgrps[i], '--query', '[].{collation:collation, name:name, location:location, dbId:databaseId}'], stdout=subprocess.PIPE)
		sql_info_json = json.loads(sql_info.stdout.decode('utf-8'))
		print(servers[i], "\n")
		pprint.pprint(sql_info_json)



	#server = sql_info_json['name']
	#rgroup = sql_info_json['rgrp']



	
	


