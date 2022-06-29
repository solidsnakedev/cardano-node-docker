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

echo_color(){
echo -e "${IGreen}$1${Reset}"
}

echo_color "This will generate a multisig script where ADA is locked, and 2 users must sign the transaction in order to spend the utxo from the script"

echo_color "\n- Addresses" && ls -1 /node/keys/*.addr

read -p "Insert origin 1 address (example payment1) : " origin1
read -p "Insert origin 2 address (example payment2) : " origin2 

echo_color "\n- Creating /node/scripts/multiSigPolicy.script"

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

echo_color "\n- Creating /node/keys/multiSigPolicy.addr"
cardano-cli address build \
    --payment-script-file /node/scripts/multiSigPolicy.script \
    --testnet-magic $TESNET_MAGIC \
    --out-file /node/keys/multiSigPolicy.addr

echo_color "\n- Send ADA to script? (y/n)"
read ans
if [[ ${ans} == "y" ]]; then
echo_color "\n- Now send ADA to the multiSigPolicy.addr"
/bin/pay-address.sh
fi

echo_color "\n- Now query multiSigPolicy.addr utxo"
echo "Waiting for 20 seconds so the transaction is in the blockchain."
sleep 20
/bin/query-utxo.sh multiSigPolicy

read -p "Insert tx-in : " txIn
read -p "Insert tx-in id : " txInId

echo_color "\n- Addresses" && ls -1 /node/keys/*.addr
read -p "Insert change address (example payment3) : " change

echo_color "\n- Building transaction\nNote: this transaction will consume the whole utxo amount, and finally send it to the change address"
cardano-cli transaction build \
    --tx-in "${txIn}#${txInId}" \
    --tx-in-script-file /node/scripts/multiSigPolicy.script \
    --change-address $(cat /node/keys/${change}.addr) \
    --witness-override 2 \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/mulsigpoltx.build

echo_color "\n- Signing transaction witness 1"
cardano-cli transaction witness \
    --tx-body-file /node/keys/mulsigpoltx.build \
    --signing-key-file /node/keys/${origin1}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/${origin1}.witness

echo_color "\n- Signing transaction witness 2"
cardano-cli transaction witness \
    --tx-body-file /node/keys/mulsigpoltx.build \
    --signing-key-file /node/keys/${origin2}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/${origin2}.witness

echo_color "\n- Assembling transaction witness 1 and 2"
cardano-cli transaction assemble \
    --tx-body-file /node/keys/mulsigpoltx.build \
    --witness-file /node/keys/${origin1}.witness \
    --witness-file /node/keys/${origin2}.witness \
    --out-file /node/keys/mulsigpoltx.signed

echo_color "\n- Submiting transaction"
cardano-cli transaction submit \
    --tx-file /node/keys/mulsigpoltx.signed \
    --testnet-magic ${TESNET_MAGIC}




