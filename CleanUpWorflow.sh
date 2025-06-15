#!/bin/bash

# Set variables
REPO="gtm-cloud-ai/da-azure"
WORKFLOW_ID="docker-image.yml"
STATUS="all"  # can be completed, failure, success, etc.
KEEP_MINIMUM=5  # minimum number of recent runs to keep

# Ensure GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    exit 1
fi

# Ensure user is authenticated
if ! gh auth status &> /dev/null; then
    echo "Please login to GitHub CLI first using: gh auth login"
    exit 1
fi

echo "Fetching workflow runs..."
# Get all workflow run IDs except the most recent ones
run_ids=$(gh api \
    -H "Accept: application/vnd.github+json" \
    "/repos/$REPO/actions/workflows/$WORKFLOW_ID/runs?status=$STATUS" \
    --jq ".workflow_runs[${KEEP_MINIMUM}:][].id")

# Check if there are any runs to delete
if [ -z "$run_ids" ]; then
    echo "No workflow runs to delete (keeping $KEEP_MINIMUM most recent runs)"
    exit 0
fi

# Delete each run
for run_id in $run_ids; do
    echo "Deleting workflow run $run_id..."
    gh api \
        --method DELETE \
        "/repos/$REPO/actions/runs/$run_id"
done

echo "Cleanup complete!"