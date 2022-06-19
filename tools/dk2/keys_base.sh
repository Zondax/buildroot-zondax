#!/usr/bin/env bash

# Path to images directory
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
buildroot_path=$script_path/../../
ls $buildroot_path
imageDir=$buildroot_path/images/
keysDir=$buildroot_path/keys/tfa_keys
pkhBootDir=$buildroot_path/board/zondax/stm32mp157/dk2-overlay/boot/publicKeyhash.bin

# Keys for signing
privName="privateKey"
pubName="publicKey"
pubKeyHashName="publicKeyhash"
privateKey=${privName}.pem
privKeyNoEnc=${privName}_noenc.pem
publicKey=${pubName}.pem
pkh=${pubKeyHashName}.bin

# Dummy password for keygen tools to
pass="test"

# Image names
plainImageName=tf-a-stm32mp157c-dk2-mx.stm32
signedImageName=tf-a-stm32mp157c-dk2-mx_Signed.stm32
