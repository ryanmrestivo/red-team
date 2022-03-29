from asn1crypto.core import ObjectIdentifier,Choice, Any, SequenceOf, BitString, Sequence, GeneralString, OctetString, Enumerated, Boolean
from minikerberos.protocol.asn1_structs import krb5int32, APOptions, Ticket, EncryptedData

UNIVERSAL = 0
APPLICATION = 1
CONTEXT = 2
TAG = 'explicit'

class MechType(ObjectIdentifier):
	_map = { 
		#'': 'SNMPv2-SMI::enterprises.311.2.2.30',
		'1.3.6.1.4.1.311.2.2.10': 'NTLMSSP - Microsoft NTLM Security Support Provider',
		'1.2.840.48018.1.2.2'   : 'MS KRB5 - Microsoft Kerberos 5',
		'1.2.840.113554.1.2.2'  : 'KRB5 - Kerberos 5',
		'1.2.840.113554.1.2.2.3': 'KRB5 - Kerberos 5 - User to User',
		'1.3.6.1.4.1.311.2.2.30': 'NEGOEX - SPNEGO Extended Negotiation Security Mechanism',
	}

class MechTypes(SequenceOf):
	_child_spec = MechType
	
class AP_REQ(Sequence):
	explicit = (APPLICATION, 14)
	_fields = [
		('pvno', krb5int32, {'tag_type': TAG, 'tag': 0}),
		('msg-type', krb5int32, {'tag_type': TAG, 'tag': 1}), #MESSAGE_TYPE
		('ap-options', APOptions, {'tag_type': TAG, 'tag': 2}),
		('ticket', Ticket , {'tag_type': TAG, 'tag': 3}),
		('authenticator', EncryptedData , {'tag_type': TAG, 'tag': 4}),
	]

class InitialContextToken(Sequence):	
	class_ = 1
	tag    = 0
	_fields = [
		('thisMech', MechType, {'optional': False}),
		('unk_bool', Boolean, {'optional': False}),
		('innerContextToken', Any, {'optional': False}),
	]

	_oid_pair = ('thisMech', 'innerContextToken')
	_oid_specs = {
		'KRB5 - Kerberos 5': AP_REQ,
}
