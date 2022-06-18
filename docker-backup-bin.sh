echo -e "\n- Found binaries in folder:"
ls ./bin
echo -e "\n- Delete bin folder? (y/n)"
read ans
if [[ ${ans} == "y" ]]
then
    rm -r bin
    container=$(docker ps -q --filter ancestor=cardano-node)
    echo -e "\n- Backing up cardano-node and cardano-cli \nFrom container ${container}:/root/.local/bin \nTo host $(pwd)/bin"
    mkdir bin
    docker cp ${container}:/root/.local/bin/cardano-node bin
    docker cp ${container}:/root/.local/bin/cardano-cli bin
    echo -e "\n- cardano-node and cardano-cli backed-up succesfully!! \n"
else
    echo -e "- Nothing to backup"
fi
