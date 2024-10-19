#!/bin/bash
set -e

# Color codes
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Clean Flutter project and native-related files and folders
clean_flutter_project() {
  echo "${YELLOW}Cleaning Flutter project and native-related files and folders...${RESET}"

  # Start timing the cleaning process with nanosecond precision
  start_time=$(date +%s.%N)
  
  echo "\n${YELLOW}==== Directory: $(pwd) ====${RESET}"
  
  # Flutter clean
  echo "${YELLOW}Running 'flutter clean'...${RESET}"
  flutter clean > /dev/null 2>&1  # Run flutter clean and suppress output
  
  # Clean native-related files and folders in nested modules
  echo "${YELLOW}Cleaning native artifacts...${RESET}"
  rm -rf ios/Pods ios/Podfile.lock ios/.symlinks android/.gradle android/build pubspec.lock build macos/Pods macos/Podfile.lock macos/.symlinks
  
  # End timing with nanosecond precision
  end_time=$(date +%s.%N)
  
  # Calculate elapsed time with decimals
  elapsed_time=$(echo "$end_time - $start_time" | bc)
  
  # Format elapsed time
  formatted_time=$(printf "%.1f" "$elapsed_time")
  
  echo "${GREEN}Cleaned current directory in $formatted_time${RESET}"
  echo "\n${GREEN}✅ Flutter project cleaned successfully.${RESET}"
}

# Clean all Flutter projects and native-related files and folders
deep_clean_flutter_project() {
  echo "${YELLOW}Cleaning all Flutter projects and native-related files and folders...${RESET}"

  echo "${YELLOW}Finding projects...${RESET}"

  # Initialize the counter for the number of projects
  countAllItem=0

  # Count the main project and nested modules
  countAllItem=$(find . -name "pubspec.yaml" -not -path "./build/*" -not -path "./.dart_tool/*" -not -path "./.idea/*" | wc -l | xargs)

  # Output the total number of projects/modules to be cleaned
  echo "${GREEN}Found $countAllItem projects${RESET}"

  # Find and clean main or nested Flutter packages/modules
  find . -name "pubspec.yaml" -not -path "./build/*" -not -path "./.dart_tool/*" -not -path "./.idea/*" | while read -r pubspec; do
    module_dir=$(dirname "$pubspec")

    # echo "\n${YELLOW}==== Directory: $module_dir ====${RESET}"

    # Start timing the cleaning process with nanosecond precision
    start_time=$(date +%s.%N)

    # Change to the module directory
    cd "$module_dir" || exit
    echo "\n${YELLOW}==== Directory: $(pwd) ====${RESET}"

    # Flutter clean
    echo "${YELLOW}Running 'flutter clean'...${RESET}"
    flutter clean > /dev/null 2>&1  # Run flutter clean and suppress output

    # Clean native-related files and folders in nested modules
    echo "${YELLOW}Cleaning native artifacts...${RESET}"
    rm -rf ios/Pods ios/Podfile.lock ios/.symlinks android/.gradle android/build pubspec.lock build macos/Pods macos/Podfile.lock macos/.symlinks

    # End timing with nanosecond precision
    end_time=$(date +%s.%N)

    # Calculate elapsed time with decimals
    elapsed_time=$(echo "$end_time - $start_time" | bc)

    # Format elapsed time
    formatted_time=$(printf "%.1f" "$elapsed_time")

    if [ "$module_dir" == "." ]; then
        echo "${GREEN}Cleaned current directory in $formatted_time${RESET}"
    else
        echo "${GREEN}Cleaned $module_dir in $formatted_time${RESET}"
    fi

    # Return to the root directory after cleaning
    cd - >/dev/null
  done
  
  echo "\n${GREEN}✅ Flutter project cleaned successfully.${RESET}"
}

# [DEEP_CLEAN] is used to clean all FLutter project. Default is "true".
DEEP_CLEAN=$1

if [ -z "$DEEP_CLEAN" ]; then
    DEEP_CLEAN="true"
fi

if [[ "${DEEP_CLEAN}" == "true" ]]; then
    deep_clean_flutter_project
else
    clean_flutter_project
fi

