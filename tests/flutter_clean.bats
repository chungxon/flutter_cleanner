#!/usr/bin/env bats

load test_helper

@test "flutter_clean.sh shows help message with -h flag" {
    run "$TEST_DIR/flutter_clean.sh" -h
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ "Usage:" ]]
}

@test "flutter_clean.sh shows version with --version flag" {
    run "$TEST_DIR/flutter_clean.sh" --version
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ "v1.0.0" ]]
}

@test "flutter_clean.sh deep cleans all Flutter projects" {
    cd "$TEST_DIR/mock_project"
    
    # Run the clean script
    run "$TEST_DIR/flutter_clean.sh"
    [ "$status" -eq 0 ]
    
    # Check if build artifacts are removed
    assert_not_exists "build/mock.txt"
    assert_not_exists ".dart_tool/mock.txt"
    assert_not_exists "ios/Pods/mock.txt"
    assert_not_exists "android/.gradle/mock.txt"
    assert_not_exists "macos/Pods/mock.txt"
    assert_not_exists "pubspec.lock"
    assert_not_exists ".flutter-plugins"
    assert_not_exists ".flutter-plugins-dependencies"
    
    # Check if nested project is also cleaned
    assert_not_exists "packages/nested_project/build/mock.txt"
    assert_not_exists "packages/nested_project/.dart_tool/mock.txt"
}

@test "flutter_clean.sh cleans only current project with -d false" {
    cd "$TEST_DIR/mock_project"
    
    # Run the clean script with -d false
    run "$TEST_DIR/flutter_clean.sh" -d false
    [ "$status" -eq 0 ]
    
    # Check if current project artifacts are removed
    assert_not_exists "build/mock.txt"
    assert_not_exists ".dart_tool/mock.txt"
    
    # Check if nested project artifacts still exist
    assert_exists "packages/nested_project/build/mock.txt"
    assert_exists "packages/nested_project/.dart_tool/mock.txt"
}

@test "flutter_clean.sh handles non-existent directory gracefully" {
    cd "$TEST_DIR"
    mkdir -p "empty_dir"
    cd "empty_dir"
    
    run "$TEST_DIR/flutter_clean.sh"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Found 0 projects" ]]
}

@test "flutter_clean.sh verbose mode shows detailed output" {
    cd "$TEST_DIR/mock_project"
    
    run "$TEST_DIR/flutter_clean.sh" -v
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Finding projects..." ]]
    [[ "${output}" =~ "Found" ]]
}
