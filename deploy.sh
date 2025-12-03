#!/bin/bash

# Flutter Web Deployment Script for Firebase Hosting
# This script builds the Flutter web app and deploys it to Firebase

set -e  # Exit on any error

echo "🚀 Starting deployment process..."

# Step 1: Build Flutter web app
echo "📦 Building Flutter web app..."
flutter build web --release

# Check if build was successful
if [ ! -d "build/web" ]; then
    echo "❌ Error: Build directory 'build/web' not found!"
    exit 1
fi

echo "✅ Flutter web build completed successfully!"

# Step 2: Deploy to Firebase
echo "🔥 Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "✅ Deployment completed successfully!"
echo "🌐 Your app should now be live at your Firebase Hosting URL!"

