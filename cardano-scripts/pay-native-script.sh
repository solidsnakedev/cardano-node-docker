set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
info "This program requires 2 witnesses in order to create a native script.\nADA is locked in native script, and then the 2 witnesses must sign the transaction in order to spend the utxo from the native script"

info "List of addresses" && ls -1 ${key_path}/*.addr

read -p "Insert witness origin 1 address (example payment1) : " wallet_origin1
read -p "Insert witness origin 2 address (example payment2) : " wallet_origin2 

info "Creating ${script_path}/multisig-policy.script from witness 1 and 2"

cat > ${script_path}/multisig-policy.script << EOF
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

cat ${script_path}/multisig-policy.script

info "Creating ${key_path}/multisig-policy.addr"
${cardanocli} address build \
    --payment-script-file ${script_path}/multisig-policy.script \
    --testnet-magic $TESTNET_MAGIC \
    --out-file ${key_path}/multisig-policy.addr
info "Address string value : $(cat ${key_path}/multisig-policy.addr)"

read -p "Send ADA to script? (y/n) : " ans

if [[ ${ans} == "y" ]]; then
  info "Sending ADA to multisig-policy.addr"
  ${cardano_script_path}/pay-address.sh
fi