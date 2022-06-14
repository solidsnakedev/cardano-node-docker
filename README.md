# Cardano node with Docker Containers

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
You can build the image using the script build-image.sh, the image size is ~10 GB
```
./build-image.sh
```
or

```
docker build -t cardano-node .
```

## Running container
You can run a container in from the new cardano-node image.
* Run container in detached mode with `-v`
* Run container attaching storage between host and container `cardano-node-db:/root/node/db`
```
./run-container.sh
```
or

```
docker run -d -v cardano-node-db:/root/node/db cardano-node
```

## Acces to container
Get running containers
```
docker ps
```
```
Example
❯  docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS        PORTS     NAMES
ee67eac03bec   cardano-node   "/root/.local/bin/st…"   13 hours ago   Up 13 hours             awesome_gagarin
```

Access the container
```
docker exec -it #### bash
```

## Removing containers
This will only remove the stopped containers
```
./rm-containers.sh
```

## Removing images
This will only remove the images that are not attached to containers
```
./rm-images.sh
```

