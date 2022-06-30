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
read -p "Insert origin address (example payment1) : " origin && /bin/query-utxo.sh ${origin}
read -p "Insert tx-in : " txIn
read -p "Insert tx-in id : " txInId
read -p "Insert destination address to pay (example payment2) : " dest
read -p "Insert change address (example payment1) : " change
read -p "Insert amount to send (example 500 ADA = 500,000,000 lovelace) : " amount

echo_green "\n- Building transaction"
cardano-cli transaction build \
    --tx-in "${txIn}#${txInId}" \
    --tx-out $(cat /node/keys/${dest}.addr)+${amount} \
    --change-address $(cat /node/keys/${change}.addr) \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/tx.build

echo_green "\n- Signing transaction"
cardano-cli transaction sign \
    --tx-body-file /node/keys/tx.build \
    --signing-key-file /node/keys/${origin}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/tx.signed

echo_green "\n- Submiting transaction"
cardano-cli transaction submit \
    --tx-file /node/keys/tx.signed \
    --testnet-magic ${TESNET_MAGIC}