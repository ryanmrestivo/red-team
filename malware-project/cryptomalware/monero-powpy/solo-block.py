#  Copyright (c) 2019, The Monero Project
#  
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  
#  1. Redistributions of source code must retain the above copyright notice, this
#  list of conditions and the following disclaimer.
#  
#  2. Redistributions in binary form must reproduce the above copyright notice,
#  this list of conditions and the following disclaimer in the documentation
#  and/or other materials provided with the distribution.
#  
#  3. Neither the name of the copyright holder nor the names of its contributors
#  may be used to endorse or promote products derived from this software without
#  specific prior written permission.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  
import binascii
import pycryptonight
import pyrx
import struct
import requests
import json
import sys
import os
import time


rpc_url = 'http://testnet.xmrchain.net:28081/json_rpc'
wallet_address = '9tiLRM5cuFhFazKELdWJNbEqHC8uENobkLaomgufKHpZL3zsPdp9aU2PJJAaKe9RKHRFQaWjrNaaTBduuTooJZga6kT77m1'


def pack_nonce(blob, nonce):
    b = binascii.unhexlify(blob)
    bin = struct.pack('39B', *bytearray(b[:39]))
    bin += struct.pack('I', nonce)
    bin += struct.pack('{}B'.format(len(b)-43), *bytearray(b[43:]))
    return bin


def main():
    base_diff = 2**256-1
    payload = {
            'jsonrpc':'2.0',
            'id':'0',
            'method':'get_block_template',
            'params': {
                'wallet_address': wallet_address
                }
            }
    print('Fetching block template')
    req = requests.post(rpc_url, json=payload)
    result = req.json().get('result')

    bhb = result.get('blockhashing_blob')
    btb = result.get('blocktemplate_blob')
    diff = result.get('difficulty')
    print('Target difficulty: {}'.format(diff))
    height = result.get('height')
    block_major = int(btb[:2], 16)
    cnv = 0
    if block_major >= 7:
        cnv = block_major - 6
    if cnv > 5:
        seed_hash = binascii.unhexlify(result.get('seed_hash'))

    nonce = 1
    hash_count = 0
    started = time.time()
    print('Mining for a valid hash')
    try:
        while 1:
            bin = pack_nonce(bhb, nonce)
            if cnv > 5:
                hash = pyrx.get_rx_hash(bin, seed_hash, height)
            else:
                hash = pycryptonight.cn_slow_hash(bin, cnv, 0, height)
            hash_count += 1
            sys.stdout.write('.')
            sys.stdout.flush()
            hex_hash = binascii.hexlify(hash)

            if base_diff / int(hex_hash, 16) >= diff:
                break
            else:
                nonce += 1
    except KeyboardInterrupt:
        print('{}Aborting'.format(os.linesep))
        sys.exit(-1)

    elapsed = time.time() - started
    hr = int(hash_count / elapsed)
    print('{}Hashrate: {} H/s'.format(os.linesep, hr))
    print('Found a valid hash: {}'.format(hex_hash.decode()))

    btb = binascii.hexlify(pack_nonce(btb, nonce))
    payload = {
            'jsonrpc':'2.0',
            'id':'0',
            'method':'submit_block',
            'params': [ btb ]
            }
    print('Submitting block')
    print(payload)
    req = requests.post(rpc_url, json=payload)
    result = req.json()
    print(result)


if __name__ == '__main__':
    main()


