
import asyncio
import logging
import traceback

from asysocks import logger
from asysocks._version import __banner__

from asysocks.protocol.http import HTTPProxyAuthFailed
from asysocks.protocol.socks5 import SOCKS5AuthFailed
from asysocks.client import SOCKSClient
from asysocks.common.credentials import SocksCredential
from asysocks.common.comms import SocksQueueComms
from asysocks.protocol.socks5 import SOCKS5Method, SOCKS5Nego, SOCKS5NegoReply, SOCKS5Request, SOCKS5Reply, SOCKS5ReplyType, SOCKS5Command, SOCKS5PlainAuth, SOCKS5PlainAuthReply, SOCKS5ServerErrorReply
from asysocks.common.clienturl import SocksClientURL

class FileStringGen:
	"""
	Parses a file line by line
	"""
	def __init__(self, filename):
		self.filename = filename

	async def run(self, target_q):
		try:
			cnt = 0
			with open(self.filename, 'r') as f:
				for line in f:
					line = line.strip()
					if line == '':
						continue
					
					await target_q.put(line)
					await asyncio.sleep(0)
					cnt += 1
					
			return cnt, None
		except Exception as e:
			return cnt, e

class ListStringGen:
	def __init__(self, targets):
		self.targets = targets

	async def run(self, target_q):
		try:
			cnt = 0
			for target in self.targets:			
				await target_q.put(target)
				await asyncio.sleep(0)
				cnt += 1
			
			return cnt, None
		except Exception as e:
			return cnt, e


class SOCKSBrute:
	def __init__(self, connection_url):
		self.connection_url = connection_url
		self.user_gens = []
		self.password_gens = []
		self.passwords = {}
		self.worker_cnt = 100
		self.timeout = 1
		self.max_retries = 50
		self.retries_sleep = 1
		self.verify_target = '8.8.8.8'
		self.verify_port = 53
		self.output_file = None
		self.only_positive = False
		self.__worker_tasks = []
		self.__addr_queue = None
		self.__target_queue = None
		self.__result_queue = None
		self.__total_addrs = 0
		self.__total_targets = 0
		self.__total_finished = 0

	async def __scanner(self):
		try:
			while True:
				try:
					temp = await self.__target_queue.get()
					if temp is None:
						return
					
					username, password, client = temp

					retries = self.max_retries
					while retries != 0:
						if retries != self.max_retries:
							await asyncio.sleep(self.retries_sleep)
						retries -= 1
						_, err = await client.handle_queue()
						if err is not None:
							if isinstance(err, (HTTPProxyAuthFailed, SOCKS5AuthFailed)):
								await self.__result_queue.put((username, password, False, None))
								break
							
							continue
							

						await self.__result_queue.put((username, password, True, None))
						break
					
					if retries == 0:
						await self.__result_queue.put((username, password, None, err))

				except asyncio.CancelledError:
					return

				except Exception as e:
					pass
		
		except asyncio.CancelledError:
			return
				
		except Exception as e:
			print(e)

	async def __gen_targets(self):
		try:		
			while True:
				password = await self.__passwords_queue.get()
				if password is None:
					break
				self.passwords[password] = 1

			while True:
				user = await self.__users_queue.get()
				if user is None:
					break

				for password in self.passwords:
					self.__total_targets += 1
					credential = SocksCredential()
					credential.username = user
					credential.password = password
					target = self.connection_url.get_target()
					target.only_open = True
					target.only_auth = True
					target.endpoint_ip = self.verify_target
					target.endpoint_port = self.verify_port


					in_q = asyncio.Queue()
					out_q = asyncio.Queue()

					comms = SocksQueueComms(in_q, out_q)

					client = SOCKSClient(comms, target, credential)

					await self.__target_queue.put((user, password, client))
				
			self.__target_gen_finished_evt.set()

		except Exception as e:
			print(e)

	async def __gen_users(self):
		try:
			for user_gen in self.user_gens:
				cnt, err = await user_gen.run(self.__users_queue)
				if err is not None:
					print(err)
				self.__total_addrs += cnt

			await self.__users_queue.put(None)
		
		except Exception as e:
			print(e)

	async def __gen_passwords(self):
		try:
			for password_gen in self.password_gens:
				cnt, err = await password_gen.run(self.__passwords_queue)
				if err is not None:
					print(err)
				self.__total_addrs += cnt

			await self.__passwords_queue.put(None)
		
		except Exception as e:
			print(e)
	
	async def run(self):
		try:
			self.__passwords_queue = asyncio.Queue()
			self.__users_queue = asyncio.Queue()
			self.__target_queue = asyncio.Queue(self.worker_cnt)
			self.__result_queue = asyncio.Queue()
			self.__target_gen_finished_evt = asyncio.Event()
			asyncio.create_task(self.__gen_passwords())
			asyncio.create_task(self.__gen_users())
			asyncio.create_task(self.__gen_targets())

			for _ in range(self.worker_cnt):
				self.__worker_tasks.append(asyncio.create_task(self.__scanner()))
			
			outfile = None
			if self.output_file is not None:
				outfile = open(self.output_file, 'w', newline = '')
			while True:
				username, password, status, err = await self.__result_queue.get()
				self.__total_finished += 1
				

				if err is not None:
					print(err)
					print(traceback.format_tb(err.__traceback__))
				
				if err is None:
					if outfile is not None:
						outfile.write('%s:%s\r\n' % (username, password))
					elif status is True:
						print('%s:%s -> %s' % (username, password, status))
					elif self.only_positive is False:
						print('%s:%s -> %s' % (username, password, status))
				else:
					if self.only_positive is False:
						print('%s:%s -> %s' % (username, password, status))
				
				
				if self.__target_gen_finished_evt.is_set() is True:
					if self.__total_finished == self.__total_targets:
						break

			for _ in range(len(self.__worker_tasks)):
				await self.__target_queue.put(None)

			for worker in self.__worker_tasks:
				worker.cancel()

			return True, None
		except Exception as e:
			return False, e

def main():

	import argparse

	parser = argparse.ArgumentParser(description='SOCKS5 proxy auth bruteforcer')
	parser.add_argument('proxy_connection_string', help='connection string decribing the socks5 proxy server connection properties')
	parser.add_argument('-u', '--users', action='append', help='User or users file with one user per line. can be stacked')
	parser.add_argument('-p', '--passwords', action='append', help='Password or password file with one password per line. can be stacked')
	parser.add_argument('-t', '--timeout', type = int, default = None, help='Brute retries sleep time')
	parser.add_argument('-w', '--worker-count', type = int, default = 1, help='Parallelism')
	parser.add_argument('-v', '--verbose', action='count', default=0, help='Verbosity')
	parser.add_argument('-s', '--silent', action='store_true', help = 'dont print banner')
	parser.add_argument('-o', '--out-file', help = 'output file')
	parser.add_argument('--positive', action='store_true', help = 'only show sucsessful results')


	args = parser.parse_args()

	if args.silent is False:
		print(__banner__)

	logger.setLevel(100)
	if args.verbose >=1:
		logger.setLevel(logging.DEBUG)
		

	elif args.verbose > 2:
		logger.setLevel(1)

	url = SocksClientURL.from_url(args.proxy_connection_string)
	brute = SOCKSBrute(url)
	brute.timeout = args.timeout
	brute.worker_cnt = args.worker_count
	brute.output_file = args.out_file
	brute.only_positive = args.positive

	if args.users is None or args.passwords is None:
		print('Users "-u" and Passwords "-p" must be set! Exiting')
		return

	notfile = []
	for target in args.users:
		try:
			f = open(target, 'r')
			f.close()
			brute.user_gens.append(FileStringGen(target))
		except:
			notfile.append(target)
	
	if len(notfile) > 0:
		brute.user_gens.append(ListStringGen(notfile))

	if len(brute.user_gens) == 0:
		print('[-] No suitable users were found!')
		return

	notfile = []
	for target in args.passwords:
		try:
			f = open(target, 'r')
			f.close()
			brute.password_gens.append(FileStringGen(target))
		except:
			notfile.append(target)
	
	if len(notfile) > 0:
		brute.password_gens.append(ListStringGen(notfile))

	if len(brute.password_gens) == 0:
		print('[-] No suitable passwords were found!')
		return

	_, err = asyncio.run(brute.run())
	if err is not None:
		print('Failed to perform bruting! Reason: %s' % err)
		return
	
	if args.silent is False:
		print('Done!')

if __name__ == '__main__':
	main()