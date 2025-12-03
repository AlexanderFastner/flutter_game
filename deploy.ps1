# Flutter Web Deployment Script for Firebase Hosting
# This script builds the Flutter web app and deploys it to Firebase

Write-Host "🚀 Starting deployment process..." -ForegroundColor Cyan

# Step 1: Build Flutter web app
Write-Host "📦 Building Flutter web app..." -ForegroundColor Yellow
flutter build web --release

# Check if build was successful
if (-not (Test-Path "build\web")) {
    Write-Host "❌ Error: Build directory 'build\web' not found!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Flutter web build completed successfully!" -ForegroundColor Green

# Step 2: Deploy to Firebase
Write-Host "🔥 Deploying to Firebase Hosting..." -ForegroundColor Yellow
firebase deploy --only hosting

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
    Write-Host "🌐 Your app should now be live at your Firebase Hosting URL!" -ForegroundColor Green
} else {
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    exit 1
}

