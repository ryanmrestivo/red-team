
import json
from pypykatz_server.protocol.command import *
from pypykatz.commons.common import *


class RemoteReader:
	def __init__(self, transport):
		self.transport = transport
		self.sysinfo = None
		
		self.current_position = None
		
	def setup(self):
		cmd = PYPYCMD()
		cmd.cmdtype = PYPYCMDType.INIT
		self.transport.send(cmd)
		
		init_reply = self.transport.recv()
		sysinfo_d = json.loads(init_reply.params[0].decode())
		#print(sysinfo_d)
		
		sysinfo = KatzSystemInfo()
		sysinfo.architecture = KatzSystemArchitecture.X86 if sysinfo_d['arch'] == 0 else KatzSystemArchitecture.X64
		sysinfo.buildnumber = sysinfo_d['buildno']
		sysinfo.msv_dll_timestamp = sysinfo_d['msvdllts']
		self.sysinfo = sysinfo
		
		return sysinfo
		
	def read_pos(self, pos, length):
		#print('READ POS: %s LENGTH: %s' % (pos, length))
		cmd = PYPYCMD()
		cmd.cmdtype = PYPYCMDType.READ
		cmd.params.append(pos.to_bytes(8, 'big', signed = True))
		cmd.params.append(length.to_bytes(8, 'big', signed = True))
		self.transport.send(cmd)
		
		rply = self.transport.recvOK()
		return rply.params[0]
		
	def seek(self, offset, whence = 1):
		if whence != 1:
			raise Exception('Segment-based relative seek is not supported for keeping the proptocol simple')
		self.current_position += offset
		
	def move(self, address):
		#print(address)
		self.current_position = address
		
	def align(self, alignment = None):
		if alignment is None:
			if self.sysinfo.architecture == KatzSystemArchitecture.X64:
				alignment = 8
			else:
				alignment = 4
		offset = self.current_position % alignment
		if offset == 0:
			return
		offset_to_aligned = (alignment - offset) % alignment
		self.seek(offset_to_aligned, 1)
		return
		
	def tell(self):
		return self.current_position
	
	def peek(self, length):
		temp = self.current_position
		data = self.read_pos(self.current_position, length)
		self.current_position = temp
		return data
	
	def read(self, length):
		if length < 1:
			raise Exception('Explicit length needed!')
		data = self.read_pos(self.current_position, length)
		self.current_position += length
		return data
	
	def read_int(self):
		if self.sysinfo.architecture == KatzSystemArchitecture.X64:
			return int.from_bytes(self.read(8), byteorder = 'little', signed = True)
		else:
			return int.from_bytes(self.read(4), byteorder = 'little', signed = True)
	
	def read_uint(self):
		if self.sysinfo.architecture == KatzSystemArchitecture.X64:
			return int.from_bytes(self.read(8), byteorder = 'little', signed = False)
		else:
			return int.from_bytes(self.read(4), byteorder = 'little', signed = False)
	
	def get_ptr(self, pos):
		self.move(pos)
		return self.read_uint()
	
	def get_ptr_with_offset(self, pos):
		if self.sysinfo.architecture == KatzSystemArchitecture.X64:
			self.move(pos)
			ptr = int.from_bytes(self.read(4), byteorder = 'little', signed = True)
			return pos + 4 + ptr
		else:
			self.move(pos)
			return self.read_uint()
	
	def find_in_module(self, module_name, pattern):
		#print(module_name)
		#print(pattern)
		cmd = PYPYCMD()
		cmd.cmdtype = PYPYCMDType.FIND
		cmd.params.append(module_name.encode())
		cmd.params.append(pattern)
		self.transport.send(cmd)
		
		rply = self.transport.recvOK()
		if len(rply.params) > 0:
			pos = int.from_bytes(rply.params[0], 'big', signed = False)
			#print('Pattern found at: %s' % pos)
			return [pos]
		else:
			return []
			
