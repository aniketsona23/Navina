# Google Maps API Setup Guide

## 🗝️ Step 1: Get Your Google Maps API Key

### 1.1 Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Project name: `Nayati Navigation App`
4. Click "Create"

### 1.2 Enable Required APIs
Enable these APIs in your project:
- **Maps SDK for Android**
- **Maps SDK for iOS**
- **Places API**
- **Directions API**
- **Geocoding API**

**How to enable:**
1. Go to "APIs & Services" → "Library"
2. Search for each API
3. Click "Enable"

### 1.3 Create API Key
1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "API Key"
3. Copy the generated key

### 1.4 Secure Your API Key (CRITICAL!)

**Application Restrictions:**
- **Android**: Add package name: `com.example.nayatiFlutter`
- **iOS**: Add bundle ID: `com.example.nayatiFlutter`

**API Restrictions:**
Select only these APIs:
- Maps SDK for Android
- Maps SDK for iOS
- Places API
- Directions API
- Geocoding API

## 📱 Step 2: Configure Android

### 2.1 Update AndroidManifest.xml
Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` in:
```
android/app/src/main/AndroidManifest.xml
```

### 2.2 Get SHA-1 Fingerprint (for production)
Run this command in your project root:
```bash
cd android
./gradlew signingReport
```

Copy the SHA-1 fingerprint and add it to your API key restrictions.

## 🍎 Step 3: Configure iOS

### 3.1 Update GoogleService-Info.plist
Replace placeholders in:
```
ios/Runner/GoogleService-Info.plist
```

You'll get these values from Google Cloud Console:
- `API_KEY`: Your Google Maps API key
- `CLIENT_ID`: iOS client ID
- `REVERSED_CLIENT_ID`: Reversed client ID
- `GCM_SENDER_ID`: Sender ID
- `PROJECT_ID`: Your project ID

### 3.2 Get Bundle Identifier
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project
3. Go to "Signing & Capabilities"
4. Copy the Bundle Identifier
5. Add it to your API key restrictions

## 🔧 Step 4: Update Configuration Files

### 4.1 Android Configuration
**File:** `android/app/src/main/AndroidManifest.xml`

Replace this line:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE" />
```

With your actual API key:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" />
```

### 4.2 iOS Configuration
**File:** `ios/Runner/GoogleService-Info.plist`

Replace all placeholder values with your actual Google Cloud values.

## 🧪 Step 5: Test Your Setup

### 5.1 Install Dependencies
```bash
cd nayati_flutter
flutter pub get
```

### 5.2 Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### 5.3 Test Features
1. **Location Permission**: App should request location access
2. **Map Display**: Map should load without errors
3. **Current Location**: Blue dot should appear showing your location
4. **Search**: Destination search should work

## 🚨 Troubleshooting

### Common Issues:

#### "Map not loading"
- ✅ Check API key is correct
- ✅ Verify APIs are enabled
- ✅ Check internet connection
- ✅ Ensure API key restrictions match your app

#### "Location not working"
- ✅ Check location permissions in device settings
- ✅ Ensure location services are enabled
- ✅ Verify location permissions in manifest/plist

#### "Search not working"
- ✅ Verify Places API is enabled
- ✅ Check API key has Places API access
- ✅ Ensure network connectivity

### Debug Commands:
```bash
# Check Flutter doctor
flutter doctor

# Check for issues
flutter analyze

# Clean build
flutter clean && flutter pub get
```

## 🔐 Security Best Practices

### 1. API Key Restrictions
- **NEVER** use unrestricted API keys in production
- Always set application restrictions
- Set API restrictions to only needed APIs

### 2. Environment Variables (Recommended)
For production, use environment variables:

**Android:**
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}" />
```

**iOS:**
Use build configurations or environment variables.

### 3. Key Rotation
- Regularly rotate your API keys
- Monitor API usage in Google Cloud Console
- Set up billing alerts

## 📊 Monitoring and Billing

### 1. Enable Billing
Google Maps APIs require billing to be enabled:
1. Go to "Billing" in Google Cloud Console
2. Link a payment method
3. Set up billing alerts

### 2. Monitor Usage
- Check API usage in "APIs & Services" → "Dashboard"
- Set up quotas and limits
- Monitor costs regularly

### 3. Free Tier Limits
- Maps SDK: $200/month free credit
- Places API: $200/month free credit
- Directions API: $200/month free credit

## 🎯 Production Checklist

Before going live:

- [ ] API key restrictions configured
- [ ] Billing enabled and monitored
- [ ] Bundle ID/Package name correct
- [ ] All required APIs enabled
- [ ] Location permissions properly configured
- [ ] Error handling implemented
- [ ] Offline fallbacks considered
- [ ] Performance optimized
- [ ] Security review completed

## 📞 Support

### Google Cloud Support:
- [Google Cloud Documentation](https://cloud.google.com/docs)
- [Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Google Cloud Support](https://cloud.google.com/support)

### Flutter Maps Support:
- [google_maps_flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Flutter Documentation](https://flutter.dev/docs)

---

**⚠️ Important:** Never commit API keys to version control. Use environment variables or secure configuration management for production deployments.
