if [ -z $(docker ps -q -a)]
then
    echo "No containers to delete"
else
    echo "Deleting containers..."
    docker rm $(docker ps -q -a)
fi