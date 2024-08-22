#!/bin/bash

REPO="jordan-ae/devpool-directory"
AUTHORIZED_ORG_IDS=("app/ubq-test-jordan")

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
    issue_author_login=$(echo "$issue" | jq -r '.author.login')
    issue_title=$(echo "$issue" | jq -r '.title')

    echo "Processing issue #$issue_number: $issue_title (by $issue_author_login)"

    # Assume the issue is unauthorized
    authorized=false

    # Check for exact match in the AUTHORIZED_ORG_IDS array
    for org_id in "${AUTHORIZED_ORG_IDS[@]}"; do
        echo "Checking if $issue_author_login matches $org_id..."
        if [[ "$issue_author_login" == "$org_id" ]]; then
            authorized=true
            echo "Match found: $issue_author_login is authorized."
            break
        fi
    done

    if [[ "$authorized" == false ]]; then
        echo "Deleting unauthorized issue: #$issue_number $issue_title (by $issue_author_login)..."
        gh issue delete "$issue_number" --repo "$REPO" --yes
    else
        echo "Issue #$issue_number is authorized. Skipping deletion."
    fi
done

echo "All unauthorized issues have been processed."
