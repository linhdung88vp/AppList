@echo off
echo 🧪 Quick Test Update v1.0.2
echo ===========================
echo.

echo 📱 Current version in app: 1.0.0
echo 🆕 New version in API: 1.0.2
echo.

echo 🔍 Testing API endpoint...
powershell -Command "Invoke-WebRequest -Uri 'https://linhdung88vp.github.io/AppList/api/update.json' -UseBasicParsing | Select-Object -ExpandProperty Content"
echo.

echo 📋 Quick Test Steps:
echo 1. Run app on device
echo 2. Go to Statistics screen
echo 3. Tap update button (⚙️ icon)
echo 4. Check update dialog
echo.

echo 🎯 Expected Results:
echo ✅ Update dialog shows v1.0.2
echo ✅ Download URL: public/app-release.apk
echo ✅ Download progress works
echo ✅ APK opens for installation
echo.

echo 📁 APK Location (if needed):
echo %cd%\build\app\outputs\flutter-apk\app-release.apk
echo.

pause
