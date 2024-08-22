#!/bin/bash

# Set the repository and authorized organization IDs
REPO="jordan-ae/devpool-directory"
AUTHORIZED_ORG_IDS=(76412717 133917611 165700353)

# Fetch all issues in JSON format
issues=$(gh issue list --repo "$REPO" --limit 1000 --json number,author,title)

# Check if the issues data was retrieved successfully
if [ -z "$issues" ]; then
    echo "Failed to retrieve issues or no issues found."
    exit 1
fi

# Loop through each issue and delete unauthorized ones
echo "$issues" | jq -c '.[]' | while IFS= read -r issue; do
    issue_number=$(echo "$issue" | jq -r '.number // empty')
    issue_author_id=$(echo "$issue" | jq -r '.author.id // empty')
    issue_title=$(echo "$issue" | jq -r '.title // empty')

    if [ -n "$issue_number" ] && [ -n "$issue_author_id" ]; then
        if [[ ! " ${AUTHORIZED_ORG_IDS[@]} " =~ " ${issue_author_id} " ]]; then
            echo "Deleting unauthorized issue: #$issue_number $issue_title (by $issue_author_id)..."
            gh issue delete "$issue_number" --repo "$REPO" --yes
        fi
    else
        echo "Skipping issue due to missing data."
    fi
done

echo "All unauthorized issues have been processed."