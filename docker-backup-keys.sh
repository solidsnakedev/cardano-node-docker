echo -e "\n- Found keys in folder:"
ls ./keys
echo -e "\n- Delete keys folder? (y/n)"
read ans
if [[ ${ans} == "y" ]]
then
    rm -r keys
    container=$(docker ps -q --filter ancestor=cardano-node)
    echo -e "\n- Backing up keys \nFrom container ${container}:/root/node/keys \nTo host $(pwd)/keys"
    mkdir keys
    docker cp ${container}:/root/node/keys .
    echo -e "\n- keys backed-up succesfully!! \n"
else
    echo -e "- Nothing to backup"
fi
