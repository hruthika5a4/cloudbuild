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

# Get the COMMIT_SHA from instance metadata
COMMIT_SHA=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/COMMIT_SHA" -H "Metadata-Flavor: Google")

# Run the container
docker run -d -p 80:80 us-central1-docker.pkg.dev/$PROJECT_ID/artifact-repo/static-web:$COMMIT_SHA
