@echo off
echo 🔧 Fixing ReanimatedModule Crash - Nuclear Option
echo ================================================

REM Navigate to Nayati directory
cd Nayati

echo 🗑️ Complete cleanup...
if exist node_modules rmdir /s /q node_modules
if exist package-lock.json del package-lock.json
if exist .expo rmdir /s /q .expo

echo 📦 Installing minimal working versions...
npm install react-native-reanimated@3.8.1
npm install react-native-gesture-handler@2.16.1

echo 🧹 Clear all caches...
npm cache clean --force
npx expo install --fix

echo 🔄 Alternative: Try without Reanimated temporarily...
echo Creating backup of current package.json...
copy package.json package.json.backup

echo Removing reanimated from package.json temporarily...
powershell -Command "(Get-Content package.json) -replace '\"react-native-reanimated\": \".*\",', '' | Set-Content package.json"

echo 📦 Installing without reanimated...
npm install

echo ✅ Try running the app now:
echo npx expo start --clear
echo.
echo If it works, we can add reanimated back later with proper setup.
echo If not, restore backup: copy package.json.backup package.json

pause
