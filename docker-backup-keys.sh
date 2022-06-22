echo -e "\n- Found keys in folder:"
ls ./backups/keys
echo -e "\n- Delete keys folder? (y/n)"
read ans
if [[ ${ans} == "y" ]]
then
    rm -r ./backups/keys
    container=$(docker ps -q --filter ancestor=cardano-node)
    echo -e "\n- Backing up keys \nFrom container ${container}:/node/keys \nTo host $(pwd)/backups/keys"
    docker cp ${container}:/node/keys ./backups/keys
    echo -e "\n- keys backed-up succesfully!! \n"
else
    echo -e "- Nothing to backup"
fi
