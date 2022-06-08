#!/usr/bin/env bash
# This script acts as a post processing utility

BOARD_DIR=$BR2_EXTERNAL_ZONDAXTEE_PATH/board/zondax/stm32mp157/

# First sign the tf_a_image
source $BOARD_DIR/sign_tfa.sh

# Sign UBOOT
source $BOARD_DIR/sign_uboot.sh

