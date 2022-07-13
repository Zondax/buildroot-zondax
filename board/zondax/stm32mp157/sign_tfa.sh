#!/usr/bin/env bash

images_dir=$BR2_EXTERNAL_ZONDAXTEE_PATH/images/
tools_dir=$BR2_EXTERNAL_ZONDAXTEE_PATH/tools/dk2/

tf_a_suffix="stm32"

# calls the script to generate keys.
#
# the script would generate new keys only 
# if the directory does not exist or is empty
source $tools_dir/generate_keys.sh
source $tools_dir/keys_base.sh

for img_file in "${BINARIES_DIR}/"*".${tf_a_suffix}"; do
    [ -e "$img_file" ] || continue
    python3 $tools_dir/sign_tfa.py "$img_file" \
        "${keysDir}/${privateKey}" "${pass}"
    if [ $? -eq 0 ]; then
        echo "$img_file signed"
    else
        echo "Signing $img_file failed"
        exit 1
    fi
done


