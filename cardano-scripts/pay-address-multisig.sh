#!/bin/bash
set -euo pipefail

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White
Reset='\e[0m'

echo_green(){
  echo -e "${IGreen}$1${Reset}"
}

echo_green "\n- List of Addresses" && ls -1 /node/keys/*.addr

read -p "Insert origin 1 address (example payment1) : " origin1 && /bin/query-utxo.sh ${origin1}
read -p "Insert tx-in : " txIn1
read -p "Insert tx-in id : " txInId1

read -p "Insert origin 2 address (example payment2) : " origin2 && /bin/query-utxo.sh ${origin2}
read -p "Insert tx-in : " txIn2
read -p "Insert tx-in id : " txInId2

read -p "Insert change address (example payment1) : " change
read -p "Insert amount to send (example 500 ADA = 500,000,000 lovelace) : " amount
read -p "Insert destination address to pay (example payment2) : " dest

echo_green "\n- Building transaction \nNote: tx-in consumed from 2 origin addresses, and 1 txout to destination address"
cardano-cli transaction build \
    --testnet-magic ${TESNET_MAGIC} \
    --change-address $(cat /node/keys/${change}.addr) \
    --tx-in "${txIn1}#${txInId1}" \
    --tx-in "${txIn2}#${txInId2}" \
    --tx-out $(cat /node/keys/${dest}.addr)+${amount} \
    --witness-override 2 \
    --out-file /node/keys/multx.build

echo_green "\n- Signing transaction witness 1"
cardano-cli transaction witness \
    --tx-body-file /node/keys/multx.build \
    --signing-key-file /node/keys/${origin1}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/${origin1}.witness

echo_green "\n- Signing transaction witness 2"
cardano-cli transaction witness \
    --tx-body-file /node/keys/multx.build \
    --signing-key-file /node/keys/${origin2}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/${origin2}.witness

echo_green "\n- Assembling transaction witness 1 and 2"
cardano-cli transaction assemble \
    --tx-body-file /node/keys/multx.build \
    --witness-file /node/keys/${origin1}.witness \
    --witness-file /node/keys/${origin2}.witness \
    --out-file /node/keys/multx.signed

echo_green "\n- Submiting transaction"
cardano-cli transaction submit \
    --tx-file /node/keys/multx.signed \
    --testnet-magic ${TESNET_MAGIC}