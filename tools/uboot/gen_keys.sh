#!/usr/bin/env bash

script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source $script_path/keys_base.sh

if ! command -v openssl &> /dev/null
then
    echo "openssl not found"
    echo "can not generate keys for optee offline signing"
    exit
fi

# Create keys directory if it doesn't exist
if [ ! -d $keysDir ]; then
    mkdir -p $keysDir
fi

if [[ ! -f $keysDir/$uboot_key ]] && [[ ! -f $keysDir/$uboot_cert ]] && [[ ! -f $keysDir/$uboot_pkey ]]; then
    #openssl genrsa -F4 -out $keysDir/$uboot_key 2048
    openssl genpkey -algorithm RSA -out $keysDir/$uboot_key -pkeyopt rsa_keygen_bits:4096

    if [ $? -eq 0 ]; then
        echo "Uboot private key generation successful"
        echo "Key located in ${keysDir} It is important to make a copy of those keys and save them in a safe place"
    else
        echo "Key generation failed"
        exit 1
    fi
    
    openssl req -new -x509 -key $keysDir/$uboot_key -out $keysDir/$uboot_cert \
        -subj '/C=CH/ST=Zug/L=./CN=www.zondax.ch'

    if [ $? -eq 0 ]; then
        echo "Uboot cert generation successful"
        echo "Certificate located in ${keysDir} It is important to make a copy and save them in a safe place"
        openssl rsa -pubout -in $keysDir/$uboot_key -out $keysDir/$uboot_pkey
        if [ $? -eq 0 ]; then
            echo "Uboot public key generation successful"
        else
            echo "Public key generation failed"
            exit 1
        fi
    else
        echo "Certificate generation failed"
        exit 1
    fi

else
    echo "Uboot-Keys already in ${keysDir} skipping key-generation"
    echo "Make a security copy of them"
fi
