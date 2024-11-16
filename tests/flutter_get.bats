#!/usr/bin/env bats

load test_helper

@test "flutter_get.sh shows help message with -h flag" {
    run "$TEST_DIR/flutter_get.sh" -h
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ "Usage:" ]]
}

@test "flutter_get.sh shows version with --version flag" {
    run "$TEST_DIR/flutter_get.sh" --version
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ "v1.0.0" ]]
}

@test "flutter_get.sh gets packages for all Flutter projects" {
    cd "$TEST_DIR/mock_project"
    
    # Run the get script
    run "$TEST_DIR/flutter_get.sh"
    [ "$status" -eq 0 ]
    
    # Check if flutter pub get was called
    [[ "${output}" =~ "Running 'flutter pub get'..." ]]
}

@test "flutter_get.sh runs pod install with -p flag" {
    cd "$TEST_DIR/mock_project"
    
    # Run the get script with pod install
    run "$TEST_DIR/flutter_get.sh" -p
    [ "$status" -eq 0 ]
    
    # Check if both commands were called
    [[ "${output}" =~ "Running 'flutter pub get'..." ]]
    [[ "${output}" =~ "Running 'pod install --repo-update'" ]]
}

@test "flutter_get.sh handles non-existent directory gracefully" {
    cd "$TEST_DIR"
    mkdir -p "empty_dir"
    cd "empty_dir"
    
    run "$TEST_DIR/flutter_get.sh"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Found 0 projects" ]]
}

@test "flutter_get.sh verbose mode shows detailed output" {
    cd "$TEST_DIR/mock_project"
    
    run "$TEST_DIR/flutter_get.sh" -v
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Finding projects..." ]]
    [[ "${output}" =~ "Found" ]]
}

@test "flutter_get.sh handles missing pubspec.yaml gracefully" {
    cd "$TEST_DIR/mock_project"
    rm pubspec.yaml
    
    run "$TEST_DIR/flutter_get.sh"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Found 1 projects" ]]
}
