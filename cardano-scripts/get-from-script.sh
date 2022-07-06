#!/bin/bash
set -uo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "\n- List of addresses"
ls -1 ${key_path}/*.addr

read -p "Insert origin address (example payment1) : " origin
${cardano_script_path}/query-utxo.sh ${origin}
read -p "Insert TxHash : " txIn_origin
read -p "Insert TxIx id : " txInId_origin

read -p "Insert Datum value (example 6666) : " datum
echo_green "- Calculating Datum Hash"
datum_hash=$(${cardanocli} transaction hash-script-data --script-data-value ${datum})
echo_green "- Datum Hash : ${datum_hash}"

read -p "Insert script address (example AlwaysSucceeds) : " script_address
echo_green "- Querying script utxo and filter by Datum Hash"
${cardano_script_path}/query-utxo.sh ${script_address} | grep ${datum_hash}
if [[ $? -ne 0 ]]; then echo_red "Error: Could not find Datum Hash in script utxos!. Insert a different Datum value"; exit 1; fi

read -p "Insert TxHash from script utxo: " txIn_script
read -p "Insert TxIx id from script utxo: " txInId_script

read -p "Insert amount to send from script utxo (example 500 ADA = 500,000,000 lovelace) : " amount

read -p "Insert destination address to pay (example payment2) : " dest

ls -1 ${script_path}/*.plutus
read -p "Insert plutus script name (example AlwaysSucceeds) : " script_file
read -p "Insert redeemer value (example 42) : " redeemer

echo_green "- Building transaction"
${cardanocli} transaction build \
    --babbage-era \
    --testnet-magic ${TESTNET_MAGIC} \
    --tx-in "${txIn_origin}#${txInId_origin}" \
    --tx-in "${txIn_script}#${txInId_script}" \
    --tx-in-datum-value ${datum} \
    --tx-in-redeemer-value ${redeemer} \
    --tx-in-script-file ${script_path}/${script_file}.plutus \
    --tx-in-collateral "${txIn_origin}#${txInId_origin}" \
    --change-address $(cat ${key_path}/${origin}.addr) \
    --tx-out $(cat ${key_path}/${dest}.addr)+${amount} \
    --tx-out-datum-hash ${datum_hash} \
    --protocol-params-file ${data_path}/protocol.json \
    --out-file ${key_path}/plutx.build

echo_green "- Signing transaction"
${cardanocli} transaction sign \
    --tx-body-file ${key_path}/plutx.build \
    --signing-key-file ${key_path}/${origin}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/plutx.signed

echo_green "- Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/plutx.signed \
    --testnet-magic ${TESTNET_MAGIC}