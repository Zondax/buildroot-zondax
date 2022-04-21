#!/usr/bin/env bash

function _clean() {
    local errno=$?

    if [[ $errno -ne 0 ]]; then
	rm -f ${BINARIES_DIR}/imx8-boot-sd.bin.signed
        rm -f ${BINARIES_DIR}/csf_fit.bin
        rm -f ${BINARIES_DIR}/csf_spl.bin
    fi

    exit $errno
}

trap _clean SIGHUP SIGINT SIGTERM EXIT

# Generate the CSF SPL
${HOST_DIR}/bin/cst --o ${BINARIES_DIR}/csf_spl.bin --i ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/csf_spl.txt || exit 1

# Generate the CSF FIT
${HOST_DIR}/bin/cst --o ${BINARIES_DIR}/csf_fit.bin --i ${BR2_EXTERNAL_ZONDAXTEE_PATH}/keys/cst_keys/csf_fit.txt || exit 5

# Concat bootloader stages and CSF files
cp ${BINARIES_DIR}/imx8-boot-sd.bin ${BINARIES_DIR}/imx8-boot-sd.bin.signed

dd if=${BINARIES_DIR}/csf_spl.bin of=${BINARIES_DIR}/imx8-boot-sd.bin.signed seek=$((0x30e00)) bs=1 conv=notrunc || exit 6
dd if=${BINARIES_DIR}/csf_fit.bin of=${BINARIES_DIR}/imx8-boot-sd.bin.signed seek=$((0x58c20)) bs=1 conv=notrunc || exit 7

exit 0
