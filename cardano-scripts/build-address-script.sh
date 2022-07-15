#!/bin/bash
set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
info "Scripts found" && ls -1 ${script_path}/*.plutus
read -p "Insert plutus script name (example AlwaysSucced): " script

if [[ -e ${script_path}/${script}.plutus ]]
then
    info "Creating/Deriving cardano address from plutus script"
    ${cardanocli} address build \
        --payment-script-file ${script_path}/${script}.plutus \
        --testnet-magic ${TESTNET_MAGIC} \
        --out-file ${key_path}/${script}.addr
    info "Plutus script address created $(ls ${key_path}/${script}.addr) \n"
else
    error "Plutus script does not exists!\n"
    info "Please build a plutus script\n"
fi