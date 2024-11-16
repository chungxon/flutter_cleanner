#!/usr/bin/env bash

# Get the directory of the test helper script
TESTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$TESTS_DIR")"

# Setup test environment
setup() {
    # Create a temporary test directory
    TEST_DIR="$(mktemp -d)"
    export TEST_DIR

    # Copy the scripts to test directory
    cp "$PROJECT_ROOT/flutter_clean.sh" "$TEST_DIR/"
    cp "$PROJECT_ROOT/flutter_get.sh" "$TEST_DIR/"
    cp "$PROJECT_ROOT/flutter_reset.sh" "$TEST_DIR/"
    
    # Make scripts executable
    chmod +x "$TEST_DIR"/*.sh
    
    # Create mock Flutter project structure
    create_mock_flutter_project "$TEST_DIR/mock_project"
    create_mock_flutter_project "$TEST_DIR/mock_project/packages/nested_project"

    # Add mock Flutter and pod to PATH
    PATH="$TEST_DIR:$PATH"
    export PATH

    # Setup mock commands
    setup_mock_commands
}

# Cleanup after tests
teardown() {
    rm -rf "$TEST_DIR"
}

# Setup mock commands
setup_mock_commands() {
    # Create mock flutter command
    cat > "$TEST_DIR/flutter" << 'EOF'
#!/bin/bash
case "$*" in
    "clean")
        echo "Running Flutter clean..."
        ;;
    "pub get")
        echo "Running Flutter pub get..."
        ;;
    *)
        echo "Unknown Flutter command: $*"
        exit 1
        ;;
esac
exit 0
EOF
    chmod +x "$TEST_DIR/flutter"

    # Create mock pod command
    cat > "$TEST_DIR/pod" << 'EOF'
#!/bin/bash
case "$1" in
    "install")
        echo "Running pod install..."
        ;;
    *)
        echo "Unknown pod command: $*"
        exit 1
        ;;
esac
exit 0
EOF
    chmod +x "$TEST_DIR/pod"
}

# Create a mock Flutter project structure
create_mock_flutter_project() {
    local project_dir="$1"
    
    # Create project directory structure
    mkdir -p "$project_dir"/{lib,test,ios,android,macos,build,.dart_tool}
    mkdir -p "$project_dir/ios/Pods"
    mkdir -p "$project_dir/android/.gradle"
    mkdir -p "$project_dir/macos/Pods"
    
    # Create pubspec.yaml
    cat > "$project_dir/pubspec.yaml" << 'EOF'
name: mock_flutter_project
description: A mock Flutter project for testing
version: 1.0.0
environment:
  sdk: ">=2.12.0 <3.0.0"
dependencies:
  flutter:
    sdk: flutter
EOF
    
    # Create iOS Podfile
    cat > "$project_dir/ios/Podfile" << 'EOF'
platform :ios, '11.0'
target 'Runner' do
  use_frameworks!
  pod 'Flutter'
end
EOF

    # Create build artifacts and lock files
    touch "$project_dir/pubspec.lock"
    touch "$project_dir/ios/Podfile.lock"
    touch "$project_dir/macos/Podfile.lock"
    touch "$project_dir/.packages"
    touch "$project_dir/.flutter-plugins"
    touch "$project_dir/.flutter-plugins-dependencies"
    
    # Create mock build artifacts
    echo "mock content" > "$project_dir/build/mock.txt"
    echo "mock content" > "$project_dir/.dart_tool/mock.txt"
    echo "mock content" > "$project_dir/ios/Pods/mock.txt"
    echo "mock content" > "$project_dir/android/.gradle/mock.txt"
    echo "mock content" > "$project_dir/macos/Pods/mock.txt"
}

# Helper function to check if a file/directory exists
assert_exists() {
    local path="$1"
    if [ ! -e "$path" ]; then
        echo "Expected $path to exist"
        return 1
    fi
}

# Helper function to check if a file/directory does not exist
assert_not_exists() {
    local path="$1"
    if [ -e "$path" ]; then
        echo "Expected $path to not exist"
        return 1
    fi
}
