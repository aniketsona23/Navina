@echo off
echo 🔧 Fixing Dependencies for Nayati App
echo =====================================

REM Navigate to Nayati directory
cd Nayati

echo 📦 Removing problematic packages...
npm uninstall react-native-worklets-core

echo 📦 Installing compatible versions...
npm install react-native-reanimated@3.16.1

echo 🧹 Clearing caches...
npm cache clean --force

echo 🗑️ Removing node_modules and package-lock.json...
if exist node_modules rmdir /s /q node_modules
if exist package-lock.json del package-lock.json

echo 📦 Reinstalling all dependencies...
npm install

echo ✅ Dependencies fixed!
echo.
echo Next steps:
echo 1. Run: npx expo start --clear
echo 2. Test the app on your device/simulator
echo.

pause
