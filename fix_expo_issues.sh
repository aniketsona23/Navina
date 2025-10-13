#!/bin/bash

echo "🔧 Fixing Expo Issues for Nayati App"
echo "===================================="

# Navigate to Nayati directory
cd Nayati

echo "📦 Installing/Updating dependencies..."

# Install specific versions to fix compatibility issues
npm install react-native-reanimated@3.16.1

echo "🧹 Clearing caches..."

# Clear npm cache
npm cache clean --force

# Clear Expo cache
npx expo start --clear --no-dev --minify

echo "✅ Dependencies updated and caches cleared!"
echo ""
echo "Next steps:"
echo "1. Run: cd Nayati && npm install"
echo "2. Run: npx expo start --clear"
echo "3. Test the app on your device/simulator"
echo ""
echo "If you still see the Worklets error, try:"
echo "npx expo install react-native-reanimated@3.16.1"
