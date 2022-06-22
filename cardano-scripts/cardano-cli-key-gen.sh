echo -e "\nInsert key name (example payment1) : "
read key

echo -e "\nInsert stake key name (example stake1) : "
read stake

cardano-cli address key-gen \
--verification-key-file /node/keys/${key}.vkey \
--signing-key-file /node/keys/${key}.skey

cardano-cli stake-address key-gen \
    --verification-key-file /node/keys/${stake}.vkey \
    --signing-key-file /node/keys/${stake}.skey

echo -e "\nKeys saved in /node/keys"
ls /node/keys/