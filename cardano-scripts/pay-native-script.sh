set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "\nThis program requires 2 witnesses in order to create a native script\n ADA is locked in native script, and then the 2 witnesses must sign the transaction in order to spend the utxo from the native script"

echo_green "\n- List of addresses" && ls -1 ${key_path}/*.addr

read -p "Insert origin 1 address (example payment1) : " wallet_origin1
read -p "Insert origin 2 address (example payment2) : " wallet_origin2 

echo_green "- Creating ${script_path}/multiSigPolicy.script"

cat > ${script_path}/multiSigPolicy.script << EOF
{
  "type": "all",
  "scripts":
  [
    {
      "type": "sig",
      "keyHash": "$(${cardanocli} address key-hash --payment-verification-key-file ${key_path}/${wallet_origin1}.vkey)"
    },
    {
      "type": "sig",
      "keyHash": "$(${cardanocli} address key-hash --payment-verification-key-file ${key_path}/${wallet_origin2}.vkey)"
    }
  ]
}
EOF

cat ${script_path}/multiSigPolicy.script

echo_green "- Creating ${key_path}/multiSigPolicy.addr"
${cardanocli} address build \
    --payment-script-file ${script_path}/multiSigPolicy.script \
    --testnet-magic $TESTNET_MAGIC \
    --out-file ${key_path}/multiSigPolicy.addr

echo_green "- Send ADA to script? (y/n)"
read ans
if [[ ${ans} == "y" ]]; then
  echo_green "- Sending ADA to multiSigPolicy.addr"
  ${cardano_script_path}/pay-address.sh
  echo_green "Waiting for ~20 seconds so the transaction is in the blockchain."
  sleep 22
fi

echo_green "\n- The following is used to consumed the utxo from the native script"

echo_green "- Querying multiSigPolicy.addr utxos"

${cardano_script_path}/query-utxo.sh multiSigPolicy

read -p "Insert tx-in : " txIn
read -p "Insert tx-in id : " txInId

echo_green "- Addresses" && ls -1 ${key_path}/*.addr
echo_green " Note: tx-in consumed from multiSigPolicy and total amount is sent to change address"
read -p "Insert change address (example payment3) : " wallet_change

echo_green "- Building transaction"
${cardanocli} transaction build \
    --babbage-era \
    --tx-in "${txIn}#${txInId}" \
    --tx-in-script-file ${script_path}/multiSigPolicy.script \
    --change-address $(cat ${key_path}/${wallet_change}.addr) \
    --witness-override 2 \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/mulsigpoltx.build

echo_green "- Signing transaction witness 1"
${cardanocli} transaction witness \
    --tx-body-file ${key_path}/mulsigpoltx.build \
    --signing-key-file ${key_path}/${wallet_origin1}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/${wallet_origin1}.witness

echo_green "- Signing transaction witness 2"
${cardanocli} transaction witness \
    --tx-body-file ${key_path}/mulsigpoltx.build \
    --signing-key-file ${key_path}/${wallet_origin2}.skey \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/${wallet_origin2}.witness

echo_green "- Assembling transaction witness 1 and 2"
${cardanocli} transaction assemble \
    --tx-body-file ${key_path}/mulsigpoltx.build \
    --witness-file ${key_path}/${wallet_origin1}.witness \
    --witness-file ${key_path}/${wallet_origin2}.witness \
    --out-file ${key_path}/mulsigpoltx.signed

echo_green "- Submiting transaction"
${cardanocli} transaction submit \
    --tx-file ${key_path}/mulsigpoltx.signed \
    --testnet-magic ${TESTNET_MAGIC}




