echo -e "\nVerification keys found"
ls ${HOME}/node/keys/*.vkey
echo -e "\nInsert verification key name (example payment1): "
read key
if [[ -e ${HOME}/node/keys/$key.vkey ]]
then
    echo -e "\nCreating/Deriving cardano address from verification key"
    cardano-cli address build \
    --payment-verification-key-file ${HOME}/node/keys/$key.vkey \
    --out-file ${HOME}/node/keys/$key.addr \
    --testnet-magic $TESNET_NETWORK_MAGIC
    echo -e "\nCardano address created"
    ls ${HOME}/node/keys/$key.addr
    echo -e "\n"
else
    echo -e "verification key does not exists!"
    echo -e "Please run cardano-cli-key-gen.sh\n"
fi