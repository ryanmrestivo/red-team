import getmac,sys

def check():
    vm_macs = ['080027','000569','000C29','001C14','005056','001C42','00163E','0A0027']

    mac = getmac.get_mac_address().split(':')
    mac = mac[0]+mac[1]+mac[2]
    mac = mac.upper()
    for macs in vm_macs:
        if mac == macs:
            sys.exit(0)
    return True

check()