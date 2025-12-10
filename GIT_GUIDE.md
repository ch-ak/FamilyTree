# 🚀 Git Version Control Guide for FamilyTree App

## What is Git?

Git is like **Time Machine for your code**. It saves snapshots (called "commits") of your project at different points in time, so you can:
- ✅ See what changed and when
- ✅ Undo mistakes by going back to any previous version
- ✅ Try new features without breaking working code
- ✅ Keep your project backed up in the cloud (GitHub)

## Your Git Repository is Now Set Up! ✅

I just committed all of today's work. Here's what we saved:
- **138 files changed**
- **35,627 lines added**
- Complete documentation of all fixes
- All working code

## Basic Git Commands (Simple Guide)

### 1️⃣ Save Your Current Work (Commit)

When you make changes and want to save a snapshot:

```bash
cd /Users/chakrikotcherlakota/Documents/FamilyTree

# See what changed
git status

# Add all changes to staging
git add -A

# Save with a message
git commit -m "Added new feature: family tree PDF export"
```

**When to commit:**
- ✅ After fixing a bug
- ✅ After adding a feature
- ✅ Before trying something risky
- ✅ At end of work session

### 2️⃣ See What Changed

```bash
# See list of commits
git log --oneline

# See detailed changes
git log --graph --all --oneline

# See what files changed in last commit
git show --name-only

# See actual code changes
git diff
```

### 3️⃣ Undo Changes

**Undo uncommitted changes (get back working code):**
```bash
# Undo changes to specific file
git restore FamilyTree/ViewModels/CleanPersonFormViewModel.swift

# Undo all uncommitted changes
git restore .
```

**Go back to a previous commit:**
```bash
# See list of commits
git log --oneline

# Go back to specific commit (use commit hash from log)
git checkout 489f418

# Go back to latest
git checkout main
```

### 4️⃣ Create Branches (Try Features Safely)

Branches let you try new features without breaking your working code:

```bash
# Create new branch for experiment
git checkout -b feature/new-d3-chart

# Make changes, test them...
# If they work:
git add -A
git commit -m "Added new D3 chart feature"

# Switch back to main
git checkout main

# Merge the feature into main
git merge feature/new-d3-chart

# If experiment failed, just delete the branch:
git branch -D feature/new-d3-chart
```

## Your Current Git Status

```
Current Branch: main
Latest Commit: ✅ Fix duplicate parent relationships & enhance family display
Total Commits: 2
Files Tracked: 138
```

### What's in Your Latest Commit (Today's Work):

```
✅ DATABASE FIXES:
   - Fixed duplicate parent relationships
   - Added duplicate prevention
   - Added deduplication logic

✅ CHAT WIZARD ENHANCEMENTS:
   - Shows actual names (not counts)
   - Added emoji indicators
   - Added confirmation step
   - Smart flow for missing relationships

✅ DOCUMENTATION:
   - DATABASE_DUPLICATE_FIX.md
   - ENHANCED_FAMILY_DISPLAY.md
   - cleanup_duplicates.sql
   - Multiple test guides
```

## Recommended Workflow

### Daily Development:

1. **Start of day:** See current status
   ```bash
   git status
   git log --oneline -5
   ```

2. **Make changes:** Edit files in Xcode

3. **Test changes:** Run and test your app

4. **Save progress:** Commit when something works
   ```bash
   git add -A
   git commit -m "Fixed sibling linking bug"
   ```

5. **End of day:** Make sure everything is committed
   ```bash
   git status  # Should show "nothing to commit"
   ```

### Before Risky Changes:

1. **Create a backup branch:**
   ```bash
   git checkout -b backup/before-major-refactor
   git checkout main  # Go back to main
   ```

2. **Make your risky changes**

3. **If it works:** Keep the changes
   ```bash
   git add -A
   git commit -m "Completed major refactor"
   git branch -D backup/before-major-refactor  # Delete backup
   ```

4. **If it breaks:** Go back to backup
   ```bash
   git checkout backup/before-major-refactor
   git checkout -b main  # Make this your new main
   ```

## Push to GitHub (Cloud Backup)

To back up your code to GitHub:

### One-time Setup:

1. **Create GitHub repository:**
   - Go to https://github.com
   - Click "New repository"
   - Name it "FamilyTree"
   - Don't initialize with README (we already have files)

2. **Link your local repo to GitHub:**
   ```bash
   cd /Users/chakrikotcherlakota/Documents/FamilyTree
   
   # Add GitHub as remote (replace YOUR_USERNAME)
   git remote add origin https://github.com/YOUR_USERNAME/FamilyTree.git
   
   # Push your code
   git push -u origin main
   ```

### Daily Use (After Setup):

```bash
# Push your commits to GitHub
git push

# Get latest from GitHub (if working from multiple computers)
git pull
```

## Useful Tips

### View Your Commit History Nicely:

```bash
# Simple list
git log --oneline

# With graph
git log --graph --all --oneline --decorate

# Last 5 commits
git log --oneline -5

# See changes in specific file
git log --oneline -- FamilyTree/ViewModels/CleanPersonFormViewModel.swift
```

### See What Changed in a File:

```bash
# See uncommitted changes
git diff FamilyTree/ViewModels/CleanPersonFormViewModel.swift

# See changes between commits
git diff 29ed8cb..489f418
```

### Find When Bug Was Introduced:

```bash
# Search commit messages
git log --all --grep="duplicate"

# Show commits that changed specific file
git log --oneline -- FamilyTree/Repositories/FamilyRepository.swift
```

## Quick Reference Card

### Most Common Commands:

| Command | What It Does |
|---------|--------------|
| `git status` | Show what changed |
| `git add -A` | Stage all changes |
| `git commit -m "message"` | Save snapshot |
| `git log --oneline` | See commit history |
| `git diff` | See what changed |
| `git restore .` | Undo all uncommitted changes |
| `git push` | Upload to GitHub |
| `git pull` | Download from GitHub |

### Safe Experimentation:

| Command | What It Does |
|---------|--------------|
| `git checkout -b feature/name` | Create new branch |
| `git checkout main` | Go back to main |
| `git merge feature/name` | Merge feature to main |
| `git branch -D feature/name` | Delete branch |

## Example Real-World Scenarios

### Scenario 1: You broke something and want to undo

```bash
# Option 1: Undo changes to specific file
git restore FamilyTree/ViewModels/CleanPersonFormViewModel.swift

# Option 2: Undo all uncommitted changes
git restore .

# Option 3: Go back to last commit
git reset --hard HEAD
```

### Scenario 2: You want to try a risky refactor

```bash
# Create backup branch
git checkout -b backup/before-refactor

# Go back to main
git checkout main

# Make changes...
# If it works:
git add -A
git commit -m "Successful refactor"

# If it breaks:
git checkout backup/before-refactor
```

### Scenario 3: You want to see what you changed yesterday

```bash
# Show commits from yesterday
git log --since="yesterday" --oneline

# Show detailed changes
git show 489f418
```

### Scenario 4: Find which commit broke something

```bash
# List all commits
git log --oneline

# Test each commit until you find the broken one
git checkout 29ed8cb  # Test this
git checkout 489f418  # Test this

# Go back to latest
git checkout main
```

## Pro Tips

1. **Commit often** - Small commits are better than big ones
2. **Write good commit messages** - "Fixed bug" is bad, "Fixed duplicate parent relationships in database" is good
3. **Use branches** - Try new features in branches, merge when they work
4. **Push to GitHub** - Don't lose your work if your computer dies
5. **Don't commit secrets** - Never commit Secrets.plist (already in .gitignore)

## What's Already Protected (in .gitignore)

These files are NOT tracked by Git (safe):
- ✅ `Secrets.plist` - Your API keys
- ✅ `*.backup`, `*.bak*` - Backup files
- ✅ `build/` - Compiled code
- ✅ `xcuserdata/` - Xcode user settings
- ✅ `.DS_Store` - Mac system files

## Next Steps

1. ✅ **Done:** Git is set up and working
2. ✅ **Done:** First commit saved (today's work)
3. **Optional:** Set up GitHub for cloud backup
4. **Start using:** Make commits as you work

## Questions?

**Q: How often should I commit?**
A: Whenever something works! Think of it like saving a Word document.

**Q: Can I undo a commit?**
A: Yes! Use `git reset --soft HEAD~1` to undo last commit but keep changes.

**Q: What if I accidentally committed a secret?**
A: Use `git filter-branch` or BFG Repo-Cleaner, but it's complex. Better: never commit secrets!

**Q: Do I need GitHub?**
A: Not required, but highly recommended for backup and sharing.

## Your Git is Now Ready! 🎉

You can now:
- ✅ Save versions of your code
- ✅ Undo mistakes safely
- ✅ Try experiments without fear
- ✅ See complete history of changes
- ✅ Never lose working code again

**Start using it today!** Every time you finish a feature or fix a bug, run:
```bash
git add -A
git commit -m "Brief description of what you did"
```

That's it! Your code is now safely versioned! 🚀
