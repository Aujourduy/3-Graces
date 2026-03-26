#!/bin/bash
source ~/.env-3graces

# Build JSON payload using jq to avoid escaping issues
PAYLOAD=$(jq -n --arg content "$(cat docs/etat-projet.md)" \
  '{files: {"etat-projet.md": {content: $content}}}')

curl -s -X PATCH "https://api.github.com/gists/$GIST_ID" \
  -H "Authorization: token $GIST_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  > /dev/null && echo "✅ Gist synced" || echo "❌ Gist sync failed"
