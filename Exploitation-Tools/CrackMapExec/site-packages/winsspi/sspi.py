import enum
import queue
from winsspi.common.function_defs import *
from winsspi.common.gssapi.asn1_structs import *

class SSPIResult(enum.Enum):
	OK = 'OK'
	CONTINUE = 'CONT'
	ERR = 'ERR'
	
class SSPIModule(enum.Enum):
	NTLM = 'NTLM'
	KERBEROS = 'KERBEROS'
	DIGEST = 'DIGEST'
	NEGOTIATE = 'NEGOTIATE'
	CREDSSP = 'CREDSSP'
	SCHANNEL = 'SCHANNEL'
	
class SSPI:
	def __init__(self, package_name):
		self.cred_struct = None
		self.context = None
		self.package_name = package_name
		
	def _get_session_key(self):
		sec_struct = SecPkgContext_SessionKey()
		QueryContextAttributes(self.context, SECPKG_ATTR.SESSION_KEY, sec_struct)
		return sec_struct.Buffer
		
	def _get_credentials(self, client_name, target_name, flags = SECPKG_CRED.BOTH):
		self.cred_struct = AcquireCredentialsHandle(client_name, self.package_name.value, target_name, flags)
		
	def _init_ctx(self, target, token_data = None, flags = ISC_REQ.INTEGRITY | ISC_REQ.CONFIDENTIALITY | ISC_REQ.SEQUENCE_DETECT | ISC_REQ.REPLAY_DETECT):
		res, self.context, data, outputflags, expiry = InitializeSecurityContext(self.cred_struct, target, token = token_data, ctx = self.context, flags = flags)
		if res == SEC_E.OK:
			return SSPIResult.OK, data
		else:
			return SSPIResult.CONTINUE, data
			
	def _unwrap(self, data, message_no = 0):
		data_buff = DecryptMessage(self.context, data, message_no)
		return data_buff
		
	def _wrap(self, data, message_no = 0):
		data_buff = EncryptMessage(self.context, data, message_no)
		return data_buff
	
	def authGSSClientInit(self, client_name, target_name):
		raise Exception('Not implemented!')
	def authGSSClientStep(self, token_data):
		raise Exception('Not implemented!')
	def authGSSClientResponse(self):
		raise Exception('Not implemented!')	
	def authGSSClientResponseConf(self):
		raise Exception('Not implemented!')	
	def authGSSClientUserName(self):
		raise Exception('Not implemented!')	
	def authGSSClientUnwrap(self):
		raise Exception('Not implemented!')	
	def authGSSClientUnwrap(self):
		raise Exception('Not implemented!')	
	def authGSSClientClean(self):
		raise Exception('Not implemented!')	
	def channelBindings(self):
		raise Exception('Not implemented!')	
	def authGSSServerInit(self):
		raise Exception('Not implemented!')	
	def authGSSServerStep(self):
		raise Exception('Not implemented!')	
	def authGSSServerResponse(self):
		raise Exception('Not implemented!')
	def authGSSServerUserName(self):
		raise Exception('Not implemented!')
	def authGSSServerClean(self):
		raise Exception('Not implemented!')	

"""
.. autofunction:: authGSSClientInit
   .. autofunction:: authGSSClientStep
   .. autofunction:: authGSSClientResponse
   .. autofunction:: authGSSClientResponseConf
   .. autofunction:: authGSSClientUserName
   .. autofunction:: authGSSClientUnwrap
   .. autofunction:: authGSSClientWrap
   .. autofunction:: authGSSClientClean
   .. autofunction:: channelBindings
   .. autofunction:: authGSSServerInit
   .. autofunction:: authGSSServerStep
   .. autofunction:: authGSSServerResponse
   .. autofunction:: authGSSServerUserName
   .. autofunction:: authGSSServerClean
"""

class NegotiateSSPI(SSPI):
	def __init__(self):
		SSPI.__init__(self, SSPIModule.NEGOTIATE)
		self.client_name = None
		self.target_name = None
		self.response_data = queue.Queue()
		
	def get_session_key(self):
		return self._get_session_key()
		
	def authGSSClientInit(self, target_name, client_name = None):
		self.target_name = target_name
		self.client_name = client_name
		self._get_credentials(client_name, target_name)
		
	def authGSSClientStep(self, token_data = None):
		res, data = self._init_ctx(self.target_name, token_data)
		self.response_data.put(data[0][1])
		return res, data
		
	def authGSSClientResponse(self):
		return self.response_data.get()
		
	def authGSSClientUnwrap(self, data, message_no = 0):
		return self._unwrap(data, message_no)
		
class KerberosSSPI(SSPI):
	def __init__(self):
		SSPI.__init__(self, SSPIModule.KERBEROS)
		self.client_name = None
		self.target_name = None		
		self.response_data = queue.Queue()
		
	def get_session_key(self):
		return self._get_session_key()
		
	def authGSSClientInit(self, target_name, client_name = None):
		self.target_name = target_name
		self._get_credentials(client_name, target_name)
		
	def authGSSClientStep(self, token_data = None):
		res, data = self._init_ctx(self.target_name, token_data)
		self.response_data.put(data)
		return res
		
	def authGSSClientResponse(self):
		return self.response_data.get()
		
	def authGSSClientUnwrap(self, data, message_no = 0):
		return self._unwrap(data, message_no)
		
class KerberoastSSPI(SSPI):
	def __init__(self):
		SSPI.__init__(self, SSPIModule.KERBEROS)
		self.target_name = None
		
	def get_ticket_for_spn(self, target_name):
		self.target_name = target_name
		self._get_credentials(None, target_name)
		res, data = self._init_ctx(self.target_name, None)
		token = InitialContextToken.load(data[0][1])
		return token.native['innerContextToken'] #this is the AP_REQ


class KerberoastSSPI2(SSPI):
	def __init__(self):
		SSPI.__init__(self, SSPIModule.KERBEROS)
		self.target_name = None
		
	def get_ticket_for_spn(self, target_name, flags = ISC_REQ.INTEGRITY | ISC_REQ.CONFIDENTIALITY | ISC_REQ.SEQUENCE_DETECT | ISC_REQ.REPLAY_DETECT):
		self.target_name = target_name
		self._get_credentials(None, target_name)
		res, data = self._init_ctx(self.target_name, None, flags=flags)
		
		return data[0][1]
		
class KerberosSMBSSPI(SSPI):
	def __init__(self, client_name = None):
		SSPI.__init__(self, SSPIModule.KERBEROS)
		self.target_name = None
		self.client_name = None #client_name
		
	def encrypt(self, data, message_no):
		return self._wrap(data, message_no)
		
	def decrypt(self, data, message_no):
		return self._unwrap(data, message_no)
		
	def get_session_key(self):
		return self._get_session_key()
		
	def get_ticket_for_spn(self, target_name, flags = None, is_rpc = False, token_data = None):
		try:
			self.target_name = target_name
			if not self.cred_struct:
				self._get_credentials(self.client_name, self.target_name)
			
			if is_rpc == True:
				res, self.context, data, outputflags, expiry = InitializeSecurityContext(self.cred_struct, self.target_name, token = token_data, ctx = self.context, flags = flags)
				return data[0][1], outputflags, None
			else:
				res, self.context, data, outputflags, expiry = InitializeSecurityContext(self.cred_struct, self.target_name, token = None, ctx = self.context, flags = flags)
				#res, data = self._init_ctx(self.target_name, flags = flags)
				token = InitialContextToken.load(data[0][1])
				return AP_REQ(token.native['innerContextToken']).dump(),  outputflags, None #this is the AP_REQ
		except Exception as e:
			return None, None, e
		
		
class NTLMSMBSSPI(SSPI):
	def __init__(self, client_name = None):
		SSPI.__init__(self, SSPIModule.NTLM)
		self.target_name = None
		self.client_name = client_name
		self.flags = ISC_REQ.CONNECTION
		
	def get_session_key(self):
		return self._get_session_key()
		
	def negotiate(self, is_rpc = False):
		self._get_credentials(self.client_name, self.target_name, flags = SECPKG_CRED.BOTH)
		if is_rpc == True:
			self.flags = ISC_REQ.REPLAY_DETECT | ISC_REQ.CONFIDENTIALITY| ISC_REQ.USE_SESSION_KEY| ISC_REQ.INTEGRITY| ISC_REQ.SEQUENCE_DETECT| ISC_REQ.CONNECTION
		res, data = self._init_ctx(self.target_name, None, flags = self.flags)
		return data[0][1], True	
		
	def authenticate(self, autorize_data, is_rpc = False):
		if is_rpc == True:
			self.flags = ISC_REQ.REPLAY_DETECT | ISC_REQ.CONFIDENTIALITY| ISC_REQ.USE_SESSION_KEY| ISC_REQ.INTEGRITY| ISC_REQ.SEQUENCE_DETECT| ISC_REQ.CONNECTION
		res, data = self._init_ctx(self.target_name, autorize_data, flags = self.flags)
		return data[0][1], False
		
	def encrypt(self, data, message_no):
		return self._wrap(data, message_no)
		
	def decrypt(self, data, message_no):
		return self._unwrap(data, message_no)
		
		

class LDAP3NTLMSSPI(SSPI):
	def __init__(self, user_name = None, domain = None, password = None):
		SSPI.__init__(self, SSPIModule.NTLM)
		self.client_name = None
		self.target_name = None
		
		self.authenticate_data = None
		#self.flags = ISC_REQ.USE_DCE_STYLE | ISC_REQ.DELEGATE | ISC_REQ.MUTUAL_AUTH |ISC_REQ.REPLAY_DETECT |ISC_REQ.SEQUENCE_DETECT |ISC_REQ.CONFIDENTIALITY |ISC_REQ.CONNECTION
		self.flags = ISC_REQ.CONNECTION
		
	def get_session_key(self):
		return self._get_session_key()
		
	def create_negotiate_message(self):
		self._get_credentials(self.client_name, self.target_name, flags = SECPKG_CRED.OUTBOUND)
		res, data = self._init_ctx(self.target_name, None, flags = self.flags )
		return data[0][1]
		
	def create_authenticate_message(self):
		return self.authenticate_data
		
		
	def parse_challenge_message(self, autorize_data):
		res, data = self._init_ctx(self.target_name, autorize_data, flags = self.flags)
		self.authenticate_data = data[0][1]

class KerberosMSLDAPSSPI:
	def __init__(self, domain = None, username = None, password = None, credusage_flags = SECPKG_CRED.BOTH):
		SSPI.__init__(self, SSPIModule.KERBEROS)
		self.target_name = None
		self.domain = domain
		self.username = username
		self.password = password
		self.credusage_flags = credusage_flags
		self.ctx_flags = None
		self.ctx_outflags = None
		self.context = None
		self.cred_struct = None
		
	def get_session_key(self):
		try:
			sec_struct = SecPkgContext_SessionKey()
			QueryContextAttributes(self.context, SECPKG_ATTR.SESSION_KEY, sec_struct)
			return sec_struct.Buffer, None
		except Exception as e:
			return None, e
		
	def get_ticket_for_spn(self, target_name, ctx_flags = ISC_REQ.CONNECTION, token_data = None):
		self.ctx_flags = ctx_flags
		self.target_name = target_name
		if self.cred_struct is None:
			self.cred_struct = AcquireCredentialsHandle(self.username, 'KERBEROS', self.target_name, self.credusage_flags)
		
		res, self.context, data, self.ctx_outflags, expiry = InitializeSecurityContext(
			self.cred_struct, 
			self.target_name, 
			token = token_data, 
			ctx = self.context, 
			flags = self.ctx_flags if self.ctx_outflags is None else self.ctx_outflags
		)
		if ISC_REQ.MUTUAL_AUTH in ISC_REQ(self.ctx_outflags.value) or ISC_REQ.USE_DCE_STYLE in ISC_REQ(self.ctx_outflags.value):
			return data[0][1], ISC_REQ(self.ctx_outflags.value)
		
		token = InitialContextToken.load(data[0][1])
		return AP_REQ(token.native['innerContextToken']).dump(), ISC_REQ(self.ctx_outflags.value)


class NTLMMSLDAPSSPI:
	def __init__(self, client_name = None, target_name = None, credusage_flags = SECPKG_CRED.BOTH):
		self.target_name = target_name
		self.client_name = client_name
		self.credusage_flags = credusage_flags
		self.ctx_flags = None
		self.ctx_outflags = None
		self.context = None

		self.cred_struct = None
		
	def get_session_key(self):
		sec_struct = SecPkgContext_SessionKey()
		QueryContextAttributes(self.context, SECPKG_ATTR.SESSION_KEY, sec_struct)
		return sec_struct.Buffer

	#def set_chbind(self, cb_data):
	#	SetContextAttributes(self.context, SECPKG_ATTR.ENDPOINT_BINDINGS, cb_data)
		
	def negotiate(self, is_rpc = False, ctx_flags = ISC_REQ.CONNECTION , cb_data = None):
		self.ctx_flags = ctx_flags
		self.cred_struct = AcquireCredentialsHandle(self.client_name, 'NTLM', self.target_name, self.credusage_flags)
		res, self.context, data, self.ctx_outflags, expiry = InitializeSecurityContext(
			self.cred_struct, 
			self.target_name, 
			token = None, 
			ctx = None, 
			flags = self.ctx_flags
		)
		if res == SEC_E.OK:
			return data[0][1], True	
		else:
			return data[0][1], True	
		
	def authenticate(self, autorize_data, is_rpc = False, ctx_flags = ISC_REQ.CONNECTION):
		res, self.context, data, self.ctx_outflags, expiry = InitializeSecurityContext(
			self.cred_struct, 
			self.target_name, 
			token = autorize_data, 
			ctx = self.context, 
			flags = self.ctx_outflags
		)
		if res == SEC_E.OK:
			return data[0][1], True	
		else:
			return data[0][1], True	
		