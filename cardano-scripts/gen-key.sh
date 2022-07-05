#!/bin/bash
set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
read -p "Insert key name (example payment1) : " payment
read -p "Insert stake key name (example stake1) : " stake

${cardanocli} address key-gen \
    --verification-key-file ${key_path}/${payment}.vkey \
    --signing-key-file ${key_path}/${payment}.skey

${cardanocli} stake-address key-gen \
    --verification-key-file ${key_path}/${stake}.vkey \
    --signing-key-file ${key_path}/${stake}.skey

echo_green "\nKeys saved in ${key_path}"