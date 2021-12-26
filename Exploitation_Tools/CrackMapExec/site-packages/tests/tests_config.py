# Author:
#  Romain Bentz (pixis - @hackanddo)
# Website:
#  https://beta.hackndo.com

"""
# RENAME THIS FILE TO tests_config.py
"""

# Include Kerberos authentication tests
kerberos = True

# Domain controller FQDN or IP, only needed if kerberos set to True
domain_controller = "192.168.56.201"

# If kerberos is set to True, FQDN of a valid target. IP address otherwise.
target = "server01.adsec.local"

# If kerberos is set to True, FQDN of target where LSASS is protected. IP address otherwise. (empty to skip tests)
protected_target = ""

# Domain Name
domain = "adsec.local"

# User with admin rights on ip_address and ip_address_protected
da_login = "jsnow"
da_password = "Winter_is_coming_!"

# User without admin rights on ip_address (empty to skip tests)
usr_login = "jlannister"
usr_password = "summer4ever!"

# Local tools for dumping methods (empty to skip tests)
procdump_path = "/home/pixis/Tools/Windows/Sysinternals/procdump.exe"
dumpert_path = "/home/pixis/Tools/Windows/Dumpert/Outflank-Dumpert.exe"
