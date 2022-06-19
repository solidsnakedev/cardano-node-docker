# Run container in detached mode, attach port 12798 and attach volumen cardano-node-db with cardano-node image
#docker run -d -p 12798:12798 -v cardano-node-db:/root/node/db cardano-node

# Run container in detached mode , and attached volumen cardano-node-db with image cardano-node
docker images
echo -e "\n- Enter Dockerfile image name to run container : "
read dockerimage
docker run -d -v cardano-node-db:/root/node/db ${dockerimage}