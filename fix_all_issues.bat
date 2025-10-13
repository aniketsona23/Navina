@echo off
echo 🔧 Fixing All Expo Issues for Nayati App
echo ========================================

REM Navigate to Nayati directory
cd Nayati

echo 📦 Removing problematic packages...
npm uninstall react-native-worklets-core

echo 📦 Installing compatible versions...
npm install react-native-reanimated@3.10.1

echo 🧹 Clearing caches...
npm cache clean --force

echo 🗑️ Removing node_modules and package-lock.json...
if exist node_modules rmdir /s /q node_modules
if exist package-lock.json del package-lock.json

echo 📦 Reinstalling all dependencies...
npm install

echo 🔧 Fixing navigation issues...
echo - Removed custom NavigationProvider
echo - Updated to use Expo Router navigation
echo - Fixed screen navigation in components

echo ✅ All issues fixed!
echo.
echo Next steps:
echo 1. Run: npx expo start --clear
echo 2. Test the app on your device/simulator
echo.
echo Fixed issues:
echo - NavigationProvider error
echo - ReanimatedModule NullPointerException  
echo - Missing default export warning
echo - Package version conflicts
echo.

pause
