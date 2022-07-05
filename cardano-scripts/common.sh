
#--------- Set the customize color for echo function ---------
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
echo_yellow(){
  echo -e "${IYellow}$1${Reset}"
}

#--------- Set the Path to your folders and binaries ---------
key_path="/node/keys"
script_path="/node/scripts"
data_path="/node/data"
cardano_script_path="/usr/local/bin"
cardanocli="/usr/local/bin/cardano-cli"
cardanonode="/usr/local/bin/cardano-node"

#--------- Helper functions ---------
#min_utxo=$(${cardanocli} transaction calculate-min-required-utxo \
#    --babbage-era \
#    --protocol-params-file ${data_path}/protocol.json \
#    --tx-out $(cat ${key_path}/${origin}.addr)+0 | awk '{print $2}')