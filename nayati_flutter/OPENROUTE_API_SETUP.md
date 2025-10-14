# 🔑 OpenRouteService API Key Setup Guide

## 📍 **Where to Put Your API Key:**

### **File Location:**
```
nayati_flutter/lib/services/open_route_service.dart
```

### **Exact Line to Replace:**
**Line 12** - Replace this line:
```dart
static const String _apiKey = 'YOUR_OPENROUTE_SERVICE_API_KEY_HERE'; // Replace with your key
```

### **With Your Actual API Key:**
```dart
static const String _apiKey = '5b3ce3597851110001cf6248xxxxxxxxxxxxx'; // Your actual key
```

---

## 🆓 **Step 1: Get Your Free API Key**

### 1.1 Visit OpenRouteService
Go to: https://openrouteservice.org/dev/#/signup

### 1.2 Create Free Account
1. Click **"Sign up"**
2. Fill in your details
3. Verify your email
4. **Free tier**: 2000 requests/day

### 1.3 Get Your API Key
1. Login to your account
2. Go to **"API Keys"** section
3. Copy your **API key** (starts with `5b3ce359...`)

---

## 🔧 **Step 2: Add API Key to Your Project**

### 2.1 Open the File
Navigate to:
```
nayati_flutter/lib/services/open_route_service.dart
```

### 2.2 Find Line 12
Look for this line:
```dart
static const String _apiKey = 'YOUR_OPENROUTE_SERVICE_API_KEY_HERE';
```

### 2.3 Replace with Your Key
Change it to:
```dart
static const String _apiKey = '5b3ce3597851110001cf6248xxxxxxxxxxxxx';
```

**Example with real key:**
```dart
static const String _apiKey = '5b3ce3597851110001cf6248a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6';
```

---

## 🧪 **Step 3: Test Your Setup**

### 3.1 Clean and Rebuild
```bash
cd nayati_flutter
flutter clean
flutter pub get
flutter run
```

### 3.2 Test Navigation
1. Navigate to **Mobility Assist** → **Outdoor Nav**
2. Search for a destination
3. Check if you get **real turn-by-turn directions**

### 3.3 Verify It's Working
**With API Key (Real Routes):**
- ✅ Detailed turn-by-turn instructions
- ✅ Real street names
- ✅ Accurate distances and times
- ✅ Professional routing

**Without API Key (Mock Routes):**
- ⚠️ Basic straight-line directions
- ⚠️ Generic instructions
- ⚠️ Estimated distances

---

## 🔍 **How to Check if API Key is Working:**

### **Look for These Indicators:**

#### **Real API (Working):**
```dart
// In the navigation instructions, you'll see:
"Turn left onto Main Street"
"Continue straight for 200 meters"
"Head north on Oak Avenue"
```

#### **Mock API (Not Working):**
```dart
// In the navigation instructions, you'll see:
"Head towards destination"
"Follow the route on the map"
"Arrive at destination"
```

---

## 🛠️ **Troubleshooting:**

### **Problem: Still Getting Mock Routes**
**Solutions:**
1. ✅ Check API key is correctly placed in line 12
2. ✅ Verify no extra spaces or quotes around the key
3. ✅ Make sure you copied the complete key
4. ✅ Check your OpenRouteService account has remaining quota

### **Problem: API Key Not Working**
**Solutions:**
1. ✅ Verify key is active in OpenRouteService dashboard
2. ✅ Check you haven't exceeded daily limit (2000 requests)
3. ✅ Ensure key starts with `5b3ce359...`
4. ✅ Try generating a new key

### **Problem: App Crashes**
**Solutions:**
1. ✅ Make sure API key is wrapped in single quotes
2. ✅ Check for any syntax errors around line 12
3. ✅ Run `flutter clean && flutter pub get`

---

## 📊 **API Key Format:**

### **Correct Format:**
```dart
static const String _apiKey = '5b3ce3597851110001cf6248a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6';
```

### **Common Mistakes:**
```dart
// ❌ Wrong - extra quotes
static const String _apiKey = "'5b3ce359...'";

// ❌ Wrong - double quotes
static const String _apiKey = "5b3ce359...";

// ❌ Wrong - missing quotes
static const String _apiKey = 5b3ce359...;

// ✅ Correct - single quotes
static const String _apiKey = '5b3ce359...';
```

---

## 🎯 **Quick Setup Checklist:**

- [ ] **Get free API key** from openrouteservice.org
- [ ] **Open** `lib/services/open_route_service.dart`
- [ ] **Find line 12** with `YOUR_OPENROUTE_SERVICE_API_KEY_HERE`
- [ ] **Replace** with your actual API key in single quotes
- [ ] **Save** the file
- [ ] **Run** `flutter clean && flutter pub get`
- [ ] **Test** navigation with real destination search

---

## 🚀 **Result:**

Once you add your API key, you'll get:
- ✅ **Real turn-by-turn directions**
- ✅ **Actual street names**
- ✅ **Accurate distances and times**
- ✅ **Professional-grade routing**
- ✅ **Walking-optimized routes** for accessibility

**The navigation will work like Google Maps but completely free!** 🗺️✨

---

## 💡 **Pro Tip:**

You can test the setup by searching for any well-known destination like:
- "Times Square, New York"
- "Central Park, New York"  
- "Golden Gate Bridge, San Francisco"

If you get detailed street-by-street directions, your API key is working perfectly!
