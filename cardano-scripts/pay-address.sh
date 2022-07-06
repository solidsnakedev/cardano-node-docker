#!/bin/bash
set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "\n- List of Addresses" && ls -1 ${key_path}/*.addr
read -p "Insert wallet origin address (example payment1) : " wallet_origin && ${cardano_script_path}/query-utxo.sh ${wallet_origin}
read -p "Insert tx-in : " txIn
read -p "Insert tx-in id : " txInId
read -p "Insert wallet destination address to pay (example payment2) : " wallet_dest
read -p "Insert wallet change address (example payment1) : " wallet_change
read -p "Insert amount to send (example 500 ADA = 500,000,000 lovelace) : " amount

echo_green "- Building transaction"
${cardanocli} transaction build \
    --babbage-era \
    --tx-in "${txIn}#${txInId}" \
    --tx-out $(cat ${key_path}/${wallet_dest}.addr)+${amount} \
    --change-address $(cat ${key_path}/${wallet_change}.addr) \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/tx.build

echo_green "- Signing transaction"
${cardanocli} transaction sign \
    --tx-body-file ${key_path}/tx.build \
    --signing-key-file ${key_path}/${wallet_origin}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/tx.signed

echo_green "- Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/tx.signed \
    --testnet-magic ${TESTNET_MAGIC}