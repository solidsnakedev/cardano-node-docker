cat > /node/data/dummy.json << EOF
{
  "0":
    {
      "node_version": "$(cardano-cli --version | awk 'NR==1{print}')",
      "message": "Hello world!",
      "time": "$(date)"
    },
  "${RANDOM}":
    {
      "description": "this is a random label"
    }
}
EOF