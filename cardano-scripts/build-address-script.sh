#!/bin/bash
set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "\n- Scripts found" && ls -1 ${script_path}/*.plutus
read -p "Insert plutus script name (example AlwaysSucced): " script

if [[ -e ${script_path}/${script}.plutus ]]
then
    echo_green "\n- Creating/Deriving cardano address from plutus script"
    ${cardanocli} address build \
        --payment-script-file ${script_path}/${script}.plutus \
        --testnet-magic ${TESTNET_MAGIC} \
        --out-file ${key_path}/${script}.addr
    echo_green "\n- Plutus script address created $(ls ${key_path}/${script}.addr) \n"
else
    echo_red "- Plutus script does not exists!\n"
    echo_red "- Please build a plutus script\n"
fi