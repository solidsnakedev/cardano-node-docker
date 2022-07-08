#!/bin/bash
set -uo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Verify correct number of arguments  ---------
if [[ "$#" -eq 0 || "$#" -ne 3 ]]; then echo_red "Error: Missing parameters" && echo_yellow "Info: Command example -> mint-asset.sh payment1 TOKENTEST 100 "; exit 1; fi
wallet_origin=${1}
token_name1=$(echo -n ${2} | xxd -ps | tr -d '\n')
#token_name2=$(echo -n "SecondTesttoken" | xxd -ps | tr -d '\n')
token_amount=${3}

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
#token_balance=${results[2]}
#token_policy_name=${results[3]}
total_native_assets=${results[2]}

#min_amount="$(min_utxo ${wallet_origin})"

min_amount=$(${cardanocli} transaction calculate-min-required-utxo \
    --babbage-era \
    --protocol-params-file ${config_path}/protocol.json \
    --tx-out-reference-script-file ${script_path}/mint-asset-policy.script \
    --tx-out $(cat ${key_path}/${wallet_origin}.addr)+0+"${token_amount} ${asset_policy_id}.${token_name1}" | awk '{print $2}')

echo_green "- Minimum UTxO: ${min_amount}"

echo_green "- Building transaction"
${cardanocli} transaction build \
    --babbage-era \
    ${tx_in} \
    --tx-out $(cat ${key_path}/${wallet_origin}.addr)+${min_amount}+"${total_native_assets} + ${token_amount} ${asset_policy_id}.${token_name1}" \
    --change-address $(cat ${key_path}/${wallet_origin}.addr) \
    --mint="${token_amount} ${asset_policy_id}.${token_name1}" \
    --minting-script-file ${script_path}/mint-asset-policy.script \
    --testnet-magic ${TESTNET_MAGIC} \
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