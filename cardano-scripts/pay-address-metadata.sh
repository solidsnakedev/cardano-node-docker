#!/bin/bash

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
echo_red(){
  echo -e "${IRed}$1${Reset}"
}

echo_green "The following transaction includes metadata . \nThe origin and change address are the same"
echo_green "\n- List of addresses" && ls -1 /node/keys/*.addr
read -p "Insert origin address (example payment1) : " origin && /bin/query-utxo.sh ${origin}
read -p "Insert tx-in : " txIn
read -p "Insert tx-in id : " txInId

ls -1 /node/data/*.json 2> /dev/null
if [[ $? -ne 0 ]]; then echo_red "Error: Json file missing!. Create a Json file or run script gen-dummy-json.sh"; exit 1; fi

read -p "Insert json file name : " jsonfile

#min_utxo is not used
min_utxo=$(cardano-cli transaction calculate-min-required-utxo \
    --protocol-params-file /node/protocol.json \
    --tx-out $(cat /node/keys/${origin}.addr)+0 | awk '{print $2}')

echo_green "\n- Building transaction \n Note: origin and change address are the same"
cardano-cli transaction build \
    --tx-in "${txIn}#${txInId}" \
    --change-address $(cat /node/keys/${origin}.addr) \
    --metadata-json-file /node/data/${jsonfile}.json \
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