#!/bin/bash
set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "\n- List of Addresses" && ls -1 ${key_path}/*.addr
read -p "Insert origin address (example payment1) : " origin && ${cardano_script_path}/query-utxo.sh ${origin}
read -p "Insert tx-in : " txIn
read -p "Insert tx-in id : " txInId
read -p "Insert destination address to pay (example payment2) : " dest
read -p "Insert change address (example payment1) : " change
read -p "Insert amount to send (example 500 ADA = 500,000,000 lovelace) : " amount

echo_green "\n- Building transaction"
${cardanocli} transaction build \
    --babbage-era \
    --tx-in "${txIn}#${txInId}" \
    --tx-out $(cat ${key_path}/${dest}.addr)+${amount} \
    --change-address $(cat ${key_path}/${change}.addr) \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file ${key_path}/tx.build

echo_green "\n- Signing transaction"
${cardanocli} transaction sign \
    --tx-body-file ${key_path}/tx.build \
    --signing-key-file ${key_path}/${origin}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file ${key_path}/tx.signed

echo_green "\n- Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/tx.signed \
    --testnet-magic ${TESNET_MAGIC}