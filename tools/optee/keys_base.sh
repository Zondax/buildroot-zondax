#!/usr/bin/env bash

# Path to images directory
script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
buildroot_path=$script_path/../../
keysDir=$buildroot_path/keys/optee_keys

priv_key="optee_priv_key.pem"
pub_key="optee_pub_key.pem"

