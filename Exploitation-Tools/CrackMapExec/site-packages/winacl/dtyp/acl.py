from winacl.dtyp.ace import ACE
import io

class ACL:
	def __init__(self, sd_object_type = None):
		self.AclRevision = None
		self.Sbz1 = 0
		self.AclSize = None
		self.AceCount = None
		self.Sbz2 = 0
		
		self.aces = []
		self.sd_object_type = sd_object_type
		
	@staticmethod
	def from_buffer(buff, sd_object_type = None):
		acl = ACL(sd_object_type)
		acl.AclRevision = int.from_bytes(buff.read(1), 'little', signed = False)
		acl.Sbz1 = int.from_bytes(buff.read(1), 'little', signed = False)
		acl.AclSize = int.from_bytes(buff.read(2), 'little', signed = False)
		acl.AceCount = int.from_bytes(buff.read(2), 'little', signed = False)
		acl.Sbz2 = int.from_bytes(buff.read(2), 'little', signed = False)
		for _ in range(acl.AceCount):
			acl.aces.append(ACE.from_buffer(buff, sd_object_type))
		return acl

	def to_bytes(self):
		buff = io.BytesIO()
		self.to_buffer(buff)
		buff.seek(0)
		return buff.read()

	def to_buffer(self, buff):
		data_buff = io.BytesIO()

		self.AceCount = len(self.aces)
		for ace in self.aces:
			data_buff.write(ace.to_bytes())

		self.AclSize = 8 + data_buff.tell()

		buff.write(self.AclRevision.to_bytes(1, 'little', signed = False))
		buff.write(self.Sbz1.to_bytes(1, 'little', signed = False))
		buff.write(self.AclSize.to_bytes(2, 'little', signed = False))
		buff.write(self.AceCount.to_bytes(2, 'little', signed = False))
		buff.write(self.Sbz2.to_bytes(2, 'little', signed = False))
		data_buff.seek(0)
		buff.write(data_buff.read())
		
	def __str__(self):
		t = '=== ACL ===\r\n'
		for ace in self.aces:
			t += '%s\r\n' % str(ace)
		return t

	def to_ssdl(self, object_type = None):
		t = ''
		for ace in self.aces:
			t += ace.to_ssdl(object_type)
		return t
