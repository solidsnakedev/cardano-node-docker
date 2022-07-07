set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "\n- The following program consumes the utxo from the native script"

echo_green "\n- Select witnesses of the native script" && ls -1 ${key_path}/*.addr

read -p "Insert witness origin 1 address (example payment1) : " wallet_origin1
read -p "Insert witness origin 2 address (example payment2) : " wallet_origin2 

echo_green "- Select multisig-policy.addr utxos to consume"

${cardano_script_path}/query-utxo.sh multisig-policy

read -p "Insert tx-in : " txIn
read -p "Insert tx-in id : " txInId

echo_green "- Select the receiver of the utxo" && ls -1 ${key_path}/*.addr
echo_green " Note: utxo is consumed from native script and total amount is sent to change address"
read -p "Insert change/receiver address (example payment3) : " wallet_change

echo_green "- Building transaction"
${cardanocli} transaction build \
    --babbage-era \
    --tx-in "${txIn}#${txInId}" \
    --tx-in-script-file ${script_path}/multisig-policy.script \
    --change-address $(cat ${key_path}/${wallet_change}.addr) \
    --witness-override 2 \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/multisig-policy-tx.build

echo_green "- Signing transaction witness 1"
${cardanocli} transaction witness \
    --tx-body-file ${key_path}/multisig-policy-tx.build \
    --signing-key-file ${key_path}/${wallet_origin1}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/${wallet_origin1}.witness

echo_green "- Signing transaction witness 2"
${cardanocli} transaction witness \
    --tx-body-file ${key_path}/multisig-policy-tx.build \
    --signing-key-file ${key_path}/${wallet_origin2}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/${wallet_origin2}.witness

echo_green "- Assembling transaction witness 1 and 2"
${cardanocli} transaction assemble \
    --tx-body-file ${key_path}/multisig-policy-tx.build \
    --witness-file ${key_path}/${wallet_origin1}.witness \
    --witness-file ${key_path}/${wallet_origin2}.witness \
    --out-file ${key_path}/multisig-policy-tx.signed

echo_green "- Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/multisig-policy-tx.signed \
    --testnet-magic ${TESTNET_MAGIC}

echo_green "- Wait for ~20 seconds so the transaction is in the blockchain."