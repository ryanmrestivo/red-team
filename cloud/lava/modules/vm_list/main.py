import subprocess
import json
import pprint

def start(args):

	help_str = "usage:\n\texec vm_list [-rgrp resource-group] ---> will list all vms and public/private ips"

	if(len(args)>0):
		if(args[0][0] == "?"):
			print(help_str)
			return

	
	if(len(args) == 0):

		print("[+] getting vm's in subscription [+]")
		
		vm_list = subprocess.run(['az','vm', 'list', '--query', '[].{name:name,os:storageProfile.osDisk.osType, username:osProfile.adminUsername, vm_size:hardwareProfile.vmSize, resource_group: resourceGroup}'], stdout=subprocess.PIPE)
		vm_list_json = json.loads(vm_list.stdout.decode('utf-8'))

		vm_iplist = subprocess.run(['az','vm', 'list-ip-addresses', '--query', '[].{name:virtualMachine.name, privateIp:virtualMachine.network.privateIpAddresses, publicIp:virtualMachine.network.publicIpAddresses[].ipAddress}'], stdout=subprocess.PIPE)
		vm_iplist_json = json.loads(vm_iplist.stdout.decode('utf-8'))

		for i in range(len(vm_list_json)):
			vm_list_json[i].update(vm_iplist_json[i])
		
		pprint.pprint(vm_list_json)

		return
	
	if "-rgrp" in args[0]:

		print("[+] getting vm's in specified resource group [+]")

		ind = args[0].index("-rgrp")
		resource_grp_name = args[0][ind+1]

		vm_list = subprocess.run(['az','vm', 'list', '-g', resource_grp_name, '--query', '[].{name:name,os:storageProfile.osDisk.osType, username:osProfile.adminUsername, vm_size:hardwareProfile.vmSize, resource_group: resourceGroup}'], stdout=subprocess.PIPE)
		vm_list_json = json.loads(vm_list.stdout.decode('utf-8'))

		vm_iplist = subprocess.run(['az','vm', 'list-ip-addresses', '-g', resource_grp_name, '--query', '[].{name:virtualMachine.name, privateIp:virtualMachine.network.privateIpAddresses, publicIp:virtualMachine.network.publicIpAddresses[].ipAddress}'], stdout=subprocess.PIPE)
		vm_iplist_json = json.loads(vm_iplist.stdout.decode('utf-8'))

		for i in range(len(vm_list_json)):
			vm_list_json[i].update(vm_iplist_json[i])
		
		pprint.pprint(vm_list_json)

	
		

