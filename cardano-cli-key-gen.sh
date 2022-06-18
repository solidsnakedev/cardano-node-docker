echo -e "\nInsert key name (example payment1) : "
read key
cardano-cli address key-gen \
--verification-key-file ${HOME}/node/keys/${key}.vkey \
--signing-key-file ${HOME}/node/keys/${key}.skey

echo -e "\nKeys saved in ${HOME}/node/keys"
ls ${HOME}/node/keys/ | grep ${key}