#!/bin/bash
set -e

# Pull the image from Artifact Registry
docker pull $DOCKER_IMAGE

# Stop any existing container
docker rm -f web-app || true

# Run the new container
docker run -d --name web-app -p 80:8080 $DOCKER_IMAGE
