#!/bin/bash

# Get the directory of this script
lc_ScriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run all test scripts in this directory except this one
for lc_TestScript in $(ls "$lc_ScriptDir" | grep -v "$(basename "${BASH_SOURCE[0]}")"); do
    echo "Running $lc_TestScript"
    bash "$lc_ScriptDir/$lc_TestScript"
done
