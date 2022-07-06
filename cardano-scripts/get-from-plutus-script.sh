#!/bin/bash
set -uo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
read -p "Insert Datum value (example 6666) : " datum_value
echo_green "- Calculating Datum Hash"
datum_hash=$(${cardanocli} transaction hash-script-data --script-data-value ${datum_value})
echo_green "- Datum Hash : ${datum_hash}"

read -p "Insert wallet script address (example AlwaysSucceeds) : " wallet_script
echo_green "- Querying script utxo and filter by Datum Hash"
${cardano_script_path}/query-utxo.sh ${wallet_script} | grep ${datum_hash}
if [[ $? -ne 0 ]]; then echo_red "Error: Could not find Datum Hash in script utxos!. Insert a different Datum value"; exit 1; fi

read -p "Insert TxHash from script utxo: " txIn_script
read -p "Insert TxIx id from script utxo: " txInId_script
read -p "Insert amount to send from script utxo (example 500 ADA = 500,000,000 lovelace) : " amount
ls -1 ${script_path}/*.plutus
read -p "Insert plutus file name (example AlwaysSucceeds) : " script_file
read -p "Insert redeemer value (example 42) : " redeemer_value

echo_green "\n- Select a wallet to be used as tx-in and collateral"
ls -1 ${key_path}/*.addr
read -p "Insert wallet origin address (example payment1) : " wallet_origin
${cardano_script_path}/query-utxo.sh ${wallet_origin}
read -p "Insert TxHash : " txIn_origin
read -p "Insert TxIx id : " txInId_origin

read -p "Insert wallet destination address to pay (example payment2) : " wallet_dest


echo_green "- Building transaction"
${cardanocli} transaction build \
    --babbage-era \
    --testnet-magic ${TESTNET_MAGIC} \
    --tx-in "${txIn_origin}#${txInId_origin}" \
    --tx-in "${txIn_script}#${txInId_script}" \
    --tx-in-datum-value ${datum_value} \
    --tx-in-redeemer-value ${redeemer_value} \
    --tx-in-script-file ${script_path}/${script_file}.plutus \
    --tx-in-collateral "${txIn_origin}#${txInId_origin}" \
    --change-address $(cat ${key_path}/${wallet_origin}.addr) \
    --tx-out $(cat ${key_path}/${wallet_dest}.addr)+${amount} \
    --tx-out-datum-hash ${datum_hash} \
    --protocol-params-file ${config_path}/protocol.json \
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