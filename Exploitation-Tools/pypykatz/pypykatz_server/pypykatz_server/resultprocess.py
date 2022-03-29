import os
import json
from multiprocessing import Queue, Process
from pypykatz.commons.common import UniversalEncoder
import traceback

class ResultProcessing(Process):
	def __init__(self, resQ, output_dir):
		Process.__init__(self)
		self.resQ = resQ
		self.output_dir = output_dir
		
		if not os.path.exists(self.output_dir):
			try:
				os.makedirs(self.output_dir)
			except Exception as e:
				traceback.print_exc()
		
		
	def run(self):
		while True:
			data = self.resQ.get()
			print('Got data!')
			if not data:
				break
			mimi, peer_addr = data
			self.process_result(mimi, peer_addr)
			
			
	def process_result(self, mimi, peer_addr):
		try:
			peer_addr = peer_addr.replace(':','_').replace('.','_')
			outfile = os.path.join(self.output_dir, '%s_%s.json' % (peer_addr,os.urandom(4).hex()))
			with open(outfile, 'w') as f:
				json.dump(mimi, f, cls = UniversalEncoder, indent=4, sort_keys=True)
				
			kdir = os.path.join(self.output_dir, '%s_%s' % (peer_addr,os.urandom(4).hex()), 'kerberos')
			os.makedirs(kdir)
			mimi.kerberos_ccache.to_file(os.path.join(kdir, 'tickets.ccache'))
			
		except Exception as e:
			traceback.print_exc()	