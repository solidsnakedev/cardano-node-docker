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

echo_green "\nThis program requires 2 witnesses in order to create a native script\n ADA is locked in native script, and then the 2 witnesses must sign the transaction in order to spend the utxo from the native script"

echo_green "\n- List of addresses" && ls -1 /node/keys/*.addr

read -p "Insert origin 1 address (example payment1) : " origin1
read -p "Insert origin 2 address (example payment2) : " origin2 

echo_green "\n- Creating /node/scripts/multiSigPolicy.script"

cat > /node/scripts/multiSigPolicy.script << EOF
{
  "type": "all",
  "scripts":
  [
    {
      "type": "sig",
      "keyHash": "$(cardano-cli address key-hash --payment-verification-key-file /node/keys/${origin1}.vkey)"
    },
    {
      "type": "sig",
      "keyHash": "$(cardano-cli address key-hash --payment-verification-key-file /node/keys/${origin2}.vkey)"
    }
  ]
}
EOF

echo_green "\n- Creating /node/keys/multiSigPolicy.addr"
cardano-cli address build \
    --payment-script-file /node/scripts/multiSigPolicy.script \
    --testnet-magic $TESNET_MAGIC \
    --out-file /node/keys/multiSigPolicy.addr

echo_green "\n- Send ADA to script? (y/n)"
read ans
if [[ ${ans} == "y" ]]; then
  echo_green "\n- Now send ADA to the multiSigPolicy.addr"
  /bin/pay-address.sh
  echo_green "Waiting for 20 seconds so the transaction is in the blockchain."
  sleep 20
fi

echo_green "\n- The following is used to consumed the utxo from the native script"

echo_green "\n- Querying multiSigPolicy.addr utxos"

/bin/query-utxo.sh multiSigPolicy

read -p "Insert tx-in : " txIn
read -p "Insert tx-in id : " txInId

echo_green "\n- Addresses" && ls -1 /node/keys/*.addr
echo_green " Note: tx-in consumed from multiSigPolicy and total amount is sent to change address"
read -p "Insert change address (example payment3) : " change

echo_green "\n- Building transaction"
cardano-cli transaction build \
    --tx-in "${txIn}#${txInId}" \
    --tx-in-script-file /node/scripts/multiSigPolicy.script \
    --change-address $(cat /node/keys/${change}.addr) \
    --witness-override 2 \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/mulsigpoltx.build

echo_green "\n- Signing transaction witness 1"
cardano-cli transaction witness \
    --tx-body-file /node/keys/mulsigpoltx.build \
    --signing-key-file /node/keys/${origin1}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/${origin1}.witness

echo_green "\n- Signing transaction witness 2"
cardano-cli transaction witness \
    --tx-body-file /node/keys/mulsigpoltx.build \
    --signing-key-file /node/keys/${origin2}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/${origin2}.witness

echo_green "\n- Assembling transaction witness 1 and 2"
cardano-cli transaction assemble \
    --tx-body-file /node/keys/mulsigpoltx.build \
    --witness-file /node/keys/${origin1}.witness \
    --witness-file /node/keys/${origin2}.witness \
    --out-file /node/keys/mulsigpoltx.signed

echo_green "\n- Submiting transaction"
cardano-cli transaction submit \
    --tx-file /node/keys/mulsigpoltx.signed \
    --testnet-magic ${TESNET_MAGIC}




