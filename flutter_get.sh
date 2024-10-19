#!/bin/bash
set -e

# Color codes
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Get all Flutter projects
get_flutter_project() {
  local podRunning=$1

  if [ -z "${podRunning}" ]; then
    podRunning="false"
  fi

  # Start running timing
  start_running_time=$(date +%s.%N)
  
  echo "${YELLOW}Get all Flutter projects...${RESET}"

  echo "${YELLOW}Finding projects...${RESET}"

  # Initialize the counter for the number of projects
  countAllItem=0

  # Count the main project and nested modules
  countAllItem=$(find . -name "pubspec.yaml" -not -path "./build/*" -not -path "./.dart_tool/*" -not -path "./.idea/*" | wc -l | xargs)

  # Output the total number of projects/modules to be got
  echo "${GREEN}Found $countAllItem projects${RESET}"

  # Find and get main or nested Flutter packages/modules
  find . -name "pubspec.yaml" -not -path "./build/*" -not -path "./.dart_tool/*" -not -path "./.idea/*" | while read -r pubspec; do
    module_dir=$(dirname "$pubspec")

    # echo "\n${YELLOW}==== Directory: $module_dir ====${RESET}"

    # Start timing the getting process with nanosecond precision
    start_time=$(date +%s.%N)

    # Change to the module directory
    cd "$module_dir" || exit
    echo "\n${YELLOW}==== Directory: $(pwd) ====${RESET}"

    # Flutter pub get
    echo "${YELLOW}Running 'flutter pub get'...${RESET}"
    flutter pub get

    # End timing with nanosecond precision
    end_time=$(date +%s.%N)

    # Calculate elapsed time with decimals
    elapsed_time=$(echo "$end_time - $start_time" | bc)

    # Format elapsed time
    formatted_time=$(printf "%.1fs" "$elapsed_time")

    if [ "$module_dir" == "." ]; then
        echo "${GREEN}Ran 'flutter pub get' in current directory ($formatted_time)${RESET}"
    else
        echo "${GREEN}Ran 'flutter pub get' in $module_dir ($formatted_time)${RESET}"
    fi

    # Return to the root directory after getting
    cd - >/dev/null
  done
  
  if [[ "${podRunning}" == "true" ]]; then
    echo "\nRunning 'pod install --repo-update' in $(pwd)..."
    cd ios && pod install --repo-update && cd ..
    # cd macos && pod install --repo-update && cd ..
  fi

  # End running timing
  end_running_time=$(date +%s.%N)

  # Calculate elapsed time with decimals
  running_time=$(echo "$end_running_time - $start_running_time" | bc)

  # Format elapsed time
  formatted_time=$(printf "%.1fs" "$running_time")

  echo "\n${GREEN}✅ Get Flutter project successfully ($formatted_time).${RESET}"
}

# [POD_RUNNING] is used to run pod install in root project for iOS after running
# `flutter pub get`. Default is "false".
POD_RUNNING=$1

if [ -z "$POD_RUNNING" ]; then
    POD_RUNNING="false"
fi

get_flutter_project $POD_RUNNING

