# Flutter Project Management Scripts

A collection of shell scripts for managing Flutter projects efficiently on macOS. An alternative to [Melos](https://pub.dev/packages/melos) or [Puby](https://pub.dev/packages/puby).

## Features

- [x] Automatic detection of all Flutter projects in your directory
- [x] Deep cleaning of Flutter projects
  - Runs `flutter clean` in all projects
  - Removes native build files and dependencies
  - Cleans iOS, Android, and macOS artifacts
- [x] Smart package management
  - Runs `flutter pub get` in all projects
  - Optional CocoaPods support for iOS
- [x] Project reset functionality
  - Combined clean and package retrieval
  - Maintains proper order of operations
- [x] Verbose mode for detailed output
- [x] Proper error handling and reporting
- [x] Progress tracking with timing information

## Installation

1. Place all three scripts in your root project directory:
   - `flutter_clean.sh`
   - `flutter_get.sh`
   - `flutter_reset.sh`

2. Make the scripts executable:
   ```bash
   chmod +x flutter_clean.sh flutter_get.sh flutter_reset.sh
   ```

## Usage

### 1. Clean Project(s)
```bash
./flutter_clean.sh [options]
```
Options:
- `-d, --deep`    Deep clean all Flutter projects (default: true)
- `-v, --verbose` Show detailed output
- `-h, --help`    Show help message
- `--version`     Show version information

Examples:
```bash
./flutter_clean.sh            # Deep clean all Flutter projects
./flutter_clean.sh -d false   # Clean only the current Flutter project
./flutter_clean.sh -v        # Deep clean with verbose output
```

### 2. Get Packages
```bash
./flutter_get.sh [options]
```
Options:
- `-p, --pod`     Run 'pod install' for iOS after getting packages
- `-v, --verbose` Show detailed output
- `-h, --help`    Show help message
- `--version`     Show version information

Examples:
```bash
./flutter_get.sh            # Get packages for all Flutter projects
./flutter_get.sh -p         # Get packages and run pod install
./flutter_get.sh -p -v      # Get packages and run pod install with verbose output
```

### 3. Reset Project(s)
```bash
./flutter_reset.sh [options]
```
Options:
- `-v, --verbose` Show detailed output
- `-h, --help`    Show help message
- `--version`     Show version information

Examples:
```bash
./flutter_reset.sh         # Reset all Flutter projects
./flutter_reset.sh -v      # Reset with verbose output
```

## Files Cleaned

The scripts clean the following files and directories:
- iOS related:
  - `ios/Pods`
  - `ios/Podfile.lock`
  - `ios/.symlinks`
  - `ios/Flutter/Flutter.framework`
  - `ios/Flutter/Flutter.podspec`
- Android related:
  - `android/.gradle`
  - `android/build`
  - `android/app/build`
  - `android/local.properties`
- Flutter/Dart related:
  - `build/`
  - `.dart_tool/`
  - `pubspec.lock`
  - `.flutter-plugins`
  - `.flutter-plugins-dependencies`
  - `.packages`
  - `.pub-cache`
  - `.pub`
- macOS related:
  - `macos/Pods`
  - `macos/Podfile.lock`
  - `macos/.symlinks`
- Other:
  - `coverage/`
  - `doc/`
  - `*.iml`
  - `*.log`

## Requirements

- Flutter SDK installed and in PATH
- bash shell
- CocoaPods (optional, for iOS development)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---
<sub><sup>_This README was generated using Windsurf._</sup></sub>