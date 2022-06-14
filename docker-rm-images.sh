if [[ -z $(docker images -q --filter "dangling=true") ]]
then
    echo "Nothing to delete"
else
    echo "Listing images"
    docker images
    echo -e "\n"
    echo "Deleting untagged images"
    docker rmi $(docker images -q --filter "dangling=true")
fi