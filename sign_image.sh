#!/usr/bin/env bash

# Path to images directory
buildroot_path=../buildroot-zondax/
imageDir=$buildroot_path/images/
keysDir=$buildroot_path/keys/
# Keys for signing
privName="privateKey"
pubName="publicKey"
pubKeyHashName="publicKeyhash"
privateKey=${privName}.pem
publicKey=${pubName}.pem
pkh=${pubKeyHashName}.bin

# Dummy password for keygen tools to
pass="12345678"

################################
# 1. Generate keys with STM32MP_KeyGen_CLI
# 2. Put these keys into keys/
# 3. Sign with STM32MP_SigningTool_CLI  images/arm-trusted-firmware  BL2 variant (sdcard, *.stm32 file)
# 4. Using dd write this onto first and second partition of SD-card image

if ! command -v STM32MP_KeyGen_CLI &> /dev/null
then
    echo "STM32MP_KeyGen_CLI could not be found"
    echo "Go to https://wiki.st.com/stm32mpu/wiki/STM32CubeProgrammer /

    for further instructions on how to install it"
    exit
fi

if ! command -v STM32MP_SigningTool_CLI &> /dev/null
then
    echo "STM32MP_SigningTool_CLI could not be found"
    exit
fi


# Create keys directory if it doesn't exist
if [ ! -d $keysDir ]; then
    mkdir $keysDir
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

#echo "Build image"
#echo "Change to tee-images directory"
#echo "$buildroot_path"


##run build image command: make build dk2
#make build dk2

# if build is successful list image from build/tmp/deploy/images/$machine/arm-trusted-firmware
if [ $? -eq 0 ]; then
    #Sign with STM32MP_SigningTool_CLI
    STM32MP_SigningTool_CLI -prvk $keysDir/$privateKey -pubk $keysDir/$publicKey -pwd $pass \
    -bin $imageDir/tf-a-stm32mp157c-dk2.stm32 \
    -t fsbl \
    -la 0x2ffc2500 -ep 0x2ffe4002
    if [ $? -eq 0 ]; then
        echo "Signing successful"
        fdisk -l $imageDir/sdcard.img
        echo "Updating raw image"
        # Do image backup
        if [ -f $imageDir/sdcard.img ]; then
            cp $imageDir/sdcard.img $imageDir/sdcard.img.bak
        fi
        # Update partition started at 34, size 256, 512 sectors
        dd if=$imageDir/tf-a-stm32mp157c-dk2_Signed.stm32 of=$imageDir/sdcard.img bs=512 seek=34 conv=notrunc \
        && sync
        # Update partition started at 546, size 256, 512 sectors
        dd if=$imageDir/tf-a-stm32mp157c-dk2_Signed.stm32 of=$imageDir/sdcard.img bs=512 seek=546 conv=notrunc \
        && sync
        #dhex $imageDir/*-mx.stm32 $imageDir/*_Signed.stm32
    else
        echo "Signing failed"
    fi
else
    echo "Build failed"
fi
