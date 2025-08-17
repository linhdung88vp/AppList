@echo off
echo 🚀 Simple Build Script v1.0.2
echo =============================
echo.

echo 📱 Building APK...
flutter build apk --debug

if %errorlevel% equ 0 (
    echo ✅ Build successful!
    echo.
    echo 📋 Creating release APK...
    copy "build\app\outputs\flutter-apk\app-debug.apk" "build\app\outputs\flutter-apk\app-release.apk"
    echo ✅ Release APK created!
    echo.
    echo 📁 APK Location:
    echo %cd%\build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo 🎯 Upload Instructions:
    echo 1. Go to: https://github.com/linhdung88vp/AppList/releases
    echo 2. Create new release with tag: v1.0.2
    echo 3. Upload: app-release.apk
    echo 4. Publish release
    echo.
    echo 🧪 Test update in app!
) else (
    echo ❌ Build failed!
    echo.
    echo 💡 Try enabling Developer Mode:
    echo 1. Press Win + I
    echo 2. Go to Privacy & Security > For developers
    echo 3. Turn on Developer Mode
    echo 4. Run this script again
)

pause
