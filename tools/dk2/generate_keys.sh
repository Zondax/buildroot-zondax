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
        echo "Private key generation successful"
        echo "it is located in ${keysDir} It is important to make a copy of those keys and save them in a safe place"
    else
        echo "Private Key generation failed"
        exit 1
    fi
else
    echo "Private Key already in ${keysDir} skipping key-generation"
    echo "Make a security copy of them"
    #openssl ec -passin pass:"${pass}" -in $keysDir/$privateKey -pubout -out $keysDir/publicKey.pem
fi

# Generate unencrypted private key if they do not exist
if [[ ! -f $keysDir/${privKeyNoEnc} ]]; then
    openssl ec -in $keysDir/$privateKey -out $keysDir/${privKeyNoEnc} -passin pass:$pass
fi

if [[ ! -f $keysDir/${publicKey} ]]; then
    echo "creating public key from private keys"
    openssl ec -passin pass:"${pass}" -in $keysDir/$privateKey -pubout -out "$keysDir/${publicKey}" || exit 1
fi
if [[ ! -f $keysDir/${pkh} ]]; then
    echo "getting public key hash"
    python3 $script_path/make_hash.py "${keysDir}/${pkh}" "$keysDir/${privKeyNoEnc}" "${pass}"  || exit 2
fi

if [[ ! -f ${pkhBootDir} ]]; then
    echo "KeyHash generation successful"
    echo "KeyHash located in ${keysDir}"
    echo "Copying public key hash to boot dir"
    ls ${keysDir}
    cp "${keysDir}/${pkh}" "${pkhBootDir}" || exit 3
fi
