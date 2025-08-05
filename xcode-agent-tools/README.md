# Xcode Agent Tools

A set of simplified Xcode build and test scripts designed for AI agents, with clear error reporting and minimal configuration required.

## Installation

Run the installation script to set up the tools:

```bash
./install.sh
```

This will:
- Create `~/.xcode-agent-tools` directory
- Copy scripts to that directory
- Add the directory to your PATH
- Make scripts executable

After installation, restart your terminal or run:
```bash
source ~/.zshrc  # for zsh
source ~/.bash_profile  # for bash
```

## Tools

### xc-build

Simplified Xcode build with clear error reporting.

**Usage:**
```bash
xc-build [OPTIONS]
```

**Options:**
- `-p, --platform <platform>`: Platform (iOS, macOS, visionOS) [default: iOS]
- `-v, --version <version>`: OS version (e.g., 26.0, 18.3.1) [default: 26.0]
- `-s, --scheme <scheme>`: Specific scheme to build
- `-h, --help`: Show help message
- `--verbose`: Show full xcodebuild output

**Examples:**
```bash
xc-build                     # Build with defaults (iOS 26.0)
xc-build -p macOS -v 15.0    # Build for macOS 15.0
xc-build -s MyScheme         # Build specific scheme
```

### xc-test

Simplified Xcode test runner with clear results.

**Usage:**
```bash
xc-test [OPTIONS]
```

**Options:**
- `-p, --platform <platform>`: Platform (iOS, macOS, visionOS) [default: iOS]
- `-v, --version <version>`: OS version [default: 26.0]
- `-s, --scheme <scheme>`: Specific scheme to test
- `-d, --device <device>`: Device name (e.g., "iPhone 16", "iPad Pro") [default: iPhone 16]
- `-c, --class <class>`: Run specific test class (e.g., "MyAppTests.LoginTests")
- `-t, --test <test>`: Run specific test (e.g., "MyAppTests.LoginTests/testLogin")
- `-h, --help`: Show help message
- `--verbose`: Show full xcodebuild output

**Examples:**
```bash
xc-test                      # Run all tests with defaults
xc-test -p macOS             # Run tests on macOS
xc-test -d "iPad Pro"        # Run tests on iPad Pro simulator
xc-test -c "MyAppTests.NetworkTests"  # Run specific test class
xc-test -t "MyAppTests.NetworkTests/testAPICall"  # Run specific test
```

## Features

### Smart Detection
- Automatically detects `.xcodeproj` or `.xcworkspace` files
- Finds available schemes automatically
- Detects available simulators

### Clear Error Reporting
- Parses xcodebuild output for errors and warnings
- Displays formatted, easy-to-read error summaries
- Shows file names, line numbers, and error messages
- Distinguishes between build errors and test failures

### Exit Codes
- **xc-build**: 0 for success, 1 for failure
- **xc-test**: 0 for all tests passed, 1 for test failures, 2 for build errors

### Progress Indication
- Shows spinner animation during long operations
- Keeps full xcodebuild output in temporary files for debugging
- Optional verbose mode for full output

## Output Examples

### Build Success
```
===== BUILD RESULTS =====
Status: SUCCESS

Build succeeded
```

### Build Failure
```
===== BUILD RESULTS =====
Status: FAILED

ERRORS (2):
❌ ContentView.swift:45 - Cannot find 'nonExistentVariable' in scope
❌ AppModel.swift:23 - Type 'AppModel' does not conform to protocol 'Observable'

Build failed with 2 errors
```

### Test Results
```
===== TEST RESULTS =====
Status: FAILED

TEST FAILURES (2):
❌ LoginTests.swift:34 - testLoginWithInvalidCredentials()
   Expected: false, Actual: true
❌ ProfileTests.swift:89 - testProfileImageUpload()
   XCTAssertNotNil failed - Image data was nil

Tests: 45 passed, 2 failed, 47 total
Tests failed
```

## Requirements

- Xcode command line tools
- macOS with Xcode installed
- Bash shell environment