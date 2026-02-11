# ⚠️ CRITICAL: API Keys in Git History

## Problem

Even though API keys have been removed from the current files, **they are still visible in the git history**. Anyone with access to the repository can retrieve them from previous commits.

### Confirmed Exposed Keys in Git History

1. **Firebase API Key**: `AIzaSyBpBW1xk3GqqLsBtqeGGHx7Zcli-teeb0s`
   - Location: `android/app/google-services.json` (main branch)
   
2. **ImageKit Keys**:
   - Public Key: `public_waBEi2DKhdfDSLxzCC2le7gIYh8=`
   - Private Key: `private_G8Agx7g0ENDvoTOqls6XZt4b0Js=`
   - URL Endpoint: `https://ik.imagekit.io/m40hxtrhc/`
   - Location: `lib/core/imagekit_config.dart` (main branch)

## 🚨 IMMEDIATE ACTIONS REQUIRED

### Step 1: Revoke Compromised API Keys

**BEFORE** cleaning git history, you must invalidate the exposed keys:

#### Firebase
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `alquilamelo-app`
3. Go to Project Settings → General
4. Under "Your apps", find the Android app
5. Click the three dots menu → Delete app (or rotate keys if available)
6. Re-add the Android app to get new credentials
7. Download the new `google-services.json` file

#### ImageKit
1. Go to [ImageKit Dashboard](https://imagekit.io/dashboard)
2. Navigate to "Developer options" → "API Keys"
3. Delete or regenerate your API keys
4. Copy the new keys for later use

### Step 2: Clean Git History

You have two options to remove sensitive data from git history:

---

## Option 1: Using git-filter-repo (RECOMMENDED)

`git-filter-repo` is the modern, fast, and safe tool for rewriting git history.

### Prerequisites
```bash
# Install git-filter-repo
pip3 install git-filter-repo
# or on macOS
brew install git-filter-repo
```

### Commands

```bash
# Navigate to repository
cd /path/to/AlquilameloAppV2

# IMPORTANT: Make a backup first!
cd ..
cp -r AlquilameloAppV2 AlquilameloAppV2-backup
cd AlquilameloAppV2

# Remove sensitive files from entire history
git filter-repo --path android/app/google-services.json --invert-paths --force
git filter-repo --path lib/core/imagekit_config.dart --invert-paths --force

# Alternative: Use a callback to replace sensitive strings
# Create a file called clean-secrets.txt with patterns to remove:
cat > /tmp/clean-secrets.txt << 'EOF'
AIzaSyBpBW1xk3GqqLsBtqeGGHx7Zcli-teeb0s==>REMOVED_API_KEY
public_waBEi2DKhdfDSLxzCC2le7gIYh8===>REMOVED_PUBLIC_KEY
private_G8Agx7g0ENDvoTOqls6XZt4b0Js===>REMOVED_PRIVATE_KEY
https://ik.imagekit.io/m40hxtrhc/==>REMOVED_ENDPOINT
EOF

git filter-repo --replace-text /tmp/clean-secrets.txt --force
```

---

## Option 2: Using BFG Repo-Cleaner (FASTER)

BFG is faster than git-filter-repo but less flexible.

### Prerequisites
```bash
# Download BFG
wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar
# or on macOS
brew install bfg
```

### Commands

```bash
# Navigate to repository parent directory
cd /path/to/parent-of-repo

# IMPORTANT: Make a backup first!
cp -r AlquilameloAppV2 AlquilameloAppV2-backup

# Clone a fresh mirror
git clone --mirror https://github.com/jtuiran4/AlquilameloAppV2.git

# Remove files from history
java -jar bfg-1.14.0.jar --delete-files google-services.json AlquilameloAppV2.git
java -jar bfg-1.14.0.jar --delete-files imagekit_config.dart AlquilameloAppV2.git

# Or replace sensitive strings
cat > secrets.txt << 'EOF'
AIzaSyBpBW1xk3GqqLsBtqeGGHx7Zcli-teeb0s
public_waBEi2DKhdfDSLxzCC2le7gIYh8=
private_G8Agx7g0ENDvoTOqls6XZt4b0Js=
EOF

java -jar bfg-1.14.0.jar --replace-text secrets.txt AlquilameloAppV2.git

# Clean up and force push
cd AlquilameloAppV2.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

---

## Step 3: Force Push Changes

⚠️ **WARNING**: Force pushing rewrites history. Coordinate with all team members!

```bash
# Verify the history is clean
git log --all --full-history -- android/app/google-services.json
git log --all --full-history -- lib/core/imagekit_config.dart

# If no results, the files are gone from history

# Force push to all branches
git push origin --force --all
git push origin --force --tags

# Or for git-filter-repo users
git remote add origin https://github.com/jtuiran4/AlquilameloAppV2.git
git push origin --force --all
git push origin --force --tags
```

---

## Step 4: Update Local Copies

After force pushing, all collaborators must update their local repositories:

```bash
# Each team member should run:
cd AlquilameloAppV2

# Save any local work
git stash

# Update remote URL if needed
git remote set-url origin https://github.com/jtuiran4/AlquilameloAppV2.git

# Fetch the rewritten history
git fetch origin

# Reset to the new history (DESTROYS LOCAL CHANGES)
git reset --hard origin/main

# Restore stashed work if needed
git stash pop
```

---

## Step 5: Add New API Keys Locally

After cleaning the history and regenerating keys:

1. **Firebase**: Place your new `google-services.json` in `android/app/`
2. **ImageKit**: 
   - Copy `lib/core/imagekit_config.dart.example` to `lib/core/imagekit_config.dart`
   - Add your new ImageKit credentials

These files are now in `.gitignore` and won't be committed again.

---

## Step 6: Verify Cleanup

```bash
# Search for old API keys in history
git log -S "AIzaSyBpBW1xk3GqqLsBtqeGGHx7Zcli-teeb0s" --all
git log -S "public_waBEi2DKhdfDSLxzCC2le7gIYh8=" --all

# Should return no results if cleanup was successful
```

---

## Alternative: Delete and Recreate Repository

If the above seems too complex, you can:

1. Create a new private repository
2. Copy only the current working files (not .git directory)
3. Initialize a new git repository
4. Commit the clean files
5. Push to the new repository
6. Update all references to point to the new repository

This gives you a completely clean history but you lose all commit history.

---

## Important Notes

- ✅ The current code is clean - API keys removed and files in `.gitignore`
- ❌ Git history still contains the old keys
- 🔄 Force push is required to update remote repository
- 👥 All team members must re-clone or reset their local copies
- 🔐 Old API keys must be regenerated/revoked before cleaning history
- 📋 Consider making the repository private if it's currently public

---

## Questions?

If you need help with any of these steps, please consult:
- [GitHub: Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [git-filter-repo documentation](https://github.com/newren/git-filter-repo)
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
