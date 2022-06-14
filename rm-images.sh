if [[ -z $(docker images -q --filter "dangling=true") ]]
then
    echo "Nothing to delete"
else
    echo "Listing images"
    docker images -q
    echo -e "\n"
    echo "Deleting images"
    docker rmi $(docker images -q --filter "dangling=true")
fi