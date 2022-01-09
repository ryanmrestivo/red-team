import subprocess
import json
import pprint

def start(args):
	
	help_str = "usage:\n\texec priv_suggest ---> will enumerate all attached roles and associated permissions and parse out what we deem 'interesting' permissions"

	if(len(args)>0):
		if(args[0][0] == "?"):
			print(help_str)
			return
	
	print("[+] getting the UPN of the current user [+]")
	upn_resp = subprocess.run(['az', 'ad', 'signed-in-user', 'show','--query', '{upn:userPrincipalName}'], stdout=subprocess.PIPE)
	upn_json_obj = json.loads(upn_resp.stdout.decode('utf-8'))
	upn = upn_json_obj['upn']

	print("[+] getting the roles of the current user [+]")
	role_resp = subprocess.run(['az', 'role', 'assignment', 'list', '--assignee', upn, '--query', '[].{roleName:roleDefinitionName}'], stdout=subprocess.PIPE)
	role_json_obj = json.loads(role_resp.stdout.decode('utf-8'))

	role_list = []
	for role in role_json_obj:
		role_list.append(role["roleName"])

	if(len(role_list) == 0):
		print("[-] no roles found [-]")
		return

	print("[+] getting definitions for each role found [+]")
	tmp_list_perms = []
	for role in role_list:
		print(role.upper())
		role_show = subprocess.run(['az', 'role', 'definition', 'list', '--name', role, '--query', '[].{actions:permissions[].actions, dataActions:permissions[].dataActions, notActions:permissions[].notActions, notDataActions:permissions[].NotDataActions}'], stdout=subprocess.PIPE)
		role_show_json = json.loads(role_show.stdout.decode('utf-8'))
		tmp_list_perms.append(role_show_json[0]['actions'][0])


	all_permissions = [item for sublist in tmp_list_perms for item in sublist]
	#pprint.pprint(all_permissions)

	analyze_perms(all_permissions)


def analyze_perms(all_permissions):
	print("[+] dumping potentially interesting permissions attached [+]")
	for perm in all_permissions:

		if("*" in perm):
			print("[+] found permission with * - should investigate: ", perm, "[+]")
		elif("write" in perm):
			print("[+] found permission with write - should investigate: ", perm, "[+]")
		elif("create" in perm):
			print("[+] found permission with create - should investigate: ", perm, "[+]")
		elif("delete" in perm):
			print("[+] found permission with delete - should investigate: ", perm, "[+]")


	print("\n[+] will now analyze specific permissions we deem interesting [+]\n")

	for perm in all_permissions:


		if("Microsoft.Authorization/*" in perm):
			print("[+] current user has permission to do all authorizations actions to resources - consider RBAC manipulation and adding a backdoor AD user [+]")
		if("Microsoft.Authorization/*/read" in perm):
			print("[+] current user has permission to read all authorizations - consider running the priv domain enum module [+]")


		if("Microsoft.Compute/*" in perm):
			print("[+] current user has permission to run all operations for all resource types - consider using the exfil modules [+]")
		if("Microsoft.Compute/*/read" in perm):
			print("[+] current user has permission to read all compute related resources - consider using the various 'list' modules [+]")


		if("Microsoft.Support/*" in perm):
			print("[+] current user has permission to issue and submit support tickets [+]")

		if("Microsoft.Resources/*" in perm):
			print("[+] current user has permission to run all Microsoft.Resources related commands [+]")
		elif("Microsoft.Resources/deployments/*" in perm):
			print("[+] current user has permission to run all deployment related commands [+]")
		elif("Microsoft.Resources/deployments/subscriptions/*" in perm):
			print("[+] current user has permission to run all subscription related commands [+]")


		if("Microsoft.Network/*" in perm):
			print("[+] current user has permission to run all networking related commands - consider running the net modules [+]")
		elif("Microsoft.Network/networkSecurityGroups/*" in perm):
			print("[+] current user has permission to run all nsg related commands - consider running the nsg backdoor module [+]")
		elif("Microsoft.Network/networkSecurityGroups/join/action" in perm):
			print("[+] current user has permission to join a network security group [+]")
			

		if("Microsoft.Compute/virtualMachines/*" in perm):
			print("[+] current user has permission to run virtual machine commands - consider running the various vm modules [+]")
		elif("Microsoft.Compute/virtualMachines/runCommand/action" in perm or "Microsoft.Compute/virtualMachines/runCommand/*" in perm):
			print("[+] current user has permission to run the runCommand virtual machine command - consider running the vm_rce [+]")

		if("Microsoft.Compute/virtualMachinesScaleSets/*" in perm):
			print("[+] current user has permission to run virtual machine scale set commands - consider running the various vmss modules [+]")
		elif("Microsoft.Compute/virtualMachinesScaleSets/runCommand/action" in perm or "Microsoft.Compute/virtualMachines/runCommand/*" in perm):
			print("[+] current user has permission to run the runCommand virtual machine scale set command - consider running the vmss_rce [+]")

		if("Microsoft.Storage/*" in perm or "Microsoft.Storage/storageAccounts/*" in perm):
			print("[+] current user has permission to run all storage account commands - consider running the various stg modules [+]")
		elif("Microsoft.Storage/storageAccounts/blobServices/containers/*" in perm):
			print("[+] current user has permissions to run all storage account container commands - consider running the various stg modules [+]")
		elif("Microsoft.Storage/storageAccounts/listKeys/action" in perm):
			print("[+] current user has permission to read storage account keys - consider running the stg blob scan/download modules [+]")

		if("Microsoft.Sql/*" in perm):
			print("+] current user has permission to run all sql commands - consider running the various sql modules [+]")
		elif("Microsoft.Sql/servers/*" in perm):
			print("+] current user has permission to run all sql server commands - consider running the sql server list or the sql backdoor firewall modules [+]")
		elif("Microsoft.Sql/servers/databases/*" in perm):
			print("+] current user has permission to run all sql database commands - consider running the sql db list [+]")
		


	
	