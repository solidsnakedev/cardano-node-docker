#!/bin/bash

#--------- Import common paths and functions ---------
source common.sh

#--------- Verification process  ---------
if [[ "$#" -eq 0 || "$#" -ne 1 ]]; then error "Missing parameters" && info "Example -> query-utxo <wallet-name>"; exit 1; fi

wallet_origin=${1}

# Verify if wallet addr exists
[[ -f ${key_path}/${wallet_origin}.addr ]] || { error "${key_path}/${wallet_origin}.addr missing"; exit 1; }

#--------- Run program ---------
${cardanocli} query utxo \
  --testnet-magic $TESTNET_MAGIC \
  --address $(cat ${key_path}/${wallet_origin}.addr)