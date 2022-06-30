#!/bin/bash

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White
Reset='\e[0m'

echo_green(){
  echo -e "${IGreen}$1${Reset}"
}
echo_red(){
  echo -e "${IRed}$1${Reset}"
}

if [[ -z $1 ]]
then
    echo_green "\n- List of addresses :"
    find /node/keys/ -name "*.addr" |  sed "s/.*\///"
    echo_green "\nInsert address name without extension .addr: "
    read key
else
    key=$1
fi

if [[ -e /node/keys/${key}.addr ]]
then
    echo_green "\nAddress string value : $(cat /node/keys/${key}.addr) "
    echo_green "\nQueryng adddress in cardano testnet ...\n"
    cardano-cli query utxo \
    --testnet-magic $TESNET_MAGIC \
    --address $(cat /node/keys/${key}.addr)
    echo -e "\n"
else
    echo_red  "\nAddress does not exists!\n"
fi