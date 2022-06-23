echo -e "\nPayment addresses found"
ls /node/keys/*.addr

echo -e "\nInsert origin address (example payment1) : "
read origin

./cardano-cli-query-utxo origin

echo -e "\nInsert tx-in : "
read txIn

echo -e "\nInsert tx-in id : "
read txInId

echo -e "\nInsert amount to pay (example 500 ADA = 500,000,000 lovelace) : "
read amount

echo -e "\nInsert signing key (example payment1) : "
ls /node/keys/*.skey
read signing

echo -e "\nInsert plutus script name (example ...) : "
ls /node/scripts/*.plutus
read script

cardano-cli address build \
    --payment-script-file /node/scripts/${script}.plutus \ 
    --testnet-magic $TESTNET_MAGIC_NUM \
    --out-file /node/keys/${script}.addr

echo -e "\nInsert datum value (example ...) : "
read datum
datum_hash=$(cardano-cli transaction hash-script-data --script-data-value ${datum})

cardano-cli transaction build \
--tx-in "${txIn}#${txInId}" \
--tx-out $(cat /node/keys/${script}.addr)+${amount} \
--tx-out-datum-hash ${datum_hash} \
--change-address $(cat /node/keys/${origin}.addr) \
--testnet-magic ${TESNET_MAGIC} \
--out-file /node/keys/tx.build

cardano-cli transaction sign \
    --tx-body-file /node/keys/tx.build \
    --signing-key-file /node/keys/${signing}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file /node/keys/tx.signed

cardano-cli transaction submit \
    --tx-file /node/keys/tx.signed \
    --testnet-magic ${TESNET_MAGIC}