# Camera Setup Instructions

To enable real camera functionality in the Visual Assist screen, you need to install the Expo Camera package.

## Installation

1. Navigate to the Nayati directory:
   ```bash
   cd Nayati
   ```

2. Install the expo-camera package:
   ```bash
   npm install expo-camera
   ```

3. For iOS, you may need to run:
   ```bash
   npx expo install --ios
   ```

4. For Android, you may need to run:
   ```bash
   npx expo install --android
   ```

## Enable Camera in VisualAssistScreen

After installing the package, uncomment the camera imports in `components/VisualAssistScreen.tsx`:

```typescript
// Uncomment these lines:
import { CameraView, CameraType, useCameraPermissions } from 'expo-camera';

// And comment out the fallback:
// // Camera imports - will be available after installing expo-camera
// // import { CameraView, CameraType, useCameraPermissions } from 'expo-camera';
```

Then replace the simulated camera logic with the real camera implementation:

```typescript
// Replace the simulated permission state with:
const [permission, requestPermission] = useCameraPermissions();
const [facing, setFacing] = useState<CameraType>('back');
const cameraRef = useRef<CameraView>(null);

// Replace the simulated camera view with:
<CameraView
  ref={cameraRef}
  style={styles.camera}
  facing={facing}
  onBarcodeScanned={isScanning ? undefined : undefined}
>
  {/* Camera content */}
</CameraView>
```

## Permissions

The app will automatically request camera permissions when the Visual Assist screen is accessed. Make sure to grant permissions when prompted.

## Features

- **Real-time Camera Feed**: Live camera preview
- **Camera Switching**: Toggle between front and back cameras
- **Object Detection**: Simulated object detection with bounding boxes
- **Permission Handling**: Automatic permission requests and fallbacks

## Troubleshooting

If you encounter issues:

1. Make sure you're running on a physical device (camera doesn't work in simulators)
2. Check that camera permissions are granted in device settings
3. Restart the Expo development server after installing the package
4. Clear the app cache if needed: `npx expo start --clear`
