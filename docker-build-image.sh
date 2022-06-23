echo -e "- Creating cardano-node image\n"
DOCKER_BUILDKIT=1 docker build -t cardano-node .