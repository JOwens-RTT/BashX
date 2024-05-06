#!/bin/bash

# STANDARD EXIT CODES
ec_GOOD=0                   # No Error
ec_GENERAL=1                # Catchall for general errors
ec_MISUSE=2                 # Missing keyword or command, or permissions problem
ec_CANNOT_EXE=126           # Permissions problem or command is not executable
ec_CMD_NOT_FOUND=127        # Possible problem with path or a typo
ec_INVALID_EXIT=128         # exit only takes interger args in the range 0 - 255
ec_CTRL_C=130               # Control-C event
ec_EXIT_OUT_OF_RANGE=255    # exit only takes interger args in the range 0 - 255

# USER DEFINED EXIT CODES [3 - 125]
ec_INVALID_ARG=3            # An arguement to a script or function is ill-formed or not provided
ec_MISSING_DATA=4           # Data required does not exist or is inaccessible

# Exit with a message
# $1 - Exit code
# $2 - Message
end() {
    # calling function name
    local func_name="${FUNCNAME[1]}"
    # calling script name
    local script_name="$(basename $0)"
    # calling line number
    local line_no="${BASH_LINENO[0]}"

    # Generate message
    local message="[$script_name:$line_no:$func_name] $2"

    # Check if the exit code is valid
    if [[ "$1" -lt 0 || "$1" -gt 255 ]]; then
        echo "Invalid exit code: $1" >&2
        exit "$ec_INVALID_EXIT"
    fi

    # Exit with message. If return code is not ec_GOOD, then print the message to stderr
    if [[ "$1" -eq "$ec_GOOD" ]]; then
        echo "$message"
    else
        echo "$message" >&2
    fi
    exit "$1"
}