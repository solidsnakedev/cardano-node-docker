FROM ubuntu:rolling
ENV DEBIAN_FRONTEND=noninteractive

USER root

# Install ubuntu dependencies
RUN apt-get update -y && \
    apt-get install git jq bc make automake rsync htop curl build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ wget libncursesw5 libtool autoconf -y

# Install Cabal dependencies
RUN apt-get -y install pkg-config libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev build-essential curl libgmp-dev libffi-dev libncurses-dev libtinfo5

#Install libsodium
RUN mkdir $HOME/git && \
    cd $HOME/git && \
    git clone https://github.com/input-output-hk/libsodium && \
    cd libsodium && \
    git checkout 66f017f1 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

# Install GHC version 8.10.4
RUN wget -O ghc.tar.xz https://downloads.haskell.org/~ghc/8.10.4/ghc-8.10.4-x86_64-deb9-linux.tar.xz && \
    tar -xf ghc.tar.xz && \
    rm ghc.tar.xz && \
    cd ghc-8.10.4 && \
    ./configure && \
    make install

# Install Cabal
RUN wget -O cabal.tar.xz https://downloads.haskell.org/~cabal/cabal-install-3.4.0.0/cabal-install-3.4.0.0-x86_64-ubuntu-16.04.tar.xz && \
    tar -xf cabal.tar.xz && \
    rm  cabal.tar.xz && \
    mkdir -p ~/.local/bin && \
    mv cabal ~/.local/bin/

# Update PATH
ENV PATH="~/.local/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

# Update Cabal
RUN /bin/bash -c "cabal update"

# Clone Cardano Node and checkout to latest version
RUN export TAG=$(curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r .tag_name) && \
    echo $TAG && \
    cd $HOME && \
    git clone https://github.com/input-output-hk/cardano-node.git && \
    cd cardano-node && \
    git fetch --all --recurse-submodules --tags && \
    git tag && \
    git checkout tags/$TAG

# Set config for cabal project
RUN echo "package cardano-crypto-praos" >>  $HOME/cardano-node/cabal.project.local && \
    echo "flags: -external-libsodium-vrf" >>  $HOME/cardano-node/cabal.project.local

RUN cd $HOME/cardano-node && \
    /bin/bash -c 'cabal build all'

# Find and copy binaries to ~/.local/bin
RUN cp $(find $HOME/cardano-node/dist-newstyle/build -type f -name "cardano-cli") ~/.local/bin/cardano-cli
RUN cp $(find $HOME/cardano-node/dist-newstyle/build -type f -name "cardano-node") ~/.local/bin/cardano-node

RUN export URL_CONFIG_FILES=$(curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r .body | grep 'Configuration files' | sed 's/\(- \[Configuration files\]\)//' | tr -d '()\r' | sed 's/\/index\.html//') && \
    echo $URL_CONFIG_FILES && \
    wget -P $HOME/node $URL_CONFIG_FILES/testnet-config.json && \
    wget -P $HOME/node $URL_CONFIG_FILES/testnet-byron-genesis.json && \
    wget -P $HOME/node $URL_CONFIG_FILES/testnet-shelley-genesis.json && \
    wget -P $HOME/node $URL_CONFIG_FILES/testnet-alonzo-genesis.json && \
    wget -P $HOME/node $URL_CONFIG_FILES/testnet-topology.json

# Change config to save them in /root/node/log/node.log file instead of stdout
RUN sed -i 's/StdoutSK/FileSK/' $HOME/node/testnet-config.json
RUN sed -i 's/stdout/\/root\/node\/logs\/node.log/' $HOME/node/testnet-config.json



# Set node socket for cardano-cli
ENV CARDANO_NODE_SOCKET_PATH="/root/node/db/node.socket"

# Copy script to run node automatically
COPY cardano-node-start.sh /root/.local/bin
RUN /bin/bash -c "chmod +x /root/.local/bin/cardano-node-start.sh"

COPY cardano-cli-tip.sh /root/.local/bin
RUN /bin/bash -c "chmod +x /root/.local/bin/cardano-cli-tip.sh"

ENV TESNET_NETWORK_MAGIC=1097911063

CMD [ "/root/.local/bin/start-cardano-node.sh" ]