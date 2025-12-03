@echo off
REM Flutter Web Deployment Script for Firebase Hosting
REM This script builds the Flutter web app and deploys it to Firebase

echo 🚀 Starting deployment process...

REM Step 1: Build Flutter web app
echo 📦 Building Flutter web app...
flutter build web --release

REM Check if build was successful
if not exist "build\web" (
    echo ❌ Error: Build directory 'build\web' not found!
    exit /b 1
)

echo ✅ Flutter web build completed successfully!

REM Step 2: Deploy to Firebase
echo 🔥 Deploying to Firebase Hosting...
firebase deploy --only hosting

if %ERRORLEVEL% EQU 0 (
    echo ✅ Deployment completed successfully!
    echo 🌐 Your app should now be live at your Firebase Hosting URL!
) else (
    echo ❌ Deployment failed!
    exit /b 1
)

