#!/bin/bash

issues=$(gh issue list --state open --json number,title,body \
  --jq '.[] | "## Issue #\(.number): \(.title)\n\(.body)\n---"' 2>/dev/null \
  || echo "No issues found")

commits=$(git log -n 5 --format="%n%ad%n%B--_" --date=short 2>/dev/null \
  || echo "No commits found")

prompt=$(cat ralph/prompt.md)

claude --permission-mode acceptEdits \
  "Previous commits: $commits Issues: $issues $prompt"
