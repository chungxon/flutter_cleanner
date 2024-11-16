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
    echo "${BLUE}Flutter Package Getter v${VERSION}${RESET}"
    echo "${BLUE}==============================${RESET}"
}

# Help function
help_function() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Get Flutter dependencies for project(s)."
    echo ""
    echo "Options:"
    echo "  -p, --pod       Run 'pod install' for iOS after getting packages (default: false)"
    echo "  -v, --verbose   Show detailed output"
    echo "  -h, --help      Show this help message"
    echo "  --version       Show version information"
    echo ""
    echo "Examples:"
    echo "  $0                    # Get packages for all Flutter projects"
    echo "  $0 -p                 # Get packages and run pod install"
    echo "  $0 -p -v              # Get packages and run pod install with verbose output"
    exit 1
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

# Check if CocoaPods is installed when needed
check_cocoapods() {
    if ! command -v pod &> /dev/null; then
        handle_error "CocoaPods is not installed. Please install it first."
    fi
}

# Run Flutter pub get command
run_flutter_pub_get() {
    # Check if pubspec.yaml exists
    if [ ! -f "pubspec.yaml" ]; then
        handle_error "No pubspec.yaml found in current directory"
    fi

    # Start timing the getting process
    start_time=$(date +%s.%N)

    echo "${YELLOW}==== Directory: $(pwd) ====${RESET}"

    echo "${YELLOW}▶ Running 'flutter pub get'...${RESET}"
    if [ "$VERBOSE" = true ]; then
        flutter pub get || handle_error "Flutter pub get failed"
    else
        flutter pub get > /dev/null 2>&1 || handle_error "Flutter pub get failed"
    fi

    # Calculate and format elapsed time
    end_time=$(date +%s.%N)
    elapsed_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    formatted_time=$(printf "%.1f" "$elapsed_time")

    echo "${GREEN}✓ Got packages for current directory in ${formatted_time}s${RESET}"
}

# Run pod install for iOS
run_pod_install() {
    if [[ "${POD_RUNNING}" == "true" ]] && [ -d "ios" ]; then
        echo "${YELLOW}▶ Running 'pod install --repo-update' in iOS directory...${RESET}"
        check_cocoapods
        (cd ios && pod install --repo-update) || handle_error "Pod install failed"
        echo "${GREEN}✓ Pod install completed${RESET}"
    fi
}

#------------------------------------------------------------------------------
# Public code
#------------------------------------------------------------------------------

# Default values
POD_RUNNING=false
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--pod)
            POD_RUNNING=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            help_function
            ;;
        --version)
            echo "v${VERSION}"
            exit 0
            ;;
        *)
            echo "${RED}Unknown option: $1${RESET}"
            help_function
            ;;
    esac
done

# Get all Flutter projects
get_flutter_project() {
    echo "${YELLOW}Getting Flutter packages...${RESET}"
    echo ""

    # Start running timing
    start_running_time=$(date +%s.%N)
    
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

    # Output the total number of projects/modules to be processed
    echo "${GREEN}Found $countAllItem projects${RESET}"
    echo ""

    # Find and get main or nested Flutter packages/modules
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
            # Run Flutter pub get
            run_flutter_pub_get
            
            # Add a blank line after each folder
            echo ""
            
            # Return to the root directory
            cd - > /dev/null 2>&1
        else
            echo "${YELLOW}Warning: Could not access directory $module_dir, skipping...${RESET}"
            echo ""
            continue
        fi
    done
    
    # Run pod install if needed
    run_pod_install

    # Calculate total running time
    end_running_time=$(date +%s.%N)
    running_time=$(echo "$end_running_time - $start_running_time" | bc 2>/dev/null || echo "0")
    formatted_time=$(printf "%.1f" "$running_time")

    echo "${GREEN}✅ All packages retrieved successfully (${formatted_time}s)${RESET}"
}

# Main execution
main() {
    print_banner
    check_flutter
    get_flutter_project
}

# Run main function
main
