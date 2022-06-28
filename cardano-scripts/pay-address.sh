#!/bin/bash
echo -e "\nPayment addresses" && ls /node/keys/*.addr
read -p "Insert origin address (example payment1) : " origin && /bin/query-utxo.sh ${origin}
read -p "Insert tx-in : " txIn
read -p "Insert tx-in id : " txInId
read -p "Insert destination address to pay (example payment2) : " dest
read -p "Insert amount to pay (example 500 ADA = 500,000,000 lovelace) : " amount

cardano-cli transaction build \
--testnet-magic ${TESNET_MAGIC} \
--change-address $(cat /node/keys/${origin}.addr) \
--tx-in "${txIn}#${txInId}" \
--tx-out $(cat /node/keys/${dest}.addr)+${amount} \
--out-file /node/keys/tx.build

cardano-cli transaction sign \
    --tx-body-file tx.build \
    --signing-key-file /node/keys/${origin}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/tx.signed

cardano-cli transaction submit \
    --tx-file /node/keys/tx.signed \
    --testnet-magic ${TESNET_MAGIC}