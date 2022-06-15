#scp -r /root/node/db workstation1@192.168.2.27:/home/workstation1/Documents/projects/cardano-node-docker
container=$(docker ps -q --filter ancestor=cardano-node)
docker cp $container:/root/node/db db