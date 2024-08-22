#!/bin/bash

# Set the repository and authorized organization IDs
REPO="jordan-ae/devpool-directory"
AUTHORIZED_ORG_IDS=(76412717 133917611 165700353)

# Fetch all issues in JSON format
issues=$(gh issue list --repo "$REPO" --limit 1000 --json number,author,title)

# Loop through each issue and delete unauthorized ones
for issue in $(echo "$issues" | jq -c '.[]'); do
    issue_number=$(echo "$issue" | jq -r '.number')
    issue_author_id=$(echo "$issue" | jq -r '.author.id // empty')
    issue_title=$(echo "$issue" | jq -r '.title // empty')

    # Check if the author ID is valid and not in the authorized list
    if [[ -n "$issue_author_id" && ! " ${AUTHORIZED_ORG_IDS[@]} " =~ " ${issue_author_id} " ]]; then
        echo "Deleting unauthorized issue: #$issue_number $issue_title (by $issue_author_id)..."
        gh issue delete "$issue_number" --repo "$REPO" --yes
    fi
done

echo "All unauthorized issues have been deleted."
