#!/bin/bash
HOSTADDR="0.0.0.0"
PORT="6000"
TOPOLOGY="/node/configuration/testnet-topology.json"
CONFIG="/node/configuration/testnet-config.json"
DBPATH="/node/db"
SOCKETPATH="/node/ipc/node.socket"

/bin/cardano-node run \
        --topology ${TOPOLOGY} \
        --database-path ${DBPATH} \
        --socket-path ${SOCKETPATH} \
        --host-addr ${HOSTADDR} \
        --port ${PORT} \
        --config ${CONFIG}