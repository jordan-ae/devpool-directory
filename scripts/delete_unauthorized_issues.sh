#!/bin/bash

REPO="jordan-ae/devpool-directory"

# Fetch repository installation info
repo_installation=$(gh api "/repos/$REPO/installation" --jq '.')

# Check if repo installation info is valid
if [[ -z "$repo_installation" ]]; then
    echo "No repository installation info found."
else
    echo "Repository Installation Info:"
    echo "$repo_installation"
fi