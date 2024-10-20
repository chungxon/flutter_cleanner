# Flutter Cleaner Script
Shell script is used to deep clean a Flutter project

Another alternative to [Melos](https://pub.dev/packages/melos) or [Puby](https://pub.dev/packages/puby)

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

# Installation

- Place scripts in your root project directory

# Usage

## 1. Clean
- Run the command `sh flutter_clean.sh` to deep clean current Flutter project, include all nested projects
- Run the command `sh flutter_clean.sh false` to clean current Flutter project only

## 2. Get
- Run the command `sh flutter_get.sh` to get all Flutter projects
- Run the command `sh flutter_get.sh true` to get all Flutter project and run
  `pod install` after getting

## 3. Reset
- Run the command `sh flutter_reset.sh` to clean and then get all Flutter projects in your current directory
