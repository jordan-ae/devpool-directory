#!/bin/bash

REPO="jordan-ae/devpool-directory"
AUTHORIZED_ORG_IDS=(76412717 133917611 165700353 175221243)

# Fetch issues with author login and author ID (org ID might be absent)
issues=$(gh issue list --repo "$REPO" --limit 100 --json number,author,title)

# Check if issues JSON is valid
if [[ -z "$issues" || "$issues" == "[]" ]]; then
    echo "No issues found or invalid JSON."
    exit 0
fi

# Process each issue
echo "$issues" | jq -c '.[]' | while read -r issue; do
    issue_number=$(echo "$issue" | jq -r '.number')
    issue_author_id=$(echo "$issue" | jq -r '.author.id')
    issue_title=$(echo "$issue" | jq -r '.title')

    # Check if author org ID is not in the authorized list
    if [[ ! " ${AUTHORIZED_ORG_IDS[@]} " =~ " ${issue_author_id} " ]]; then
        echo "Deleting unauthorized issue: #$issue_number $issue_title (by author with ID $issue_author_id)..."
        gh issue delete "$issue_number" --repo "$REPO" --yes
    fi
done

echo "All unauthorized issues have been deleted."

