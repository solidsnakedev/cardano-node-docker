echo -e "\nPayment addresses found"
ls ${HOME}/node/keys/*.addr

echo -e "\nInsert address to pay (example payment2) : "
read payment

echo -e "\nInsert amount to pay (example 500 ADA -> 500000000) : "
read amount

echo -e "\nInsert tx-in : "
read txIn

echo -e "\nInsert tx-in id : "
read txInId

echo -e "\nInsert change address (example payment1) : "
read change

echo -e "\nInsert signing key (example payment1) : "
read signing

cardano-cli transaction build \
--testnet-magic ${TESNET_NETWORK_MAGIC} \
--change-address $(cat ${change}.addr) \
--tx-in "${txIn}#${txInId}" \
--tx-out $(cat ${payment}.addr)+${amount} \
--out-file tx.build

cardano-cli transaction sign \
    --tx-body-file tx.build \
    --signing-key-file ${signing}.skey \
    --testnet-magic ${TESNET_NETWORK_MAGIC} \
    --out-file tx.signed

cardano-cli transaction submit \
    --tx-file tx.signed \
    --testnet-magic ${TESNET_NETWORK_MAGIC}