#!/bin/bash
set -o pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Verify correct number of arguments  ---------
if [[ "$#" -eq 0 || "$#" -ne 1 ]]; then echo_red "Error: Missing parameters" && echo_yellow "Info: Command example -> gen-policy-asset.sh <policy-name> "; exit 1; fi

#--------- Get token policy name  ---------
policy_name=${1}

#--------- Verify if policy vkey exists ---------
echo_green "- Verification keys found : "
ls -1 ${key_path}/${policy_name}.vkey 2> /dev/null
if [[ $? -ne 0 ]]; then 
echo_red "Error: Verification key does not exists!"
echo_yellow "Info: Please run ${cardano_script_path}/gen-key.sh ${policy_name}\n"; exit 1; fi

#--------- Run program ---------

#--------- Create policy script ---------
echo_green "- Creating ${script_path}/${policy_name}.script"

cat > ${script_path}/${policy_name}.script << EOF
{
  "type": "sig",
  "keyHash": "$(${cardanocli} address key-hash --payment-verification-key-file ${key_path}/${policy_name}.vkey)"
}
EOF

cat ${script_path}/${policy_name}.script