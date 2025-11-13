#!/usr/bin/env bash

# ABOUTME: Git cleanup script for orphaned worktrees and branches without remote references
# Usage: git-cleanup-orphaned [--dry-run] [--auto]

set -euo pipefail

DRY_RUN=false
AUTO=false
CURRENT_BRANCH=""
PROTECTED_BRANCHES=("main" "master" "develop" "dev")

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --auto)
            AUTO=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--dry-run] [--auto]"
            echo "  --dry-run: Show what would be deleted without actually deleting"
            echo "  --auto:    Skip manual confirmation (use with caution)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

echo "🧹 Git Cleanup Tool"
echo "Current branch: $CURRENT_BRANCH"
echo "Protected branches: ${PROTECTED_BRANCHES[*]}"
echo

# Function to check if branch has remote reference
has_remote_reference() {
    local branch="$1"
    git branch -r --contains "$branch" | grep -q . 2>/dev/null
}

# Function to check if branch is protected
is_protected_branch() {
    local branch="$1"
    for protected in "${PROTECTED_BRANCHES[@]}"; do
        if [[ "$branch" == "$protected" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to confirm action
confirm() {
    local message="$1"
    if [[ "$AUTO" == true ]]; then
        return 0
    fi
    
    echo -n "$message (y/N): "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Fetch latest remote information
echo "📡 Fetching latest remote information..."
git fetch --prune

# Find orphaned worktrees
echo
echo "🔍 Checking for orphaned worktrees..."
ORPHANED_WORKTREES=()

while IFS= read -r line; do
    if [[ "$line" =~ ^worktree\ (.+) ]]; then
        worktree_path="${BASH_REMATCH[1]}"
        # Get the branch for this worktree
        branch=$(git -C "$worktree_path" branch --show-current 2>/dev/null || echo "")
        
        if [[ -n "$branch" ]] && ! has_remote_reference "$branch" && ! is_protected_branch "$branch"; then
            ORPHANED_WORKTREES+=("$worktree_path:$branch")
        fi
    fi
done < <(git worktree list --porcelain)

# Find orphaned local branches
echo
echo "🔍 Checking for orphaned local branches..."
ORPHANED_BRANCHES=()

while IFS= read -r branch; do
    # Skip current branch and protected branches
    if [[ "$branch" != "$CURRENT_BRANCH" ]] && ! is_protected_branch "$branch" && ! has_remote_reference "$branch"; then
        ORPHANED_BRANCHES+=("$branch")
    fi
done < <(git branch --format='%(refname:short)')

# Display findings
echo
if [[ ${#ORPHANED_WORKTREES[@]} -eq 0 ]] && [[ ${#ORPHANED_BRANCHES[@]} -eq 0 ]]; then
    echo "✅ No orphaned worktrees or branches found!"
    exit 0
fi

if [[ ${#ORPHANED_WORKTREES[@]} -gt 0 ]]; then
    echo "🗂️  Orphaned worktrees (${#ORPHANED_WORKTREES[@]}):"
    for item in "${ORPHANED_WORKTREES[@]}"; do
        worktree_path="${item%:*}"
        branch="${item#*:}"
        echo "  - $worktree_path ($branch)"
    done
    echo
fi

if [[ ${#ORPHANED_BRANCHES[@]} -gt 0 ]]; then
    echo "🌿 Orphaned local branches (${#ORPHANED_BRANCHES[@]}):"
    for branch in "${ORPHANED_BRANCHES[@]}"; do
        echo "  - $branch"
    done
    echo
fi

# Perform cleanup
if [[ "$DRY_RUN" == true ]]; then
    echo "🔍 DRY RUN - No changes will be made"
    exit 0
fi

# Clean up worktrees
if [[ ${#ORPHANED_WORKTREES[@]} -gt 0 ]]; then
    if confirm "Remove ${#ORPHANED_WORKTREES[@]} orphaned worktree(s)?"; then
        for item in "${ORPHANED_WORKTREES[@]}"; do
            worktree_path="${item%:*}"
            branch="${item#*:}"
            echo "🗑️  Removing worktree: $worktree_path ($branch)"
            git worktree remove "$worktree_path" --force
        done
        echo "✅ Orphaned worktrees removed"
    else
        echo "⏭️  Skipped worktree cleanup"
    fi
    echo
fi

# Clean up branches
if [[ ${#ORPHANED_BRANCHES[@]} -gt 0 ]]; then
    if confirm "Delete ${#ORPHANED_BRANCHES[@]} orphaned local branch(es)?"; then
        for branch in "${ORPHANED_BRANCHES[@]}"; do
            echo "🗑️  Deleting branch: $branch"
            git branch -D "$branch"
        done
        echo "✅ Orphaned branches deleted"
    else
        echo "⏭️  Skipped branch cleanup"
    fi
fi

echo
echo "🎉 Cleanup completed!"