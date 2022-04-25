#!/usr/bin/env bash

# Create the folder
if [ ! -d "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys" ] ; then
    mkdir -p ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/ca || exit 1
    mkdir -p ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts || exit 2
    mkdir -p ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/keys || exit 3
fi

if [ ! -f "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/serial" ] ; then
    echo 00000001 > ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/serial || exit 4
fi

if [ ! -f "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/keys/key_pass.txt" ] ; then
    echo -e "zondaxhabcert\nzondaxhabcert" > ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/keys/key_pass.txt || exit 5
fi

if [ ! -f "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/SRK4_sha256_4096_65537_v3_ca_crt.pem" ] ; then
    ${BR2_EXTERNAL_ZONDAXTEE_PATH}/tools/evk/hab4_pki_tree.sh \
        -existing-ca n -use-ecc n -kl 4096 -duration 10 -num-srk 4 -srk-ca y || exit 6
fi

if [ ! -f "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/SRK_1_2_3_4_fuse.bin" ] ; then
    ${HOST_DIR}/bin/srktool \
        -h 4 \
        -t ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/SRK_1_2_3_4_table.bin \
        -e ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/SRK_1_2_3_4_fuse.bin \
        -d sha256 \
        -c ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/SRK1_sha256_4096_65537_v3_ca_crt.pem,\
           ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/SRK2_sha256_4096_65537_v3_ca_crt.pem,\
	   ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/SRK3_sha256_4096_65537_v3_ca_crt.pem,\
           ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/SRK4_sha256_4096_65537_v3_ca_crt.pem \
	   -f 1 || exit 7

    hexdump -e '/4 "0x"' -e '/4 "%X""\n"' < ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/SRK_1_2_3_4_fuse.bin > ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/SRK_1_2_3_4_fuse.hexdump || exit 8
fi

if [ ! -f "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/csf_spl.txt" ] ; then

cat <<EOF > ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/csf_spl.txt
[Header]
    Version = 4.3
    Hash Algorithm = sha256
    Engine = CAAM
    Engine Configuration = 0
    Certificate Format = X509
    Signature Format = CMS

[Install SRK]
    # Index of the key location in the SRK table to be installed
    File = "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/SRK_1_2_3_4_table.bin"
    Source index = 0

[Install CSFK]
    # Key used to authenticate the CSF data
    File = "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/CSF1_1_sha256_4096_65537_v3_usr_crt.pem"

[Authenticate CSF]

[Unlock]
    # Leave Job Ring and DECO master ID registers Unlocked
    Engine = CAAM
    Features = MID

[Install Key]
    # Key slot index used to authenticate the key to be installed
    Verification index = 0
    # Target key slot in HAB key store where key will be installed
    Target index = 2
    # Key to install
    File = "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/IMG1_1_sha256_4096_65537_v3_usr_crt.pem"

[Authenticate Data]
    # Key slot index used to authenticate the image data
    Verification index = 2
    # Authenticate Start Address, Offset, Length and file
    Blocks = 0x7e0fc0 0x0 0x30e00 "${BINARIES_DIR}/imx8-boot-sd.bin"

EOF

[ $? != 0 ] && exit 9

fi

if [ ! -f "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/print_fit_hab.txt" ]; then
    if grep -Eq "^BR2_TARGET_OPTEE_OS=y$" ${BR2_CONFIG}; then
	BL31=${BINARIES_DIR}/bl31.bin BL32=${BINARIES_DIR}/tee.bin BL33=${BINARIES_DIR}/u-boot-nodtb.bin TEE_LOAD_ADDR=0xfe000000 ATF_LOAD_ADDR=0x00920000 ${HOST_DIR}/bin/print_fit_hab.sh > ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/print_fit_hab.txt 0x0 || exit 10
    else
	BL31=${BINARIES_DIR}/bl31.bin BL33=${BINARIES_DIR}/u-boot-nodtb.bin TEE_LOAD_ADDR=0xfe000000 ATF_LOAD_ADDR=0x00920000 ${HOST_DIR}/bin/print_fit_hab.sh > ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/print_fit_hab.txt 0x0 || exit 10
    fi
fi

if [ ! -f "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/csf_fit.txt" ] ; then

cat <<EOF > ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/csf_fit.txt
[Header]
    Version = 4.3
    Hash Algorithm = sha256
    Engine = CAAM
    Engine Configuration = 0
    Certificate Format = X509
    Signature Format = CMS

[Install SRK]
    # Index of the key location in the SRK table to be installed
    File = "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/SRK_1_2_3_4_table.bin"
    Source index = 0

[Install CSFK]
    # Key used to authenticate the CSF data
    File = "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/CSF1_1_sha256_4096_65537_v3_usr_crt.pem"

[Authenticate CSF]

[Install Key]
    # Key slot index used to authenticate the key to be installed
    Verification index = 0
    # Target key slot in HAB key store where key will be installed
    Target index = 2
    # Key to install
    File = "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/IMG1_1_sha256_4096_65537_v3_usr_crt.pem"

[Authenticate Data]
    # Key slot index used to authenticate the image data
    Verification index = 2
    # Authenticate Start Address, Offset, Length and file
    Blocks = 0x401fcdc0 0x57c00 0x1020 "${BINARIES_DIR}/imx8-boot-sd.bin"

EOF

[ $? != 0 ] && exit 11

fi

exit 0
