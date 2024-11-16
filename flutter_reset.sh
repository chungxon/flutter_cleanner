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
    echo "${BLUE}Flutter Project Resetter v${VERSION}${RESET}"
    echo "${BLUE}==============================${RESET}"
    echo "This script will clean and get packages for your Flutter project."
    echo ""
}

# Help function
help_function() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Reset Flutter project by cleaning and getting packages."
    echo ""
    echo "Options:"
    echo "  -v, --verbose   Show detailed output"
    echo "  -h, --help      Show this help message"
    echo "  --version       Show version information"
    echo ""
    echo "Examples:"
    echo "  $0              # Reset Flutter project"
    echo "  $0 -v          # Reset Flutter project with verbose output"
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

#------------------------------------------------------------------------------
# Public code
#------------------------------------------------------------------------------

# Default values
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
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

# Main execution
main() {
    print_banner
    check_flutter
    
    echo "Starting Flutter project reset..."
    echo ""
    
    # Start timing
    start_time=$(date +%s.%N)
    
    # Clean project
    echo "▶ Step 1: Cleaning project..."
    if [ "$VERBOSE" = true ]; then
        ./flutter_clean.sh -v || handle_error "Project cleaning failed"
    else
        ./flutter_clean.sh || handle_error "Project cleaning failed"
    fi
    echo "${GREEN}✓ Project cleaned successfully${RESET}"
    echo ""
    
    # Get packages
    echo "▶ Step 2: Getting packages..."
    if [ "$VERBOSE" = true ]; then
        ./flutter_get.sh -v || handle_error "Package installation failed"
    else
        ./flutter_get.sh || handle_error "Package installation failed"
    fi
    echo "${GREEN}✓ Packages installed successfully${RESET}"
    echo ""
    
    # Calculate total time
    end_time=$(date +%s.%N)
    elapsed_time=$(echo "$end_time - $start_time" | bc)
    formatted_time=$(printf "%.1f" "$elapsed_time")
    
    echo "${GREEN}✅ Flutter project reset completed successfully (${formatted_time}s)${RESET}"
}

# Run main function
main
