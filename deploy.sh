#!/bin/bash
set -e

COMMIT_SHA="$1"
if [[ -z "$COMMIT_SHA" ]]; then
  echo "ERROR: COMMIT_SHA not provided!"
  exit 1
fi

TEMPLATE="web-template-$COMMIT_SHA-$(date +%s)"
echo "Creating instance template: $TEMPLATE"

gcloud compute instance-templates create "$TEMPLATE" \
  --machine-type=e2-small \
  --tags=http-server \
  --metadata=DOCKER_IMAGE="us-central1-docker.pkg.dev/$PROJECT_ID/web-repo/web-app:$COMMIT_SHA" \
  --metadata-from-file=startup-script=startup.sh \
  --quiet

echo "Rolling update MIG my-app with template: $TEMPLATE"
gcloud compute instance-groups managed rolling-action start-update my-app \
  --version=template="$TEMPLATE" \
  --zone=us-central1-c \
  --type=proactive \
  --max-surge=1 \
  --max-unavailable=0 \
  --quiet
