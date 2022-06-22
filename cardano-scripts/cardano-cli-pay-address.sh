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

echo -e "\nInsert destination address to pay (example payment2) : "
read dest

echo -e "\nInsert signing key (example payment1) : "
ls /node/keys/*.skey
read signing

cardano-cli transaction build \
--testnet-magic ${TESNET_MAGIC} \
--change-address $(cat ${origin}.addr) \
--tx-in "${txIn}#${txInId}" \
--tx-out $(cat ${dest}.addr)+${amount} \
--out-file tx.build

cardano-cli transaction sign \
    --tx-body-file tx.build \
    --signing-key-file ${signing}.skey \
    --testnet-magic ${TESNET_MAGIC} \
    --out-file tx.signed

cardano-cli transaction submit \
    --tx-file tx.signed \
    --testnet-magic ${TESNET_MAGIC}