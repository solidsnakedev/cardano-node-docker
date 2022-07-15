#!/bin/bash
set -o pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Verification  ---------

# Verify correct number of arguments  ---------
if [[ "$#" -eq 0 || "$#" -ne 5 ]]; then error "Missing parameters" && info "Command example -> burn-asset.sh <wallet-name> <token-name> <amount-to-burn> <policy-name> <slot-number> "; exit 1; fi

# Get wallet name
wallet_origin=${1}

# Convert token name to Hex
# Note that asset names are now output in hex format when querying UTxO entries.
token_name1=$(echo -n ${2} | xxd -ps | tr -d '\n')

# Get token amount to burn
amount_to_burn=${3}

# Get token amount to burn
policy_name=${4}

slot_number=${5}

# Verify if policy vkey exists
info "Verification keys found : "
ls -1 ${key_path}/${policy_name}.vkey 2> /dev/null
if [[ $? -ne 0 ]]; then 
error "Verification key does not exists!"
info "Please run ${cardano_script_path}/gen-key.sh ${policy_name}\n"; exit 1; fi

# Verify if policy script exists
info "Policy verification : "
ls -1 ${script_path}/${policy_name}.script 2> /dev/null
if [[ $? -ne 0 ]]; then 
error "Policy script does not exists!"
info "Please run gen-policy-asset.sh or gen-policy-nft.sh ${policy_name}\n"; exit 1; fi

#--------- Run program ---------

# Compute policy id
asset_policy_id=$(${cardanocli} transaction policyid --script-file ${script_path}/${policy_name}.script)
info "Policy ID: ${asset_policy_id}"

# Query utxos from wallet
info "Queryng adddress: $(cat ${key_path}/${wallet_origin}.addr)"
${cardano_script_path}/query-utxo.sh ${wallet_origin}
# Get the total balance, and all utxos so they can be consumed when building the transaction
info "Getting all UTxO from ${wallet_origin}"
readarray results <<< "$(generate_UTXO ${wallet_origin})"
# Get total balance
total_balance=${results[0]}
# Get utxo inputs
tx_in=${results[1]}
# Get number of utxos inputs
tx_cnt=${results[2]}
# Get all native assets
native_assets=${results[3]}

# Filter native assets
readarray filter_asset_result <<< "$(filter_asset "${native_assets}" "${token_name1}")"
# Get filtered native asset balance
native_asset_balance=${filter_asset_result[0]}
# Get filtered native asset name
native_asset_name=${filter_asset_result[1]}
# Calculate change of the native asset to be burnt
native_asset_change=$((native_asset_balance - amount_to_burn))
# Get remainders native assets
remainder_assets=${filter_asset_result[2]}
if [[ -z ${remainder_assets} ]]; then
all_native_assets="${native_asset_change} ${native_asset_name}"
echo ${all_native_assets}
else
all_native_assets="${remainder_assets} + ${native_asset_change} ${native_asset_name}"
echo ${all_native_assets}
fi

min_amount=$(${cardanocli} transaction calculate-min-required-utxo \
    --babbage-era \
    --protocol-params-file ${config_path}/protocol.json \
    --tx-out-reference-script-file ${script_path}/${policy_name}.script \
    --tx-out $(cat ${key_path}/${wallet_origin}.addr)+0+"${amount_to_burn} ${asset_policy_id}.${token_name1}" | awk '{print $2}')

info "Minimum UTxO: ${min_amount}"


info "Building Raw transaction"
${cardanocli} transaction build-raw \
    --babbage-era \
    --fee 0 \
    ${tx_in} \
    --tx-out "$(cat ${key_path}/${wallet_origin}.addr)+${total_balance}+${all_native_assets}" \
    --mint="-${amount_to_burn} ${native_asset_name}" \
    --minting-script-file ${script_path}/${policy_name}.script \
    --invalid-hereafter ${slot_number} \
    --out-file ${key_path}/${policy_name}-tx.raw

fee=$(${cardanocli} transaction calculate-min-fee \
    --tx-body-file ${key_path}/${policy_name}-tx.raw \
    --tx-in-count ${tx_cnt} \
    --tx-out-count 1 \
    --witness-count 2 \
    --testnet-magic ${TESTNET_MAGIC} \
    --protocol-params-file ${config_path}/protocol.json | cut -d " " -f1)

info "Calc fee: ${fee}"
final_balance=$((total_balance - fee))

info "Building transaction"
${cardanocli} transaction build-raw \
    --babbage-era \
    --fee ${fee} \
    ${tx_in} \
    --tx-out "$(cat ${key_path}/${wallet_origin}.addr)+${final_balance}+${all_native_assets}" \
    --mint="-${amount_to_burn} ${native_asset_name}" \
    --minting-script-file ${script_path}/${policy_name}.script \
    --invalid-hereafter ${slot_number} \
    --out-file ${key_path}/${policy_name}-tx.build

info "Signing transaction"
${cardanocli} transaction sign \
    --tx-body-file ${key_path}/${policy_name}-tx.build \
    --signing-key-file ${key_path}/${wallet_origin}.skey \
    --signing-key-file ${key_path}/${policy_name}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/${policy_name}-tx.signed

info "Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/${policy_name}-tx.signed \
    --testnet-magic ${TESTNET_MAGIC}

info "Wait for ~20 seconds so the transaction is in the blockchain."