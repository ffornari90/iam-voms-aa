#!/bin/bash
if [ $# -eq 0 ]; then
  echo "No arguments supplied. You must provide a Docker image name. Exit."
  exit 1
else
  export DOCKER_IMAGE_NAME="$1"
  docker run -v /var/run/docker.sock:/var/run/docker.sock \
             -v $PWD:/output \
             --privileged \
             --rm \
             quay.io/singularity/docker2singularity \
             -m "/output" \
             -n ${DOCKER_IMAGE_NAME} \
             ${DOCKER_IMAGE_NAME}
  exit 0
fi
