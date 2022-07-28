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

exit 0
