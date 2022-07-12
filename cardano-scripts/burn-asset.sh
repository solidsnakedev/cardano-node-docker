#!/bin/bash
set -uo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Verify correct number of arguments  ---------
if [[ "$#" -eq 0 || "$#" -ne 3 ]]; then echo_red "Error: Missing parameters" && echo_yellow "Info: Command example -> mint-asset.sh payment1 TOKENTEST 100 "; exit 1; fi

#--------- Set wallet name  ---------
wallet_origin=${1}

#--------- Convert token name to Hex  ---------
#Note: Since Cardano Node version 1.32.1
#Asset Name Format Change. Note that asset names are now output in hex format when querying UTxO entries. 
#Any user who is relying on asset names to be represented as ASCII text will need to change their tooling. 
#As a temporary transitional solution, it is possible to use Cardano-cli version 1.31 with node version 1.32.1 if desired, or to continue to use node version 1.31.
#This will not be possible following the next hard fork (which is expected in early 2022).
token_name1=$(echo -n ${2} | xxd -ps | tr -d '\n')

#--------- Set token amount to burn  ---------
amount_to_burn=${3}

#--------- Verify if policy vkey exists ---------
echo_green "- Verification keys found : "
ls -1 ${key_path}/mint-asset-policy.vkey 2> /dev/null
if [[ $? -ne 0 ]]; then 
echo_red "Error: Verification key does not exists!"
echo_yellow "Info: Please run ${cardano_script_path}/gen-key.sh mint-asset-policy\n"; exit 1; fi

#--------- Create policy script ---------
echo_green "- Creating ${script_path}/mint-asset-policy.script"

cat > ${script_path}/mint-asset-policy.script << EOF
{
  "type": "sig",
  "keyHash": "$(${cardanocli} address key-hash --payment-verification-key-file ${key_path}/mint-asset-policy.vkey)"
}
EOF

cat ${script_path}/mint-asset-policy.script

#--------- Compute policy id ---------
asset_policy_id=$(${cardanocli} transaction policyid --script-file ${script_path}/mint-asset-policy.script)
echo_green "- Policy ID: ${asset_policy_id}"

#--------- Query utxos from wallet ---------
echo_green "- Queryng adddress: $(cat ${key_path}/${wallet_origin}.addr)"
${cardano_script_path}/query-utxo.sh ${wallet_origin}
#--------- Get the total balance, and all utxos so they can be consumed when building the transaction ---------
echo_green "- Getting all UTxO from ${wallet_origin}"
readarray results <<< "$(generate_UTXO ${wallet_origin})"
#--------- Set total balance ---------
total_balance=${results[0]}
#--------- Set utxo inputs ---------
tx_in=${results[1]}
#--------- Set number of utxos inputs ---------
tx_cnt=${results[2]}
#--------- Set all native assets ---------
all_native_assets=${results[3]}

#--------- Filter native assets ---------
readarray filter_asset_result <<< "$(filter_asset "${all_native_assets}" "${token_name1}")"
#--------- Set filtered native asset balance ---------
native_asset_balance=${filter_asset_result[0]}
#--------- Set filtered native asset name ---------
native_asset_name=${filter_asset_result[1]}
#--------- Set remainders native assets ---------
remainder_assets=${filter_asset_result[2]}

#--------- Calculate change of the native asset to be burnt ---------
native_asset_change=$(expr $native_asset_balance - ${amount_to_burn})

min_amount=$(${cardanocli} transaction calculate-min-required-utxo \
    --babbage-era \
    --protocol-params-file ${config_path}/protocol.json \
    --tx-out-reference-script-file ${script_path}/mint-asset-policy.script \
    --tx-out $(cat ${key_path}/${wallet_origin}.addr)+0+"${amount_to_burn} ${asset_policy_id}.${token_name1}" | awk '{print $2}')

echo_green "- Minimum UTxO: ${min_amount}"


echo_green "- Building Raw transaction"
${cardanocli} transaction build-raw \
    --babbage-era \
    --fee 0 \
    ${tx_in} \
    --tx-out "$(cat ${key_path}/${wallet_origin}.addr)+${total_balance}+${remainder_assets} + ${native_asset_change} ${native_asset_name}" \
    --mint="-${amount_to_burn} ${native_asset_name}" \
    --minting-script-file ${script_path}/mint-asset-policy.script \
    --out-file ${key_path}/mint-asset-policy-tx.raw

fee=$(${cardanocli} transaction calculate-min-fee \
    --tx-body-file ${key_path}/mint-asset-policy-tx.raw \
    --tx-in-count ${tx_cnt} \
    --tx-out-count 1 \
    --witness-count 1 \
    --testnet-magic ${TESTNET_MAGIC} \
    --protocol-params-file ${config_path}/protocol.json | cut -d " " -f1)

echo_green "- Calc fee: ${fee}"
output_balance=$(expr ${total_balance} - ${fee})

echo_green "- Building transaction"
${cardanocli} transaction build-raw \
    --babbage-era \
    --fee ${fee} \
    ${tx_in} \
    --tx-out $(cat ${key_path}/${wallet_origin}.addr)+${output_balance}+"${remainder_assets} + ${native_asset_change} ${native_asset_name}" \
    --mint="-${amount_to_burn} ${native_asset_name}" \
    --minting-script-file ${script_path}/mint-asset-policy.script \
    --out-file ${key_path}/mint-asset-policy-tx.build

echo_green "- Signing transaction"
${cardanocli} transaction sign \
    --tx-body-file ${key_path}/mint-asset-policy-tx.build \
    --signing-key-file ${key_path}/${wallet_origin}.skey \
    --signing-key-file ${key_path}/mint-asset-policy.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/mint-asset-policy-tx.signed

echo_green "- Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/mint-asset-policy-tx.signed \
    --testnet-magic ${TESTNET_MAGIC}

echo_green "- Wait for ~20 seconds so the transaction is in the blockchain."