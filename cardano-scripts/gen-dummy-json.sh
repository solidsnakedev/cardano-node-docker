#!/bin/bash
set -euo pipefail

#--------- Import common paths and functions ---------
source common.sh

#--------- Run program ---------
echo_green "- Generating dummy json file, saved in ${data_path}"
cat > ${data_path}/dummy.json << EOF
{
  "0":
    {
      "node_version": "$(${cardanocli} --version | awk 'NR==1{print}')",
      "message": "Hello world!",
      "time": "$(date)"
    },
  "${RANDOM}":
    {
      "description": "this is a random label"
    }
}
EOF

cat ${data_path}/dummy.json