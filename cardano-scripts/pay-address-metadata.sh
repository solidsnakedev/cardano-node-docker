#!/bin/bash

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "The following transaction includes metadata . \nThe origin and change address are the same"
echo_green "\n- List of addresses" && ls -1 ${key_path}/*.addr
read -p "Insert origin address (example payment1) : " origin && ${cardano_script_path}/query-utxo.sh ${origin}
read -p "Insert tx-in : " txIn
read -p "Insert tx-in id : " txInId

ls -1 ${data_path}/*.json 2> /dev/null
if [[ $? -ne 0 ]]; then echo_red "Error: Json file missing!. Create a Json file or run script gen-dummy-json.sh"; exit 1; fi

read -p "Insert json file name (example dummy): " jsonfile

echo_green "\n- Building transaction \n Note: origin and change address are the same"
${cardanocli} transaction build \
    --babbage-era \
    --tx-in "${txIn}#${txInId}" \
    --change-address $(cat ${key_path}/${origin}.addr) \
    --metadata-json-file ${data_path}/${jsonfile}.json \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/metatx.build

echo_green "\n- Signing transaction"
${cardanocli} transaction sign \
    --tx-body-file ${key_path}/metatx.build \
    --signing-key-file ${key_path}/${origin}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/metatx.signed

echo_green "\n- Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/metatx.signed \
    --testnet-magic ${TESTNET_MAGIC}