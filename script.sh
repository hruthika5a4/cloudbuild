#!/bin/bash
set -e

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    apt-get update
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
fi

# Pull the image from Artifact Registry
docker pull us-central1.pkg.dev/singular-object-464504-a3/artifact-repo/web-app:$COMMIT_SHA

# Stop existing container (if any)
docker rm -f web-app || true

# Run the new container
docker run -d --name web-app -p 80:80 us-central1.pkg.dev/singular-object-464504-a3/artifact-repo/web-app:$COMMIT_SHA
