#!/usr/bin/env bash

function _clean() {
    local errno=$?

    if [[ $errno -ne 0 ]]; then
	rm -f ${BINARIES_DIR}/imx8-boot-sd.bin.signed
        rm -f ${BINARIES_DIR}/csf_fit.bin
        rm -f ${BINARIES_DIR}/csf_spl.bin
    else
	rm -f ${BINARIES_DIR}/csf_fit.txt
	rm -f ${BINARIES_DIR}/csf_spl.txt
	rm -f ${BINARIES_DIR}/print_fit_hab.txt
    fi

    exit $errno
}

trap _clean SIGHUP SIGINT SIGTERM EXIT

if [ -f "${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/crts/SRK_1_2_3_4_fuse.bin" ] ; then

    cat <<EOF > ${BINARIES_DIR}/csf_spl.txt
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

    [ $? != 0 ] && exit 1

    cat <<EOF > ${BINARIES_DIR}/csf_fit.txt
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
    Blocks = 0x401fcdc0 0x57c00 0x1020 "${BINARIES_DIR}/imx8-boot-sd.bin", \\
EOF

    [ $? != 0 ] && exit 2

    # Get data offset and size
    if grep -Eq "^BR2_TARGET_OPTEE_OS=y$" ${BR2_CONFIG}; then
       BL31=${BINARIES_DIR}/bl31.bin BL32=${BINARIES_DIR}/tee-pager_v2.bin BL33=${BINARIES_DIR}/u-boot-nodtb.bin TEE_LOAD_ADDR=0xbe000000 ATF_LOAD_ADDR=0x00920000 VERSION=v1 ${HOST_DIR}/bin/print_fit_hab.sh 0x60000 $2 > ${BINARIES_DIR}/print_fit_hab.txt || exit 3
    else
        BL31=${BINARIES_DIR}/bl31.bin BL33=${BINARIES_DIR}/u-boot-nodtb.bin ATF_LOAD_ADDR=0x00920000 VERSION=v1 ${HOST_DIR}/bin/print_fit_hab.sh 0x60000 $2 > ${BINARIES_DIR}/print_fit_hab.txt || exit 4
    fi

    # Fill Authenticate Data
    lenght=$(cat ${BINARIES_DIR}/print_fit_hab.txt|wc -l)
    current=$(($lenght-1))
    while read -r line; do
        tmp="$line \"${BINARIES_DIR}/imx8-boot-sd.bin\""
        if [ $current -gt 0 ]; then
           tmp="${tmp}, \\"
        fi
        echo $tmp >> ${BINARIES_DIR}/csf_fit.txt
        current=$(($current-1))
    done <${BINARIES_DIR}/print_fit_hab.txt

    # Generate the CSF SPL
    ${HOST_DIR}/bin/cst --o ${BINARIES_DIR}/csf_spl.bin --i ${BINARIES_DIR}/csf_spl.txt || exit 5

    # Generate the CSF FIT
    ${HOST_DIR}/bin/cst --o ${BINARIES_DIR}/csf_fit.bin --i ${BINARIES_DIR}/csf_fit.txt || exit 6

    # Concat bootloader stages and CSF files
    cp ${BINARIES_DIR}/imx8-boot-sd.bin ${BINARIES_DIR}/imx8-boot-sd.bin.signed

    dd if=${BINARIES_DIR}/csf_spl.bin of=${BINARIES_DIR}/imx8-boot-sd.bin.signed seek=$((0x30e00)) bs=1 conv=notrunc || exit 7
    dd if=${BINARIES_DIR}/csf_fit.bin of=${BINARIES_DIR}/imx8-boot-sd.bin.signed seek=$((0x58c20)) bs=1 conv=notrunc || exit 8

fi

exit 0
