cardano-cli transaction build \
--testnet-magic ${TESNET_NETWORK_MAGIC} \
--change-address $(cat payment1.addr) \
--tx-in e8e21c09f8c2a7a5eec36ce4d48bc6d4d6fcf9558180e31b833f5dde856e2bfd#0 \
--tx-out $(cat payment2.addr)+500000000 \
--out-file tx.build

cardano-cli transaction sign \
    --tx-body-file tx.build \
    --signing-key-file payment1.skey \
    --mainnet \
    --out-file tx.signed

cardano-cli transaction submit \
    --tx-file tx.signed \
    --testnet-magic ${TESNET_NETWORK_MAGIC}