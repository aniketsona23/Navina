# Camera Testing Guide

## Testing the Visual Assist Screen Camera

### Prerequisites
1. Make sure you have installed expo-camera:
   ```bash
   npm install expo-camera
   ```

2. Run the app on a physical device (camera doesn't work in simulators):
   ```bash
   npm start
   # Then press 'i' for iOS or 'a' for Android
   ```

### Testing Steps

1. **Navigate to Visual Assist Screen**:
   - Open the app
   - Go to the Home tab
   - Tap on "Visual Assist" mode

2. **Grant Camera Permission**:
   - When prompted, grant camera permission
   - If permission is denied, tap "Grant Permission" button

3. **Test Camera Features**:
   - **Camera Feed**: You should see live camera feed
   - **Camera Switch**: Tap the camera flip button (top-right) to switch between front/back cameras
   - **Start Scanning**: Tap "Start Object Detection" to begin scanning
   - **Object Detection**: After 1 second, simulated objects will appear with bounding boxes
   - **Stop Scanning**: Tap "Stop Scanning" to end detection

4. **Test Permission States**:
   - **Loading**: Shows "Requesting camera permission..." while permission is being requested
   - **Denied**: Shows "Camera permission required" with grant button
   - **Granted**: Shows live camera feed

### Expected Behavior

- **Camera Feed**: Live video from device camera in portrait 9:16 aspect ratio
- **Camera Controls**: Flip button works to switch cameras
- **Object Detection**: Simulated objects appear with blue bounding boxes (optimized for portrait view)
- **Scanning Overlay**: "Scanning objects..." text appears when active
- **Permission Handling**: Proper fallbacks for different permission states
- **Portrait Layout**: Tall, mobile-optimized camera view that takes up more screen space

### Troubleshooting

1. **Camera not showing**:
   - Make sure you're on a physical device
   - Check camera permissions in device settings
   - Restart the app

2. **Permission issues**:
   - Go to device settings > Apps > [Your App] > Permissions
   - Enable camera permission manually

3. **App crashes**:
   - Make sure expo-camera is properly installed
   - Clear app cache: `npx expo start --clear`

### Features Implemented

✅ **Real Camera Feed**: Live camera preview using Expo Camera
✅ **Portrait Layout**: 9:16 aspect ratio optimized for mobile viewing
✅ **Camera Switching**: Toggle between front and back cameras
✅ **Permission Handling**: Automatic permission requests and fallbacks
✅ **Object Detection**: Simulated object detection with bounding boxes (portrait-optimized)
✅ **Scanning States**: Visual indicators for scanning mode
✅ **Barcode Scanning**: Ready for barcode detection (currently disabled)
✅ **Error Handling**: Graceful fallbacks for permission issues
