set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
info "The following program consumes the utxo from the native script"

info "Select witnesses of the native script" && ls -1 ${key_path}/*.addr

read -p "Insert witness origin 1 address (example payment1) : " wallet_origin1
read -p "Insert witness origin 2 address (example payment2) : " wallet_origin2 

read -p "Insert native script name (example multisig-policy) : " policy_name

${cardano_script_path}/query-utxo.sh ${policy_name}

read -p "Insert tx-in : " txIn
read -p "Insert tx-in id : " txInId

info "Select the receiver of the utxo" && ls -1 ${key_path}/*.addr
info "Note: utxo is consumed from native script and total amount is sent to change address"
read -p "Insert change/receiver address (example payment3) : " wallet_change

info "Building transaction"
${cardanocli} transaction build \
    --babbage-era \
    --tx-in "${txIn}#${txInId}" \
    --tx-in-script-file ${script_path}/${policy_name}.script \
    --change-address $(cat ${key_path}/${wallet_change}.addr) \
    --witness-override 2 \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/${policy_name}-tx.build

info "Signing transaction witness 1"
${cardanocli} transaction witness \
    --tx-body-file ${key_path}/${policy_name}-tx.build \
    --signing-key-file ${key_path}/${wallet_origin1}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/${wallet_origin1}.witness

info "Signing transaction witness 2"
${cardanocli} transaction witness \
    --tx-body-file ${key_path}/${policy_name}-tx.build \
    --signing-key-file ${key_path}/${wallet_origin2}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/${wallet_origin2}.witness

info "Assembling transaction witness 1 and 2"
${cardanocli} transaction assemble \
    --tx-body-file ${key_path}/${policy_name}-tx.build \
    --witness-file ${key_path}/${wallet_origin1}.witness \
    --witness-file ${key_path}/${wallet_origin2}.witness \
    --out-file ${key_path}/${policy_name}-tx.signed

info "Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/${policy_name}-tx.signed \
    --testnet-magic ${TESTNET_MAGIC}

info "Wait for ~20 seconds so the transaction is in the blockchain."