#!/bin/bash
set -o pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Verification  ---------

# Verify correct number of arguments
if [[ "$#" -eq 0 || "$#" -ne 1 ]]; then echo_red "Error: Missing parameters" && echo_yellow "Info: Command example -> gen-policy-nft.sh <policy-name> "; exit 1; fi

# Get token policy name
policy_name=${1}

# Verify if policy vkey exists
info "Verification keys found : "
ls -1 ${key_path}/${policy_name}.vkey 2> /dev/null
if [[ $? -ne 0 ]]; then 
echo_red "Error: Verification key does not exists!"
echo_yellow "Info: Please run ${cardano_script_path}/gen-key.sh ${policy_name}\n"; exit 1; fi

#--------- Run program ---------

# Create policy script
info "Creating ${script_path}/${policy_name}.script"

# Get slot number from policy script/
slot_number=$(expr $(${cardanocli} query tip --testnet-magic ${TESTNET_MAGIC} | jq .slot?) + 10000)

cat > ${script_path}/${policy_name}.script << EOF
{
  "type": "all",
  "scripts":
  [
    {
      "type": "before",
      "slot": ${slot_number}
    },
    {
      "type": "sig",
      "keyHash": "$(${cardanocli} address key-hash --payment-verification-key-file ${key_path}/${policy_name}.vkey)"
    }
  ]
}
EOF