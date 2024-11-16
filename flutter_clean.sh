#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

#------------------------------------------------------------------------------
# Private code
#------------------------------------------------------------------------------

# Color codes
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

# Script version
VERSION="1.0.0"

# Print script banner
print_banner() {
    echo "${BLUE}Flutter Project Cleaner v${VERSION}${RESET}"
    echo "${BLUE}==============================${RESET}"
}

# Help function with improved documentation
help_function() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Clean Flutter project(s) by removing build artifacts and dependencies."
    echo ""
    echo "Options:"
    echo "  -d, --deep     Deep clean all Flutter projects (default: true)"
    echo "  -v, --verbose  Show detailed output"
    echo "  -h, --help     Show this help message"
    echo "  --version      Show version information"
    echo ""
    echo "Examples:"
    echo "  $0                   # Deep clean all Flutter projects"
    echo "  $0 -d false          # Clean only the current Flutter project"
    echo "  $0 -d true -v        # Deep clean all projects with verbose output"
    exit 0
}

# Error handling function
handle_error() {
    echo "${RED}Error: $1${RESET}" >&2
    exit 1
}

# Check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        handle_error "Flutter is not installed or not in PATH"
    fi
}

# Run Flutter clean command
run_flutter_clean() {
    echo "${YELLOW}▶ Running 'flutter clean'...${RESET}"
    if [ "$VERBOSE" = true ]; then
        flutter clean
    else
        flutter clean > /dev/null 2>&1 || handle_error "Flutter clean failed"
    fi
    echo "${GREEN}✓ Flutter clean completed${RESET}"
}

# Remove Flutter and native artifacts
remove_artifacts() {
    echo "${YELLOW}▶ Cleaning native artifacts...${RESET}"
    local artifacts=(
        "ios/Pods"
        "ios/Podfile.lock"
        "ios/.symlinks"
        "ios/Flutter/Flutter.framework"
        "ios/Flutter/Flutter.podspec"
        "android/.gradle"
        "android/build"
        "android/app/build"
        "android/local.properties"
        "pubspec.lock"
        "build"
        ".dart_tool"
        ".flutter-plugins"
        ".flutter-plugins-dependencies"
        "macos/Pods"
        "macos/Podfile.lock"
        "macos/.symlinks"
        "web/build"
        ".packages"
        ".pub-cache"
        ".pub"
        "coverage"
        "doc"
        "*.iml"
        "*.log"
    )
    
    for artifact in "${artifacts[@]}"; do
        if [ -e "$artifact" ]; then
            rm -rf "$artifact"
            [ "$VERBOSE" = true ] && echo "${GREEN}✓ Removed $artifact${RESET}"
        fi
    done
}

clean_current_project() {
    # Check if pubspec.yaml exists
    if [ ! -f "pubspec.yaml" ]; then
        handle_error "No pubspec.yaml found in current directory"
    fi

    # Start timing the cleaning process with nanosecond precision
    start_time=$(date +%s.%N)
    
    echo "${YELLOW}==== Directory: $(pwd) ====${RESET}"
    
    # Run Flutter clean
    run_flutter_clean
    
    # Clean native artifacts
    remove_artifacts
    
    # Calculate and format elapsed time
    end_time=$(date +%s.%N)
    elapsed_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    formatted_time=$(printf "%.1f" "$elapsed_time")
    
    echo "${GREEN}✓ Cleaned current directory in ${formatted_time}s${RESET}"
}

#------------------------------------------------------------------------------
# Public code
#------------------------------------------------------------------------------

# Default values
DEEP_CLEAN=true
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--deep)
            DEEP_CLEAN="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            help_function
            exit 0
            ;;
        --version)
            echo "v${VERSION}"
            exit 0
            ;;
        *)
            echo "${RED}Unknown option: $1${RESET}"
            help_function
            exit 1
            ;;
    esac
done

# Clean Flutter project and native-related files
clean_flutter_project() {
    echo "${YELLOW}Cleaning Flutter project and native-related files...${RESET}"
    
    # Run clean current project
    clean_current_project

    echo "${GREEN}✅ Flutter project cleaned successfully.${RESET}"
}

# Clean all Flutter projects and native-related files and folders
deep_clean_flutter_project() {
    echo "${YELLOW}Cleaning all Flutter projects and native-related files and folders...${RESET}"
    echo ""

    echo "${YELLOW}Finding projects...${RESET}"

    # Initialize the counter for the number of projects
    countAllItem=0

    # Count the main project and nested modules
    countAllItem=$(find . -name "pubspec.yaml" \
        -not -path "*/build/*" \
        -not -path "*/.dart_tool/*" \
        -not -path "*/.idea/*" \
        -not -path "*/.*/*" \
        -not -path "*/linux/*" \
        -not -path "*/windows/*" \
        -not -path "*/macos/*" \
        -not -path "*/ios/*" \
        -not -path "*/android/*" | wc -l | xargs)

    # Output the total number of projects/modules to be cleaned
    echo "${GREEN}Found $countAllItem projects${RESET}"
    echo ""

    # Find and clean main or nested Flutter packages/modules
    find . -name "pubspec.yaml" \
        -not -path "*/build/*" \
        -not -path "*/.dart_tool/*" \
        -not -path "*/.idea/*" \
        -not -path "*/.*/*" \
        -not -path "*/linux/*" \
        -not -path "*/windows/*" \
        -not -path "*/macos/*" \
        -not -path "*/ios/*" \
        -not -path "*/android/*" | while read -r pubspec; do
        module_dir=$(dirname "$pubspec")

        # echo "${YELLOW}==== Directory: $module_dir ====${RESET}"

        # Change to the module directory
        if cd "$module_dir" 2>/dev/null; then
            # Run clean current project
            clean_current_project

            echo ""
            
            # Return to the root directory after cleaning
            cd - > /dev/null 2>&1
        else
            echo "${YELLOW}Warning: Could not access directory $module_dir, skipping...${RESET}"
            echo
            continue
        fi
    done
    
    echo "${GREEN}✅ Flutter project cleaned successfully.${RESET}"
}

# Main execution
main() {
    print_banner
    check_flutter
    
    if [[ "${DEEP_CLEAN}" == "true" ]]; then
        deep_clean_flutter_project
    else
        clean_flutter_project
    fi
}

# Run main function
main
