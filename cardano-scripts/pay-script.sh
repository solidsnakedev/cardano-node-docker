#!/bin/bash
echo -e "\nPayment addresses found"
ls /node/keys/*.addr

read -p "Insert origin address (example payment1) : " origin && /bin/query-utxo.sh ${origin}
read -p "Insert TxHash : " txIn
read -p "Insert TxIx id : " txInId
read -p "Insert amount to send (example 500 ADA = 500,000,000 lovelace) : " amount
ls /node/scripts/*.plutus
read -p "Insert plutus script name (example ...) : " script
read -p "Insert datum value (example 123) : " datum
datum_hash=$(cardano-cli transaction hash-script-data --script-data-value ${datum})
echo -e "Datum Hash : \n${datum_hash}"

cardano-cli transaction build \
    --tx-in "${txIn}#${txInId}" \
    --tx-out $(cat /node/keys/${script}.addr)+${amount} \
    --tx-out-datum-hash ${datum_hash} \
    --change-address $(cat /node/keys/${origin}.addr) \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/plutx.build

cardano-cli transaction sign \
    --tx-body-file /node/keys/plutx.build \
    --signing-key-file /node/keys/${origin}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/plutx.signed

cardano-cli transaction submit \
    --tx-file /node/keys/plutx.signed \
    --testnet-magic ${TESNET_MAGIC}