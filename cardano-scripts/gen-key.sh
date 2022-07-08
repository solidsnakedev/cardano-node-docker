#!/bin/bash
set -o pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------

if [[ "$#" -eq 0 ]]; then echo_red "Error: Missing parameters" && echo_yellow "Info: Command example -> gen-key.sh payment1 stake1 | gen-key.sh payment1"; exit 1; fi
payment=${1}

${cardanocli} address key-gen \
    --verification-key-file ${key_path}/${payment}.vkey \
    --signing-key-file ${key_path}/${payment}.skey

echo_green "- Keys saved in ${key_path}/${payment}.vkey and ${key_path}/${payment}.skey "

if [[ -z ${2} ]]; then exit 0; fi
stake=${2}

${cardanocli} stake-address key-gen \
    --verification-key-file ${key_path}/${stake}.vkey \
    --signing-key-file ${key_path}/${stake}.skey

echo_green "- Keys saved in ${key_path}/${stake}.vkey and ${key_path}/${stake}.skey"