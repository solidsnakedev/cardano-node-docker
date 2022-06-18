backup_db(){
    container=$(docker ps -q --filter ancestor=cardano-node)
    echo -e "\n- Backing up cardano-node database \nFrom container $container:/root/node/db \nTo host $(pwd)/db"
    docker cp $container:/root/node/db .
    echo -e "\n- Cardano node db succesfully copied!! \nTotal size directory:"
    du -h -c db
}

if [[ -d db ]]; then
    echo -e "\n- Found db directory in $(pwd)"
    ls db
    echo -e "\n- Delete db folder, then run backup? (y/n)"
    read ans
    if [[ ${ans} == "y" ]]; then
        rm -r -v db
        backup_db
    else
        echo -e "- Nothing to backup"
    fi
else
    backup_db
fi

