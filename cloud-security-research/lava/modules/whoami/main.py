import subprocess
import json
import pprint

def start(args):

	whoami = subprocess.run(['az','account', 'show', '--query', '{subscription:name, username: user.name, tenant:tenantId}'], stdout=subprocess.PIPE)
	whoami_json = json.loads(whoami.stdout.decode('utf-8'))

	pprint.pprint(whoami_json)
