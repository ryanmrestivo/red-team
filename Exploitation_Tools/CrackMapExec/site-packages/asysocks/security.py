

import asyncio
import ipaddress
import random

from asysocks import logger
from asysocks.common.constants import SocksServerVersion, SocksCommsMode
from asysocks.protocol.socks4 import SOCKS4Request, SOCKS4Reply, SOCKS4CDCode
from asysocks.protocol.socks5 import SOCKS5Method, SOCKS5Nego, SOCKS5NegoReply, SOCKS5Request, SOCKS5Reply, SOCKS5ReplyType, SOCKS5Command, SOCKS5PlainAuth, SOCKS5PlainAuthReply, SOCKS5ServerErrorReply
from asysocks.common.target import SocksTarget
from asysocks.common.credentials import SocksCredential
from asysocks.common.comms import SocksQueueComms
from asysocks.client import SOCKSClient


class SocksSecurity:
	def __init__(self):
		self.server_ip = None
		self.server_port = None
		self.server_sslctx = None
		self.timeout = None

		self.verify_host = None #endpoint ip/hostname to test the connection
		self.verify_port = None #endpoint port
		self.verify_send = None #data to be sent to the endpoint service upon succsessfull connection
		self.verify_recv = None #data expected from the endpoint service in response to verify_send
	
	def socks4_noauth(self):
		pass

	async def socks5_authmethods(self, methods = [SOCKS5Method.NOAUTH, SOCKS5Method.PLAIN, SOCKS5Method.GSSAPI], timeout = None):
		"""
		Checks which auth methods are supported by the server
		"""
		supported = []
		notsupported = []
		errors = []

		for method in methods:
			remote_reader = None
			remote_writer = None
			try:
				logger.debug('method %s' % method.name)
				try:
					remote_reader, remote_writer = await asyncio.wait_for(
						asyncio.open_connection(
							self.server_ip, 
							self.server_port,
							ssl = self.server_sslctx,
						),
						timeout = self.timeout
					)
					logger.debug('Connected to socks server!')
				except Exception as e:
					logger.debug('Failed to connect to SOCKS server!')
					return None, None, e
				
				nego = SOCKS5Nego.from_methods([method])
				logger.debug('[SOCKS5] Sending negotiation command to server @ %s:%d' % remote_writer.get_extra_info('peername'))
				remote_writer.write(nego.to_bytes())
				await asyncio.wait_for(
					remote_writer.drain(), 
					timeout = timeout
				)

				rep_nego = await asyncio.wait_for(
					SOCKS5NegoReply.from_streamreader(remote_reader), 
					timeout = timeout
					)
				logger.debug(
					'[SOCKS5] Got negotiation reply from from %s! Server choosen auth type: %s' % 
					(remote_writer.get_extra_info('peername'), rep_nego.METHOD.name)
				)

				if rep_nego.METHOD == method:
					supported.append(method)
				else:
					notsupported.append(method)
			
			except Exception as e:
				logger.debug('Failed proto test for method %s. Reason: %s' % (method.name, e))
				errors.append((method, e))
				continue
			
			finally:
				if remote_writer is not None:
					remote_writer.close()

		
		return supported, notsupported, errors

	async def socks5_login(self, username, password, timeout = None):
		"""
		Tries to open connection to a remote endpoint using the socks proxy server using plaintext auth method with username and password
		"""
		try:
			remote_reader = None
			remote_writer = None
			try:
				remote_reader, remote_writer = await asyncio.wait_for(
					asyncio.open_connection(
						self.server_ip, 
						self.server_port,
						ssl = self.server_sslctx,
					),
					timeout = self.timeout
				)
				logger.debug('Connected to socks server!')
			except Exception as e:
				logger.debug('Failed to connect to SOCKS server!')
				return None, e

			
			logger.debug('[SOCKS5] invoked')
			methods = [SOCKS5Method.PLAIN]

			nego = SOCKS5Nego.from_methods(methods)
			logger.debug('[SOCKS5] Sending negotiation command to server @ %s:%d' % remote_writer.get_extra_info('peername'))
			remote_writer.write(nego.to_bytes())
			await asyncio.wait_for(
				remote_writer.drain(), 
				timeout = timeout
			)

			rep_nego = await asyncio.wait_for(
				SOCKS5NegoReply.from_streamreader(remote_reader), 
				timeout = timeout
			)
			logger.debug(
				'[SOCKS5] Got negotiation reply from from %s! Server choosen auth type: %s' % 
				(remote_writer.get_extra_info('peername'), rep_nego.METHOD.name)
			)

			if rep_nego.METHOD != SOCKS5Method.PLAIN:
				return False, None

			auth = SOCKS5PlainAuth.construct(username, password)

			remote_writer.write(auth.to_bytes())
			await asyncio.wait_for(
				remote_writer.drain(), 
				timeout = timeout
			)
			
			rep_data = await asyncio.wait_for(
				remote_reader.read(2),
				timeout = timeout
			)

			if rep_data == b'':
				return False, None

			rep_nego = SOCKS5PlainAuthReply.from_bytes(rep_data)

			if rep_nego.STATUS != SOCKS5ReplyType.SUCCEEDED:
				return False, None


			if self.verify_host is None:
				return True, None
			
			logger.debug('[SOCKS5] Opening channel to %s:%s' % (self.verify_host, self.verify_port))
			logger.debug('[SOCKS5] Sending connect request to SOCKS server @ %s:%d' % remote_writer.get_extra_info('peername'))

			try:
				target = ipaddress.ip_address(self.verify_host)
			except:
				target = self.verify_host

			remote_writer.write(
				SOCKS5Request.construct(
					SOCKS5Command.CONNECT,
					target,
					int(self.verify_port)
				).to_bytes()
			)

			await asyncio.wait_for(
				remote_writer.drain(), 
				timeout=timeout
			)

			rep = await asyncio.wait_for(
				SOCKS5Reply.from_streamreader(remote_reader), 
				timeout=timeout
			)
			if rep.REP != SOCKS5ReplyType.SUCCEEDED:
				#logger.info('Failed to connect to proxy %s! Server replied: %s' % (self.proxy_writer.get_extra_info('peername'), repr(rep.REP)))
				return False, rep.REP.name				
			
			logger.debug('[SOCKS5] Server @ %s:%d successfully set up the connection to the endpoint! ' % remote_writer.get_extra_info('peername'))
			if self.verify_send is None:
				return True, None
			
			remote_writer.write(self.verify_send)
			await asyncio.wait_for(
				remote_writer.drain(), 
				timeout=timeout
			)

			data = await remote_reader.read(4096)
			if data.find(self.verify_recv) == -1:
				return False, None

			return True, None
			
		except Exception as e:
			return None, e

		finally:
			if remote_writer is not None:
				remote_writer.close()

	async def socks5_noauth(self, timeout = None):
		"""
		Tries to open connection to a remote endpoint using the socks proxy server without authentication
		"""
		try:
			remote_reader = None
			remote_writer = None
			try:
				remote_reader, remote_writer = await asyncio.wait_for(
					asyncio.open_connection(
						self.server_ip, 
						self.server_port,
						ssl = self.server_sslctx,
					),
					timeout = self.timeout
				)
				logger.debug('Connected to socks server!')
			except Exception as e:
				logger.debug('Failed to connect to SOCKS server!')
				return None, e

			
			logger.debug('[SOCKS5] invoked')
			methods = [SOCKS5Method.NOAUTH]

			nego = SOCKS5Nego.from_methods(methods)
			logger.debug('[SOCKS5] Sending negotiation command to server @ %s:%d' % remote_writer.get_extra_info('peername'))
			remote_writer.write(nego.to_bytes())
			await asyncio.wait_for(
				remote_writer.drain(), 
				timeout = timeout
			)

			rep_nego = await asyncio.wait_for(
				SOCKS5NegoReply.from_streamreader(remote_reader), 
				timeout = timeout
			)
			logger.debug(
				'[SOCKS5] Got negotiation reply from from %s! Server choosen auth type: %s' % 
				(remote_writer.get_extra_info('peername'), rep_nego.METHOD.name)
			)

			if rep_nego.METHOD != SOCKS5Method.NOAUTH:
				return False, None


			if self.verify_host is None:
				return True, None
			
			logger.debug('[SOCKS5] Opening channel to %s:%s' % (self.verify_host, self.verify_port))
			logger.debug('[SOCKS5] Sending connect request to SOCKS server @ %s:%d' % remote_writer.get_extra_info('peername'))

			try:
				target = ipaddress.ip_address(self.verify_host)
			except:
				target = self.verify_host

			remote_writer.write(
				SOCKS5Request.construct(
					SOCKS5Command.CONNECT,
					target, 
					int(self.verify_port)
				).to_bytes()
			)

			await asyncio.wait_for(
				remote_writer.drain(), 
				timeout=timeout
			)

			rep = await asyncio.wait_for(
				SOCKS5Reply.from_streamreader(remote_reader), 
				timeout=timeout
			)
			if rep.REP != SOCKS5ReplyType.SUCCEEDED:
				#logger.info('Failed to connect to proxy %s! Server replied: %s' % (self.proxy_writer.get_extra_info('peername'), repr(rep.REP)))
				return False, rep.REP.name				
			
			logger.debug('[SOCKS5] Server @ %s:%d successfully set up the connection to the endpoint! ' % remote_writer.get_extra_info('peername'))
			if self.verify_send is None:
				return True, None
			
			remote_writer.write(self.verify_send)
			await asyncio.wait_for(
				remote_writer.drain(), 
				timeout=timeout
			)

			data = await remote_reader.read(4096)
			if data.find(self.verify_recv) == -1:
				return False, None

			return True, None
			

		except Exception as e:
			return None, e

		finally:
			if remote_writer is not None:
				remote_writer.close()


	async def socks5_bind(self, username = None, password = None, timeout = None):
		"""
		Tests if port binding is supported by the socks server
		"""
		try:
			target = SocksTarget()
			target.version = SocksServerVersion.SOCKS5
			target.server_ip = self.server_ip
			target.server_port = self.server_port
			target.is_bind = True
			target.timeout = 10
			target.buffer_size = 4096
			target.ssl_ctx = self.server_sslctx
			target.endpoint_ip = '0.0.0.0'
			target.endpoint_port = random.randint(35000, 50000)
			target.endpoint_timeout = None
			target.only_bind = True

			credential = SocksCredential()
			credential.username = username
			credential.password = password

			in_q = asyncio.Queue()
			out_q = asyncio.Queue()

			comms = SocksQueueComms(in_q, out_q)
			client = SOCKSClient(comms, target, credential)
			
			res, err = await client.handle_queue()
			if err is None:
				return True, None
			
			if isinstance(err, SOCKS5ServerErrorReply):
				if err.reply == SOCKS5ReplyType.COMMAND_NOT_SUPPORTED:
					return False, None

			return res, err
		except Exception as e:
			return None, e

	async def socks5_local(self, username = None, password = None, timeout = None):
		"""
		Tests if port binding is supported by the socks server
		"""
		try:
			target = SocksTarget()
			target.version = SocksServerVersion.SOCKS5
			target.server_ip = self.server_ip
			target.server_port = self.server_port
			target.is_bind = False
			target.timeout = 10
			target.buffer_size = 4096
			target.ssl_ctx = self.server_sslctx
			target.endpoint_ip = self.server_ip
			target.endpoint_port = self.verify_port if self.verify_port is not None else 22
			target.endpoint_timeout = None

			credential = SocksCredential()
			credential.username = username
			credential.password = password

			in_q = asyncio.Queue()
			out_q = asyncio.Queue()

			comms = SocksQueueComms(in_q, out_q)
			client = SOCKSClient(comms, target, credential)
			
			res, err = await client.handle_queue()
			if err is None:
				return True, None
			
			if isinstance(err, SOCKS5ServerErrorReply):
				if err.reply in [SOCKS5ReplyType.FAILURE, SOCKS5ReplyType.CONN_NOT_ALLOWED]:
					return False, None

			return res, err
		except Exception as e:
			return None, e

	async def socks5_test_port(self, username = None, password = None, timeout = None, retries = -1):
		"""
		Tests if port binding is supported by the socks server
		"""
		try:
			while retries != 0:
				retries -= 1
				target = SocksTarget()
				target.version = SocksServerVersion.SOCKS5
				target.server_ip = self.server_ip
				target.server_port = self.server_port
				target.is_bind = False
				target.timeout = 10
				target.buffer_size = 4096
				target.ssl_ctx = self.server_sslctx
				target.endpoint_ip = self.verify_host
				target.endpoint_port = self.verify_port #random.randint(35000, 50000)
				target.endpoint_timeout = None
				target.only_open = True

				credential = SocksCredential()
				credential.username = username
				credential.password = password

				in_q = asyncio.Queue()
				out_q = asyncio.Queue()

				comms = SocksQueueComms(in_q, out_q)
				channel_open_evt = asyncio.Event()
				
				client = SOCKSClient(comms, target, credential, bind_evt = channel_open_evt)
				#client_task = asyncio.create_task(client.run())

				res, err = await client.handle_queue()
				if err is not None:
					if isinstance(err, SOCKS5ServerErrorReply):
						if err.reply in [SOCKS5ReplyType.TTL_EXPIRED, SOCKS5ReplyType.CONN_REFUSED, SOCKS5ReplyType.HOST_UNREACHABLE, SOCKS5ReplyType.CONN_NOT_ALLOWED]:
							return False, err

						elif err.reply in [SOCKS5ReplyType.ADDRESS_TYPE_NOT_SUPPORTED]:
							return None, err
					
					continue

				return True, None
			return None, Exception('Max retries reached!')
		except Exception as e:
			return None, e


