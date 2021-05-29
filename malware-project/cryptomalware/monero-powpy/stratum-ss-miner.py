#  Copyright (c) 2019, The Monero Project
#  
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  
#  1. Redistributions of source code must retain the above copyright notice,
#  this list of conditions and the following disclaimer.
#  
#  2. Redistributions in binary form must reproduce the above copyright notice,
#  this list of conditions and the following disclaimer in the documentation
#  and/or other materials provided with the distribution.
#  
#  3. Neither the name of the copyright holder nor the names of its
#  contributors may be used to endorse or promote products derived from this
#  software without specific prior written permission.
#  
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.

import socket
import select
import binascii
import pycryptonight
import pyrx
import struct
import json
import sys
import os
import time
import requests
from multiprocessing import Process, Queue


pool_host = 'localhost'
pool_port = 4242
pool_pass = 'xx'
wallet_address = '9xBuE3RDR6yGYhsgtNK92ZYqYYDUQRxSABxbw6CTGnXnCvnmuXq2xanDGrJMoDMZGkZgb4Bbx5cvxhfAufYdujvVEwwSSq3'
rpc_url = 'http://localhost:28081/json_rpc'


def main():
    pool_ip = socket.gethostbyname(pool_host)
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((pool_ip, pool_port))

    q = Queue()
    proc = Process(target=worker, args=(q, s))
    proc.daemon = True
    proc.start()

    login = {
        'method': 'login',
        'params': {
            'login': wallet_address,
            'pass': pool_pass,
            'rigid': '',
            'agent': 'stratum-miner-py/0.1',
            'mode': 'self-select'
        },
        'id':1
    }
    print('Logging into pool: {}:{}'.format(pool_host, pool_port))
    s.sendall(str(json.dumps(login)+'\n').encode('utf-8'))

    try:
        while 1:
            line = s.makefile().readline()
            r = json.loads(line)
            error = r.get('error')
            result = r.get('result')
            method = r.get('method')
            params = r.get('params')
            if error:
                print('Error: {}'.format(error))
                sys.exit(-1)
            if result and result.get('status'):
                print('Status: {}'.format(result.get('status')))
            if result and result.get('job'):
                client_id = result.get('id')
                print('Login ID: {}'.format(client_id))
                job = result.get('job')
                job['client_id'] = client_id
                job['blob'], job['height'], job['seed_hash'] = get_set_template(job, client_id, s)
                q.put(job)
            elif method and method == 'job' and len(client_id):
                job = params
                job['blob'], job['height'], job['seed_hash'] = get_set_template(job, client_id, s)
                q.put(job)
    except KeyboardInterrupt:
        print('{}Exiting'.format(os.linesep))
        proc.terminate()
        s.close()
        sys.exit(0)


def pack_nonce(blob, nonce):
    b = binascii.unhexlify(blob)
    bin = struct.pack('39B', *bytearray(b[:39]))
    bin += struct.pack('I', nonce)
    bin += struct.pack('{}B'.format(len(b)-43), *bytearray(b[43:]))
    return bin

def get_set_template(job, cid, s):
    extra = job.get('extra_nonce')
    wallet = job.get('pool_wallet')
    job_id = job.get('job_id')
    seed_hash = job.get('seed_hash')
    payload = {
        'jsonrpc':'2.0',
        'id':'0',
        'method':'get_block_template',
        'params': {
            'wallet_address': wallet,
            'extra_nonce': extra
        }
    }
    print('Fetching block template from daemon')
    req = requests.post(rpc_url, json=payload)
    result = req.json().get('result')
    if not result:
        print(req.json())
    blob = result.get('blocktemplate_blob')
    payload = {
        'method':'block_template',
        'params': {
            'id': cid,
            'job_id': job_id,
            'blob': result.get('blocktemplate_blob'),
            'height': result.get('height'),
            'difficulty': result.get('difficulty'),
            'prev_hash': result.get('prev_hash'),
            'seed_hash': result.get('seed_hash'),
            'next_seed_hash': result.get('next_seed_hash')
        },
        'id':1
    }
    print('Sending block template to pool')
    s.sendall(str(json.dumps(payload)+'\n').encode('utf-8'))
    select.select([s], [], [], 15)
    return result.get('blockhashing_blob'), result.get('height'), result.get('seed_hash')

def worker(q, s):
    started = time.time()
    hash_count = 0

    while 1:
        job = q.get()
        if job.get('client_id'):
            client_id = job.get('client_id')
        target = job.get('target')
        job_id = job.get('job_id')
        height = job.get('height')
        blob = job.get('blob')
        block_major = int(blob[:2], 16)
        cnv = 0
        if block_major >= 7:
            cnv = block_major - 6
        if cnv > 5:
            seed_hash = binascii.unhexlify(job.get('seed_hash'))
            print('New job with target: {}, RandomX, height: {}'.format(target, height))
        else:
            print('New job with target: {}, CNv{}, height: {}'.format(target, cnv, height))
        target = struct.unpack('I', binascii.unhexlify(target))[0]
        if target >> 32 == 0:
            target = int(0xFFFFFFFFFFFFFFFF / int(0xFFFFFFFF / target))
        nonce = 1

        while 1:
            bin = pack_nonce(blob, nonce)
            if cnv > 5:
                hash = pyrx.get_rx_hash(bin, seed_hash, height)
            else:
                hash = pycryptonight.cn_slow_hash(bin, cnv, 0, height)
            hash_count += 1
            sys.stdout.write('.')
            sys.stdout.flush()
            hex_hash = binascii.hexlify(hash).decode()
            r64 = struct.unpack('Q', hash[24:])[0]
            if r64 < target:
                elapsed = time.time() - started
                hr = int(hash_count / elapsed)
                print('{}Hashrate: {} H/s'.format(os.linesep, hr))
                submit = {
                    'method':'submit',
                    'params': {
                        'id': client_id,
                        'job_id': job_id,
                        'nonce': binascii.hexlify(struct.pack('<I', nonce)).decode(),
                        'result': hex_hash
                    },
                    'id':1
                }
                print('Submitting hash: {}'.format(hex_hash))
                s.sendall(str(json.dumps(submit)+'\n').encode('utf-8'))
                select.select([s], [], [], 3)
                if not q.empty():
                    break
            nonce += 1

if __name__ == '__main__':
    main()

