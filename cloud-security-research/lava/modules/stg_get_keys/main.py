import subprocess
import json
import pprint

def start(args):
	storage_order = ['blob', 'dfs', 'file', 'queue', 'table', 'web']

	help_str = "usage:\n\texec stg_get_keys ---> scans subscription for storage account keys"
	
	if(len(args)>0):
		if(args[0][0] == "?"):
			print(help_str)
			return

	print("[+] getting storage accounts in subscription... [+]")
	val = subprocess.run(['az', 'storage', 'account', 'list', '--query', '[].{acct_name:name, resource_group:resourceGroup, storage_types:primaryEndpoints}'], stdout=subprocess.PIPE)
	json_obj = json.loads(val.stdout.decode('utf-8'))
	#pprint.pprint(json_obj)

	print("[+] getting the account names [+]")
	print("[+] getting the resource group names [+]")
	print("[+] getting the storage endpoint names [+]\n")

	accts = []
	rgroups = []
	tmp_storages = []
	for acct in json_obj:
		accts.append(acct['acct_name'])
		rgroups.append(acct['resource_group'])
		tmp = []
		for stor_type in acct['storage_types']:
			#print(stor_type)
			tmp.append(acct['storage_types'][stor_type])
		tmp_storages.append(tmp)

	storages = []
	for i in range(len(tmp_storages)):
		tmp = []
		for val in tmp_storages[i]:
			if val != None and 'blob' in val:
				tmp.append(val)
		storages.append(tmp)


	#get account keys

	print("[+] getting the account keys [+]")

	account_keys = []
	for i in range(len(accts)):
		ret = subprocess.run(['az', 'storage', 'account', 'keys', 'list', '--account-name', accts[i]], stdout=subprocess.PIPE)
		if(ret.returncode != 0):
			print("[-] error: could not list account keys [-]")
			return
		json_obj = json.loads(ret.stdout.decode('utf-8'))
		account_keys.append(json_obj[0]['value'])

	pprint.pprint(account_keys)


