#!/bin/bash
set -euo pipefail
read -p "Insert key name (example payment1) : " key
read -p "Insert stake key name (example stake1) : " stake

cardano-cli address key-gen \
--verification-key-file /node/keys/${key}.vkey \
--signing-key-file /node/keys/${key}.skey

cardano-cli stake-address key-gen \
    --verification-key-file /node/keys/${stake}.vkey \
    --signing-key-file /node/keys/${stake}.skey

echo -e "\nKeys saved in /node/keys"
ls /node/keys/