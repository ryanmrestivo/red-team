#!/usr/bin/env python
# -*- coding: utf-8 -*-
# PYTHON_ARGCOMPLETE_OK

# Copyright: (c) 2020 Jordan Borean (@jborean93) <jborean93@gmail.com>
# MIT License (see LICENSE or https://opensource.org/licenses/MIT)

"""
Script that can be used to parse a Negotiate token and output a human readable structure. You can pass in an actual
SPNEGO token or just a raw Kerberos or NTLM token, the script should be smart enough to detect the structure of the
input.
"""

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import argparse
import base64
import hashlib
import json
import os.path
import re
import struct
import sys

from spnego._compat import (
    Dict,
    Optional,
)

from spnego._context import (
    GSSMech,
)

from spnego._kerberos import (
    KerberosV5Msg,
    parse_enum,
    parse_flags,
    parse_kerberos_token,
)

from spnego._ntlm_raw.crypto import (
    hmac_md5,
    kxkey,
    lmowfv1,
    ntowfv1,
    ntowfv2,
    rc4k,
)

from spnego._ntlm_raw.messages import (
    Authenticate,
    AvId,
    Challenge,
    Negotiate,
    NegotiateFlags,
    NTClientChallengeV2,
)

from spnego._text import (
    to_bytes,
    to_native,
    to_text,
)

from spnego._spnego import (
    InitialContextToken,
    NegTokenInit,
    NegTokenResp,
    unpack_token,
)

try:
    import argcomplete
except ImportError:
    argcomplete = None

try:
    from ruamel import yaml
except ImportError:
    yaml = None


def _get_ntlm_payload_offset(msg, fields, expected_payload_offset):
    """
    Some NTLM messages omit the Version field altogether while others just set 8 NULL bytes where it should be set.
    This function determines the actual offset of the payload based on the Offset fields in the msg.
    """
    payload_offset = expected_payload_offset
    for field in fields:
        offset = msg[field + 'Fields']['BufferOffset']
        if offset and offset < payload_offset:
            payload_offset = offset

    return payload_offset


def _parse_ntlm_version(version):
    if not version:
        return

    return {
        'Major': version.major,
        'Minor': version.minor,
        'Build': version.build,
        'Reserved': to_text(base64.b16encode(version.reserved)),
        'NTLMRevision': version.revision,
    }


def _parse_ntlm_target_info(target_info):
    if target_info is None:
        return

    text_values = [AvId.nb_computer_name, AvId.nb_domain_name, AvId.dns_computer_name, AvId.dns_domain_name,
                   AvId.dns_tree_name, AvId.target_name]

    info = []
    for av_id, raw_value in target_info.items():

        if av_id == AvId.eol:
            value = None
        elif av_id in text_values:
            value = raw_value
        elif av_id == AvId.flags:
            value = parse_flags(raw_value)
        elif av_id == AvId.timestamp:
            value = to_text(raw_value)
        elif av_id == AvId.single_host:
            value = {
                'Size': raw_value.size,
                'Z4': raw_value.z4,
                'CustomData': to_text(base64.b16encode(raw_value.custom_data)),
                'MachineId': to_text(base64.b16encode(raw_value.machine_id)),
            }
        else:
            value = to_text(base64.b16encode(raw_value))

        info.append({'AvId': parse_enum(av_id), 'Value': value})

    return info


def _parse_ntlm_negotiate(data):  # type: (Negotiate) -> Dict[str, any]
    b_data = data.pack()

    msg = {
        'NegotiateFlags': parse_flags(data.flags, enum_type=NegotiateFlags),
        'DomainNameFields': {
            'Len': struct.unpack("<H", b_data[16:18])[0],
            'MaxLen': struct.unpack("<H", b_data[18:20])[0],
            'BufferOffset': struct.unpack("<I", b_data[20:24])[0],
        },
        'WorkstationFields': {
            'Len': struct.unpack("<H", b_data[24:26])[0],
            'MaxLen': struct.unpack("<H", b_data[26:28])[0],
            'BufferOffset': struct.unpack("<I", b_data[28:32])[0],
        },
        'Version': _parse_ntlm_version(data.version),
        'Payload': {
            'DomainName': data.domain_name,
            'Workstation': data.workstation,
        }
    }

    payload_offset = _get_ntlm_payload_offset(msg, ['DomainName', 'Workstation'], 40)
    if not msg['Version'] and payload_offset == 40 and len(b_data) >= 40:
        msg['Version'] = to_text(base64.b16encode(b_data[32:40]))

    return msg


def _parse_ntlm_challenge(data):  # type: (Challenge) -> Dict[str, any]
    b_data = data.pack()

    msg = {
        'TargetNameFields': {
            'Len': struct.unpack("<H", b_data[12:14])[0],
            'MaxLen': struct.unpack("<H", b_data[14:16])[0],
            'BufferOffset': struct.unpack("<I", b_data[16:20])[0],
        },
        'NegotiateFlags': parse_flags(data.flags, enum_type=NegotiateFlags),
        'ServerChallenge': to_text(base64.b16encode(b_data[24:32])),
        'Reserved': to_text(base64.b16encode(b_data[32:40])),
        'TargetInfoFields': {
            'Len': struct.unpack("<H", b_data[40:42])[0],
            'MaxLen': struct.unpack("<H", b_data[42:44])[0],
            'BufferOffset': struct.unpack("<I", b_data[44:48])[0],
        },
        'Version': _parse_ntlm_version(data.version),
        'Payload': {
            'TargetName': data.target_name,
            'TargetInfo': _parse_ntlm_target_info(data.target_info),
        },
    }

    payload_offset = _get_ntlm_payload_offset(msg, ['TargetName', 'TargetInfo'], 56)
    if not msg['Version'] and payload_offset == 56 and len(b_data) >= 56:
        msg['Version'] = to_text(base64.b16encode(b_data[48:56]))

    return msg


def _parse_ntlm_authenticate(data, password):  # type: (Authenticate, str) -> Dict[str, any]
    b_data = data.pack()

    msg = {
        'LmChallengeResponseFields': {
            'Len': struct.unpack("<H", b_data[12:14])[0],
            'MaxLen': struct.unpack("<H", b_data[14:16])[0],
            'BufferOffset': struct.unpack("<I", b_data[16:20])[0],
        },
        'NtChallengeResponseFields': {
            'Len': struct.unpack("<H", b_data[20:22])[0],
            'MaxLen': struct.unpack("<H", b_data[22:24])[0],
            'BufferOffset': struct.unpack("<I", b_data[24:28])[0],
        },
        'DomainNameFields': {
            'Len': struct.unpack("<H", b_data[28:30])[0],
            'MaxLen': struct.unpack("<H", b_data[30:32])[0],
            'BufferOffset': struct.unpack("<I", b_data[32:36])[0],
        },
        'UserNameFields': {
            'Len': struct.unpack("<H", b_data[36:38])[0],
            'MaxLen': struct.unpack("<H", b_data[38:40])[0],
            'BufferOffset': struct.unpack("<I", b_data[40:44])[0],
        },
        'WorkstationFields': {
            'Len': struct.unpack("<H", b_data[44:46])[0],
            'MaxLen': struct.unpack("<H", b_data[46:48])[0],
            'BufferOffset': struct.unpack("<I", b_data[48:52])[0],
        },
        'EncryptedRandomSessionKeyFields': {
            'Len': struct.unpack("<H", b_data[52:54])[0],
            'MaxLen': struct.unpack("<H", b_data[54:56])[0],
            'BufferOffset': struct.unpack("<I", b_data[56:60])[0],
        },
        'NegotiateFlags': parse_flags(data.flags, enum_type=NegotiateFlags),
        'Version': _parse_ntlm_version(data.version),
        'MIC': to_text(base64.b16encode(data.mic)) if data.mic else None,
        'Payload': {
            'LmChallengeResponse': None,
            'NtChallengeResponse': None,
            'DomainName': data.domain_name,
            'UserName': data.user_name,
            'Workstation': data.workstation,
            'EncryptedRandomSessionKey': None,
        },
    }

    payload_offset = _get_ntlm_payload_offset(msg, ['LmChallengeResponse', 'NtChallengeResponse', 'DomainName',
                                                    'UserName', 'Workstation', 'EncryptedRandomSessionKey'], 88)
    if payload_offset == 88:
        if not msg['Version']:
            msg['Version'] = to_text(base64.b16encode(b_data[64:72]))

        if not msg['MIC']:
            msg['MIC'] = to_text(base64.b16encode(b_data[72:88]))

    elif payload_offset == 80:
        if not msg['MIC']:
            msg['MIC'] = to_text(base64.b16encode(b_data[64:80]))

    elif payload_offset == 72:
        if not msg['Version']:
            msg['Version'] = to_text(base64.b16encode(b_data[64:72]))

    key_exchange_key = None

    lm_response_data = data.lm_challenge_response
    if lm_response_data:
        lm_response = {
            'ResponseType': None,
            'LMProofStr': None,
        }

        if len(lm_response_data) == 24:
            lm_response['ResponseType'] = 'LMv1'
            lm_response['LMProofStr'] = to_text(base64.b16encode(lm_response_data))

        else:
            lm_response['ResponseType'] = 'LMv2'
            lm_response['LMProofStr'] = to_text(base64.b16encode(lm_response_data[:16]))
            lm_response['ChallengeFromClient'] = to_text(base64.b16encode(lm_response_data[16:]))

        msg['Payload']['LmChallengeResponse'] = lm_response

    nt_response_data = data.nt_challenge_response
    if nt_response_data:
        nt_response = {
            'ResponseType': None,
            'NTProofStr': None,
        }

        if len(nt_response_data) == 24:
            nt_response['ResponseType'] = 'NTLMv1'
            nt_response['NTProofStr'] = to_text(base64.b16encode(nt_response_data))

            if password and lm_response_data:
                session_base_key = hashlib.new('md4', ntowfv1(password)).digest()
                lmowf = lmowfv1(password)

                # TODO: need to get a sane way to include the server challenge for ESS KXKEY.
                if data.flags & NegotiateFlags.extended_session_security == 0:
                    key_exchange_key = kxkey(data.flags, session_base_key, lmowf, lm_response_data, b"")

        else:
            nt_proof_str = nt_response_data[:16]
            nt_response['ResponseType'] = 'NTLMv2'
            nt_response['NTProofStr'] = to_text(base64.b16encode(nt_proof_str))

            challenge = NTClientChallengeV2.unpack(nt_response_data[16:])
            b_challenge = nt_response_data[16:]

            nt_response['ClientChallenge'] = {
                'RespType': challenge.resp_type,
                'HiRespType': challenge.hi_resp_type,
                'Reserved1': struct.unpack("<H", b_challenge[2:4])[0],
                'Reserved2': struct.unpack("<I", b_challenge[4:8])[0],
                'TimeStamp': str(challenge.time_stamp),
                'ChallengeFromClient': to_text(base64.b16encode(challenge.challenge_from_client)),
                'Reserved3': struct.unpack("<I", b_challenge[24:28])[0],
                'AvPairs': _parse_ntlm_target_info(challenge.av_pairs),
                'Reserved4': struct.unpack("<I", b_challenge[-4:])[0],
            }

            if password:
                response_key_nt = ntowfv2(msg['Payload']['UserName'], ntowfv1(password), msg['Payload']['DomainName'])
                key_exchange_key = hmac_md5(response_key_nt, nt_proof_str)

        msg['Payload']['NtChallengeResponse'] = nt_response

    if data.encrypted_random_session_key:
        msg['Payload']['EncryptedRandomSessionKey'] = to_text(base64.b16encode(data.encrypted_random_session_key))

    if data.flags & NegotiateFlags.key_exch and (data.flags & NegotiateFlags.sign or data.flags & NegotiateFlags.seal):
        session_key = None
        if key_exchange_key:
            session_key = rc4k(key_exchange_key, data.encrypted_random_session_key)

    else:
        session_key = key_exchange_key

    msg['SessionKey'] = to_text(base64.b16encode(session_key)) if session_key else 'Failed to derive'

    return msg


def _parse_spnego_init(data, secret=None, encoding=None):
    # type: (NegTokenInit, Optional[str], Optional[str]) -> Dict[str, any]
    mech_types = [parse_enum(m, enum_type=GSSMech) for m in data.mech_types] \
        if data.mech_types else None

    mech_token = None
    if data.mech_token:
        mech_token = parse_token(data.mech_token, secret=secret, encoding=encoding)

    encoding = encoding if encoding else 'utf-8'

    msg = {
        'mechTypes': mech_types,
        'reqFlags': parse_flags(data.req_flags) if data.req_flags is not None else None,
        'mechToken': mech_token,
        'mechListMIC': to_text(base64.b16encode(data.mech_list_mic)) if data.mech_list_mic is not None else None,
    }

    if data.hint_name or data.hint_address:
        # This is a NegTokenInit2 structure.
        msg['negHints'] = {
            'hintName': to_text(data.hint_name, encoding=encoding) if data.hint_name else None,
            'hintAddress': to_text(data.hint_address, encoding=encoding) if data.hint_address else None,
        }

    return msg


def _parse_spnego_resp(data, secret=None, encoding=None):
    # type: (NegTokenResp, Optional[str], Optional[str]) -> Dict[str, any]

    supported_mech = parse_enum(data.supported_mech, enum_type=GSSMech) if data.supported_mech else None

    response_token = None
    if data.response_token:
        response_token = parse_token(data.response_token, secret=secret, encoding=encoding)

    msg = {
        'negState': parse_enum(data.neg_state) if data.neg_state is not None else None,
        'supportedMech': supported_mech,
        'responseToken': response_token,
        'mechListMIC': to_text(base64.b16encode(data.mech_list_mic)) if data.mech_list_mic is not None else None,
    }
    return msg


def main():
    """Main program entry point."""
    args = parse_args()

    if args.token:
        b_data = to_bytes(args.token)
    else:
        if args.file:
            file_path = os.path.abspath(os.path.expanduser(os.path.expandvars(args.file)))
            b_file_path = to_bytes(file_path)
            if not os.path.exists(b_file_path):
                raise ValueError("Cannot find file at path '%s'" % to_native(b_file_path))

            with open(b_file_path, mode='rb') as fd:
                b_data = fd.read()
        else:
            b_data = sys.stdin.buffer.read()

    if re.match(b'^[a-fA-F0-9\\s]+$', b_data):
        # Input data was a hex string.
        b_data = base64.b16decode(re.sub(b'[\\s]', b'', b_data.strip().upper()))
    if re.match(b'^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$', b_data):
        # Input data was a base64 string.
        b_data = base64.b64decode(b_data.strip())

    token_info = parse_token(b_data, secret=args.secret, encoding=args.encoding)

    if args.output_format == 'yaml':
        y = yaml.YAML()
        y.default_flow_style = False
        y.dump(token_info, sys.stdout)
    else:
        print(json.dumps(token_info, indent=4))


def parse_args():
    """Parse and return args."""
    parser = argparse.ArgumentParser(description='Parse Microsoft authentication tokens into a human readable format.')

    data = parser.add_mutually_exclusive_group()

    data.add_argument('-t', '--token',
                      dest='token',
                      help='Raw base64 encoded or hex string token as a command line argument.')

    data.add_argument('-f', '--file',
                      default='',
                      dest='file',
                      help='Path to file that contains raw bytes, base64, or hex string of token to parse, Defaults '
                           'to reading from stdin if neither -t or -f is specified.')

    parser.add_argument('--encoding',
                        dest='encoding',
                        help="The encoding to use when trying to decode text fields from bytes in tokens that don't "
                             "have a negotiated encoding. This defaults to 'windows-1252' for NTLM tokens and 'utf-8' "
                             "for Kerberos/SPNEGO tokens.")

    parser.add_argument('--format', '--output-format',
                        choices=['json', 'yaml'],
                        default='json',
                        dest='output_format',
                        type=lambda s: s.lower(),
                        help='Set the output format of the token, default is (json). Using yaml requires the '
                             'ruamel.yaml Python library to be installed ''pip install pyspnego[yaml]''.')

    parser.add_argument('--secret', '--password',
                        dest='secret',
                        default=None,
                        help='Optional info that is the secret information for a protocol that can be used to decrypt '
                             'encrypted fields and/or derive the unique session key in the exchange. This is '
                             'currently only supported by NTLM tokens to generate the session key.')

    if argcomplete:
        argcomplete.autocomplete(parser)

    args = parser.parse_args()

    if args.output_format == 'yaml' and not yaml:
        raise ValueError('Cannot output as yaml as ruamel.yaml is not installed.')

    return args


def parse_token(b_data, secret=None, encoding=None, mech=None):
    """
    :param b_data: A byte string of the token to parse. This can be a NTLM or GSSAPI (SPNEGO/Kerberos) token.
    :param secret: The secret data used to decrypt fields and/or derive session keys.
    :param encoding: The encoding to use for token fields that represent text. This is only used for fields where there
        is no negotiation for the encoding of that particular field. Defaults to 'windows-1252' for NTLM and 'utf-8'
        for Kerberos.
    :return: A dict containing the parsed token data.
    """
    if mech and not isinstance(mech, GSSMech):
        mech = GSSMech.from_oid(mech)

    try:
        token = unpack_token(b_data, mech=mech, unwrap=True, encoding=encoding)
    except Exception as e:
        return {
            'MessageType': 'Unknown - Failed to parse see Data for more details.',
            'Data': 'Failed to parse token: %s' % to_native(e),
            'RawData': to_text(base64.b16encode(b_data)),
        }

    # SPNEGO messages.
    if isinstance(token, InitialContextToken):
        msg_type = 'SPNEGO InitialContextToken'
        data = {
            'thisMech': parse_enum(token.this_mech, enum_type=GSSMech),
            'innerContextToken': parse_token(token.inner_context_token, mech=token.this_mech, secret=secret,
                                             encoding=encoding),
        }

    elif isinstance(token, NegTokenInit):
        data = _parse_spnego_init(token, secret, encoding)
        if 'negHints' in data:
            msg_type = 'SPNEGO NegTokenInit2'

        else:
            msg_type = 'SPNEGO NegTokenInit'

    elif isinstance(token, NegTokenResp):
        msg_type = 'SPNEGO NegTokenResp'
        data = _parse_spnego_resp(token, secret, encoding)

    # NTLM messages.
    elif isinstance(token, (Negotiate, Challenge, Authenticate)):
        msg_type = parse_enum(token.MESSAGE_TYPE)

        if isinstance(token, Negotiate):
            data = _parse_ntlm_negotiate(token)

        elif isinstance(token, Challenge):
            data = _parse_ntlm_challenge(token)

        else:
            data = _parse_ntlm_authenticate(token, secret)

    # Kerberos messages.
    elif isinstance(token, KerberosV5Msg):
        msg_type = parse_enum(token.MESSAGE_TYPE)
        data = parse_kerberos_token(token, secret, encoding)

    else:
        msg_type = 'Unknown'
        data = 'Failed to parse SPNEGO token due to unknown mech type'

    return {
        'MessageType': msg_type,
        'Data': data,
        'RawData': to_text(base64.b16encode(b_data)),
    }


if __name__ == '__main__':
    main()
