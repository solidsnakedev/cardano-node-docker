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

echo_green "\nList of addresses"
ls -1 /node/keys/*.addr

read -p "Insert origin address (example payment1) : " origin && /bin/query-utxo.sh ${origin}
read -p "Insert TxHash : " txIn
read -p "Insert TxIx id : " txInId
read -p "Insert amount to send (example 500 ADA = 500,000,000 lovelace) : " amount
ls -1 /node/scripts/*.plutus
read -p "Insert plutus script name (example ...) : " script
read -p "Insert datum value (example 123) : " datum
datum_hash=$(cardano-cli transaction hash-script-data --script-data-value ${datum})
echo -e "Datum Hash : \n${datum_hash}"

echo_green "\n- Building transaction"
cardano-cli transaction build \
    --tx-in "${txIn}#${txInId}" \
    --tx-out $(cat /node/keys/${script}.addr)+${amount} \
    --tx-out-datum-hash ${datum_hash} \
    --change-address $(cat /node/keys/${origin}.addr) \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/plutx.build

echo_green "\n- Signing transaction"
cardano-cli transaction sign \
    --tx-body-file /node/keys/plutx.build \
    --signing-key-file /node/keys/${origin}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/plutx.signed

echo_green "\n- Submiting transaction"
cardano-cli transaction submit \
    --tx-file /node/keys/plutx.signed \
    --testnet-magic ${TESNET_MAGIC}