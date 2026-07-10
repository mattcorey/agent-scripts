# Agent Scripts

A collection of utility scripts for development workflows, organized by category.

## Installation

To install all scripts and make them available system-wide, run:

```bash
./install.sh
```

This will create symbolic links in your PATH so you can run the scripts from anywhere.

## Scripts by Category

### claude-agents/

Claude Code subagent definitions that can be referenced globally after installation.

These agents extend Claude Code's capabilities with specialized knowledge and toolsets for specific tasks.

**Available Agents:**
- `code-refactoring-architect` - Specialized in analyzing and refactoring code structure, identifying architectural issues
- `swiftui-architecture-specialist` - Expert in SwiftUI architecture, iOS development, and modern iOS features

**Usage:**
After installation, these agents are available globally in any Claude Code session via the Task tool.

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
wt-remove MyProject-feature-auth
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
wt-find-deriveddata MyProject-ui-tweaks
wt-find-deriveddata --current
wt-find-deriveddata MyProject-feature --verbose
```

### xcode-agent-tools/

Xcode build, test, and CI utilities.

#### `xc-build`
Simplified Xcode build with clear error reporting.

**Usage:** `xc-build [options]`

**Options:**
- `-p, --platform <platform>` - Platform: iOS, macOS, visionOS [default: iOS]
- `-v, --version <version>` - OS version [default: 26.0]
- `-s, --scheme <scheme>` - Specific scheme to build
- `--verbose` - Show full xcodebuild output

#### `xc-test`
Simplified Xcode test runner with clear results and isolation commands for failures.

**Usage:** `xc-test [options]`

**Options:**
- `-p, --platform <platform>` - Platform: iOS, macOS, visionOS [default: iOS]
- `-s, --scheme <scheme>` - Specific scheme to test
- `-d, --device <device>` - Device name [default: iPhone 16]
- `-t, --test <test>` - Run specific test class or method
- `--verbose` - Show full xcodebuild output

#### `xc-ci`
Local CI pipeline replicating Xcode Cloud. Clones a repo into an isolated temp workspace and supports testing, archiving, exporting, and uploading iOS, visionOS, and macOS builds to App Store Connect/TestFlight. macOS exports are uploaded as installer packages.

**Usage:** `xc-ci --repo <url> --app-id <id> [options]`

**Required:**
- `--repo <url>` - Git repo SSH URL
- `--app-id <id>` - App Store Connect app ID (numeric)

**Options:**
- `--branch <branch>` - Branch to build [default: main]
- `--scheme <scheme>` - Xcode scheme [default: auto-detect]
- `--xcode-dir <path>` - Xcode.app path to use without changing `xcode-select`
- `--team-id <id>` - Development team ID [required with `--macos-only`]
- `--skip-tests` - Skip the platform test phase
- `--ios-only` - Only test + archive for iOS (skip visionOS)
- `--visionos-only` - Only build-check + archive for visionOS (skip iOS)
- `--macos-only` - Test, archive, export a PKG, and upload macOS only
- `--keep-workspace` - Don't clean up temp directory on exit
- `--verbose` - Show full xcodebuild output

Build number lookup and uploads use the `asc` CLI. Run `asc auth doctor` before `xc-ci` to verify App Store Connect authentication.

Archive export requires a local distribution signing identity. iOS and visionOS exports require installed App Store provisioning profiles named `xc-ci AppStore <bundle-id>`. For macOS, `xc-ci` passes `-allowProvisioningUpdates`, uses `--team-id` for `DEVELOPMENT_TEAM`, and generates an App Store Connect export options plist.

The selected macOS target must set an App Category (`LSApplicationCategoryType`); `xc-ci` validates this before export so App Store Connect does not reject the uploaded package.

**Examples:**
```bash
xc-ci --repo git@github.com:user/App.git --app-id 123456789
xc-ci --repo git@github.com:user/App.git --app-id 123456789 --ios-only
xc-ci --repo git@github.com:user/App.git --app-id 123456789 --skip-tests
xc-ci --repo git@github.com:user/App.git --app-id 123456789 --xcode-dir /Applications/Xcode.app
xc-ci --repo git@github.com:user/MacApp.git --app-id 123456789 --scheme MacApp --team-id ABC1234567 --macos-only
```

## Requirements

- Git
- Bash
- Xcode (for xcode-agent-tools and `wt-find-deriveddata`)
- [asc CLI](https://github.com/appstoreconnect/asc) (for `xc-ci` upload to App Store Connect)
- jq (for `xc-ci` build number management)
