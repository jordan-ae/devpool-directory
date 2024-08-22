#!/bin/bash

REPO="jordan-ae/devpool-directory"

# Fetch repository installation info
repo_installation=$(gh api "/repos/$REPO/installation" --jq '.')

# Check if repo installation info is valid
if [[ -z "$repo_installation" ]]; then
    echo "No repository installation info found."
else
    echo "Repository Installation Info: $repo_installation"
fi

# Fetch issues with the available fields
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