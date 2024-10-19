#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Include the scripts for cleaning and getting Flutter projects
. flutter_clean.sh
. flutter_get.sh true
