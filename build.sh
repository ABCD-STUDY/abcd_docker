#/bin/bash

# use new buildkit
export DOCKER_BUILDKIT=1

# Path to file containing Matlab fileInstallationKey
keypath="license/matlab/fileInstallationKey"

# start build to abcd:latest
docker build --build-arg fileInstallationKey=$(cat ${keypath}) --tag abcd .
