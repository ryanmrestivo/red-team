import subprocess
import json
import pprint

def start(args):

	help_str = "usage:\n\texec vmss_list [-rgrp resource-group -scale_set scale-set-name] ---> will list all vmss and all instance member public ips"
	if(len(args)>0):
		if(args[0][0] == "?"):
			print(help_str)
			return

	if(len(args) == 0):

		print("[+] getting vmss's in subscription [+]")
		vmss_list = subprocess.run(['az','vmss', 'list', '--query', '[].{name:name, rgrp:resourceGroup}'], stdout=subprocess.PIPE)
		vmss_list_json = json.loads(vmss_list.stdout.decode('utf-8'))

		for i in range(len(vmss_list_json)):
			
			vmss_list = subprocess.run(['az','vmss', 'list', '--resource-group', vmss_list_json[i]['rgrp'], '--query', '[].{name:name, vmss_size:sku.name, os_distro:virtualMachineProfile.storageProfile.imageReference.offer,os_version:virtualMachineProfile.storageProfile.imageReference.sku, username:virtualMachineProfile.osProfile.adminUsername, rgrp: resourceGroup}'], stdout=subprocess.PIPE)

			vmss_list_json = json.loads(vmss_list.stdout.decode('utf-8'))

			pprint.pprint(vmss_list_json[i])


			vmss_iplist = subprocess.run(['az','vmss', 'list-instance-public-ips', '--resource-group', vmss_list_json[i]['rgrp'], '--name', vmss_list_json[i]['name'],  '--query', '[].{ipAddress:ipAddress}'], stdout=subprocess.PIPE)
			vmss_iplist_json = json.loads(vmss_iplist.stdout.decode('utf-8'))


			pprint.pprint(vmss_iplist_json)

		return

	if "-rgrp" in args[0] and "-scale_set" in args[0]:

		print("[+] getting vmss's in specified scale set [+]")

		ind = args[0].index("-rgrp")
		resource_grp_name = args[0][ind+1]

		ind = args[0].index("-scale_set")
		scale_set_name = args[0][ind+1]

		vmss_list = subprocess.run(['az','vmss', 'list', '--resource-group', resource_grp_name, '--query', '[].{name:name, vmss_size:sku.name, os:virtualMachineProfile.storageProfile.imageReference.offer, username:virtualMachineProfile.osProfile.adminUsername, resource_group: resourceGroup}'], stdout=subprocess.PIPE)

		vmss_list_json = json.loads(vmss_list.stdout.decode('utf-8'))

		pprint.pprint(vmss_list_json)

		vmss_iplist = subprocess.run(['az','vmss', 'list-instance-public-ips', '--resource-group', resource_grp_name, '--name', scale_set_name,  '--query', '[].{ipAddress:ipAddress}'], stdout=subprocess.PIPE)
		vmss_iplist_json = json.loads(vmss_iplist.stdout.decode('utf-8'))

		pprint.pprint(vmss_iplist_json)
		
		for i in range(len(vmss_list_json)):
			vmss_list_json[i].update(vmss_iplist_json[i])
		return


	if "-rgrp" in args[0] and "-scale_set" not in args[0]:

		print("[+] getting vmss's in specified resource group [+]")

		ind = args[0].index("-rgrp")
		resource_grp_name = args[0][ind+1]

		vmss_list = subprocess.run(['az','vmss', 'list', '--query', '[].{name:name}'], stdout=subprocess.PIPE)
		vmss_list_json = json.loads(vmss_list.stdout.decode('utf-8'))

		for i in range(len(vmss_list_json)):
			
			vmss_list = subprocess.run(['az','vmss', 'list', '--resource-group', resource_grp_name, '--query', '[].{name:name, vmss_size:sku.name, os_distro:virtualMachineProfile.storageProfile.imageReference.offer,os_version:virtualMachineProfile.storageProfile.imageReference.sku, username:virtualMachineProfile.osProfile.adminUsername, rgrp: resourceGroup}'], stdout=subprocess.PIPE)

			vmss_list_json = json.loads(vmss_list.stdout.decode('utf-8'))

			pprint.pprint(vmss_list_json[i])


			vmss_iplist = subprocess.run(['az','vmss', 'list-instance-public-ips', '--resource-group', resource_grp_name, '--name', vmss_list_json[i]['name'],  '--query', '[].{ipAddress:ipAddress}'], stdout=subprocess.PIPE)
			vmss_iplist_json = json.loads(vmss_iplist.stdout.decode('utf-8'))

			pprint.pprint(vmss_iplist_json)

			print()
		
		#pprint.pprint(vmss_list_json)
		

