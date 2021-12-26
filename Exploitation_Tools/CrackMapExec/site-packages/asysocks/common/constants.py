import enum

class SocksServerVersion(enum.Enum):
	SOCKS4 = 'SOCKS4'
	SOCKS5 = 'SOCKS5'
	SOCKS5S = 'SOCKS5S'
	SOCKS4S = 'SOCKS4S'
	HTTP = 'HTTP'
	HTTPS = 'HTTPS'

class SocksProtocol(enum.Enum):
	TCP = 'TCP'
	UDP = 'UDP'

class SocksCommsMode(enum.Enum):
	LISTENER = 'LISTENER'
	QUEUE = 'QUEUE'

class SOCKS5Method(enum.Enum):
	NOAUTH = 0x00
	GSSAPI = 0x01
	PLAIN  = 0x02
	# IANA ASSIGNED X'03' to X'7F'
	# RESERVED FOR PRIVATE METHODS X'80' to X'FE'

	NOTACCEPTABLE = 0xFF