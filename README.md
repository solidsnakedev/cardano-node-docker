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

## Give executable permissions to docker scripts
```
chmod +x docker-*
```

## Building image
You can build the image using the script `docker-build-image.sh`, the image size is ~10 GB

```
docker build -t cardano-node .
```
or
```
./docker-build-image.sh
```

## Running container :smiley:
You can run a container in from the new cardano-node image.
The `Dockerfile` has an `CMD` to run the cardano-node as soon as you run the container
* Run container in detached mode with `-v`
* Run container attaching storage between host and container `cardano-node-db:/root/node/db`
```
docker run -d -v cardano-node-db:/root/node/db cardano-node
```
or
```
./docker-run-container.sh
```

## Getting status of cardano-node from host
```
./docker-cardano-cli-tip.sh
```
```
Example
❯  ./docker-cardano-cli-tip.sh 

### Printing cardano-cli version ###

cardano-cli 1.34.1 - linux-x86_64 - ghc-8.10
git rev 73f9a746362695dc2cb63ba757fbcabb81733d23

### Printing tip of the blockchain ###

{
    "era": "Alonzo",
    "syncProgress": "100.00",
    "hash": "87bf7c1c408f5bda87c28b0dfa54ecc306909a35ea5d6946f2d92ab4b9dd652a",
    "epoch": 211,
    "slot": 60867451,
    "block": 3631210
}
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
or 
```
./docker-interact.sh awesome_gagarin
```
```
Example
❯  docker exec -it awesome_gagarin bash
root@ee67eac03bec:/# 
```

### Interacting with Cardano node
Once you're inside the container you can run `cardano-node` or `cardano-cli` commands.

*Note: The variable `$TESNET_NETWORK_MAGIC` is set in `Dockerfile`*
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
or
```
./docker-interact.sh
```

### Exiting the container
You can exit the container typing `exit`
```
Example
root@ee67eac03bec:/# exit
exit
```

## Removing containers
You can remove all the containers with the below script, and this will only remove the exited containers
```
./docker-rm-containers.sh
```

## Removing images
You can remove all the images with the below script, and this will only remove the untagged images
```
./docker-rm-images.sh
```

