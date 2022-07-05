#!/bin/bash

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
if [[ -z $1 ]]
then
    echo_green "\n- List of addresses :" && ls -1 ${key_path}/*.addr
    read -p "Insert address (example payment1): " key
else
    key=$1
fi

if [[ -e ${key_path}/${key}.addr ]]
then
    echo_green "\n- Address string value : $(cat ${key_path}/${key}.addr) "
    echo_green "\n- Queryng adddress in cardano testnet ...\n"
    ${cardanocli} query utxo \
      --testnet-magic $TESNET_MAGIC \
      --address $(cat ${key_path}/${key}.addr)
    echo -e "\n"
else
    echo_red  "\n- Address does not exists!\n"
fi