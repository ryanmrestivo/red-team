

"""
the nk-Record
=============

Offset	Size	Contents
0x0000	Word	ID: ASCII-"nk" = 0x6B6E
0x0002	Word	for the root-key: 0x2C, otherwise 0x20
0x0004	Q-Word	write-date/time in windows nt notation
0x0010	D-Word	Offset of Owner/Parent key
0x0014	D-Word	number of sub-Keys
0x001C	D-Word	Offset of the sub-key lf-Records
0x0024	D-Word	number of values
0x0028	D-Word	Offset of the Value-List
0x002C	D-Word	Offset of the sk-Record
0x0030	D-Word	Offset of the Class-Name
0x0044	D-Word	Unused (data-trash)
0x0048	Word	name-length
0x004A	Word	class-name length
0x004C	????	key-name
"""
import io
import enum


class NKFlag(enum.IntFlag):
	UNK1 = 0x4000 #Unknown; shows up on normal-seeming keys in Vista and W2K3 hives.
	UNK2 = 0x1000 #Unknown; shows up on normal-seeming keys in Vista and W2K3 hives.
	UNK3 = 0x0080 #Unknown; shows up on root keys in some Vista "software" hives.
	PREDEFINED_HANDLE = 0x0040 #Predefined handle; see: [10]
	ASCII_NAME = 0x0020 #The key name will be in ASCII if set; otherwise it is in UTF-16LE.
	SYMLINK = 0x0010 #Symlink key; see: [6]
	NO_DELETE = 0x0008 #This key cannot be deleted.
	ROOT = 0x0004 #Key is root of a registry hive.
	FOREIGN_MOUNT = 0x0002 #Mount point of another hive.
	VOLATILE = 0x0001 #Volatile key; these keys shouldn’



class NTRegistryNK:
	def __init__(self):
		self.magic = b'nk'
		self.flags = None
		self.wite_time = None
		self.owner_offset = None
		self.u1 = None
		self.subkey_cnt_stable = None
		self.subkey_cnt = None
		self.offset_lf_stable = None
		self.offset_lf = None
		self.value_cnt = None
		self.offset_value_list = None
		self.offset_sk = None
		self.offset_classname = None
		self.sk_name_max = None
		self.sk_classname_max = None
		self.vl_name_max = None
		self.vl_max = None
		self.unknown = None
		self.name_length = None
		self.class_name_length = None
		self.name = None

	@staticmethod
	def from_bytes(data):
		return NTRegistryNK.from_buffer(io.BytesIO(data))

	@staticmethod
	def from_buffer(buff):
		nk = NTRegistryNK()
		nk.magic = buff.read(2)
		assert nk.magic == b'nk'
		nk.flags = NKFlag(int.from_bytes(buff.read(2), 'little', signed = False))
		nk.wite_time = buff.read(8)
		nk.owner_offset = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.u1 = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.subkey_cnt_stable = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.subkey_cnt = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.offset_lf_stable = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.offset_lf = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.value_cnt = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.offset_value_list = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.offset_sk = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.offset_classname = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.sk_name_max = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.sk_classname_max = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.vl_name_max = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.vl_max = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.unknown = int.from_bytes(buff.read(4), 'little', signed = False)
		nk.name_length = int.from_bytes(buff.read(2), 'little', signed = False)
		nk.class_name_length = int.from_bytes(buff.read(2), 'little', signed = False)
		encoding = 'iso-8859-15' if NKFlag.ASCII_NAME in nk.flags else 'utf-16-le'
		try:
			nk.name = buff.read(nk.name_length)
			nk.name = nk.name.decode(encoding)
		except Exception as e:
			raise e

		return nk

	def __str__(self):
		t = '== NT Registry NK block ==\r\n'
		for k in self.__dict__:
			t += '%s: %s \r\n' % (k, self.__dict__[k])
		return t
