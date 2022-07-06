
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
config_path="/node/configuration"
cardano_script_path="/usr/local/bin"
cardanocli="/usr/local/bin/cardano-cli"
cardanonode="/usr/local/bin/cardano-node"

#--------- Helper functions ---------

get_all_txin(){
    #--------- Query utxos and save it in fullUtxo.out ---------
    local wallet="${1}"
    ${cardanocli} query utxo \
        --address $(cat ${key_path}/${wallet}.addr) \
        --testnet-magic ${TESTNET_MAGIC} > ${data_path}/fullUtxo.out

    #--------- Remove 3 first rows, and sort balance ---------
    tail -n +3 ${data_path}/fullUtxo.out | sort -k3 -nr > ${data_path}/balance.out

    #--------- Read balance.out file and compose utxo inputs ---------
    local tx_in=""
    local total_balance=0
    while read -r utxo; do
        in_addr=$(awk '{ print $1 }' <<< "${utxo}")
        idx=$(awk '{ print $2 }' <<< "${utxo}")
        utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
        total_balance=$((${total_balance}+${utxo_balance}))
        tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
    done < ${data_path}/balance.out
    echo ${total_balance}
    echo ${tx_in}
}

#min_utxo=$(${cardanocli} transaction calculate-min-required-utxo \
#    --babbage-era \
#    --protocol-params-file ${config_path}/protocol.json \
#    --tx-out $(cat ${key_path}/${origin}.addr)+0 | awk '{print $2}')