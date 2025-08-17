@echo off
echo 🧪 Test Update Functionality
echo.

echo 📱 Current version in app: 1.0.0
echo 🆕 New version in API: 1.0.1
echo.

echo 🔍 Testing API endpoint...
curl -s https://linhdung88vp.github.io/AppList/api/update.json
echo.
echo.

echo 📋 Test Steps:
echo 1. Install current app (v1.0.0)
echo 2. Go to Statistics screen
echo 3. Tap update button
echo 4. Check if update dialog appears
echo 5. Test download and install
echo.

echo 🎯 Expected behavior:
echo ✅ Update dialog shows
echo ✅ Download progress works
echo ✅ APK opens for installation
echo.

pause
