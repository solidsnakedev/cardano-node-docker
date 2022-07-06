#!/bin/bash
set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "\n- List of addresses"
ls -1 ${key_path}/*.addr

read -p "Insert wallet origin address (example payment1) : " wallet_origin
${cardano_script_path}/query-utxo.sh ${wallet_origin}
read -p "Insert TxHash : " txIn
read -p "Insert TxIx id : " txInId
read -p "Insert amount to send (example 500 ADA = 500,000,000 lovelace) : " amount

ls -1 ${script_path}/*.plutus
read -p "Insert plutus name (example AlwaysSucceeds) : " wallet_script
read -p "Insert Datum value (example 6666) : " datum_value
echo_green "- Calculating Datum Hash"
datum_hash=$(${cardanocli} transaction hash-script-data --script-data-value ${datum_value})
echo_green "- Datum Hash : ${datum_hash}"

echo_green "- Building transaction"
${cardanocli} transaction build \
    --babbage-era \
    --tx-in "${txIn}#${txInId}" \
    --tx-out $(cat ${key_path}/${wallet_script}.addr)+${amount} \
    --tx-out-datum-hash ${datum_hash} \
    --change-address $(cat ${key_path}/${wallet_origin}.addr) \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/plutx.build

echo_green "- Signing transaction"
${cardanocli} transaction sign \
    --tx-body-file ${key_path}/plutx.build \
    --signing-key-file ${key_path}/${wallet_origin}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/plutx.signed

echo_green "- Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/plutx.signed \
    --testnet-magic ${TESTNET_MAGIC}

echo_green "- Wait for ~20 seconds so the transaction is in the blockchain."