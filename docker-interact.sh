
if [[ -z "$1" ]]
then
    docker ps
    echo -e "\nPlease insert container name!!"
    docker ps -q
else 
    echo -e "\nInteractive with container $1\n"
    docker exec -it $1 bash
fi
