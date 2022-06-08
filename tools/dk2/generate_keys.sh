#!/usr/bin/env bash

# Path to
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $script_path/keys_base.sh

# Create keys directory if it doesn't exist
if [ ! -d $keysDir ]; then
    mkdir -p $keysDir
fi

# Copy keys only if they do not exist
if [[ ! -f $keysDir/$privateKey ]]; then
    openssl genpkey -algorithm ec \
        -pkeyopt ec_paramgen_curve:prime256v1 \
        -aes-256-cbc -pass pass:"${pass}" \
        -out "${keysDir}/${privateKey}"

    if [ $? -eq 0 ]; then
        echo "Key generation successful"
        echo "Keys located in ${keysDir} It is important to make a copy of those keys and save them in a safe place"
    else
        echo "Key generation failed"
        exit 1
    fi
else
    echo "Keys already in ${keysDir} skipping key-generation"
    echo "Make a security copy of them"
fi

python3 $script_path/make_hash.py "${keysDir}/${pkh}" "${keysDir}/${privateKey}" "${pass}"

if [ $? -eq 0 ]; then
    echo "KeyHash generation successful"
    echo "KeyHash located in ${keysDir} It is important to make a copy of those keys and save them in a safe place"
else
    echo "KeyHash generation failed"
    exit 1
fi

# Generate unencrypted private key if they do not exist
if [[ ! -f $keysDir/${privName}_noenc.pem ]]; then
    openssl ec -in $keysDir/$privateKey -out $keysDir/${privName}_noenc.pem -passin pass:$pass
fi
