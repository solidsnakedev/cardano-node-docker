#!/bin/bash
echo -e "\nVerification keys found : " && ls -1 /node/keys/*.vkey
read -p "Insert verification key name (example payment1): " key
read -p "Insert verification stake key name (example stake1): " stake

if [[ -e /node/keys/${key}.vkey && -e /node/keys/${stake}.vkey ]]
then
    echo -e "\nCreating/Deriving cardano address from verification key"
    cardano-cli address build \
        --payment-verification-key-file /node/keys/${key}.vkey \
        --stake-verification-key-file /node/keys/${stake}.vkey \
        --out-file /node/keys/${key}.addr \
        --testnet-magic $TESNET_MAGIC
    echo -e "\nCardano address created"
    ls /node/keys/$key.addr
    echo -e "\n"
else
    echo -e "verification key does not exists!"
    echo -e "Please run /bin/gen-key.sh\n"
fi