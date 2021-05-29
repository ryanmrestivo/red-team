import subprocess
import json
import pprint

def start(args):

	print("[+] getting resource groups in subscription [+]")
	rgroup = subprocess.run(['az','group', 'list', '--query', '[].{name:name, location: location, id: id}'], stdout=subprocess.PIPE)
	rgroup_json = json.loads(rgroup.stdout.decode('utf-8'))

	pprint.pprint(rgroup_json)

