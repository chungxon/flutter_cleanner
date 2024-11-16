#!/usr/bin/env bats

load test_helper

@test "flutter_reset.sh shows help message with -h flag" {
    run "$TEST_DIR/flutter_reset.sh" -h
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ "Usage:" ]]
}

@test "flutter_reset.sh shows version with --version flag" {
    run "$TEST_DIR/flutter_reset.sh" --version
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ "v1.0.0" ]]
}

@test "flutter_reset.sh performs clean and get operations" {
    cd "$TEST_DIR/mock_project"
    
    # Mock flutter commands
    function flutter() {
        case "$*" in
            "clean") mock_flutter_clean ;;
            "pub get") mock_flutter_pub_get ;;
        esac
        return 0
    }
    export -f flutter
    
    # Run the reset script
    run "$TEST_DIR/flutter_reset.sh"
    [ "$status" -eq 0 ]
    
    # Check if both operations were performed
    [[ "${output}" =~ "Step 1: Cleaning project..." ]]
    [[ "${output}" =~ "Step 2: Getting packages..." ]]
    
    # Check if artifacts were removed
    assert_not_exists "build/mock.txt"
    assert_not_exists ".dart_tool/mock.txt"
    assert_not_exists "ios/Pods/mock.txt"
}

@test "flutter_reset.sh verbose mode shows detailed output" {
    cd "$TEST_DIR/mock_project"
    
    run "$TEST_DIR/flutter_reset.sh" -v
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Step 1: Cleaning project..." ]]
    [[ "${output}" =~ "Step 2: Getting packages..." ]]
    [[ "${output}" =~ "Finding projects..." ]]
}

@test "flutter_reset.sh handles errors gracefully" {
    cd "$TEST_DIR/mock_project"
    
    # Mock flutter to fail
    function flutter() {
        return 1
    }
    export -f flutter
    
    run "$TEST_DIR/flutter_reset.sh"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "failed" ]]
}

@test "flutter_reset.sh shows execution time" {
    cd "$TEST_DIR/mock_project"
    
    run "$TEST_DIR/flutter_reset.sh"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "completed successfully" ]]
    [[ "${output}" =~ "s)" ]]
}
