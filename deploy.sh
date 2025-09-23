#!/bin/bash
set -e

COMMIT_SHA="$1"
if [[ -z "$COMMIT_SHA" ]]; then
  echo "ERROR: COMMIT_SHA not provided!"
  exit 1
fi

# Shortened instance template name
TEMPLATE="static-tmpl-${COMMIT_SHA:0:10}-$(date +%s)"
echo "Creating instance template: $TEMPLATE"

# Create instance template
gcloud compute instance-templates create "$TEMPLATE" \
  --machine-type=e2-small \
  --tags=http-server,https-server \
  --metadata=COMMIT_SHA="$COMMIT_SHA" \
  --metadata-from-file=startup-script=script.sh \
  --quiet

# Zone of your MIG
ZONE="us-central1-a"

echo "Starting rolling update in MIG web-1-mig to template: $TEMPLATE"
gcloud compute instance-groups managed rolling-action start-update web-1-mig \
  --version=template="$TEMPLATE" \
  --zone="$ZONE" \
  --type=proactive \
  --max-surge=1 \
  --max-unavailable=0 \
  --quiet

# Cleanup old templates (keep last 3)
templates=$(gcloud compute instance-templates list \
  --filter="name~static-tmpl-" \
  --sort-by=~creationTimestamp \
  --format="value(name)" | tail -n +4)
for t in $templates; do
  echo "Deleting old template: $t"
  gcloud compute instance-templates delete "$t" --quiet
done
