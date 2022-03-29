from aiowinreg.filestruct.nk import NTRegistryNK
from aiowinreg.filestruct.sk import NTRegistrySK
from aiowinreg.filestruct.vk import NTRegistryVK
from aiowinreg.filestruct.ri import NTRegistryRI
from aiowinreg.filestruct.lf import NTRegistryLF
from aiowinreg.filestruct.lh import NTRegistryLH
from aiowinreg.filestruct.hashrecord import NTRegistryHR

NTRegistryKeyTypes = {
	b'nk': NTRegistryNK,
	b'sk': NTRegistrySK,
	b'vk': NTRegistryVK,
	b'hr': NTRegistryHR,
	b'ri': NTRegistryRI,
	b'lh': NTRegistryLH,
	b'lf': NTRegistryLF,
	
}