#!/bin/bash
set -euo pipefail
if [[ -z $1 ]]
then
    echo -e "\nFound addresses :"
    find /node/keys/ -name "*.addr" |  sed "s/.*\///"
    echo -e "\nInsert address name without extension .addr: "
    read key
else
    key=$1
fi

if [[ -e /node/keys/${key}.addr ]]
then
    echo -e "\nAddress string value : $(cat /node/keys/${key}.addr) "
    echo -e "\nQueryng adddress in cardano testnet ...\n"
    cardano-cli query utxo \
    --testnet-magic $TESNET_MAGIC \
    --address $(cat /node/keys/${key}.addr)
    echo -e "\n"
else
    echo -e "\nAddress does not exists!\n"
fi