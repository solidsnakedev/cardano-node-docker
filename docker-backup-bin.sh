echo -e "\n- Found binaries in folder:"
ls ./backups/bin/
echo -e "\n- Delete bin folder? (y/n)"
read ans
if [[ ${ans} == "y" ]]
then
    rm -r ./backups/bin
    container=$(docker ps -q --filter ancestor=cardano-node)
    echo -e "\n- Backing up cardano-node and cardano-cli \nFrom container ${container}:/bin \nTo host $(pwd)/backups/bin"
    mkdir -p ./backups/bin/
    docker cp ${container}:/usr/local/bin/cardano-node ./backups/bin
    docker cp ${container}:/usr/local/bin/cardano-cli ./backups/bin
    echo -e "\n- cardano-node and cardano-cli backed-up succesfully!! \n"
else
    echo -e "- Nothing to backup"
fi
