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
echo_red(){
  echo -e "${IRed}$1${Reset}"
}

echo_green "\n- List of addresses" && ls -1 /node/keys/*.addr
read -p "Insert origin address (example payment1) : " origin && /bin/query-utxo.sh ${origin}

cardano-cli query utxo \
    --address $(cat /node/keys/${origin}.addr) \
    --testnet-magic ${TESNET_MAGIC} > fullUtxo.out

tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out

cat balance.out

tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo_green "TxHash: ${in_addr}#${idx}"
    echo_green "ADA: ${utxo_balance}"
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
    echo_green ${tx_in}
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo_green "Total ADA balance: ${total_balance}"
echo_green "Number of UTXOs: ${txcnt}"
echo ${tx_in}

echo_green "\n- Building transaction"
cardano-cli transaction build \
    ${tx_in} \
    --change-address $(cat /node/keys/${origin}.addr) \
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