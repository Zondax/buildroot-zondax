#!/usr/bin/env bash

# Path to images directory
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
buildroot_path=$script_path/../../
keysDir=$buildroot_path/keys/uboot_keys

uboot_key="uboot_keys.key"
uboot_pkey="uboot_keys.pem"
uboot_cert="uboot_keys.crt"

