import asyncio


class HTTPProxyAuthRequiredException(Exception):
	pass

class HTTPProxyAuthFailed(Exception):
	pass

class HTTPResponse:
	def __init__(self):
		self.version = None
		self.status = None
		self.reason = None
		self.headers = {}
		self.headers_upper = {}
		self.data = None

	@staticmethod
	async def from_streamreader(reader, timeout = None):
		try:
			resp = HTTPResponse()
						
			#reading headers
			temp = await asyncio.wait_for(reader.readuntil(b'\r\n\r\n'), timeout = timeout)
			temp = temp.split(b'\r\n')[:-1]
			version, status, reason = temp[0].split(b' ', 2)
			resp.version = version.decode()
			resp.status = int(status.decode())
			resp.reason = reason.decode()

			for hdr_raw in temp[1:]:
				if hdr_raw.strip() == b'':
					continue
				key_raw, value_raw = hdr_raw.split(b': ', 1)
				key = key_raw.decode()
				value = value_raw.strip().decode()

				resp.headers[key] = value
				resp.headers_upper[key.upper()] = value
						
			if 'CONTENT-LENGTH' in resp.headers_upper:
				rem_len = int(resp.headers_upper['CONTENT-LENGTH'])
				resp.data = await asyncio.wait_for(reader.readexactly(rem_len), timeout = timeout)

			return resp, None
		
		except Exception as e:
			return None, e