# Installing `cardano-node` and `cardano-cli` using Docker container
## Overview
This guide will show you how to compile and install the `cardano-node` and `cardano-cli` using Docker container, directly from the source-code.

Image size is only ~787MB !

## 1. Install Docker Engine Ubuntu
https://docs.docker.com/engine/install/ubuntu/

## 2. Give executable permissions to docker scripts
```
chmod +x docker-*
```

## 3. Building image
You can build the image using the script `docker-build-image.sh`, the image size is ~10 GB

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
./docker-cardano-cli-stats.sh
```
Example
```
❯  ./docker-cardano-cli-stats.sh 

### Printing cardano-cli version ###

cardano-cli 1.34.1 - linux-x86_64 - ghc-8.10
git rev 73f9a746362695dc2cb63ba757fbcabb81733d23

### Printing cardano-node logs ###

[730193f7:cardano.node.ChainDB:Notice:661] [2022-06-14 20:18:44.35 UTC] Chain extended, new tip: faff9e70bd777ce371e11368c6ad5b7f3d2ab6d8467c460d325786138e2378f7 at slot 60868708
[730193f7:cardano.node.ChainDB:Notice:661] [2022-06-14 20:19:00.65 UTC] Chain extended, new tip: 9bfaea2e41ca5ee969f170d109474896fc1b625e45a1c9f8760143066c98462c at slot 60868724
[730193f7:cardano.node.ChainDB:Notice:661] [2022-06-14 20:19:19.50 UTC] Chain extended, new tip: 14bdf2e7bac15861701657368393ed85894b7227bab461f32338c24bd951b183 at slot 60868743
[730193f7:cardano.node.ChainDB:Notice:661] [2022-06-14 20:19:41.58 UTC] Chain extended, new tip: 7553e7ff144b0917b1605f979c220443cf221c859044dee13e871a3ac0b7e3de at slot 60868765
[730193f7:cardano.node.ChainDB:Notice:661] [2022-06-14 20:20:16.59 UTC] Chain extended, new tip: 086e1abe775f2a0c40ed25d3f3f11db1a2878be337f164e05e3f4ee9f090a34b at slot 60868800
[730193f7:cardano.node.ChainDB:Notice:661] [2022-06-14 20:20:42.81 UTC] Chain extended, new tip: 45d2446e5e67123246a338ddea9fd936bfb6fdcc659e6372943cd8c05ae7f57a at slot 60868826
[730193f7:cardano.node.ChainDB:Notice:661] [2022-06-14 20:21:01.74 UTC] Chain extended, new tip: c137483d7f427061ee2fdbff97774e6178e62e01a6bacc791fbccedf580495ef at slot 60868845
[730193f7:cardano.node.ChainDB:Notice:661] [2022-06-14 20:22:45.53 UTC] Chain extended, new tip: 90958bd76b5b165be1f5a3a89ca92572dc20d31c781a00f18341fb592325f5e7 at slot 60868949
[730193f7:cardano.node.ChainDB:Notice:661] [2022-06-14 20:22:57.25 UTC] Chain extended, new tip: 0a077395844c0859b0b02480fde585cd1d49c57096df8f149fbaf2b735cff85f at slot 60868960
[730193f7:cardano.node.ChainDB:Notice:661] [2022-06-14 20:22:59.93 UTC] Chain extended, new tip: 4e57c837b46d9a668e814adc3fedbb8953370c984810bf9c3cd8876496c42bcd at slot 60868963

### Printing tip of the blockchain ###

{
    "era": "Alonzo",
    "syncProgress": "100.00",
    "hash": "4e57c837b46d9a668e814adc3fedbb8953370c984810bf9c3cd8876496c42bcd",
    "epoch": 211,
    "slot": 60868963,
    "block": 3631266
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
cardano-cli-tip.sh 
```
Example
```
root@ee67eac03bec:/# cardano-cli-tip.sh 
{
    "era": "Alonzo",
    "syncProgress": "100.00",
    "hash": "425cad2cb7e724ac0b6899b30a63dc7c7c0a2b53d6a043b950e16c2f30a2e753",
    "epoch": 211,
    "slot": 60843409,
    "block": 3630484
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