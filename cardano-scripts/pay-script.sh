#!/bin/bash
echo -e "\nPayment addresses found"
ls /node/keys/*.addr

read -p "Insert origin address (example payment1) : " origin && /bin/query-utxo.sh ${origin}
read -p "Insert TxHash : " txIn
read -p "Insert TxIx id : " txInId
read -p "Insert amount to pay (example 500 ADA = 500,000,000 lovelace) : " amount
ls /node/scripts/*.plutus
read -p "Insert plutus script name (example ...) : " script

cardano-cli address build \
    --payment-script-file /node/scripts/${script}.plutus \
    --testnet-magic ${TESTNET_MAGIC} \
    --out-file /node/keys/${script}.addr

read -p "Insert datum value (example ...) : " datum
datum_hash=$(cardano-cli transaction hash-script-data --script-data-value ${datum})
echo -e "Datum Hash : \n${datum_hash}"

cardano-cli transaction build \
    --tx-in "${txIn}#${txInId}" \
    --tx-out $(cat /node/keys/${script}.addr)+${amount} \
    --tx-out-datum-hash ${datum_hash} \
    --change-address $(cat /node/keys/${origin}.addr) \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/tx.build

cardano-cli transaction sign \
    --tx-body-file /node/keys/tx.build \
    --signing-key-file /node/keys/${origin}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/tx.signed

cardano-cli transaction submit \
    --tx-file /node/keys/tx.signed \
    --testnet-magic ${TESNET_MAGIC}