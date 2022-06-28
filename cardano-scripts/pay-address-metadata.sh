#!/bin/bash
echo -e "The following transaction includes metadata . The origin and destination address are the same and the amount of ADA to send is 0"
echo -e "\nPayment addresses" && ls -1 /node/keys/*.addr
read -p "Insert origin address (example payment1) : " origin && /bin/query-utxo.sh ${origin}
read -p "Insert tx-in : " txIn
read -p "Insert tx-in id : " txInId
ls -1 /node/data/*.json
read -p "Insert json file name : " jsonfile

cardano-cli transaction build \
    --testnet-magic ${TESNET_MAGIC} \
    --change-address $(cat /node/keys/${origin}.addr) \
    --tx-in "${txIn}#${txInId}" \
    --tx-out $(cat /node/keys/${origin}.addr)+0 \
    --metadata-json-file /node/data/${jsonfile}.json
    --out-file /node/keys/tx.build

cardano-cli transaction sign \
    --tx-body-file /node/keys/tx.build \
    --signing-key-file /node/keys/${origin}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/tx.signed

cardano-cli transaction submit \
    --tx-file /node/keys/tx.signed \
    --testnet-magic ${TESNET_MAGIC}