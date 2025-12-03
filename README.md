# Neon Escape (Two cars inspired)

## Project Structure

```
flutter_game/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── screens/
│   │   ├── main_menu_screen.dart    # Main menu with play button
│   │   ├── game_setup_screen.dart   # Difficulty and map selection
│   │   ├── game_screen.dart         # Game screen
│   │   ├── game_over_screen.dart    # Game over screen
│   │   ├── high_scores_screen.dart  # High scores display
│   │   └── settings_screen.dart     # Settings screen
│   ├── services/
│   │   ├── high_score_service.dart  # High score management
│   │   ├── settings_service.dart    # Settings persistence
│   │   └── theme_service.dart       # Theme management
│   └── widgets/
│       ├── aspect_ratio_wrapper.dart # Aspect ratio wrapper widget
│       └── themed_background.dart   # Themed background widget
├── web/                             # Web platform files
│   ├── index.html                   # Web entry point
│   ├── manifest.json                # Web app manifest
│   └── icons/                       # Web app icons
├── android/                         # Android platform files
├── ios/                             # iOS platform files
├── windows/                         # Windows platform files
├── linux/                           # Linux platform files
├── macos/                           # macOS platform files
├── test/                            # Test files
├── pubspec.yaml                     # Flutter dependencies
├── firebase.json                    # Firebase Hosting configuration
├── deploy.sh                        # Deployment script (WSL/Linux)
├── deploy.bat                       # Deployment script (Windows CMD)
├── deploy.ps1                       # Deployment script (PowerShell)
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
r
flutter emulators
```

### 4. Run the App

#### Option A: Run on a specific device
```bash
flutter emulators --launch S21ish
flutter run -d <device-id>
flutter run -d emulator-5554
```

#### Option B: Run on my phone
```bash
flutter run -d R5CR20NQRZL #My phone USB

adb tcpip 5555
adb connect 192.168.1.185:5555 #my phone over WIFI (check ip)
flutter run -d R5CR20NQRZL
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

#### Web
```bash
flutter run -d chrome
```

#### Desktop (Linux/Windows)
```bash
flutter run -d linux    # For Linux
flutter run -d windows  # For Windows
```

## Web Deployment to Firebase Hosting

### Deployment Steps

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

3. **Build Flutter Web App**
   ```bash
   flutter build web
   ```

4. **Initialize Firebase Hosting**
   ```bash
   firebase init hosting
   ```
   - Select your Firebase project
   - Set public directory to `build/web`
   - Configure as single-page app: **Yes**
   - Set up automatic builds: **No** (optional)
   - Don't overwrite existing `index.html`: **No**

5. **Deploy to Firebase**

   **Option A: Use the deployment script (recommended)**
   
   For WSL/Linux/Git Bash:
   ```bash
   ./deploy.sh
   ```
   
   For Windows Command Prompt:
   ```cmd
   deploy.bat
   ```
   
   For Windows PowerShell:
   ```powershell
   .\deploy.ps1
   ```
   
   The script will automatically:
   - Build the Flutter web app (`flutter build web --release`)
   - Deploy to Firebase Hosting (`firebase deploy --only hosting`)
   
   **Option B: Manual deployment**
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

6. **Access Your App**
   Your app will be available at:
   - `https://[project-id].web.app`
   - `https://[project-id].firebaseapp.com`

### Updating the Deployed App

To update your app after making code changes, simply redeploy:

**Using deployment script (recommended):**
```bash
./deploy.sh        # WSL/Linux/Git Bash
deploy.bat         # Windows CMD
.\deploy.ps1       # PowerShell
```

**Manual update:**
```bash
flutter build web --release
firebase deploy --only hosting
```