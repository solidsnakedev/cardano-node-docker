FROM ubuntu:rolling
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install git jq bc make automake rsync htop curl build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ wget libncursesw5 libtool autoconf -y

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
RUN ln -s /usr/local/lib/libsodium.so.23.3.0 /usr/lib/libsodium.so.23

# TODO: check if it's neccesary to keep the below line
# Set packages for ghc
RUN apt-get -y install pkg-config libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev build-essential curl libgmp-dev libffi-dev libncurses-dev libtinfo5

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

# Install Cardano Node
RUN export TAG=$(curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r .tag_name) && \
    echo $TAG && \
    git clone https://github.com/input-output-hk/cardano-node.git && \
    cd cardano-node && \
    git fetch --all --recurse-submodules --tags && \
    git tag && \
    git checkout tags/$TAG

RUN echo "package cardano-crypto-praos" >>  /cardano-node/cabal.project.local && \
    echo "flags: -external-libsodium-vrf" >>  /cardano-node/cabal.project.local

RUN cd cardano-node && \
    /bin/bash -c 'cabal build all'

RUN cp $(find /cardano-node/dist-newstyle/build -type f -name "cardano-cli") ~/.local/bin/cardano-cli

RUN cp $(find /cardano-node/dist-newstyle/build -type f -name "cardano-node") ~/.local/bin/cardano-node