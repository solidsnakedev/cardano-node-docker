backup_db(){
    container=$(docker ps -q --filter ancestor=cardano-node)
    echo -e "\n- Backing up cardano-node database \nFrom container $container:/node/db \nTo host $(pwd)/backups/db"
    docker cp $container:/node/db ./backups/db
    echo -e "\n- Cardano node db succesfully copied!! \nTotal size directory:"
    du -h -c db
}

if [[ -d ./backups/db ]]; then
    echo -e "\n- Found db directory in $(pwd)"
    ls ./backups/db
    echo -e "\n- Delete db folder, then run backup? (y/n)"
    read ans
    if [[ ${ans} == "y" ]]; then
        rm -r -v ./backups/db
        backup_db
    else
        echo -e "- Nothing to backup"
    fi
else
    backup_db
fi

