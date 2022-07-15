#!/bin/bash
set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

# Verify correct number of arguments  ---------
if [[ "$#" -eq 0 || "$#" -ne 1 ]]; then error "Missing parameters" && info "Usage: build-address-script.sh <script-name>"; exit 1; fi

# Get wallet name
script_name=${1}

# Verify if plutus script exists
[[ -f ${script_path}/${script_name}.plutus ]] && info "OK ${script_name}.plutus exists" || { error "${script_name}.plutus missing"; exit 1; }


#--------- Run program ---------

info "Creating/Deriving cardano address from plutus script"
${cardanocli} address build \
    --payment-script-file ${script_path}/${script_name}.plutus \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file ${key_path}/${script_name}.addr
info "Plutus script address created ${key_path}/${script_name}.addr)"
