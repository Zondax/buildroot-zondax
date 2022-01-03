#!/usr/bin/env bash

# Path to this script directory
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $script_path/keys_base.sh

################################
# 1. Sign with STM32MP_SigningTool_CLI  images/arm-trusted-firmware  BL2 variant (sdcard, *.stm32 file)
# 2. The post_image script will detecd there is a signed file and use it 

#Sign with STM32MP_SigningTool_CLI
STM32MP_SigningTool_CLI -prvk $keysDir/$privateKey -pubk $keysDir/$publicKey -pwd $pass \
    -bin $imageDir/$plainImageName -iv 5 -of 0 \
    -t fsbl \
    -la 0x2ffc2500 -ep 0x2ffe4002
if [ $? -eq 0 ]; then
    echo "*.stm32 signed successful"
else
    echo "Signing failed $"
fi
