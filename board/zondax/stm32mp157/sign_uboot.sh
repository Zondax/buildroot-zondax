#!/bin/sh
# This script acts as a post processing utility

BOARD_DIR=$(dirname $0)
ls $HOST_DIR/bin/
mkimage=$HOST_DIR/bin/mkimage
#futility=$HOST_DIR/bin/futility
keys=$BR2_EXTERNAL_ZONDAXTEE_PATH/keys/uboot_keys/
key_name="uboot_keys"
FIT_IMG="fitImage"
ORIGINAL_FDT="stm32mp157c-dk2-mx.dtb"
#CTRL_FDT="stm32mp157c-dk2-mx_pubkey.dtb"
CTRL_FDT="u-boot.dtb"
UBOOT_BIN="u-boot-nodtb.bin"

run() { echo "$@"; "$@"; }

die() { echo "$@" >&2; exit 1; }

test -f $BINARIES_DIR/$FIT_IMG
if [ $? -eq 0 ]; then
    echo "$FIT_IMG already created, please delete it to proceed"
    # Should we abort this here by returning 1?
    exit 0
fi

test -f $BINARIES_DIR/zImage || \
	die "No kernel image found"
test -x $mkimage || \
	die "No mkimage found (host-uboot-tools has not been built?)"
test -x $BINARIES_DIR/$FIT_IMG

run cp $BOARD_DIR/stm32.its $BINARIES_DIR/stm32.its || exit 1
ls "$BINARIES_DIR"
run cp $BINARIES_DIR/$ORIGINAL_FDT $BINARIES_DIR/$CTRL_FDT || exit 1
(cd $BINARIES_DIR && run $mkimage -f stm32.its $FIT_IMG) || exit 1

DOPTS="-I dts -O dtb -p 0x1000"
(cd $BINARIES_DIR && run $mkimage -D "${DOPTS}" -F -K $CTRL_FDT -r $FIT_IMG) || exit 1

# Now add them and sign them
echo "Signing $FIT_IMG configurations with our keys"
echo " --------------------------------"

run $mkimage -D "${DOPTS}" -F \
-k "${keys}" -K $BINARIES_DIR/${CTRL_FDT} -r $BINARIES_DIR/${FIT_IMG} || exit 1

echo ""
echo "Copying $FIT_IMG to boot dir so uboot can load it"
run cp $BINARIES_DIR/$FIT_IMG $TARGET_DIR/boot/$FIT_IMG || exit 1
#run cp $BOARD_DIR/uEnv.txt $TARGET_DIR/boot/ || exit 1

rm $BINARIES_DIR/stm32.its
#run cat $BINARIES_DIR/$UBOOT_BIN $BINARIES_DIR/$CTRL_FDT > $BINARIES_DIR/u-boot.bin || exit 1   #Appended to the end portion ( Please refer to the block diagram)
