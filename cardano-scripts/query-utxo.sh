#!/bin/bash

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
if [[ -z $1 ]]
then
    echo_green "\n- List of addresses :" && ls -1 ${key_path}/*.addr
    read -p "Insert wallet address (example payment1): " wallet
else
    wallet=$1
fi

if [[ -e ${key_path}/${wallet}.addr ]]
then
    echo_green "- Address string value : $(cat ${key_path}/${wallet}.addr) "
    echo_green "- Queryng adddress in cardano testnet ...\n"
    ${cardanocli} query utxo \
      --testnet-magic $TESTNET_MAGIC \
      --address $(cat ${key_path}/${wallet}.addr)
else
    echo_red  "- Address does not exists!\n"
fi

