
import asyncio
import ipaddress
import logging

from asysocks import logger

from asysocks.client import SOCKSClient
from asysocks.common.comms import SocksQueueComms
from asysocks.protocol.socks5 import SOCKS5Method, SOCKS5Nego, SOCKS5NegoReply, SOCKS5Request, SOCKS5Reply, SOCKS5ReplyType, SOCKS5Command, SOCKS5PlainAuth, SOCKS5PlainAuthReply, SOCKS5ServerErrorReply
from asysocks.common.clienturl import SocksClientURL

class FileTargetPortGen:
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
					
					if line.find('-') != -1:
						start, end = line.split('-')
						for i in range(int(start), int(end)):
							await target_q.put(i)
							await asyncio.sleep(0)
							cnt += 1
					
					else:
						try:
							line = int(line)
							await target_q.put(line)
							await asyncio.sleep(0)
							cnt += 1
						except:
							pass
					
			return cnt, None
		except Exception as e:
			return cnt, e

class FileTargetIPGen:
	"""
	Parses a file line by line looking for ip address or ipaddres range or hostname
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

					try:
						ipaddress.ip_address(line)
						await target_q.put(line)
						await asyncio.sleep(0)
						cnt += 1
						continue
					except:
						pass
					
					try:
						for ipaddr in ipaddress.ip_network(line,strict=False):
							await target_q.put(str(ipaddr))
							await asyncio.sleep(0)
							cnt += 1
						continue
					except:
						pass
					
					await target_q.put(line)
					await asyncio.sleep(0)
					cnt += 1
					
			return cnt, None
		except Exception as e:
			return cnt, e

class ListTargetIPGen:
	def __init__(self, targets):
		self.targets = targets

	async def run(self, target_q):
		try:
			cnt = 0
			for target in self.targets:
				
				try:
					ipaddress.ip_address(target)
					await target_q.put(target)
					await asyncio.sleep(0)
					cnt += 1
					continue
				except:
					pass
					
				try:
					for ipaddr in ipaddress.ip_network(target,strict=False):
						await target_q.put(str(ipaddr))
						await asyncio.sleep(0)
						cnt += 1
					continue
				except:
					pass
				
				
				await target_q.put(target)
				await asyncio.sleep(0)
				cnt += 1
			
			return cnt, None
		except Exception as e:
			return cnt, e

class ListTargetPortGen:
	def __init__(self, targets):
		self.targets = targets
		self.ports = {}

	def run(self):
		try:
			for target in self.targets:
				
				if target.find('-') != -1:
					start, end = target.split('-')
					for i in range(int(start), int(end)):
						self.ports[i] = 1
					
				else:
					try:
						target = int(target)
						self.ports[target] = 1
					except:
						pass

			return self.ports
		except Exception as e:
			return e


class SOCKSPortscan:
	def __init__(self, connection_url):
		self.connection_url = connection_url
		self.target_gens = []
		self.port_gens = []
		self.ports = {}
		self.worker_cnt = 10
		self.max_retries = 1
		self.retries_timeout = 1
		self.__worker_tasks = []
		self.__addr_queue = None
		self.__target_queue = None
		self.__result_queue = None
		self.__total_addrs = 0
		self.__total_targets = 0
		self.__total_finished = 0
		self.__addr_gen_finished_evt = None

	async def __scanner(self):
		try:
			while True:
				try:
					temp = await self.__target_queue.get()
					if temp is None:
						return
					
					ip, port, client = temp

					retries = self.max_retries
					while retries != 0:
						if retries != self.max_retries:
							await asyncio.sleep(self.retries_timeout)
						retries -= 1
						_, err = await client.handle_queue()
						if err is not None:
							#print(err)
							if isinstance(err, SOCKS5ServerErrorReply):
								if err.reply in [SOCKS5ReplyType.TTL_EXPIRED, SOCKS5ReplyType.CONN_REFUSED, SOCKS5ReplyType.HOST_UNREACHABLE, SOCKS5ReplyType.CONN_NOT_ALLOWED]:
									await self.__result_queue.put((ip, port, False, None))	

								elif err.reply in [SOCKS5ReplyType.ADDRESS_TYPE_NOT_SUPPORTED]:
									await self.__result_queue.put((ip, port, None, err))
								
								break
							
							continue
						

						await self.__result_queue.put((ip, port, True, None))
						break
					
					if retries == 0:
						await self.__result_queue.put((ip, port, None, Exception('Max tries reached!')))

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
			for port_gen in self.port_gens:
				ports = port_gen.run()
				for port in ports:
					self.ports[port] = 1

			
			while True:
				addr = await self.__addr_queue.get()
				if addr is None:
					break
				print(addr)
				for port in self.ports:
					self.__total_targets += 1
					credential = self.connection_url.get_creds()
					target = self.connection_url.get_target()
					target.endpoint_ip = addr
					target.endpoint_port = port
					target.timeout = None
					target.only_open = True


					in_q = asyncio.Queue()
					out_q = asyncio.Queue()

					comms = SocksQueueComms(in_q, out_q)

					client = SOCKSClient(comms, target, credential)

					await self.__target_queue.put((addr, port, client))
				
			self.__target_gen_finished_evt.set()

		except Exception as e:
			print(e)

	async def __gen_addrs(self):
		try:
			for target_gen in self.target_gens:
				cnt, err = await target_gen.run(self.__addr_queue)
				print(cnt)
				if err is not None:
					print(err)
				self.__total_addrs += cnt

			await self.__addr_queue.put(None)
			self.__addr_gen_finished_evt.set()
		
		except Exception as e:
			print(e)
	
	async def run(self):
		try:
			self.__addr_queue = asyncio.Queue()
			self.__target_queue = asyncio.Queue()
			self.__result_queue = asyncio.Queue()
			self.__addr_gen_finished_evt = asyncio.Event()
			self.__target_gen_finished_evt = asyncio.Event()
			asyncio.create_task(self.__gen_addrs())
			asyncio.create_task(self.__gen_targets())

			for _ in range(self.worker_cnt):
				self.__worker_tasks.append(asyncio.create_task(self.__scanner()))
			
			while True:
				ip, port, status, err = await self.__result_queue.get()
				self.__total_finished += 1

				if status is True:
					print('%s:%s -> %s' % (ip, port, status))
				
				if self.__target_gen_finished_evt.is_set() is True:
					if self.__total_finished == self.__total_targets:
						print('END!')
						print(self.__total_finished)
						print(self.__total_targets)
						break

			for _ in range(len(self.__worker_tasks)):
				await self.__target_queue.put(None)

			for worker in self.__worker_tasks:
				worker.cancel()
		
		except Exception as e:
			print(e)

def main():

	import argparse

	parser = argparse.ArgumentParser(description='SOCKS/HTTP proxy port scanner')
	parser.add_argument('proxy_connection_string', help='connection string decribing the socks5 proxy server connection properties')
	parser.add_argument('-p', '--ports', action='append', help='port to scan / port range to scan / port range file. can be stacked')
	parser.add_argument('-t', '--timeout', type = int, default = None, help='Scan retries sleep time')
	parser.add_argument('-r', '--retries', type = int, default = 0, help='Retries for testing the port')
	parser.add_argument('-w', '--worker-count', type = int, default = 1, help='Parallelism')
	parser.add_argument('-v', '--verbose', action='count', default=0)
	parser.add_argument('targets', nargs='+', help='IP address / IP range (CDIR) / targets file')

	args = parser.parse_args()


	logger.setLevel(100)
	if args.verbose >=1:
		logger.setLevel(logging.DEBUG)
		

	elif args.verbose > 2:
		logger.setLevel(1)

	url = SocksClientURL.from_url(args.proxy_connection_string)
	scanner = SOCKSPortscan(url)
	scanner.max_retries = args.retries
	scanner.retries_timeout = args.timeout
	scanner.worker_cnt = args.worker_count

	notfile = []
	for target in args.targets:
		try:
			f = open(target, 'r')
			f.close()
			scanner.target_gens.append(FileTargetIPGen(target))
		except:
			notfile.append(target)
	
	if len(notfile) > 0:
		scanner.target_gens.append(ListTargetIPGen(notfile))

	if len(scanner.target_gens) == 0:
		print('[-] No suitable targets were found!')
		return

	notfile = []
	for target in args.ports:
		try:
			f = open(target, 'r')
			f.close()
			scanner.port_gens.append(FileTargetPortGen(target))
		except:
			notfile.append(target)
	
	if len(notfile) > 0:
		scanner.port_gens.append(ListTargetPortGen(notfile))

	if len(scanner.port_gens) == 0:
		print('[-] No suitable ports were found!')
		return

	asyncio.run(scanner.run())


if __name__ == '__main__':
	main()