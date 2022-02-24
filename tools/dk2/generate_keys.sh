#!/usr/bin/env bash

# Path to
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $script_path/keys_base.sh

if ! command -v STM32MP_KeyGen_CLI &> /dev/null
then
    echo "STM32MP_KeyGen_CLI could not be found"
    echo "Go to https://wiki.st.com/stm32mpu/wiki/STM32CubeProgrammer /

    for further instructions on how to install it"
    exit
fi

# Create keys directory if it doesn't exist
if [ ! -d $keysDir ]; then
    mkdir -p $keysDir
fi

# Copy keys only if they do not exist
if [[ ! -f $keysDir/$privateKey ]] && [[ ! -f $keysDir/$publicKey ]] && [[ ! -f $keysDir/$pkh ]]; then
    #Generate keys with STM32MP_KeyGen_CLI
    STM32MP_KeyGen_CLI -prvk $keysDir/$privateKey -pubk $keysDir/$publicKey -pwd $pass

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
