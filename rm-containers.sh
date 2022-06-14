if [ -z $(docker ps -q -a --filter 'status=exited') ]
then
    echo "Nothing to delete"
else
    echo "Listing containers with exited status"
    docker ps -a --filter 'status=exited'
    echo "\n"
    echo "Deleting containers with exited status"
    docker rm $(docker ps -q -a --filter 'status=exited')
fi