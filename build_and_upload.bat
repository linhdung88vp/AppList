@echo off
echo 🚀 Gara App - Build and Upload Script
echo ======================================
echo.

echo 📱 Step 1: Cleaning project...
flutter clean
if %errorlevel% neq 0 (
    echo ❌ Clean failed!
    pause
    exit /b 1
)
echo ✅ Clean completed
echo.

echo 📦 Step 2: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Dependencies failed!
    pause
    exit /b 1
)
echo ✅ Dependencies installed
echo.

echo 🔨 Step 3: Building APK...
flutter build apk --debug
if %errorlevel% neq 0 (
    echo ❌ Build failed!
    pause
    exit /b 1
)
echo ✅ Build completed
echo.

echo 📋 Step 4: Creating release APK...
copy "build\app\outputs\flutter-apk\app-debug.apk" "build\app\outputs\flutter-apk\app-release.apk"
if %errorlevel% neq 0 (
    echo ❌ Copy failed!
    pause
    exit /b 1
)
echo ✅ Release APK created
echo.

echo 📁 APK Location:
echo %cd%\build\app\outputs\flutter-apk\app-release.apk
echo.

echo 📊 APK Info:
for %%F in ("build\app\outputs\flutter-apk\app-release.apk") do (
    echo Size: %%~zF bytes
)
echo.

echo 🎯 Step 5: Upload Instructions
echo ==============================
echo 1. Go to: https://github.com/linhdung88vp/AppList/releases
echo 2. Click "Create a new release"
echo 3. Tag: v1.0.2
echo 4. Title: Gara App v1.0.2
echo 5. Description: Auto-update feature v1.0.2
echo 6. Upload file: build\app\outputs\flutter-apk\app-release.apk
echo 7. Publish release
echo.

echo 🧪 Step 6: Test Update
echo ======================
echo 1. Install current app (v1.0.0)
echo 2. Go to Statistics screen
echo 3. Tap update button
echo 4. Check if update dialog appears
echo 5. Test download and install
echo.

echo 🎉 Build completed successfully!
echo 📱 APK ready for upload: app-release.apk
echo.

pause
