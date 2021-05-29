import subprocess
import json
import pprint

def start(args):
	storage_order = ['blob', 'dfs', 'file', 'queue', 'table', 'web']

	help_str = "usage:\n\texec stg_file_scan ---> scans available storage accounts in subscription for files"
	
	if(len(args)>0):
		if(args[0][0] == "?"):
			print(help_str)
			return

	print("[+] getting storage accounts in subscription... [+]")
	val = subprocess.run(['az', 'storage', 'account', 'list', '--query', '[].{acct_name:name, resource_group:resourceGroup, storage_types:primaryEndpoints}'], stdout=subprocess.PIPE)
	json_obj = json.loads(val.stdout.decode('utf-8'))


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
			if val != None and 'file' in val:
				tmp.append(val)
		storages.append(tmp)


	#get account keys
	print("[+] getting the account keys [+]")

	account_keys = []
	for i in range(len(accts)):
		ret = subprocess.run(['az', 'storage', 'account', 'keys', 'list', '--account-name', accts[i]], stdout=subprocess.PIPE)
		if(ret.returncode != 0):
			print("some error")
			return
		json_obj = json.loads(ret.stdout.decode('utf-8'))
		account_keys.append(json_obj[0]['value'])


	#get share list

	print("[+] getting the share list [+]")

	shares = []
	for i in range(len(accts)):
		ret = subprocess.run(['az', 'storage', 'share', 'list', '--account-name', accts[i], '--account-key', account_keys[i]], stdout=subprocess.PIPE)
		if(ret.returncode != 0):
			print("[-] error: could not list shares [-]")
			return
		json_obj = json.loads(ret.stdout.decode('utf-8'))
		tmp_conts = []
		#tmp_conts.append(rgroups[i])
		for i in range(len(json_obj)):
			tmp_conts.append(json_obj[i]['name'])
		shares.append(tmp_conts)


	print("[+] getting files and creating fqdn path [+]")
	
	files = []
	for i in range(len(accts)):
		for share in shares[i]:
			ret = subprocess.run(['az', 'storage', 'file', 'list', '--share-name', share, '--account-name', accts[i], '--account-key', account_keys[i]], stdout=subprocess.PIPE)
			if(ret.returncode != 0):
				print("[-] error: could not list files in", share, "[-]")
				return
			json_obj = json.loads(ret.stdout.decode('utf-8'))
			tmp_files = []
			tmp_files.append(storages[i][0])
			tmp_files.append(share)
			for ind in range(len(json_obj)):
				tmp_files.append(json_obj[ind]['name'])
			files.append(tmp_files)

	full_urls = []
	for i in range(len(files)):
		for j in range(2, len(files[i])):
			url = files[i][0]+files[i][1]
			full_urls.append(url+"/"+files[i][j])

	if(len(full_urls) > 0):
		print("[+] got files! [+]")
		pprint.pprint(full_urls)
		print("")
	else:
		print("[-] nothing was found in the shares discovered")


