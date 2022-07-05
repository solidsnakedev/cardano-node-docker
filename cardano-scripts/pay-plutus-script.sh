#!/bin/bash
set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "\n- List of addresses"
ls -1 ${key_path}/*.addr

read -p "Insert origin address (example payment1) : " origin
${cardano_script_path}/query-utxo.sh ${origin}
read -p "Insert TxHash : " txIn
read -p "Insert TxIx id : " txInId
read -p "Insert amount to send (example 500 ADA = 500,000,000 lovelace) : " amount
ls -1 ${script_path}/*.plutus
read -p "Insert plutus script name (example ...) : " script
read -p "Insert datum value (example 123) : " datum
datum_hash=$(${cardanocli} transaction hash-script-data --script-data-value ${datum})
echo -e "Datum Hash : \n${datum_hash}"

echo_green "\n- Building transaction"
${cardanocli} transaction build \
    --babbage-era \
    --tx-in "${txIn}#${txInId}" \
    --tx-out $(cat ${key_path}/${script}.addr)+${amount} \
    --tx-out-datum-hash ${datum_hash} \
    --change-address $(cat ${key_path}/${origin}.addr) \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file ${key_path}/plutx.build

echo_green "\n- Signing transaction"
${cardanocli} transaction sign \
    --tx-body-file ${key_path}/plutx.build \
    --signing-key-file ${key_path}/${origin}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file ${key_path}/plutx.signed

echo_green "\n- Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/plutx.signed \
    --testnet-magic ${TESNET_MAGIC}