# cardano-node-docker

## Creating docker volume
the purpose of this volume is to share a persistent storage the cardano database between the host and the container
this folder is nomally stored in '/var/lib/docker/volumes/cardano-node-db/_data'
```
docker volume create cardano-node-db
```

## Building image
You can build the image using the script build-image.sh, the image size is ~10 GB
```
./build-image.sh
``
or

```
docker build -t cardano-node .
```

## Running container
You can run a container in from the new cardano-node image.
### Options
* -v -> detached mode
* cardabi-node-db:/root/node/db -> cardano-node-db attached to /root/node/db
```
./run-containers.sh
```

or

```
docker run -d -v cardano-node-db:/root/node/db cardano-node
```


