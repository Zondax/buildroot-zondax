#!/usr/bin/env bash

# Path to images directory
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
buildroot_path=$script_path/../../
ls $buildroot_path
imageDir=$buildroot_path/images/
keysDir=$buildroot_path/keys/tfa_keys
# Keys for signing
privName="privateKey"
pubName="publicKey"
pubKeyHashName="publicKeyhash"
privateKey=${privName}.pem
publicKey=${pubName}.pem
pkh=${pubKeyHashName}.bin

# Dummy password for keygen tools to
pass="test"

# Image names
plainImageName=tf-a-stm32mp157c-dk2-mx.stm32
signedImageName=tf-a-stm32mp157c-dk2-mx_Signed.stm32
