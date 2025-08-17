@echo off
echo 🚀 Upload APK to GitHub Releases
echo.

echo 📱 Checking APK file...
if not exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ❌ APK not found! Building first...
    call build_stable.bat
)

echo 📤 Uploading to GitHub Releases...
echo.
echo 📋 Instructions:
echo 1. Go to: https://github.com/linhdung88vp/AppList/releases
echo 2. Click "Create a new release"
echo 3. Tag: v1.0.1
echo 4. Title: Gara App v1.0.1
echo 5. Description: Auto-update feature
echo 6. Upload file: build\app\outputs\flutter-apk\app-release.apk
echo 7. Publish release
echo.

echo 📁 APK location:
echo %cd%\build\app\outputs\flutter-apk\app-release.apk
echo.

echo 🎯 After upload, test update in app!
echo.

pause
