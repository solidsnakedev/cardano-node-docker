set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "\nThis program requires 2 witnesses in order to create a native script.\nADA is locked in native script, and then the 2 witnesses must sign the transaction in order to spend the utxo from the native script"

echo_green "\n- List of addresses" && ls -1 ${key_path}/*.addr

read -p "Insert witness origin 1 address (example payment1) : " wallet_origin1
read -p "Insert witness origin 2 address (example payment2) : " wallet_origin2 

echo_green "- Creating ${script_path}/multiSigPolicy.script from witness 1 and 2"

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
echo_green "- Address string value : $(cat ${key_path}/multiSigPolicy.addr)"

read -p "Send ADA to script? (y/n) : " ans

if [[ ${ans} == "y" ]]; then
  echo_green "- Sending ADA to multiSigPolicy.addr"
  ${cardano_script_path}/pay-address.sh
fi