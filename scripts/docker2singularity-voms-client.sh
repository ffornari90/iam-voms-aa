#!/bin/bash
docker run -v /var/run/docker.sock:/var/run/docker.sock --privileged --rm -v $PWD:/output quay.io/singularity/docker2singularity -m "/output" -n voms-client ffornari/voms-client:latest
