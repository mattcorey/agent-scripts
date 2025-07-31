# Agent Scripts

A collection of utility scripts for development workflows, organized by category.

## Installation

To install all scripts and make them available system-wide, run:

```bash
./install.sh
```

This will create symbolic links in your PATH so you can run the scripts from anywhere.

## Scripts by Category

### worktrees/

Git worktree management utilities for working with multiple branches simultaneously.

#### `wt-add`
Creates a new git worktree as a sister directory with project prefix.

**Usage:** `wt-add <branch-name> [base-branch]`

Creates a new worktree in a sister directory to the current repo. The worktree directory will be named: `<project-name>-<branch-name>`

**Examples:**
```bash
wt-add feature/auth
wt-add hotfix/critical-bug main
```

#### `wt-list`
Lists all git worktrees with enhanced formatting.

**Usage:** `wt-list [options]`

**Options:**
- `-v, --verbose` - Show detailed information including last commit and uncommitted changes
- `-h, --help` - Show help message

**Examples:**
```bash
wt-list
wt-list --verbose
```

#### `wt-remove`
Removes a worktree and optionally deletes the associated branch.

**Usage:** `wt-remove <worktree-name> [options]`

**Options:**
- `--keep-branch` - Keep the branch after removing worktree
- `--force` - Force removal even with uncommitted changes
- `-h, --help` - Show help message

**Examples:**
```bash
wt-remove BrainstormAI-feature-auth
wt-remove MyProject-hotfix --keep-branch
wt-remove MyProject-temp --force
```

#### `wt-find-deriveddata`
Finds the DerivedData path for a git worktree containing an Xcode project.

**Usage:** `wt-find-deriveddata <worktree-name> [options]`

**Options:**
- `--current` - Use current directory instead of worktree name
- `--verbose` - Show detailed information during detection
- `-h, --help` - Show help message

**Examples:**
```bash
wt-find-deriveddata BrainstormAI-ui-tweaks
wt-find-deriveddata --current
wt-find-deriveddata MyProject-feature --verbose
```

## Requirements

- Git
- Bash
- Xcode (for `wt-find-deriveddata` script)

## License

MIT