#!/bin/bash
set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------

#--------- Select Wallet ---------
info "List of Addresses" && ls -1 ${key_path}/*.addr
read -p "Insert wallet origin address (example payment1) : " wallet_origin
#read -p "Insert tx-in : " txIn
#read -p "Insert tx-in id : " txInId

#--------- Query utxos ---------
${cardano_script_path}/query-utxo.sh ${wallet_origin}
#--------- Get the total balance, and all utxos so they can be consumed when building the transaction ---------
info "Getting all utxos from ${wallet_origin}"
readarray results <<< "$(generate_UTXO ${wallet_origin})"
#--------- Set total balance ---------
total_balance=${results[0]}
#--------- Set utxo inputs ---------
tx_in=${results[1]}

info "Total Balance : ${total_balance}"
read -p "Insert amount to send (example 500 ADA = 500,000,000 lovelace) : " amount
read -p "Insert wallet change address (example payment1) : " wallet_change
read -p "Insert wallet destination address to pay (example payment2) : " wallet_dest

 #--tx-in "${txIn}#${txInId}" \

info "Building transaction"
${cardanocli} transaction build \
    --babbage-era \
    ${tx_in} \
    --tx-out $(cat ${key_path}/${wallet_dest}.addr)+${amount} \
    --change-address $(cat ${key_path}/${wallet_change}.addr) \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/tx.build

info "Signing transaction"
${cardanocli} transaction sign \
    --tx-body-file ${key_path}/tx.build \
    --signing-key-file ${key_path}/${wallet_origin}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/tx.signed

info "Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/tx.signed \
    --testnet-magic ${TESTNET_MAGIC}

info "Wait for ~20 seconds so the transaction is in the blockchain."
