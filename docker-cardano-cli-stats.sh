container=$(docker ps -q --filter ancestor=cardano-node)

echo -e "\n### Printing cardano-cli version ###\n"
docker exec $container /bin/cardano-cli --version
echo -e "\n### Printing cardano-node logs ###\n"
docker exec $container tail /node/logs/node.log
echo -e "\n### Printing tip of the blockchain ###\n"
docker exec $container /bin/cardano-cli query tip --testnet-magic 1097911063