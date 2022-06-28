#!/bin/bash
echo -e "\nPayment addresses" && ls -1 /node/keys/*.addr

read -p "Insert origin 1 address (example payment1) : " origin1 && /bin/query-utxo.sh ${origin1}
read -p "Insert tx-in : " txIn1
read -p "Insert tx-in id : " txInId1

read -p "Insert origin 2 address (example payment2) : " origin2 && /bin/query-utxo.sh ${origin2}
read -p "Insert tx-in : " txIn2
read -p "Insert tx-in id : " txInId2

read -p "Insert change address (example payment1) : " change
read -p "Insert amount to send (example 500 ADA = 500,000,000 lovelace) : " amount
read -p "Insert destination address to pay (example payment2) : " dest

cardano-cli transaction build \
    --testnet-magic ${TESNET_MAGIC} \
    --change-address $(cat /node/keys/${change}.addr) \
    --tx-in "${txIn1}#${txInId1}" \
    --tx-in "${txIn2}#${txInId2}" \
    --tx-out $(cat /node/keys/${dest}.addr)+${amount} \
    --witness-override 2 \
    --out-file /node/keys/multx.build

cardano-cli transaction witness \
    --tx-body-file /node/keys/multx.build \
    --signing-key-file /node/keys/${origin1}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/${origin1}.witness

cardano-cli transaction witness \
    --tx-body-file /node/keys/multx.build \
    --signing-key-file /node/keys/${origin2}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/${origin2}.witness

cardano-cli transaction assemble \
    --tx-body-file /node/keys/multx.build \
    --witness-file /node/keys/${origin1}.witness \
    --witness-file /node/keys/${origin2}.witness \
    --out-file /node/keys/multx.signed

cardano-cli transaction submit \
    --tx-file /node/keys/multx.signed \
    --testnet-magic ${TESNET_MAGIC}