#!/bin/bash
set -euo pipefail
echo -e "\nScripts found" && ls -1 /node/scripts/
read -p "Insert plutus script name (example AlwaysSucced): " script

if [[ -e /node/scripts/${script}.plutus ]]
then
    echo -e "\nCreating/Deriving cardano address from plutus script"
    cardano-cli address build \
        --payment-script-file /node/scripts/${script}.plutus \
        --testnet-magic ${TESTNET_MAGIC} \
        --out-file /node/keys/${script}.addr
    echo -e "\nPlutus script address created $(ls /node/scripts/${script}.addr) \n"
else
    echo -e "Plutus script does not exists! \nPlease build a plutus script\n"
fi