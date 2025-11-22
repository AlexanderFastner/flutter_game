# Flutter Game App

A simple Flutter game app framework with a main menu, difficulty/map selection, and game screen.

## Project Structure

```
flutter_game/
├── lib/
│   ├── main.dart                    # App entry point
│   └── screens/
│       ├── main_menu_screen.dart    # Main menu with play button
│       ├── game_setup_screen.dart   # Difficulty and map selection
│       └── game_screen.dart         # Game screen (placeholder)
├── pubspec.yaml                     # Flutter dependencies
└── README.md                        # This file
```

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK**: Download and install from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. **Dart SDK**: Included with Flutter
3. **Android Studio / VS Code**: For development and testing
4. **Android Emulator / iOS Simulator / Physical Device**: For running the app

## Setup Instructions

### 1. Verify Flutter Installation

```bash
flutter doctor
```

This will check your Flutter installation and show any missing dependencies.

### 2. Install Dependencies

Navigate to the project directory and install the Flutter dependencies:

```bash
cd /mnt/c/Users/Alexander/Programming/flutter_game
flutter pub get
```

### 3. Check Available Devices

List all available devices (emulators, simulators, or physical devices):

```bash
flutter devices
```

### 4. Run the App

#### Option A: Run on a specific device
```bash
flutter run -d <device-id>
flutter run -d emulator-5554
```

#### Option B: Run and let Flutter choose a device
```bash
flutter run
```

#### Option C: Run in debug mode with hot reload
```bash
flutter run --debug
```

## Testing the App

### Navigation Flow

1. **Main Menu Screen**: 
   - You'll see a blue gradient background with "Flutter Game" title
   - Click the "Play" button to proceed

2. **Game Setup Screen**:
   - Select a difficulty level (Easy, Medium, or Hard)
   - Select a map (Map 1, Map 2, or Map 3)
   - Click "Start Game" to launch the game

3. **Game Screen**:
   - Currently displays the selected difficulty and map
   - This is a placeholder - you can add your game logic here
   - Use the back button to return to the setup screen

### Hot Reload

While the app is running, you can use hot reload to see changes instantly:

- Press `r` in the terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Testing on Different Platforms

#### Android
```bash
flutter run -d android
```

#### iOS (macOS only)
```bash
flutter run -d ios
```

#### Web
```bash
flutter run -d chrome
```

#### Desktop (Linux/Windows/macOS)
```bash
flutter run -d linux    # For Linux
flutter run -d windows  # For Windows
flutter run -d macos    # For macOS
```

## Development Tips

1. **Hot Reload**: Make changes to your code and press `r` in the terminal to see updates instantly
2. **Debug Mode**: Use `flutter run --debug` for better debugging capabilities
3. **Release Mode**: Use `flutter run --release` for optimized performance testing

## Next Steps

The game screen (`lib/screens/game_screen.dart`) is currently a placeholder. You can:

1. Add your game logic to the `GameScreen` widget
2. Create game models and controllers
3. Add game assets (images, sounds) to an `assets/` folder
4. Implement game mechanics based on the selected difficulty and map

## Troubleshooting

### If `flutter pub get` fails:
- Ensure you have an active internet connection
- Check that your Flutter SDK is up to date: `flutter upgrade`

### If no devices are found:
- Start an Android emulator from Android Studio
- Start an iOS simulator from Xcode (macOS only)
- Connect a physical device via USB and enable USB debugging

### If the app doesn't run:
- Check for errors in the terminal output
- Ensure all dependencies are installed: `flutter pub get`
- Try cleaning the build: `flutter clean && flutter pub get`

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

