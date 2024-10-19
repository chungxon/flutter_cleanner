# Flutter Cleaner Script
Shell script is used to deep clean a Flutter project 

# Features
- [x] Scan all Flutter projects in your directory
- [x] Run `flutter clean` in all projects
- [x] Remove all native-related files and folders
    - ios/Pods
    - ios/Podfile.lock
    - ios/.symlinks
    - android/.gradle
    - android/build
    - pubspec.lock
    - build
    - macos/Pods
    - macos/Podfile.lock
    - macos/.symlinks

# Usage

- Place the script in your root project directory
- Run the command `sh flutter_clean.sh` or `sh flutter_clean.sh false` to clean current directory
