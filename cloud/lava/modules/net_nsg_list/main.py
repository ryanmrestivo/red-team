import subprocess
import json
import pprint

def start(args):
	help_str = "usage:\n\texec net_nsg_list [-rgrp resource-group] ---> lists network security group rules"
	if(len(args)>0):
		if(args[0][0] == "?"):
			print(help_str)
			return
	


	if(len(args) == 0):
		print("[+] getting nsg rules [+]")
		nsg_info = subprocess.run(['az', 'network', 'nsg', 'list', '--query', '[].{name:name, rule_access:securityRules[].access, rule_name:securityRules[].name, rule_priority:securityRules[].priority, sourceIP:securityRules[].sourceAddressPrefix, destPort:securityRules[].destinationPortRange}'], stdout=subprocess.PIPE)
		nsg_info_json = json.loads(nsg_info.stdout.decode('utf-8'))

		nsg_names = []
		for i in range(len(nsg_info_json)):
			nsg_dict = {}
			nsg_dict_rules = []
			for j in range(len(nsg_info_json[i]['rule_access'])):
				nsg_dict_sub_rules = []
				nsg_dict_sub_rules.append("Rule access: "+ str(nsg_info_json[i]['rule_access'][j]))
				nsg_dict_sub_rules.append("SourceIP: "+str(nsg_info_json[i]['sourceIP'][j]))
				nsg_dict_sub_rules.append("destination port: "+ str(nsg_info_json[i]['destPort'][j]))
				nsg_dict_sub_rules.append("rule name: "+str(nsg_info_json[i]['rule_name'][j]))
				nsg_dict_sub_rules.append("rule priority: "+str(nsg_info_json[i]['rule_priority'][j]))
				nsg_dict_rules.append(nsg_dict_sub_rules)
			nsg_dict[nsg_info_json[i]['name']] = nsg_dict_rules
			nsg_names.append(nsg_dict) 
			
		if(len(nsg_names) == 0):
			print("[-] none found [-]")
			return

		for nsg in nsg_names:
			pprint.pprint(nsg)

		return



	if "-rgrp" in args[0]:

		print("[+] getting nsg rule names in specified resource group [+]")

		ind = args[0].index("-rgrp")
		resource_grp_name = args[0][ind+1]

		print("[+] getting nsg rules [+]")
		nsg_info = subprocess.run(['az', 'network', 'nsg', 'list', '-g', resource_grp_name, '--query', '[].{name:name, rule_access:securityRules[].access, rule_name:securityRules[].name, rule_priority:securityRules[].priority, sourceIP:securityRules[].sourceAddressPrefix, destPort:securityRules[].destinationPortRange}'], stdout=subprocess.PIPE)
		nsg_info_json = json.loads(nsg_info.stdout.decode('utf-8'))

		nsg_names = []
		for i in range(len(nsg_info_json)):
			nsg_dict = {}
			nsg_dict_rules = []
			for j in range(len(nsg_info_json[i]['rule_access'])):
				nsg_dict_sub_rules = []
				nsg_dict_sub_rules.append("Rule access: "+ str(nsg_info_json[i]['rule_access'][j]))
				nsg_dict_sub_rules.append("SourceIP: "+str(nsg_info_json[i]['sourceIP'][j]))
				nsg_dict_sub_rules.append("destination port: "+ str(nsg_info_json[i]['destPort'][j]))
				nsg_dict_sub_rules.append("rule name: "+str(nsg_info_json[i]['rule_name'][j]))
				nsg_dict_sub_rules.append("rule priority: "+str(nsg_info_json[i]['rule_priority'][j]))
				nsg_dict_rules.append(nsg_dict_sub_rules)
			nsg_dict[nsg_info_json[i]['name']] = nsg_dict_rules
			nsg_names.append(nsg_dict) 
			
		if(len(nsg_names) == 0):
			print("[-] none found [-]")
			return

		for nsg in nsg_names:
			pprint.pprint(nsg)





		



	
	


