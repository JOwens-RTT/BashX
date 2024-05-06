#!/bin/bash

# Create unit testing convenience functions

# Global variables
total_tests=0
total_passes=0
total_fails=0
test_functions=()

# Test runner
# $1 - Test function
run_test() {
    local test_function="$1"

    # Test result variable
    local test_result
    
    # Run test in subshell
    (
        $test_function
    )
    # Capture test result
    test_result=$?
        
    total_tests=$((total_tests + 1))

    # Check test result
    if [[ $test_result -eq 0 ]]; then
        echo "PASS: $test_function"
        total_passes=$((total_passes + 1))
    else
        echo "FAIL: $test_function"
        total_fails=$((total_fails + 1))
    fi
}

# Test registration
# $1 - Test function
register_test() {
    local test_function="$1"
    test_functions+=("$test_function")
}

# Run all registered tests
run_all_tests() {
    for test_function in "${test_functions[@]}"; do
        run_test "$test_function"
    done

    # Display test results
    echo "Total tests: $total_tests"
    echo "Passes: $total_passes"
    echo "Fails: $total_fails"
}

# Compare two values
# $1 - Value 1
# $2 - Operator
# $3 - Value 2
compare() {
    if [[ "$2" == "==" ]]; then
        [[ "$1" == "$3" ]]
    elif [[ "$2" == "!=" ]]; then
        [[ "$1" != "$3" ]]
    elif [[ "$2" == "-eq" ]]; then
        [[ "$1" -eq "$3" ]]
    elif [[ "$2" == "-ne" ]]; then
        [[ "$1" -ne "$3" ]]
    elif [[ "$2" == "-lt" ]]; then
        [[ "$1" -lt "$3" ]]
    elif [[ "$2" == "-gt" ]]; then
        [[ "$1" -gt "$3" ]]
    elif [[ "$2" == "-le" ]]; then
        [[ "$1" -le "$3" ]]
    elif [[ "$2" == "-ge" ]]; then
        [[ "$1" -ge "$3" ]]
    else
        echo "Invalid operator: $2"
        exit 1
    fi
}

# Assert - exit on failure
# $1 - Expected value
# $2 - Operator
# $3 - Actual value
# $4 - Message on failure (optional)
assert() {
    compare "$1" "$2" "$3" || {
        if [[ -n "$4" ]]; then
            echo "$4"
        fi
        exit 1
    }
    return 0
}

# Assert - continue on failure
# $1 - Expected value
# $2 - Operator
# $3 - Actual value
# $4 - Message on failure (optional)
soft_assert() {
    compare "$1" "$2" "$3" || {
        if [[ -n "$4" ]]; then
            echo "$4"
        fi
        return 1
    }
    return 0
}

# Expect failure - exit on success
# $1 - Command
# $2 - Message on success (optional)
expect_fail() {
    if $1; then
        if [[ -n "$2" ]]; then
            echo "$2"
        fi
        exit 1
    else
        return 0
    fi
}

# Expect failure - continue on success
# $1 - Command
# $2 - Message on success (optional)
soft_expect_fail() {
    if $1; then
        if [[ -n "$2" ]]; then
            echo "$2"
        fi
        return 1
    else
        return 0
    fi
}

# Expect success - exit on failure
# $1 - Command
# $2 - Message on failure (optional)
expect_success() {
    if $1; then
        return 0
    else
        if [[ -n "$2" ]]; then
            echo "$2"
        fi
        exit 1
    fi
}

# Expect success - continue on failure
# $1 - Command
# $2 - Message on failure (optional)
soft_expect_success() {
    if $1; then
        return 0
    else
        if [[ -n "$2" ]]; then
            echo "$2"
        fi
        return 1
    fi
}

# Benchmarking map key: function name, value: time in ns
declare -A benchmark_map


# Benchmarking
# $1 - Command
# $2 - Number of iterations
# $3 - goal time in nano seconds (optional)
benchmark() {
    local command="$1"
    local iterations="$2"
    local goal_time="$3"

    # Run command once to cache it
    eval "$command" &>/dev/null

    # Run command for iterations
    local total_time=0
    local max_time=0
    local min_time=0
    for ((i = 0; i < iterations; i++)); do
        local start_time=$(date +%s%N)
        eval "$command" &>/dev/null
        local end_time=$(date +%s%N)
        local elapsed_time=$((end_time - start_time))
        total_time=$((total_time + elapsed_time))
        if [[ "$elapsed_time" -gt "$max_time" ]]; then
            max_time=$elapsed_time
        fi
        if [[ "$min_time" -eq 0 || "$elapsed_time" -lt "$min_time" ]]; then
            min_time=$elapsed_time
        fi
    done

    # Calculate average time
    local average_time=$((total_time / iterations))
    local average_time_ns="$average_time"
    local average_time_unit="ns"

    # Convert average time to an appropriate unit
    if [[ "$((average_time / 1000000000))" -gt 0 ]]; then
        average_time=$((average_time / 1000000000))
        average_time_unit="s"
    elif [[ "$((average_time / 1000000))" -gt 0 ]]; then
        average_time=$((average_time / 1000000))
        average_time_unit="ms"
    elif [[ "$((average_time / 1000))" -gt 0 ]]; then
        average_time=$((average_time / 1000))
        average_time_unit="us"
    fi

    # Convert min and max times to an appropriate unit
    local min_time_unit="ns"
    local max_time_unit="ns"

    if [[ "$((min_time / 1000000000))" -gt 0 ]]; then
        min_time=$((min_time / 1000000000))
        min_time_unit="s"
    elif [[ "$((min_time / 1000000))" -gt 0 ]]; then
        min_time=$((min_time / 1000000))
        min_time_unit="ms"
    elif [[ "$((min_time / 1000))" -gt 0 ]]; then
        min_time=$((min_time / 1000))
        min_time_unit="us"
    fi

    if [[ "$((max_time / 1000000000))" -gt 0 ]]; then
        max_time=$((max_time / 1000000000))
        max_time_unit="s"
    elif [[ "$((max_time / 1000000))" -gt 0 ]]; then
        max_time=$((max_time / 1000000))
        max_time_unit="ms"
    elif [[ "$((max_time / 1000))" -gt 0 ]]; then
        max_time=$((max_time / 1000))
        max_time_unit="us"
    fi

    # Store benchmark result
    benchmark_map["$command"]=$average_time_ns

    # Display results
    echo "Ran $command $iterations times"
    printf "Average time: %d %s\tMin time: %d %s\tMax time: %d %s\n" "$average_time" "$average_time_unit" "$min_time" "$min_time_unit" "$max_time" "$max_time_unit"

    # Check if goal time was provided
    if [[ -n "$goal_time" ]]; then
        # Validate goal time
        assert "$goal_time" -ge "$average_time_ns" "Goal time not met"
    fi
}

# Self-tests (asserts, benchmarks, etc.)
test_benchmark() {
    # Test benchmarking - no condition
    benchmark "echo hello" 10

    # Test benchmarking - with condition
    benchmark "sleep 2" 1 2200000000

    # Test benchmarking - should fail
    (
        benchmark "sleep 1" 1 1
    )
    if [[ "$?" -eq 0 ]]; then
        return 1
    fi
    return 0
}

test_assert() {
    # numbers
    assert 1 -eq 1 "'1 -eq 1' Assert failed"
    assert 1 -ne 0 "'1 -ne 0' Assert failed"
    assert 1 -lt 2 "'1 -lt 2' Assert failed"
    assert 2 -gt 1 "'2 -gt 1' Assert failed"
    assert 1 -le 1 "'1 -le 1' Assert failed"
    assert 1 -ge 1 "'1 -ge 1' Assert failed"

    # strings
    assert "hello" == "hello" "'hello == hello' Assert failed"
    assert "hello" != "world" "'hello != world' Assert failed"
}

test_assert_fail() {
    (
        assert 1 -eq 0 "'1 -eq 0' Assert failed as expected"
    )
    if [[ "$?" -eq 0 ]]; then
        exit 1
    fi
}

test_soft_assert() {
    local failures=0
    # numbers - success
    soft_assert 1 -eq 1 "'1 -eq 1' Assert failed"
    failures=$((failures + $?))
    soft_assert 1 -ne 0 "'1 -ne 0' Assert failed"
    failures=$((failures + $?))
    soft_assert 1 -lt 2 "'1 -lt 2' Assert failed"
    failures=$((failures + $?))
    soft_assert 2 -gt 1 "'2 -gt 1' Assert failed"
    failures=$((failures + $?))
    soft_assert 1 -le 1 "'1 -le 1' Assert failed"
    failures=$((failures + $?))
    soft_assert 1 -ge 1 "'1 -ge 1' Assert failed"
    failures=$((failures + $?))

    # strings - success
    soft_assert "hello" == "hello" "'hello == hello' Assert failed"
    failures=$((failures + $?))
    soft_assert "hello" != "world" "'hello != world' Assert failed"
    failures=$((failures + $?))

    # numbers - failure
    soft_assert 1 -eq 0 "'1 -eq 0' Assert failed as expected"
    failures=$((failures + $?))
    soft_assert 1 -ne 1 "'1 -ne 1' Assert failed as expected"
    failures=$((failures + $?))
    soft_assert 1 -lt 0 "'1 -lt 0' Assert failed as expected"
    failures=$((failures + $?))
    soft_assert 1 -gt 2 "'1 -gt 2' Assert failed as expected"
    failures=$((failures + $?))
    soft_assert 1 -le 0 "'1 -le 0' Assert failed as expected"
    failures=$((failures + $?))
    soft_assert 1 -ge 2 "'1 -ge 2' Assert failed as expected"
    failures=$((failures + $?))

    # strings - failure
    soft_assert "hello" == "world" "'hello == world' Assert failed as expected"
    failures=$((failures + $?))
    soft_assert "hello" != "hello" "'hello != hello' Assert failed as expected"
    failures=$((failures + $?))

    if [[ "$failures" -ne 8 ]]; then
        exit 1
    fi
}

test_will_fail() {
    return 1
}

test_will_succeed() {
    return 0
}

test_expect_fail() {
    local failures=0
    expect_fail "test_will_fail" "'test_will_fail' Expected failure, but succeeded"
    failures=$((failures + $?))
    (
        expect_fail "test_will_succeed" "'test_will_succeed' Succeeded as expected, causing failure"
    )
    failures=$((failures + $?))
    soft_expect_fail "test_will_succeed" "'test_will_succeed' Succeeded as expected, causing failure"
    failures=$((failures + $?))
    soft_expect_fail "test_will_fail" "'test_will_fail' Expected failure, but succeeded"
    failures=$((failures + $?))

    if [[ "$failures" -ne 2 ]]; then
        exit 1
    fi
}

test_expect_success() {
    local failures=0
    expect_success "test_will_succeed" "'test_will_succeed' Expected success, but failed"
    failures=$((failures + $?))
    (
        expect_success "test_will_fail" "'test_will_fail' Failed as expected, causing failure"
    )
    failures=$((failures + $?))
    soft_expect_success "test_will_fail" "'test_will_fail' Failed as expected, causing failure"
    failures=$((failures + $?))
    soft_expect_success "test_will_succeed" "'test_will_succeed' Expected success, but failed"
    failures=$((failures + $?))

    if [[ "$failures" -ne 2 ]]; then
        exit 1
    fi
}

# Run self-tests without polluting the global test list
run_test_utility_self_test(){
    run_test test_benchmark
    run_test test_assert
    run_test test_assert_fail
    run_test test_soft_assert
    run_test test_expect_fail
    run_test test_expect_success
}