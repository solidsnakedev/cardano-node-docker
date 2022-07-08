#!/bin/bash

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "\nThe following transaction includes metadata . \nThe origin and change address are the same"
echo_green "\n- List of addresses" && ls -1 ${key_path}/*.addr
read -p "Insert wallet origin address (example payment1) : " wallet_origin
#read -p "Insert tx-in : " txIn
#read -p "Insert tx-in id : " txInId

#--------- Query utxos ---------
${cardano_script_path}/query-utxo.sh ${wallet_origin}
#--------- Get the total balance, and all utxos so they can be consumed when building the transaction ---------
echo_green "- Getting all utxos from ${wallet_origin}"
readarray results <<< "$(generate_UTXO ${wallet_origin})"
#--------- Set total balance ---------
total_balance=${results[0]}
#--------- Set utxo inputs ---------
tx_in=${results[1]}

#--------- Listing json file to be sent ---------
ls -1 ${data_path}/*.json 2> /dev/null
if [[ $? -ne 0 ]]; then echo_red "Error: Json file missing!. Create a Json file or run script gen-dummy-json.sh"; exit 1; fi

read -p "Insert json file name (example dummy): " jsonfile

#--tx-in "${txIn}#${txInId}" \
echo_green "- Building transaction \n  Note: wallet origin and change address are the same"
${cardanocli} transaction build \
    --babbage-era \
    ${tx_in} \
    --change-address $(cat ${key_path}/${wallet_origin}.addr) \
    --metadata-json-file ${data_path}/${jsonfile}.json \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/metadata-tx.build

echo_green "- Signing transaction"
${cardanocli} transaction sign \
    --tx-body-file ${key_path}/metadata-tx.build \
    --signing-key-file ${key_path}/${wallet_origin}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/metadata-tx.signed

echo_green "- Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/metadata-tx.signed \
    --testnet-magic ${TESTNET_MAGIC}

echo_green "- Wait for ~20 seconds so the transaction is in the blockchain."
