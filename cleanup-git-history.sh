#!/bin/bash

# Script to clean sensitive data from git history
# USE AT YOUR OWN RISK - This will rewrite git history!

set -e

echo "========================================"
echo "  Git History Cleanup Script"
echo "========================================"
echo ""
echo "⚠️  WARNING: This script will rewrite git history!"
echo "⚠️  Make sure you have:"
echo "    1. Revoked/regenerated all exposed API keys"
echo "    2. Created a backup of the repository"
echo "    3. Coordinated with all team members"
echo ""

read -p "Have you completed all prerequisites? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Aborting. Please complete prerequisites first."
    exit 1
fi

echo ""
echo "Checking for git-filter-repo..."
if ! command -v git-filter-repo &> /dev/null; then
    echo "❌ git-filter-repo not found!"
    echo "Install it with:"
    echo "  pip3 install git-filter-repo"
    echo "  or: brew install git-filter-repo (macOS)"
    exit 1
fi

echo "✅ git-filter-repo found"
echo ""

# Create replacement file
echo "Creating secrets replacement file..."
cat > /tmp/git-secrets-replace.txt << 'EOF'
AIzaSyBpBW1xk3GqqLsBtqeGGHx7Zcli-teeb0s==>***REMOVED_FIREBASE_KEY***
public_waBEi2DKhdfDSLxzCC2le7gIYh8===>***REMOVED_IMAGEKIT_PUBLIC***
private_G8Agx7g0ENDvoTOqls6XZt4b0Js===>***REMOVED_IMAGEKIT_PRIVATE***
https://ik.imagekit.io/m40hxtrhc/==>***REMOVED_IMAGEKIT_ENDPOINT***
EOF

echo "✅ Replacement file created"
echo ""

# Backup current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $current_branch"
echo ""

read -p "Proceed with history rewrite? (yes/no): " proceed
if [ "$proceed" != "yes" ]; then
    echo "❌ Aborting."
    exit 1
fi

echo ""
echo "🔄 Rewriting git history..."
echo "This may take a few minutes..."
echo ""

# Method 1: Remove files completely from history
echo "Step 1: Removing sensitive files from history..."
git filter-repo --path android/app/google-services.json --invert-paths --force
echo "✅ Removed google-services.json from history"

git filter-repo --path lib/core/imagekit_config.dart --invert-paths --force
echo "✅ Removed imagekit_config.dart from history"

# Method 2: Replace sensitive strings
echo ""
echo "Step 2: Replacing sensitive strings in remaining history..."
git filter-repo --replace-text /tmp/git-secrets-replace.txt --force
echo "✅ Replaced sensitive strings"

echo ""
echo "🔄 Cleaning up repository..."
git reflog expire --expire=now --all
git gc --prune=now --aggressive
echo "✅ Repository cleaned"

echo ""
echo "========================================"
echo "  ✅ History Cleanup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Verify the cleanup:"
echo "   git log --all --full-history -- android/app/google-services.json"
echo "   (should return no results)"
echo ""
echo "2. Re-add the remote:"
echo "   git remote add origin https://github.com/jtuiran4/AlquilameloAppV2.git"
echo ""
echo "3. Force push to remote:"
echo "   git push origin --force --all"
echo "   git push origin --force --tags"
echo ""
echo "4. All team members must re-clone or reset their repositories"
echo ""
echo "⚠️  Remember: Old API keys are still exposed until you:"
echo "   - Force push these changes to the remote repository"
echo "   - Regenerate/revoke the exposed API keys"
echo ""

# Clean up
rm -f /tmp/git-secrets-replace.txt
