#!/bin/bash

echo "🚀 Building Gara App Stable APK..."
echo

echo "📱 Cleaning project..."
flutter clean
echo "✅ Clean completed"

echo "📦 Getting dependencies..."
flutter pub get
echo "✅ Dependencies installed"

echo "🔨 Building APK..."
flutter build apk --release
echo "✅ Build completed"

echo "📁 APK location:"
echo "$(pwd)/build/app/outputs/flutter-apk/app-release.apk"
echo

echo "🎉 Build successful!"
echo "📱 APK ready for distribution"
echo
