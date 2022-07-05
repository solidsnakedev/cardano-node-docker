if [[ -z "$1" ]]; then
    docker ps
    read -p "- Enter Container name to copy files : " container
else 
    container=$1
fi

while read line; do
        echo -e "- Copying ./cardano-scripts/${line} -> ${container}:/usr/local/bin"
        docker cp ./cardano-scripts/${line} ${container}:/usr/local/bin
    done <<< $(ls ./cardano-scripts/)