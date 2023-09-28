#!/bin/bash

export IMAGE_NAME="voxelbone.cloud/resonite-pri:latest"
#export IMAGE_NAME="ghcr.io/voxelbonecloud/pterodactyl-resonite"

docker buildx build --pull -t $IMAGE_NAME .

#docker save $IMAGE_NAME | bzip2 | pv | ssh HOST_HERE docker load
