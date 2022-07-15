#!/bin/bash
set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
info "Verification keys found : " && ls -1 ${key_path}/*.vkey
read -p "Insert verification key name (example payment1): " key
read -p "Insert verification stake key name (example stake1): " stake

if [[ -e ${key_path}/${key}.vkey && -e ${key_path}/${stake}.vkey ]]
then
    info "Creating/Deriving cardano address from verification key"
    ${cardanocli} address build \
        --payment-verification-key-file ${key_path}/${key}.vkey \
        --stake-verification-key-file ${key_path}/${stake}.vkey \
        --out-file ${key_path}/${key}.addr \
        --testnet-magic $TESTNET_MAGIC
    info "Cardano address created"
    ls ${key_path}/${key}.addr
    echo -e "\n"
else
    error "Verification key does not exists!"
    info "Please run ${cardano_script_path}/gen-key.sh\n"
fi