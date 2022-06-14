#!/bin/bash
HOSTADDR="0.0.0.0"
PORT="6000"
TOPOLOGY="$HOME/node/testnet-topology.json"
CONFIG="$HOME/node/testnet-config.json"
DBPATH="$HOME/node/db"
SOCKETPATH="$HOME/node/db/node.socket"

echo -e "TOPOLOGY: $TOPOLOGY\n" \
        "CONFIG: $CONFIG\n" \
        "DBPATH: $DBPATH\n" \
        "SOCKETPATH: $SOCKETPATH\n" \
    
$HOME/.local/bin/cardano-node run --topology $TOPOLOGY \
                    --database-path $DBPATH \
                    --socket-path $SOCKETPATH \
                    --host-addr $HOSTADDR \
                    --port $PORT \
                    --config $CONFIG \