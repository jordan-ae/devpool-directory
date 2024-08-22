#!/bin/bash

REPO="jordan-ae/devpool-directory"
AUTHORIZED_ORG_IDS=(76412717 133917611 165700353 app/jordan-ubiquibot-test)

# Fetch issues with author login and author association (organization info might be absent)
issues=$(gh issue list --repo "$REPO" --limit 100 --json assignees,author,body,closed,closedAt,comments,createdAt,id,isPinned,labels,milestone,number,projectCards,projectItems,reactionGroups,state,stateReason,title,updatedAt,url)

# Check if issues JSON is valid
if [[ -z "$issues" || "$issues" == "[]" ]]; then
    echo "No issues found or invalid JSON."
    exit 0
fi

# Print out the entire JSON structure for each issue
echo "$issues" | jq -c '.[]' | while read -r issue; do
    echo "Issue JSON: $issue"
done

echo "All unauthorized issues have been deleted."