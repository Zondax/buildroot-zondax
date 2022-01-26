#!/usr/bin/env bash

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $script_path/keys_base.sh

if ! command -v openssl &> /dev/null
then
    echo "openssl not found"
    echo "can not generate keys for optee offline signing"
    exit
fi

if [[ ! -f $keysDir/$priv_key ]] && [[ ! -f $keysDir/$pub_key ]]; then
    openssl genrsa -out $keysDir/$priv_key 2048

    if [ $? -eq 0 ]; then
        echo "Optee private key generation successful"
        echo "Key located in ${keysDir} It is important to make a copy of those keys and save them in a safe place"
    else
        echo "private key generation failed"
        exit 1
    fi
    openssl rsa -in $keysDir/$priv_key -pubout -out $keysDir/$pub_key
    if [ $? -eq 0 ]; then
        echo "Optee public key generation successful"
        echo "PubKey located in ${keysDir} It is important to make a copy of those keys and save them in a safe place"
    else
        echo "PubKey generation failed"
        exit 1
    fi

else
    echo "Optee-Keys already in ${keysDir} skipping key-generation"
    echo "Make a security copy of them"
fi
