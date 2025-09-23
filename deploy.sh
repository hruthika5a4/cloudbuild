#!/bin/bash
set -e

COMMIT_SHA="$1"
if [[ -z "$COMMIT_SHA" ]]; then
  echo "ERROR: COMMIT_SHA not provided!"
  exit 1
fi

# Generate unique instance template name (shortened)
TEMPLATE="static-tmpl-${COMMIT_SHA:0:10}-$(date +%s)"

echo "Creating instance template: $TEMPLATE"

gcloud compute instance-templates create "$TEMPLATE" \
  --machine-type=e2-small \
  --tags=http-server,https-server \
  --metadata=COMMIT_SHA="$COMMIT_SHA" \
  --metadata-from-file=startup-script=script.sh \
  --quiet

echo "Starting rolling update in MIG my-static-app to template: $TEMPLATE"
gcloud compute instance-groups managed rolling-action start-update my-static-app \
  --version=template="$TEMPLATE" \
  --zone=us-central1-c \
  --type=proactive \
  --max-surge=1 \
  --max-unavailable=0 \
  --quiet

# Optional: cleanup old templates (keep last 3)
templates=$(gcloud compute instance-templates list \
  --filter="name~static-template-" \
  --sort-by=~creationTimestamp \
  --format="value(name)" | tail -n +4)
for t in $templates; do
  echo "Deleting old template: $t"
  gcloud compute instance-templates delete "$t" --quiet
done
