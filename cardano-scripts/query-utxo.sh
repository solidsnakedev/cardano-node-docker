#!/bin/bash

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
if [[ "$#" -eq 0 || "$#" -ne 1 ]]; then error "Missing parameters" && info "Example -> query-utxo payment1"; exit 1; fi

wallet=$1

if [[ ! -e ${key_path}/${wallet}.addr ]]; then error "Address does not exists!"; exit 1; fi

#echo_green "- Queryng adddress: $(cat ${key_path}/${wallet}.addr)"
${cardanocli} query utxo \
  --testnet-magic $TESTNET_MAGIC \
  --address $(cat ${key_path}/${wallet}.addr)