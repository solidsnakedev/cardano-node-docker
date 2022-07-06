# Installing `cardano-node` and `cardano-cli` using Docker container
## Overview
This guide will show you how to compile and install the `cardano-node` and `cardano-cli` using Docker container, directly from the source-code.

Image size is only ~800MB !

## 1. Install Docker Engine Ubuntu
https://docs.docker.com/engine/install/ubuntu/

## 2. Give executable permissions to docker scripts
```
chmod +x docker-*
```

## 3. Building image
You can build the image using the script `docker-build-image.sh`, the image size is ~800 MB

```
./docker-build-image.sh
```

## 4. Running container :smiley:
You can run a container from the new cardano-node image.
The `Dockerfile` has an `CMD` to run the cardano-node as soon as you run the container
* Run container in detached mode

```
./docker-run-container.sh
```

## 5. Getting status of cardano-node from host
```
./docker-cardano-stats.sh
```
Example
```
❯  ./docker-cardano-stats.sh 

### Printing cardano-cli version ###

cardano-cli 1.35.0 - linux-x86_64 - ghc-8.10
git rev 9f1d7dc163ee66410d912e48509d6a2300cfa68a

### Printing cardano-node logs ###

[a24cc094:cardano.node.ChainDB:Notice:2249] [2022-07-06 19:25:01.16 UTC] Chain extended, new tip: 151cf9008a65a773d7ed7cccf15338da4e1743422731dae859b76dcb5caf1d75 at slot 62766285
[a24cc094:cardano.node.ChainDB:Notice:2249] [2022-07-06 19:26:21.31 UTC] Chain extended, new tip: 0459ac407ed3aa1eeec313776ab07fc8e17785f40041b18e4474096cec2ff4aa at slot 62766365
[a24cc094:cardano.node.ChainDB:Notice:2249] [2022-07-06 19:26:41.46 UTC] Chain extended, new tip: 472852ee9275b7407b5dc56fe433fd91ce57aca9d546a744b8e86ca0121adbb6 at slot 62766385
[a24cc094:cardano.node.ChainDB:Notice:2249] [2022-07-06 19:26:45.25 UTC] Chain extended, new tip: 326e0fbc173304f5575e6f772521a7cbf4fe877ec8298da3eba26a9d5ae8d1ea at slot 62766389
[a24cc094:cardano.node.ChainDB:Notice:2249] [2022-07-06 19:27:17.52 UTC] Chain extended, new tip: 838b0adfc0997ca91ff66b2aacbbf23757031e4fd8fd4f560bd30df668e20d53 at slot 62766421
[a24cc094:cardano.node.ChainDB:Notice:2249] [2022-07-06 19:27:28.31 UTC] Chain extended, new tip: c87290757d3ea02e9e378ca45f704b1a4123d0a7809551cd77f6652cdbe3239b at slot 62766432
[a24cc094:cardano.node.ChainDB:Notice:2249] [2022-07-06 19:27:36.18 UTC] Chain extended, new tip: 94f4eb387bd8a82e385c5fef54f2fbd5e852769ff8b35230a53cbd2561f08795 at slot 62766440
[a24cc094:cardano.node.ChainDB:Notice:2249] [2022-07-06 19:27:47.21 UTC] Chain extended, new tip: b5c9a280be7f254826a51d93f0c6a6bf48eaca05638f23ef1d850913fa9d8378 at slot 62766451
[a24cc094:cardano.node.ChainDB:Notice:2249] [2022-07-06 19:28:33.31 UTC] Chain extended, new tip: 6d0a1fde84c208aee6e40a82863e9ab8a6efce6cdc5731b6a90345fcb91e04bf at slot 62766497
[a24cc094:cardano.node.ChainDB:Notice:2249] [2022-07-06 19:29:16.23 UTC] Chain extended, new tip: 717f081c8037b8a1d5257c3a5592abd4938158c275220170e3f804cb1109ab03 at slot 62766540

### Printing tip of the blockchain ###

{
    "block": 3688351,
    "epoch": 215,
    "era": "Babbage",
    "hash": "717f081c8037b8a1d5257c3a5592abd4938158c275220170e3f804cb1109ab03",
    "slot": 62766540,
    "syncProgress": "100.00"
}
```
## 6. Creating bash session in container
Fist we need to list the running containers
```
docker ps
```
Example
```
❯  docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED        STATUS        PORTS     NAMES
ee67eac03bec   cardano-node   "/root/.local/bin/st…"   13 hours ago   Up 13 hours             awesome_gagarin
```

### 6.1 Now you can access the container (example `awesome_gagarin`)
```
./docker-interact.sh awesome_gagarin
```

### 6.2 Inside cardano-node container
Once you're inside the container you can run `cardano-node` or `cardano-cli` commands.

*Note: The environment variable `$TESNET_MAGIC` is set in `Dockerfile`*
```
query-tip.sh 
```
Example
```
root@a24cc0944179:/# query-tip.sh 
{
    "block": 3688353,
    "epoch": 215,
    "era": "Babbage",
    "hash": "dc37225eae7cbf4c2eb241c8e1b70fd71e4937c581e76bb0e73e401251d64dd3",
    "slot": 62766612,
    "syncProgress": "100.00"
}
```


### 7. Exiting the container
You can exit the container typing `exit`
```
Example
root@ee67eac03bec:/# exit
exit
```

## 8. Removing containers
You can remove all the containers with the below script, and this will only remove containers with exited status
```
./docker-rm-containers.sh
```

## 9. Removing images
You can remove all the images with the below script, and this will only remove the untagged images
```
./docker-rm-images.sh
```