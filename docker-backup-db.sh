#scp -r /root/node/db workstation1@192.168.2.27:/home/workstation1/Documents/projects/cardano-node-docker
container=$(docker ps -q --filter ancestor=cardano-node)
echo -e "\nBacking up cardano-node database from container $container:/root/node/db to host db directory"
docker cp $container:/root/node/db db
echo -e "\nCardano node db succesfully copied!! \nTotal size directory:"
du -h -c db