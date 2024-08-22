#!/bin/bash

REPO="jordan-ae/devpool-directory"
AUTHORIZED_ORG_IDS=(76412717 133917611 165700353 )

# Fetch issues with author login and author association (organization info might be absent)
issues=$(gh issue list --repo "$REPO" --limit 100 --json number,author,title,id)

# Check if issues JSON is valid
if [[ -z "$issues" || "$issues" == "[]" ]]; then
    echo "No issues found or invalid JSON."
    exit 0
fi

# Process each issue
echo "$issues" | jq -c '.[]' | while read -r issue; do
    issue_number=$(echo "$issue" | jq -r '.number')
    issue_author=$(echo "$issue" | jq -r '.author')
    issue_title=$(echo "$issue" | jq -r '.title')

    echo "Issue #$issue_number: $issue_title"
    echo "Author details: $issue_author"
    echo "-------------------------------"
done