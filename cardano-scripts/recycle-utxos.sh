#!/bin/bash
set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "\n- List of addresses" && ls -1 ${key_path}/*.addr
read -p "Insert origin address (example payment1) : " origin
${cardano_script_path}/query-utxo.sh ${origin}

#--------- Query utxos and save it in fullUtxo.out ---------
${cardanocli} query utxo \
    --address $(cat ${key_path}/${origin}.addr) \
    --testnet-magic ${TESNET_MAGIC} > ${data_path}/fullUtxo.out

#--------- Remove 3 first rows, and sort balance ---------
tail -n +3 ${data_path}/fullUtxo.out | sort -k3 -nr > ${data_path}/balance.out

#--------- Print balance ---------
cat ${data_path}/balance.out

#--------- Read balance.out file and compose utxo inputs ---------
tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo_green "TxHash: ${in_addr}#${idx}"
    echo_green "ADA: ${utxo_balance}"
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
    echo_green ${tx_in}
done < ${data_path}/balance.out
txcnt=$(cat ${data_path}/balance.out | wc -l)
echo_green "Total ADA balance: ${total_balance}"
echo_green "Number of UTXOs: ${txcnt}"
echo ${tx_in}

#--------- Build transaction ---------
echo_green "\n- Building transaction"
${cardanocli} transaction build \
    --babbage-era \
    ${tx_in} \
    --change-address $(cat ${key_path}/${origin}.addr) \
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