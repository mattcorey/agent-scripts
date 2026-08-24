#!/bin/bash

set -e

REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
FIXTURES="$REPO_ROOT/tests/fixtures/xc-ci"
TEST_TMP=$(mktemp -d "${TMPDIR:-/tmp/}xc-ci-ios-simulator-test-XXXXXXXX")
trap 'rm -rf "$TEST_TMP"' EXIT

FAKE_XCODE="$TEST_TMP/Xcode-beta.app"
mkdir -p "$FAKE_XCODE/Contents/Developer/usr/bin" "$TEST_TMP/workspaces"
mkdir -p "$TEST_TMP/xcrun-state"
cp "$FIXTURES/xcodebuild" "$FAKE_XCODE/Contents/Developer/usr/bin/xcodebuild"
cp "$FIXTURES/xcrun" "$FAKE_XCODE/Contents/Developer/usr/bin/xcrun"
chmod +x "$FAKE_XCODE/Contents/Developer/usr/bin/xcodebuild"
chmod +x "$FAKE_XCODE/Contents/Developer/usr/bin/xcrun"

ARCHIVE_FAILURE_ASC_LOG="$TEST_TMP/archive-failure-asc.log"
ARCHIVE_FAILURE_XCODEBUILD_LOG="$TEST_TMP/archive-failure-xcodebuild.log"
ARCHIVE_FAILURE_XCRUN_LOG="$TEST_TMP/archive-failure-xcrun.log"
export ASC_COMMAND_LOG="$ARCHIVE_FAILURE_ASC_LOG"
export XCODEBUILD_COMMAND_LOG="$ARCHIVE_FAILURE_XCODEBUILD_LOG"
export XCRUN_COMMAND_LOG="$ARCHIVE_FAILURE_XCRUN_LOG"
export XC_CI_XCRUN_STATE_DIR="$TEST_TMP/xcrun-state"
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

assert_not_contains() {
    local file="$1"
    local unexpected="$2"
    if rg -F -- "$unexpected" "$file" >/dev/null; then
        fail "Did not expect '$unexpected' in $file"
    fi
}

run_ios_fixture() {
    "$REPO_ROOT/xcode-agent-tools/xc-ci" \
        --repo git@github.com:example/ExampleApp.git \
        --app-id 1234567890 \
        --branch main \
        --scheme ExampleApp \
        --ios-only \
        --xcode-dir "$FAKE_XCODE" \
        --verbose \
        "$@"
}

PIPELINE_OUTPUT="$TEST_TMP/archive-failure.txt"
DELETE_ATTEMPT_FILE="$TEST_TMP/archive-failure-delete-attempted"
set +e
XC_CI_FAIL_ARCHIVE=true \
XC_CI_FAIL_FIRST_DELETE=true \
XC_CI_DELETE_ATTEMPT_FILE="$DELETE_ATTEMPT_FILE" \
    run_ios_fixture > "$PIPELINE_OUTPUT" 2>&1
PIPELINE_STATUS=$?
set -e

[ "$PIPELINE_STATUS" -ne 0 ] || fail "The archive failure fixture unexpectedly succeeded"
assert_contains "$XCRUN_COMMAND_LOG" "simctl create xc-ci-iOS-"
assert_contains "$XCRUN_COMMAND_LOG" "com.apple.CoreSimulator.SimDeviceType.iPhone-99-Pro com.apple.CoreSimulator.SimRuntime.iOS-27-0"
assert_contains "$XCODEBUILD_COMMAND_LOG" "-destination platform=iOS Simulator,id=AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"
assert_contains "$XCRUN_COMMAND_LOG" "simctl shutdown AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"
assert_contains "$XCRUN_COMMAND_LOG" "simctl delete AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"
DELETE_COUNT=$(rg -c -F "simctl delete AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA" "$XCRUN_COMMAND_LOG")
[ "$DELETE_COUNT" -eq 2 ] || fail "Expected cleanup to retry a transient simulator deletion failure"
assert_not_contains "$XCRUN_COMMAND_LOG" "simctl shutdown 11111111-1111-1111-1111-111111111111"
assert_not_contains "$XCRUN_COMMAND_LOG" "simctl delete 11111111-1111-1111-1111-111111111111"
if rg -v "^DEVELOPER_DIR=$FAKE_XCODE/Contents/Developer |" "$XCRUN_COMMAND_LOG" >/dev/null; then
    fail "An xcrun invocation did not use the selected Xcode"
fi

export ASC_COMMAND_LOG="$TEST_TMP/test-failure-asc.log"
export XCODEBUILD_COMMAND_LOG="$TEST_TMP/test-failure-xcodebuild.log"
export XCRUN_COMMAND_LOG="$TEST_TMP/test-failure-xcrun.log"
TEST_FAILURE_OUTPUT="$TEST_TMP/test-failure.txt"
set +e
XC_CI_FAIL_TESTS=true \
XC_CI_SIMULATOR_UDID="BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB" \
    run_ios_fixture > "$TEST_FAILURE_OUTPUT" 2>&1
TEST_FAILURE_STATUS=$?
set -e

[ "$TEST_FAILURE_STATUS" -ne 0 ] || fail "The test failure fixture unexpectedly succeeded"
assert_contains "$TEST_FAILURE_OUTPUT" "iOS tests failed"
assert_contains "$XCODEBUILD_COMMAND_LOG" "-destination platform=iOS Simulator,id=BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB"
assert_contains "$XCRUN_COMMAND_LOG" "simctl shutdown BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB"
assert_contains "$XCRUN_COMMAND_LOG" "simctl delete BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB"
assert_not_contains "$XCODEBUILD_COMMAND_LOG" " archive"
assert_not_contains "$ASC_COMMAND_LOG" "builds upload"

export ASC_COMMAND_LOG="$TEST_TMP/delete-failure-asc.log"
export XCODEBUILD_COMMAND_LOG="$TEST_TMP/delete-failure-xcodebuild.log"
export XCRUN_COMMAND_LOG="$TEST_TMP/delete-failure-xcrun.log"
DELETE_FAILURE_OUTPUT="$TEST_TMP/delete-failure.txt"
set +e
XC_CI_FAIL_ARCHIVE=true \
XC_CI_FAIL_DELETE=true \
XC_CI_SIMULATOR_UDID="FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF" \
    run_ios_fixture > "$DELETE_FAILURE_OUTPUT" 2>&1
DELETE_FAILURE_STATUS=$?
set -e

[ "$DELETE_FAILURE_STATUS" -ne 0 ] || fail "The simulator deletion failure fixture unexpectedly succeeded"
assert_contains "$DELETE_FAILURE_OUTPUT" "Could not delete temporary iOS simulator: FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF"
assert_not_contains "$XCODEBUILD_COMMAND_LOG" " archive"
assert_not_contains "$ASC_COMMAND_LOG" "builds upload"

export ASC_COMMAND_LOG="$TEST_TMP/create-failure-asc.log"
export XCODEBUILD_COMMAND_LOG="$TEST_TMP/create-failure-xcodebuild.log"
export XCRUN_COMMAND_LOG="$TEST_TMP/create-failure-xcrun.log"
CREATE_FAILURE_OUTPUT="$TEST_TMP/create-failure.txt"
set +e
XC_CI_FAIL_CREATE=true run_ios_fixture > "$CREATE_FAILURE_OUTPUT" 2>&1
CREATE_FAILURE_STATUS=$?
set -e

[ "$CREATE_FAILURE_STATUS" -ne 0 ] || fail "The simulator creation failure fixture unexpectedly succeeded"
assert_contains "$CREATE_FAILURE_OUTPUT" "Could not create a temporary iOS 27.0 simulator"
assert_contains "$CREATE_FAILURE_OUTPUT" "fixture simulator creation failure"
assert_not_contains "$XCODEBUILD_COMMAND_LOG" " test"
assert_not_contains "$ASC_COMMAND_LOG" "builds upload"

export ASC_COMMAND_LOG="$TEST_TMP/runtime-failure-asc.log"
export XCODEBUILD_COMMAND_LOG="$TEST_TMP/runtime-failure-xcodebuild.log"
export XCRUN_COMMAND_LOG="$TEST_TMP/runtime-failure-xcrun.log"
RUNTIME_FAILURE_OUTPUT="$TEST_TMP/runtime-failure.txt"
set +e
XC_CI_NO_RUNTIME=true run_ios_fixture > "$RUNTIME_FAILURE_OUTPUT" 2>&1
RUNTIME_FAILURE_STATUS=$?
set -e

[ "$RUNTIME_FAILURE_STATUS" -ne 0 ] || fail "The missing runtime fixture unexpectedly succeeded"
assert_contains "$RUNTIME_FAILURE_OUTPUT" "does not expose an available iOS 27.0 simulator runtime"
assert_not_contains "$XCRUN_COMMAND_LOG" "simctl create"

export ASC_COMMAND_LOG="$TEST_TMP/device-type-failure-asc.log"
export XCODEBUILD_COMMAND_LOG="$TEST_TMP/device-type-failure-xcodebuild.log"
export XCRUN_COMMAND_LOG="$TEST_TMP/device-type-failure-xcrun.log"
DEVICE_TYPE_FAILURE_OUTPUT="$TEST_TMP/device-type-failure.txt"
set +e
XC_CI_NO_DEVICE_TYPE=true run_ios_fixture > "$DEVICE_TYPE_FAILURE_OUTPUT" 2>&1
DEVICE_TYPE_FAILURE_STATUS=$?
set -e

[ "$DEVICE_TYPE_FAILURE_STATUS" -ne 0 ] || fail "The missing device type fixture unexpectedly succeeded"
assert_contains "$DEVICE_TYPE_FAILURE_OUTPUT" "No iPhone simulator device type is available in the selected Xcode"
assert_not_contains "$XCRUN_COMMAND_LOG" "simctl create"

export ASC_COMMAND_LOG="$TEST_TMP/invalid-udid-asc.log"
export XCODEBUILD_COMMAND_LOG="$TEST_TMP/invalid-udid-xcodebuild.log"
export XCRUN_COMMAND_LOG="$TEST_TMP/invalid-udid-xcrun.log"
INVALID_UDID_OUTPUT="$TEST_TMP/invalid-udid.txt"
set +e
XC_CI_SIMULATOR_UDID="not-a-udid" \
XC_CI_ACTUAL_SIMULATOR_UDID="EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE" \
    run_ios_fixture > "$INVALID_UDID_OUTPUT" 2>&1
INVALID_UDID_STATUS=$?
set -e

[ "$INVALID_UDID_STATUS" -ne 0 ] || fail "The invalid simulator UDID fixture unexpectedly succeeded"
assert_contains "$INVALID_UDID_OUTPUT" "simctl create returned an invalid simulator UDID: not-a-udid"
assert_contains "$XCRUN_COMMAND_LOG" "simctl delete EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE"
assert_not_contains "$XCODEBUILD_COMMAND_LOG" " test"
assert_not_contains "$ASC_COMMAND_LOG" "builds upload"

export ASC_COMMAND_LOG="$TEST_TMP/validation-failure-asc.log"
export XCODEBUILD_COMMAND_LOG="$TEST_TMP/validation-failure-xcodebuild.log"
export XCRUN_COMMAND_LOG="$TEST_TMP/validation-failure-xcrun.log"
VALIDATION_FAILURE_OUTPUT="$TEST_TMP/validation-failure.txt"
set +e
XC_CI_SIMULATOR_UDID="DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD" \
XC_CI_ACTUAL_SIMULATOR_UDID="99999999-9999-9999-9999-999999999999" \
    run_ios_fixture > "$VALIDATION_FAILURE_OUTPUT" 2>&1
VALIDATION_FAILURE_STATUS=$?
set -e

[ "$VALIDATION_FAILURE_STATUS" -ne 0 ] || fail "The simulator validation failure fixture unexpectedly succeeded"
assert_contains "$VALIDATION_FAILURE_OUTPUT" "Could not validate the newly created iOS simulator"
assert_contains "$XCRUN_COMMAND_LOG" "simctl delete DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD"
assert_not_contains "$XCRUN_COMMAND_LOG" "simctl delete 99999999-9999-9999-9999-999999999999"
assert_not_contains "$XCODEBUILD_COMMAND_LOG" " test"
assert_not_contains "$ASC_COMMAND_LOG" "builds upload"

export ASC_COMMAND_LOG="$TEST_TMP/empty-discovery-asc.log"
export XCODEBUILD_COMMAND_LOG="$TEST_TMP/empty-discovery-xcodebuild.log"
export XCRUN_COMMAND_LOG="$TEST_TMP/empty-discovery-xcrun.log"
EMPTY_DISCOVERY_OUTPUT="$TEST_TMP/empty-discovery.txt"
set +e
XC_CI_EMPTY_DEVICE_DISCOVERY=true \
XC_CI_SIMULATOR_UDID="77777777-7777-7777-7777-777777777777" \
    run_ios_fixture > "$EMPTY_DISCOVERY_OUTPUT" 2>&1
EMPTY_DISCOVERY_STATUS=$?
set -e

[ "$EMPTY_DISCOVERY_STATUS" -ne 0 ] || fail "The empty simulator discovery fixture unexpectedly succeeded"
assert_contains "$EMPTY_DISCOVERY_OUTPUT" "Could not validate the newly created iOS simulator"
assert_contains "$XCRUN_COMMAND_LOG" "simctl delete 77777777-7777-7777-7777-777777777777"
assert_not_contains "$XCODEBUILD_COMMAND_LOG" " test"
assert_not_contains "$ASC_COMMAND_LOG" "builds upload"

export ASC_COMMAND_LOG="$TEST_TMP/skip-tests-asc.log"
export XCODEBUILD_COMMAND_LOG="$TEST_TMP/skip-tests-xcodebuild.log"
export XCRUN_COMMAND_LOG="$TEST_TMP/skip-tests-xcrun.log"
SKIP_TESTS_OUTPUT="$TEST_TMP/skip-tests.txt"
set +e
XC_CI_FAIL_ARCHIVE=true run_ios_fixture --skip-tests > "$SKIP_TESTS_OUTPUT" 2>&1
SKIP_TESTS_STATUS=$?
set -e

[ "$SKIP_TESTS_STATUS" -ne 0 ] || fail "The skipped-tests archive failure fixture unexpectedly succeeded"
assert_contains "$SKIP_TESTS_OUTPUT" "Skipping iOS tests (--skip-tests)"
if [ -e "$XCRUN_COMMAND_LOG" ]; then
    fail "Skipping iOS tests must not inspect, create, or clean up a simulator"
fi

export ASC_COMMAND_LOG="$TEST_TMP/signal-asc.log"
export XCODEBUILD_COMMAND_LOG="$TEST_TMP/signal-xcodebuild.log"
export XCRUN_COMMAND_LOG="$TEST_TMP/signal-xcrun.log"
TESTS_STARTED_FILE="$TEST_TMP/tests-started"
SIGNAL_OUTPUT="$TEST_TMP/signal.txt"

XC_CI_BLOCK_TESTS=true \
XC_CI_TESTS_STARTED_FILE="$TESTS_STARTED_FILE" \
XC_CI_SIMULATOR_UDID="CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC" \
    "$REPO_ROOT/xcode-agent-tools/xc-ci" \
        --repo git@github.com:example/ExampleApp.git \
        --app-id 1234567890 \
        --branch main \
        --scheme ExampleApp \
        --ios-only \
        --xcode-dir "$FAKE_XCODE" \
        --verbose > "$SIGNAL_OUTPUT" 2>&1 &
SIGNAL_PIPELINE_PID=$!

for _ in {1..100}; do
    [ -f "$TESTS_STARTED_FILE" ] && break
    sleep 0.05
done
[ -f "$TESTS_STARTED_FILE" ] || fail "Timed out waiting for the test fixture to start"

kill -TERM "$SIGNAL_PIPELINE_PID"
set +e
wait "$SIGNAL_PIPELINE_PID" 2>/dev/null
SIGNAL_STATUS=$?
set -e

[ "$SIGNAL_STATUS" -ne 0 ] || fail "The signal-driven pipeline unexpectedly succeeded"
assert_contains "$XCRUN_COMMAND_LOG" "simctl shutdown CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC"
assert_contains "$XCRUN_COMMAND_LOG" "simctl delete CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC"

echo "xc-ci iOS simulator tests passed"
