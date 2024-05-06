#!/bin/bash

# Import testing module
source ../lib/test_utility.sh

# Import error handling module
source ../lib/error_handling.sh

# Test the end function for each exit code
test_end() {
    # Test the end function for each labeled exit code
    expect_success "end $ec_GOOD" "end $ec_GOOD failed"
    expect_fail "end $ec_GENERAL" "end $ec_GENERAL failed"
    expect_fail "end $ec_MISUSE" "end $ec_MISUSE failed"
    expect_fail "end $ec_CANNOT_EXE" "end $ec_CANNOT_EXE failed"
    expect_fail "end $ec_CMD_NOT_FOUND" "end $ec_CMD_NOT_FOUND failed"
    expect_fail "end $ec_INVALID_EXIT" "end $ec_INVALID_EXIT failed"
    expect_fail "end $ec_CTRL_C" "end $ec_CTRL_C failed"
    expect_fail "end $ec_EXIT_OUT_OF_RANGE" "end $ec_EXIT_OUT_OF_RANGE failed"
    expect_fail "end $ec_INVALID_ARG" "end $ec_INVALID_ARG failed"
    expect_fail "end $ec_MISSING_DATA" "end $ec_MISSING_DATA failed"
}

# Run tests
run_test test_end
