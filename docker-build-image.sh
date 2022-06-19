echo -e "\n- Docker files found :"
ls  Dockerfile*

echo -e "\n- Enter Dockerfile name : "
read dockerfile

if [[ -e ${dockerfile} ]]
then
    if [[ ${dockerfile} == "Dockerfile.build" ]]
    then
        echo -e "creating cardano-node-build\n"
        docker build -f ${dockerfile} -t cardano-node-build .
    else
        echo -e "creating cardano-node-dev\n"
        docker build -f ${dockerfile} -t cardano-node-dev .
    fi
else
    echo "Dockerfile does not exists!"
fi