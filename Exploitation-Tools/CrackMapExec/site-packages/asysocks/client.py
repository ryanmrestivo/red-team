
import asyncio
import base64

from asysocks import logger
from asysocks.common.constants import SocksServerVersion, SocksCommsMode
from asysocks.protocol.http import HTTPResponse, HTTPProxyAuthRequiredException, HTTPProxyAuthFailed
from asysocks.protocol.socks4 import SOCKS4Request, SOCKS4Reply, SOCKS4CDCode
from asysocks.protocol.socks5 import SOCKS5Method, SOCKS5Nego, SOCKS5NegoReply, SOCKS5Request, SOCKS5Reply, SOCKS5ReplyType, SOCKS5PlainAuth, SOCKS5PlainAuthReply, SOCKS5ServerErrorReply, SOCKS5AuthFailed



class SOCKSClient:
	def __init__(self, comms, target, credentials = None, bind_evt = None, channel_open_evt = None):
		self.target = target
		self.comms = comms
		self.credentials = credentials
		self.server_task = None
		self.proxytask_in = None
		self.proxytask_out = None
		self.proxy_stopped_evt = None
		self.__http_auth = None
		self.bind_progress_evt = bind_evt
		self.bind_port = None
		self.channel_open_evt = channel_open_evt
	
	async def terminate(self):
		if self.proxy_stopped_evt is not None:
			self.proxy_stopped_evt.set()
		if self.proxytask_in is not None:
			self.proxytask_in.cancel()
		if self.proxytask_out is not None:
			self.proxytask_out.cancel()


	@staticmethod
	async def proxy_stream(in_stream, out_stream, proxy_stopped_evt, buffer_size = 4096, timeout = None):
		try:
			while True:
				data = await asyncio.wait_for(
					in_stream.read(buffer_size),
					timeout = timeout
				)
				if data == b'':
					logger.debug('Stream channel broken!')
					return
				out_stream.write(data)
				await out_stream.drain()
		except asyncio.CancelledError:
			return
		except asyncio.TimeoutError:
			logger.debug('proxy_stream timeout! (timeout=%s)' % str(timeout))
		except Exception as e:
			logger.debug('proxy_stream err: %s' % str(e))
		finally:
			proxy_stopped_evt.set()

	@staticmethod
	async def proxy_queue_in(in_queue, writer, proxy_stopped_evt, buffer_size = 4096):
		try:
			while True:
				data = await in_queue.get()
				if data is None:
					logger.debug('proxy_queue_in client disconncted!')
					return
				writer.write(data)
				await writer.drain()
		except asyncio.CancelledError:
			return
		except Exception as e:
			logger.debug('proxy_queue_in err: %s' % str(e))
		finally:
			proxy_stopped_evt.set()
			try:
				writer.close()
			except:
				pass

	@staticmethod
	async def proxy_queue_out(out_queue, reader, proxy_stopped_evt, buffer_size = 4096, timeout = None):
		try:
			while True:
				data = await asyncio.wait_for(
					reader.read(buffer_size),
					timeout = timeout
				)
				if data == b'':
					logger.debug('proxy_queue_out endpoint disconncted!')
					await out_queue.put((None, Exception('proxy_queue_out endpoint disconncted gracefully!')))
					return
				await out_queue.put((data, None))
		except asyncio.CancelledError:
			await out_queue.put((None, Exception('proxy_queue_out got cancelled!')))
			return
		except Exception as e:
			logger.debug('')
			try:
				await out_queue.put((None, e))
			except:
				pass
		finally:
			proxy_stopped_evt.set()
	

	async def run_http(self, remote_reader, remote_writer, timeout = None):		
		try:
			#

			logger.debug('[HTTP] Opening channel to %s:%s' % (self.target.endpoint_ip, self.target.endpoint_port))
			connect_cmd = 'CONNECT %s:%s HTTP/1.1\r\nHost: %s:%s\r\n' % (self.target.endpoint_ip, self.target.endpoint_port,self.target.endpoint_ip, self.target.endpoint_port)
			connect_cmd = connect_cmd.encode()

			if self.__http_auth is None:
				
				remote_writer.write(connect_cmd + b'\r\n')
				#remote_writer.write(connect_cmd + b'\r\n')
				await asyncio.wait_for(remote_writer.drain(), timeout = timeout)
				
				resp, err = await HTTPResponse.from_streamreader(remote_reader, timeout=timeout)
				if err is not None:
					raise err

				if resp.status == 200:
					logger.debug('[HTTP] Server succsessfully connected!')
					return True, None
			
				elif resp.status == 407:
					logger.debug('[HTTP] Server proxy auth required!')

					if self.credentials is None:
						raise Exception('HTTP proxy auth required but no credentials set!')
					
					auth_type = resp.headers_upper.get('PROXY-AUTHENTICATE', None)
					if auth_type is None:
						raise Exception('HTTP proxy requires authentication, but requested auth type could not be determined')
					
					auth_type, _ = auth_type.split(' ', 1)
					self.__http_auth = auth_type.upper()

					return False, HTTPProxyAuthRequiredException()
			
			elif self.__http_auth == 'BASIC':
				auth_data = base64.b64encode(('%s:%s' % (self.credentials.username, self.credentials.password) ).encode() )
				auth_connect = connect_cmd + b'Proxy-Authorization: Basic ' + auth_data + b'\r\n'
				remote_writer.write(auth_connect + b'\r\n')
				await asyncio.wait_for(remote_writer.drain(), timeout = timeout)

				resp, err = await HTTPResponse.from_streamreader(remote_reader, timeout=timeout)
				if err is not None:
					raise err

				if resp.status == 200:
					logger.debug('[HTTP] Server proxy auth succsess!')
					return True, None
					
				else:
					raise HTTPProxyAuthFailed() #raise Exception('Proxy auth failed!')
				
			else:
				raise Exception('HTTP proxy requires %s authentication, but it\'s not implemented' % self.__http_auth)


		except Exception as e:
			logger.debug('run_http')
			return False, e

	async def run_socks4(self, remote_reader, remote_writer, timeout = None):
		"""
		Does the intial "handshake" instructing the remote server to set up the connection to the endpoint
		"""
		try:
			#logger.debug('[SOCKS4] Requesting new channel from remote socks server')
			logger.debug('[SOCKS4] Opening channel to %s:%s' % (self.target.endpoint_ip, self.target.endpoint_port))
			req = SOCKS4Request.from_target(self.target)
			if self.credentials is not None and self.credentials.username is not None:
				req.USERID = self.credentials.username
			remote_writer.write(req.to_bytes())
			await asyncio.wait_for(remote_writer.drain(), timeout = timeout)
			rep, err = await asyncio.wait_for(SOCKS4Reply.from_streamreader(remote_reader), timeout = timeout)
			if err is not None:
				raise err

			if rep is None:
				raise Exception('Socks server failed to reply to CONNECT request!')

			if rep.CD != SOCKS4CDCode.REP_GRANTED:
				raise Exception('Socks server returned error on CONNECT! %s' % rep.CD.value)
			logger.debug('[SOCKS4] Channel opened')
			return True, None
		except Exception as e:
			logger.debug('run_socks4')
			return False, e

	async def run_socks5(self, remote_reader, remote_writer, timeout = None):
		"""
		Does the intial "handshake" instructing the remote server to set up the connection to the endpoint
		"""
		logger.debug('[SOCKS5] invoked')
		
		methods = [SOCKS5Method.NOAUTH]
		if self.credentials is not None and self.credentials.username is not None and self.credentials.password is not None:
			#methods.append(SOCKS5Method.PLAIN)
			methods = [SOCKS5Method.PLAIN]
		try:
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
			#logger.debug('Got negotiation reply from %s: %s' % (self.proxy_writer.get_extra_info('peername'), repr(rep_nego)))
			
			if rep_nego.METHOD == SOCKS5Method.PLAIN:
				if self.credentials is None or self.credentials.username is None or self.credentials.password is None:
					raise Exception('SOCKS5 server requires PLAIN authentication, but no credentials were supplied!')
				
				logger.debug('Preforming plaintext auth to %s:%d' % remote_writer.get_extra_info('peername'))
				remote_writer.write(
					SOCKS5PlainAuth.construct(
						self.credentials.username, 
						self.credentials.password
					).to_bytes()
				)
				await asyncio.wait_for(
					remote_writer.drain(), 
					timeout=None
				)
				rep_data = await asyncio.wait_for(
					remote_reader.read(2),
					timeout = timeout
				)

				if rep_data == b'':
					raise SOCKS5AuthFailed() #raise Exception('Plaintext auth failed! Bad username or password')

				rep_nego = SOCKS5PlainAuthReply.from_bytes(rep_data)

				if rep_nego.STATUS != SOCKS5ReplyType.SUCCEEDED:
					raise SOCKS5AuthFailed() #raise Exception('Plaintext auth failed! Bad username or password')

			elif rep_nego.METHOD == SOCKS5Method.GSSAPI:
				raise Exception('SOCKS5 server requires GSSAPI authentication, but it\'s not supported at the moment')

			logger.debug('[SOCKS5] Opening channel to %s:%s' % (self.target.endpoint_ip, self.target.endpoint_port))
			logger.debug('[SOCKS5] Sending connect request to SOCKS server @ %s:%d' % remote_writer.get_extra_info('peername'))
			
			if self.target.only_auth is True:
				return True, None

			remote_writer.write(
				SOCKS5Request.from_target(
					self.target
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
				logger.info('Socks5 remote end failed to connect to target! Reson: %s' % rep.REP.name)
				raise SOCKS5ServerErrorReply(rep.REP)
			
			if self.target.is_bind is False:
				logger.debug('[SOCKS5] Server @ %s:%d successfully set up the connection to the endpoint! ' % remote_writer.get_extra_info('peername'))
				return True, None
			
			s_ip, s_port = remote_writer.get_extra_info('peername')
			logger.debug('[SOCKS5] Server @ %s:%d BIND first set completed, port %s available!' % (s_ip, s_port , rep.BIND_PORT))
			#bind in progress, waiting for a second reply to notify us that the remote endpoint connected back.
			
			self.bind_port = rep.BIND_PORT
			self.bind_progress_evt.set() #notifying that the bind port is now available on the socks server to be used
			if self.target.only_bind is True:
				return True, None

			rep = await asyncio.wait_for(
				SOCKS5Reply.from_streamreader(remote_reader), 
				timeout=timeout
			)

			if rep.REP != SOCKS5ReplyType.SUCCEEDED:
				logger.info('Socks5 remote end failed to connect to target! Reson: %s' % rep.REP.name)
				raise SOCKS5ServerErrorReply(rep.REP)

			return True, None

		except Exception as e:
			logger.debug('[SOCKS5] Error in run_socks5 %s' % e)
			return False, e

	async def handle_client(self, reader, writer):
		remote_writer = None
		remote_reader = None

		try:
			logger.debug('[handle_client] Client connected!')
			
			for i in range(3, 0 , -1):
				if remote_writer is not None:
					remote_writer.close()

				try:
					remote_reader, remote_writer = await asyncio.wait_for(
						asyncio.open_connection(
							self.target.server_ip, 
							self.target.server_port,
							ssl=self.target.ssl_ctx,
						),
						timeout = self.target.timeout
					)
					logger.debug('Connected to socks server!')
				except:
					logger.debug('Failed to connect to SOCKS server!')
					raise
				
				if self.target.version in [SocksServerVersion.SOCKS4, SocksServerVersion.SOCKS4S]:
					_, err = await self.run_socks4(remote_reader, remote_writer)
					if err is not None:
						raise err
					break

				elif self.target.version in [SocksServerVersion.SOCKS5, SocksServerVersion.SOCKS5S]:
					_, err = await self.run_socks5(remote_reader, remote_writer)
					if err is not None:
						raise err
					break
				
				elif self.target.version in [SocksServerVersion.HTTP, SocksServerVersion.HTTPS]:
					_, err = await self.run_http(remote_reader, remote_writer)
					if i > 0 and isinstance(err, HTTPProxyAuthRequiredException):
						continue
					if err is not None:
						raise err
					break

				else:
					raise Exception('Unknown SOCKS version!')
			
			logger.debug('[handle_client] Starting proxy...')
			self.channel_open_evt.set()
			self.proxy_stopped_evt = asyncio.Event()
			self.proxytask_in = asyncio.create_task(
				SOCKSClient.proxy_stream(
					reader, 
					remote_writer, 
					self.proxy_stopped_evt , 
					buffer_size = self.target.buffer_size,
					timeout = self.target.endpoint_timeout
				)
			)
			self.proxytask_out = asyncio.create_task(
				SOCKSClient.proxy_stream(
					remote_reader, 
					writer, 
					self.proxy_stopped_evt, 
					buffer_size = self.target.buffer_size,
					timeout = self.target.endpoint_timeout
				)
			)
			logger.debug('[handle_client] Proxy started!')
			await self.proxy_stopped_evt.wait()
			logger.debug('[handle_client] Proxy stopped!')
			self.proxytask_in.cancel()
			self.proxytask_out.cancel()
		
		except Exception as e:
			logger.exception('[handle_client]')

		finally:
			if remote_writer is not None:
				remote_writer.close()

	async def handle_queue(self):
		logger.debug('[queue] Connecting to socks server...')
		#connecting to socks server
		remote_writer = None
		remote_reader = None
		if self.bind_progress_evt is None:
			self.bind_progress_evt = asyncio.Event()

		try:
			for i in range(3, 0 , -1):
				if remote_writer is not None:
					remote_writer.close()
				
				remote_reader, remote_writer = await asyncio.wait_for(
					asyncio.open_connection(
						self.target.server_ip, 
						self.target.server_port
					),
					timeout = self.target.timeout
				)

				logger.debug('[queue] Connected to socks server!')

				if self.target.version in [SocksServerVersion.SOCKS4, SocksServerVersion.SOCKS4S]:
					_, err = await self.run_socks4(remote_reader, remote_writer)
					if err is not None:
						raise err
					break

				elif self.target.version in [SocksServerVersion.SOCKS5, SocksServerVersion.SOCKS5S]:
					_, err = await self.run_socks5(remote_reader, remote_writer)
					if err is not None:
						raise err
					break
				
				elif self.target.version in [SocksServerVersion.HTTP, SocksServerVersion.HTTPS]:
					_, err = await self.run_http(remote_reader, remote_writer)
					if i > 0 and isinstance(err, HTTPProxyAuthRequiredException):
						continue
					if err is not None:
						raise err
					break

				else:
					raise Exception('[queue] Unknown SOCKS version!')
			
			if self.target.only_bind is True:
				return True, None

			if self.target.only_open is True or self.target.only_auth is True:
				# for auth guessing and connection testing
				return True, None

			if self.channel_open_evt is not None:
				self.channel_open_evt.set()
			logger.debug('[queue] Starting proxy...')
			
			self.proxy_stopped_evt = asyncio.Event()
			self.proxytask_in = asyncio.create_task(
				SOCKSClient.proxy_queue_in(
					self.comms.in_queue, 
					remote_writer, 
					self.proxy_stopped_evt, 
					buffer_size = self.target.buffer_size
				)
			)
			self.proxytask_out = asyncio.create_task(
				SOCKSClient.proxy_queue_out(
					self.comms.out_queue, 
					remote_reader, 
					self.proxy_stopped_evt, 
					buffer_size = self.target.buffer_size, 
					timeout = self.target.endpoint_timeout
				)
			)
			logger.debug('[queue] Proxy started!')
			await self.proxy_stopped_evt.wait()
			logger.debug('[queue] Proxy stopped!')
			self.proxytask_in.cancel()
			self.proxytask_out.cancel()

			return True, None
		
		except Exception as e:
			await self.comms.in_queue.put((None,e))
			await self.comms.out_queue.put((None,e))
			return False, e
		
		finally:
			if remote_writer is not None:
				remote_writer.close()


	async def run(self):
		if self.target.is_bind is True and self.bind_progress_evt is None:
			self.bind_progress_evt = asyncio.Event()
		
		if self.channel_open_evt is None:
			self.channel_open_evt = asyncio.Event()
		
		if self.comms.mode == SocksCommsMode.LISTENER:
			server = await asyncio.start_server(
				self.handle_client, 
				self.comms.listen_ip, 
				self.comms.listen_port,

			)
			logger.debug('[PROXY] Awaiting server task now...')
			await server.serve_forever()

		else:
			await self.handle_queue()
		