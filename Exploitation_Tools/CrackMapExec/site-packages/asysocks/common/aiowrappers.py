import asyncio

async def readexactly_or_exc(reader, n, timeout = None):
	"""
	Helper function to read exactly N amount of data from the wire.
	:param reader: The reader object
	:type reader: asyncio.StreamReader
	:param n: The maximum amount of bytes to read.
	:type n: int
	:param timeout: Time in seconds to wait for the reader to return data
	:type timeout: int
	:return: bytearray
	"""
	temp = await asyncio.gather(*[asyncio.wait_for(reader.readexactly(n), timeout = timeout)], return_exceptions=True)
	if isinstance(temp[0], bytes):
		return temp[0]
	else:
		raise temp[0]


async def read_or_exc(reader, n, timeout = None):
	"""
	Helper function to read N amount of data from the wire.
	:param reader: The reader object
	:type reader: asyncio.StreamReader
	:param n: The maximum amount of bytes to read. BEWARE: this only sets an upper limit of the data to be read
	:type n: int
	:param timeout: Time in seconds to wait for the reader to return data
	:type timeout: int
	:return: bytearray
	"""

	temp = await asyncio.gather(*[asyncio.wait_for(reader.read(n), timeout = timeout)], return_exceptions=True)
	if isinstance(temp[0], bytes):
		return temp[0]
	else:
		raise temp[0]

async def readuntil_or_exc(reader, separator = b'\n', timeout = None):
	"""
	Helper function to read stream until separator is hit.
	:param reader: The reader object
	:type reader: asyncio.StreamReader
	:param n: The maximum amount of bytes to read. BEWARE: this only sets an upper limit of the data to be read
	:type n: int
	:param timeout: Time in seconds to wait for the reader to return data
	:type timeout: int
	:return: bytearray
	"""

	temp = await asyncio.gather(*[asyncio.wait_for(reader.readuntil(separator), timeout = timeout)], return_exceptions=True)
	if isinstance(temp[0], bytes):
		return temp[0]
	else:
		raise temp[0]