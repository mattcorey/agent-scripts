#!/bin/bash

set -e

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
FIXTURES="$REPO_ROOT/tests/fixtures/xc-ci"
TEST_TMP=$(mktemp -d "${TMPDIR:-/tmp/}xc-ci-macos-test-XXXXXXXX")
trap 'rm -rf "$TEST_TMP"' EXIT

FAKE_XCODE="$TEST_TMP/Xcode-beta.app"
mkdir -p "$FAKE_XCODE/Contents/Developer/usr/bin" "$TEST_TMP/workspaces"
cp "$FIXTURES/xcodebuild" "$FAKE_XCODE/Contents/Developer/usr/bin/xcodebuild"
chmod +x "$FAKE_XCODE/Contents/Developer/usr/bin/xcodebuild"

export ASC_COMMAND_LOG="$TEST_TMP/asc.log"
export XCODEBUILD_COMMAND_LOG="$TEST_TMP/xcodebuild.log"
export PATH="$FIXTURES:$PATH"
export TMPDIR="$TEST_TMP/workspaces/"

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

assert_contains() {
    local file="$1"
    local expected="$2"
    rg -F -- "$expected" "$file" >/dev/null || fail "Expected '$expected' in $file"
}

HELP_OUTPUT="$TEST_TMP/help.txt"
"$REPO_ROOT/xcode-agent-tools/xc-ci" --help > "$HELP_OUTPUT"
assert_contains "$HELP_OUTPUT" "--macos-only         Test, archive, export, and upload macOS only"

PIPELINE_OUTPUT="$TEST_TMP/pipeline.txt"
"$REPO_ROOT/xcode-agent-tools/xc-ci" \
    --repo git@github.com:example/ExampleMacApp.git \
    --app-id 1234567890 \
    --branch main \
    --scheme ExampleMacApp \
    --team-id ABCDE12345 \
    --macos-only \
    --xcode-dir "$FAKE_XCODE" \
    --keep-workspace \
    --verbose > "$PIPELINE_OUTPUT"

assert_contains "$PIPELINE_OUTPUT" "Marketing version: 1.4.0"
assert_contains "$PIPELINE_OUTPUT" "Bundle ID: com.example.macapp"
assert_contains "$PIPELINE_OUTPUT" "App category: public.app-category.productivity"
assert_contains "$PIPELINE_OUTPUT" "macOS build uploaded to App Store Connect"
assert_contains "$ASC_COMMAND_LOG" "builds next-build-number --app 1234567890 --version 1.4.0 --platform MAC_OS"
assert_contains "$ASC_COMMAND_LOG" "builds upload --app 1234567890 --pkg"
assert_contains "$ASC_COMMAND_LOG" "--version 1.4.0 --build-number 42 --wait"
assert_contains "$XCODEBUILD_COMMAND_LOG" "-scheme ExampleMacApp -configuration Release -destination generic/platform=macOS -showBuildSettings -json"
assert_contains "$XCODEBUILD_COMMAND_LOG" "CURRENT_PROJECT_VERSION=42 DEVELOPMENT_TEAM=ABCDE12345 -allowProvisioningUpdates clean archive"
assert_contains "$XCODEBUILD_COMMAND_LOG" "-exportOptionsPlist"
assert_contains "$XCODEBUILD_COMMAND_LOG" "-allowProvisioningUpdates"
if rg -F "PRODUCT_BUNDLE_IDENTIFIER=" "$XCODEBUILD_COMMAND_LOG" >/dev/null; then
    fail "xc-ci must not globally override target bundle identifiers"
fi

if rg -v "^DEVELOPER_DIR=$FAKE_XCODE/Contents/Developer \|" "$XCODEBUILD_COMMAND_LOG" >/dev/null; then
    fail "An xcodebuild invocation did not use the selected Xcode"
fi

EXPORT_PLIST=$(find "$TEST_TMP/workspaces" -name macos-ExportOptions.plist -print -quit)
[ -n "$EXPORT_PLIST" ] || fail "macOS ExportOptions.plist was not created"
assert_contains "$EXPORT_PLIST" "<string>app-store-connect</string>"
assert_contains "$EXPORT_PLIST" "<string>ABCDE12345</string>"

FAILURE_OUTPUT="$TEST_TMP/failure.txt"
WORKSPACE_COUNT_BEFORE=$(find "$TEST_TMP/workspaces" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
set +e
XC_CI_FAIL_EXPORT=true "$REPO_ROOT/xcode-agent-tools/xc-ci" \
    --repo git@github.com:example/ExampleMacApp.git \
    --app-id 1234567890 \
    --scheme ExampleMacApp \
    --team-id ABCDE12345 \
    --macos-only \
    --xcode-dir "$FAKE_XCODE" \
    --skip-tests > "$FAILURE_OUTPUT" 2>&1
FAILURE_STATUS=$?
set -e

[ "$FAILURE_STATUS" -ne 0 ] || fail "The export failure fixture unexpectedly succeeded"
assert_contains "$FAILURE_OUTPUT" "Pipeline failed; preserving workspace:"
WORKSPACE_COUNT_AFTER=$(find "$TEST_TMP/workspaces" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
[ "$WORKSPACE_COUNT_AFTER" -gt "$WORKSPACE_COUNT_BEFORE" ] || fail "Failed pipeline workspace was not preserved"

echo "xc-ci macOS tests passed"
