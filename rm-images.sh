if [ -z $(docker images -q)]
then
    echo "No images to delete"
else
    docker rmi $(docker images -q)
fi