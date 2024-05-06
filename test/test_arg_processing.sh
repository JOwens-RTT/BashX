#!/bin/bash

# Import the testing module
source ../lib/test_utility.sh

# Import the module to test
source ../lib/arg_processing.sh

# Define the help message
read -r -d '' testHelp << EOF
Usage: test.sh [OPTION]... [ARG]...
  -s  Switch s
  -t  Switch t
  -v  Switch v
  -x  Switch x
  -z  Switch z
  --opt0  Option 0
  --op1  Option 1
  --help  Display this help message
EOF

# Define the expected results
declare -a lv_EXPECTED_POSITIONAL=("pos0" "pos1" "pos2")
declare -A lv_EXPECTED_SWITCHES=(["s"]=1 ["t"]=1 ["v"]=1 ["x"]=1 ["z"]=1)
declare -A lv_EXPECTED_OPTIONS=(["opt0"]="o0" ["op1"]="o1")

# Test the processArgs function
test_argument_processing()
{
    processArgs "$testHelp" pos0 pos1 -s -tvx --opt0 o0 pos2 --op1 o1 -z
    assert "${args_POSITIONAL[*]}" == "${lv_EXPECTED_POSITIONAL[*]}" "processArgs: args_POSITIONAL"
    assert "${args_SWITCHES[*]}" == "${lv_EXPECTED_SWITCHES[*]}" "processArgs: args_SWITCHES"
    assert "${args_OPTIONS[*]}" == "${lv_EXPECTED_OPTIONS[*]}" "processArgs: args_OPTIONS"
}

# Run the tests
run_test test_argument_processing
