if [ -z $(docker images -q)]
then
    echo "Nothing to delete"
else
    docker rmi $(docker images -q)
fi