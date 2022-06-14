# Installing `cardano-node` and `cardano-cli` using Docker container
## Overview
This guide will show you how to compile and install the `cardano-node` and `cardano-cli` using Docker container, directly from the source-code

## Install Docker Engine Ubuntu
https://docs.docker.com/engine/install/ubuntu/

## Creating docker volume
The purpose of this volume is to share a persistent storage between the host and the container.
This folder is nomally stored in `/var/lib/docker/volumes/cardano-node-db/_data`
```
docker volume create cardano-node-db
```

## Give executable permissions to scripts
```
chmod +x build-image.sh run-container.sh rm-*
```

## Building image
You can build the image using the script `build-image.sh`, the image size is ~10 GB

```
docker build -t cardano-node .
```
or
```
./build-image.sh
```

## Running container
You can run a container in from the new cardano-node image.
The `dockerfile` has an `ENTRYPOINT` to run the cardano-node as soon as you run the container
* Run container in detached mode with `-v`
* Run container attaching storage between host and container `cardano-node-db:/root/node/db`
```
docker run -d -v cardano-node-db:/root/node/db cardano-node
```
or
```
./run-container.sh
```

## Acces to container
Fist we need to list the running containers
```
docker ps
```
```
Example
❯  docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS        PORTS     NAMES
ee67eac03bec   cardano-node   "/root/.local/bin/st…"   13 hours ago   Up 13 hours             awesome_gagarin
```

Now you can access the container, in this example `awesome_gagarin`
```
docker exec -it awesome_gagarin bash
```
```
Example
❯  docker exec -it awesome_gagarin bash
root@ee67eac03bec:/# 
```

### Interacting with Cardano node
Once you're inside the container you can interact with `cardano-node` and `cardano-cli`
The variable `$TESNET_NETWORK_MAGIC` is set in `Dockerfile`
```
cardano-cli query tip --testnet-magic $TESNET_NETWORK_MAGIC
```
```
Example 
root@ee67eac03bec:/# cardano-cli query tip --testnet-magic $TESNET_NETWORK_MAGIC 
{
    "era": "Alonzo",
    "syncProgress": "100.00",
    "hash": "425cad2cb7e724ac0b6899b30a63dc7c7c0a2b53d6a043b950e16c2f30a2e753",
    "epoch": 211,
    "slot": 60843409,
    "block": 3630484
}
```

### Exiting the container
You can exit the container typing `exit`
```
Example
root@ee67eac03bec:/# exit
exit
```

## Removing containers
You can remove all the containers with the below script, and this will only remove the stopped containers
```
./rm-containers.sh
```

## Removing images
You can remove all the images with the below script, and this will only remove the images that are not attached to containers
```
./rm-images.sh
```

