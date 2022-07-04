FROM ubuntu:rolling AS builder
ENV DEBIAN_FRONTEND=noninteractive

# Trick to disable cache when a new cardano-node version is found
ADD https://api.github.com/repos/input-output-hk/cardano-node/releases/latest latest_commit

# Install dependencies
RUN apt-get update -y && \
    apt-get install automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf liblmdb-dev curl -y

# Create src folder for installations
RUN mkdir src

# Install libsodium
RUN cd src && \
    git clone https://github.com/input-output-hk/libsodium && \
    cd libsodium && \
    git checkout 66f017f1 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

#Install libsecp256k1
RUN cd src && \
    git clone https://github.com/bitcoin-core/secp256k1 && \
    cd secp256k1 && \
    git checkout ac83be33 && \
    ./autogen.sh && \
    ./configure --enable-module-schnorrsig --enable-experimental && \
    make && \
    make install

# Install GHC version 8.10.4 and Cabal
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_MINIMAL=1 sh
ENV PATH="/root/.ghcup/bin:${PATH}"
RUN ghcup upgrade && \
    ghcup install cabal 3.6.2.0 && \
    ghcup set cabal 3.6.2.0 && \
    ghcup install ghc 8.10.7 && \
    ghcup set ghc 8.10.7

# Update PATH
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

# Update Cabal
RUN cabal update

# Clone Cardano Node and checkout to latest version
RUN export TAG=$(curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r .tag_name) && \
    echo $TAG && \
    cd src && \
    git clone https://github.com/input-output-hk/cardano-node.git && \
    cd cardano-node && \
    git fetch --all --recurse-submodules --tags && \
    git tag && \
    git checkout tags/$TAG

# Set config for cabal project
RUN echo "package cardano-crypto-praos" >>  /src/cardano-node/cabal.project.local && \
    echo "flags: -external-libsodium-vrf" >>  /src/cardano-node/cabal.project.local

# Build cardano-node & cardano-cli
RUN cd src/cardano-node && \
    cabal build all

# Find and copy binaries to ~/.local/bin
RUN cp $(find /src/cardano-node/dist-newstyle/build -type f -name "cardano-cli") /bin/cardano-cli
RUN cp $(find /src/cardano-node/dist-newstyle/build -type f -name "cardano-node") /bin/cardano-node

FROM ubuntu:rolling

COPY --from=builder /bin/cardano-cli /bin
COPY --from=builder /bin/cardano-node /bin

# Install dependencies
RUN apt-get update -y && \
    apt-get install automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf liblmdb-dev curl vim -y

#Install libsodium
RUN mkdir src && \
    cd src && \
    git clone https://github.com/input-output-hk/libsodium && \
    cd libsodium && \
    git checkout 66f017f1 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

#Install libsecp256k1
RUN cd src && \
    git clone https://github.com/bitcoin-core/secp256k1 && \
    cd secp256k1 && \
    git checkout ac83be33 && \
    ./autogen.sh && \
    ./configure --enable-module-schnorrsig --enable-experimental && \
    make && \
    make install

# Delete src folder
RUN rm -r /src

# Update PATH
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

# Get latest config files from IOHK github api
RUN wget -P /node/configuration \
    https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-config.json \
    https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-byron-genesis.json \
    https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-shelley-genesis.json \
    https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-alonzo-genesis.json \
    https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-topology.json

# Change config to save them in /root/node/log/node.log file instead of stdout
RUN sed -i 's/StdoutSK/FileSK/' /node/configuration/testnet-config.json && \
    sed -i 's/stdout/\/node\/logs\/node.log/' /node/configuration/testnet-config.json

# Set node socket for cardano-cli in evironment
ENV CARDANO_NODE_SOCKET_PATH="/node/ipc/node.socket"

# Set testnet magic number
ENV TESNET_MAGIC=1097911063

# Create keys, ipc, data, scripts, logs folders
RUN mkdir -p /node/keys /node/ipc /node/data /node/scripts /node/logs

# Copy scripts
COPY cardano-scripts/ /bin

# Set executable permits
RUN /bin/bash -c "chmod +x /bin/*.sh"

# Run cardano-node at the startup
CMD [ "/bin/cardano-node-run.sh" ]