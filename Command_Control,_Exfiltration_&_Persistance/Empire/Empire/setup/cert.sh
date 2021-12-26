#!/bin/bash

# generate a self-signed CERT
#openssl genrsa -des3 -out ./data/empire.orig.key 2048
#openssl rsa -in ./data/empire.orig.key -out ./data/empire.key
#openssl req -new -key ./data/empire.key -out ./data/empire.csr
#openssl x509 -req -days 365 -in ./data/empire.csr -signkey ./data/empire.key -out ./data/empire.crt

#openssl req -new -x509 -keyout ../data/empire-priv.key -out ../data/empire-chain.pem -days 365 -nodes
if [[ "$(pwd)" != *setup ]]
then
	cd ./setup
fi

openssl req -new -x509 -keyout ../empire/server/data/empire-priv.key -out ../empire/server/data/empire-chain.pem -days 365 -nodes -subj "/C=US" >/dev/null 2>&1

echo -e "\x1b[1;34m[*] Certificate written to ../empire/server/data/empire-chain.pem\x1b[0m"
echo -e "\x1b[1;34m[*] Private key written to ../empire/server/data/empire-priv.key\x1b[0m"

cd ..
