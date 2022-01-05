import io
import enum

###
### TOTAL_LEN|CMD|VAR_CNT|LEN_VAR1|VAR1      |LEN_VAR2|VAR2
### 4        |1  |1      |4       |len(var_n)|4       |len(varn+1)....
###
class PYPYCMDType(enum.Enum):
	INIT = 0
	FIND = 1
	READ = 2
	ERR = 3
	OK = 4
	END = 5

class PYPYCMD:
	def __init__(self):
		self.cmdtype = None
		self.params = []
	
	@staticmethod
	def from_string(data):
		return PYPYCMD.from_bytes(bytes.fromhex(data))
		
	@staticmethod
	def from_bytes(data):
		return PYPYCMD.from_buffer(io.BytesIO(data))
		
	@staticmethod
	def from_buffer(buff):
		cmd = PYPYCMD()
		cmd.cmdtype = PYPYCMDType(buff.read(1)[0])
		param_len = buff.read(1)[0]
		for i in range(param_len):
			plen = int.from_bytes(buff.read(4), 'big', signed = False)
			cmd.params.append(buff.read(plen))
		return cmd
		
	def to_bytes(self):
		t = self.cmdtype.value.to_bytes(1, 'big', signed = False)
		t += len(self.params).to_bytes(1, 'big', signed = False)
		for i in range(len(self.params)):
			t += len(self.params[i]).to_bytes(4, 'big', signed = False)
			t += self.params[i]
		return t
		
	def to_string(self):
		return self.to_bytes().hex()
		
	def __str__(self):
		t = '==== PYPYCMD ====\r\n'
		t += 'cmdtype: %s\r\n' % self.cmdtype.name
		for i, val in enumerate(self.params):
			t += 'var%s: %s\r\n' % (i, val)
		
		return t