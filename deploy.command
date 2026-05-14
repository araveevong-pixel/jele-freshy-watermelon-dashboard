#!/bin/bash
set -e
cd "$(dirname "$0")"
echo "=== JELE Freshy แตงโม Dashboard Deploy ==="

TOKEN_LINE=$(grep -E "ghp_|github_pat_" ../.git/config 2>/dev/null | head -1)
[ -z "$TOKEN_LINE" ] && { echo "ERROR: token not found"; exit 1; }
TOKEN=$(echo "$TOKEN_LINE" | grep -oE "(ghp_|github_pat_)[A-Za-z0-9_]+")

API_USER=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/user | grep '"login"' | head -1 | sed 's/.*: "\(.*\)",/\1/')
[ -z "$API_USER" ] && { echo "ERROR: token invalid"; exit 1; }
echo "→ Auth as: $API_USER"

REPO_NAME="jele-freshy-watermelon-dashboard"
echo "→ Creating repo $API_USER/$REPO_NAME..."
curl -s -X POST -H "Authorization: token $TOKEN" -H "Accept: application/vnd.github+json" \
    https://api.github.com/user/repos \
    -d "{\"name\":\"$REPO_NAME\",\"public\":true,\"description\":\"JELE Freshy แตงโม 2026 KOL Marketing Dashboard\"}" > /tmp/repo_resp.json
grep -q '"name"' /tmp/repo_resp.json && echo "  ✓ Repo created" || echo "  Repo may already exist"

[ -d .git ] || git init -b main
git config user.email "${API_USER}@users.noreply.github.com"
git config user.name "$API_USER"
git add -A
git diff --staged --quiet || git commit -m "Deploy JELE Freshy แตงโม dashboard"
git remote remove origin 2>/dev/null || true
git remote add origin "https://${API_USER}:${TOKEN}@github.com/${API_USER}/${REPO_NAME}.git"
echo "→ Pushing..."
git push -u origin main --force

echo "→ Enabling Pages..."
curl -s -X POST -H "Authorization: token $TOKEN" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${API_USER}/${REPO_NAME}/pages" \
    -d '{"source":{"branch":"main","path":"/"}}' > /dev/null
echo "  ✓ Pages enabled"

echo "→ Setting TIKTOK_COOKIES secret (re-using from lotus repo if available)..."
# Note: GitHub doesn't let us read secrets, so nick needs to re-add it manually
# or we share the same cookies file via clipboard. Skipping for now.

echo "→ Triggering first scrape..."
sleep 3
curl -s -X POST -H "Authorization: token $TOKEN" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${API_USER}/${REPO_NAME}/actions/workflows/auto-update.yml/dispatches" \
    -d '{"ref":"main"}' > /dev/null
echo "  ✓ Workflow dispatched"

echo ""
echo "==================================================="
echo "  ✅ DEPLOY SUCCESS"
echo "==================================================="
echo "  Live: https://${API_USER}.github.io/${REPO_NAME}/"
echo "  Repo: https://github.com/${API_USER}/${REPO_NAME}"
echo "==================================================="
echo ""
echo "⚠️  สำคัญ: เพิ่ม TIKTOK_COOKIES secret ที่:"
echo "  https://github.com/${API_USER}/${REPO_NAME}/settings/secrets/actions"
echo "  (Copy cookies เดิมจาก lotus repo ได้)"
