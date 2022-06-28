#!/bin/bash
set -euo pipefail
echo -e "\nQueryng protocol parameters ..."
cardano-cli query protocol-parameters \
  --testnet-magic $TESNET_MAGIC \
  --out-file /node/protocol.json
echo -e "protocol.json saved in : \n"
ls /node/protocol.json