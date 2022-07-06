#!/bin/bash
set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "- Queryng protocol parameters ..."
${cardanocli} query protocol-parameters \
  --testnet-magic $TESTNET_MAGIC \
  --out-file ${config_path}/protocol.json

echo_green "protocol.json saved in ${config_path}/protocol.json"