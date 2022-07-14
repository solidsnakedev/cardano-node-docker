#!/bin/bash
set -o pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Verify correct number of arguments  ---------
if [[ "$#" -eq 0 || "$#" -ne 4 ]]; then echo_red "Error: Missing parameters" && echo_yellow "Info: Command example -> mint-asset.sh <wallet-name> <token-name> <amount> <policy-name>"; exit 1; fi

#--------- Get wallet name  ---------
wallet_origin=${1}

#--------- Convert token name to Hex  ---------
#Note: Since Cardano Node version 1.32.1
#Asset Name Format Change. Note that asset names are now output in hex format when querying UTxO entries. 
#Any user who is relying on asset names to be represented as ASCII text will need to change their tooling. 
#As a temporary transitional solution, it is possible to use Cardano-cli version 1.31 with node version 1.32.1 if desired, or to continue to use node version 1.31.
#This will not be possible following the next hard fork (which is expected in early 2022).
token_name1=$(echo -n ${2} | xxd -ps | tr -d '\n')

#token_name2=$(echo -n "SecondTesttoken" | xxd -ps | tr -d '\n')

#--------- Get token amount to mint  ---------
token_amount=${3}

policy_name=${4}

#--------- Verify if policy vkey exists ---------
echo_green "- Verification keys found : "
ls -1 ${key_path}/${policy_name}.vkey 2> /dev/null
if [[ $? -ne 0 ]]; then 
echo_red "Error: Verification key does not exists!"
echo_yellow "Info: Please run ${cardano_script_path}/gen-key.sh ${policy_name}\n"; exit 1; fi

#--------- Verify if policy script exists ---------
echo_green "- Policy verification : "
ls -1 ${script_path}/${policy_name}.script 2> /dev/null
if [[ $? -ne 0 ]]; then 
echo_red "Error: Policy script does not exists!"
echo_yellow "Info: Please run gen-policy-asset.sh ${policy_name}\n"; exit 1; fi

#--------- Compute policy id ---------
asset_policy_id=$(${cardanocli} transaction policyid --script-file ${script_path}/${policy_name}.script)
echo_green "- Policy ID: ${asset_policy_id}"

#--------- Query utxos from wallet ---------
echo_green "- Queryng adddress: $(cat ${key_path}/${wallet_origin}.addr)"
${cardano_script_path}/query-utxo.sh ${wallet_origin}

#--------- Get the total balance, and all utxos so they can be consumed when building the transaction ---------
echo_green "- Getting all UTxO from ${wallet_origin}"
readarray results <<< "$(generate_UTXO "${wallet_origin}")"

#--------- Get total balance ---------
total_balance=${results[0]}
#--------- Get utxo inputs ---------
tx_in=${results[1]}
#--------- Get number of utxos inputs ---------
tx_cnt=${results[2]}
#--------- Get all native assets ---------
native_assets=${results[3]}
if [[ -z "${native_assets}" ]]; then
all_native_assets="${token_amount} ${asset_policy_id}.${token_name1}"
else
all_native_assets="${native_assets} + ${token_amount} ${asset_policy_id}.${token_name1}" 
fi

min_amount=$(${cardanocli} transaction calculate-min-required-utxo \
    --babbage-era \
    --protocol-params-file ${config_path}/protocol.json \
    --tx-out-reference-script-file ${script_path}/${policy_name}.script \
    --tx-out $(cat ${key_path}/${wallet_origin}.addr)+0+"${token_amount} ${asset_policy_id}.${token_name1}" | awk '{print $2}')

echo_green "- Minimum UTxO: ${min_amount}"

echo_green "- Building Raw transaction"
${cardanocli} transaction build-raw \
    --babbage-era \
    --fee 0 \
    ${tx_in} \
    --tx-out "$(cat ${key_path}/${wallet_origin}.addr)+${total_balance}+${all_native_assets}" \
    --mint="${token_amount} ${asset_policy_id}.${token_name1}" \
    --minting-script-file ${script_path}/${policy_name}.script \
    --out-file ${key_path}/${policy_name}-tx.raw

fee=$(${cardanocli} transaction calculate-min-fee \
    --tx-body-file ${key_path}/${policy_name}-tx.raw \
    --tx-in-count ${tx_cnt} \
    --tx-out-count 1 \
    --witness-count 1 \
    --testnet-magic ${TESTNET_MAGIC} \
    --protocol-params-file ${config_path}/protocol.json | cut -d " " -f1)

echo_green "- Calc fee: ${fee}"
final_balance=$((total_balance - fee))

echo_green "- Building transaction"
${cardanocli} transaction build-raw \
    --babbage-era \
    --fee ${fee} \
    ${tx_in} \
    --tx-out "$(cat ${key_path}/${wallet_origin}.addr)+${final_balance}+${all_native_assets}" \
    --mint="${token_amount} ${asset_policy_id}.${token_name1}" \
    --minting-script-file ${script_path}/${policy_name}.script \
    --out-file ${key_path}/${policy_name}-tx.build

echo_green "- Signing transaction"
${cardanocli} transaction sign \
    --tx-body-file ${key_path}/${policy_name}-tx.build \
    --signing-key-file ${key_path}/${wallet_origin}.skey \
    --signing-key-file ${key_path}/${policy_name}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/${policy_name}-tx.signed

echo_green "- Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/${policy_name}-tx.signed \
    --testnet-magic ${TESTNET_MAGIC}

echo_green "- Wait for ~20 seconds so the transaction is in the blockchain."