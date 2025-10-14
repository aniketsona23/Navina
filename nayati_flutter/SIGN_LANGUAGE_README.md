# Sign Language Recognition Feature

This document describes the sign language to text conversion feature integrated into the Visual Assist module of the Nayati Flutter app.

## Overview

The sign language recognition feature allows users to convert sign language gestures into text and speech, making communication more accessible for deaf and hard-of-hearing individuals. This feature is integrated into the Visual Assist module and can be accessed through a dedicated sign language screen.

## Features

### 1. Real-time Sign Language Recognition
- Camera-based gesture capture
- Image processing for sign language detection
- Text output with confidence scores
- Voice synthesis of recognized text

### 2. Multiple Input Methods
- **Camera Capture**: Real-time gesture recognition using device camera
- **Gallery Import**: Process pre-recorded images from device gallery
- **Video Processing**: Support for video file uploads (future enhancement)

### 3. User Interface
- Intuitive camera interface with detection overlay
- Real-time processing status indicators
- Confidence score display
- Text-to-speech controls
- History tracking of recognized text

### 4. Accessibility Features
- Clear visual feedback during processing
- Audio output for recognized text
- Large, readable text display
- Error handling with user-friendly messages

## Architecture

### Core Components

1. **SignLanguageService** (`lib/services/sign_language_service.dart`)
   - Handles API communication with sign language recognition backend
   - Manages video/image processing requests
   - Provides text-to-speech functionality
   - Handles connection testing and model management

2. **SignLanguageProvider** (`lib/providers/sign_language_provider.dart`)
   - State management for sign language recognition
   - Handles processing status and results
   - Manages history and error states
   - Provides text-to-speech controls

3. **SignLanguageScreen** (`lib/screens/sign_language_screen.dart`)
   - Main UI for sign language recognition
   - Camera interface with detection overlay
   - Results display and controls
   - Integration with Visual Assist module

## API Integration

The feature integrates with the [SIGNify API](https://github.com/utmgdsc/SIGNify/) for sign language recognition:

### Base URL
- **Production**: `https://signify-10529.uc.r.appspot.com/`
- **Development**: `http://localhost:5000`

### Endpoints Used

#### 1. Video Processing
```
POST /upload_video
Content-Type: multipart/form-data
Body: {
  video: [video file],
  username: [optional username]
}
Response: {
  "word": "recognized text"
}
```

#### 2. Image Processing
```
POST /upload_image
Content-Type: multipart/form-data
Body: {
  image: [image file],
  username: [optional username]
}
Response: {
  "word": "recognized text"
}
```

#### 3. Connection Test
```
GET /
Response: "Hello, welcome to the api endpoint for SIGNify!"
```

## Usage

### Accessing Sign Language Recognition

1. **From Visual Assist Screen**:
   - Open the Visual Assist module
   - Tap the gesture icon button in the controls
   - This opens the dedicated Sign Language Recognition screen

2. **Direct Navigation**:
   - The feature can be accessed programmatically
   - Integrated into the Visual Assist workflow

### Using the Recognition Feature

1. **Camera Mode**:
   - Point camera at sign language gestures
   - Ensure good lighting and clear hand movements
   - Tap the capture button to process the image
   - View recognized text in the results panel

2. **Gallery Mode**:
   - Tap the gallery icon to select an image
   - Choose a photo containing sign language gestures
   - The image will be processed automatically
   - View results in the recognition panel

3. **Voice Output**:
   - Tap the speaker icon to hear the recognized text
   - Use the volume controls to adjust audio
   - Text is spoken using the device's TTS engine

## Configuration

### Dependencies

The sign language feature requires the following dependencies:
- `camera: ^0.11.0+2` - Camera functionality
- `image_picker: ^1.1.2` - Gallery image selection
- `flutter_tts: ^3.8.5` - Text-to-speech
- `http: ^1.2.2` - API communication

### Permissions

Required permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

## Error Handling

The feature includes comprehensive error handling for:

- **Camera Initialization Failures**: User-friendly error messages
- **API Connection Issues**: Offline mode indicators
- **Processing Errors**: Clear error messages with retry options
- **Permission Denials**: Guidance for enabling required permissions
- **Network Timeouts**: Automatic retry mechanisms

## Performance Considerations

### Optimization Features
- **Image Compression**: Automatic image optimization before upload
- **Caching**: Local storage of recognition history
- **Background Processing**: Non-blocking API calls
- **Memory Management**: Proper disposal of camera resources

### Recommended Settings
- **Image Quality**: 85% compression for optimal balance
- **Max Resolution**: 1920x1080 for processing efficiency
- **Processing Timeout**: 30 seconds for API calls
- **History Limit**: 50 recent recognitions

## Future Enhancements

### Planned Features
1. **Real-time Video Processing**: Continuous gesture recognition
2. **Multiple Sign Languages**: Support for different sign language systems
3. **Custom Models**: User-specific model training
4. **Offline Mode**: Local processing capabilities
5. **Gesture Learning**: Interactive sign language tutorials

### Integration Opportunities
- **Hearing Assist Module**: Integration with live transcription
- **Mobility Assist**: Sign language navigation instructions
- **History Tracking**: Persistent recognition history
- **User Profiles**: Personalized recognition settings

## Testing

### Manual Testing
1. Test camera functionality with different lighting conditions
2. Verify gallery image processing
3. Test text-to-speech output
4. Check error handling scenarios
5. Validate API connectivity

### Automated Testing
- Unit tests for service methods
- Widget tests for UI components
- Integration tests for API communication
- Performance tests for image processing

## Troubleshooting

### Common Issues

1. **Camera Not Working**:
   - Check camera permissions
   - Restart the app
   - Verify camera hardware functionality

2. **API Connection Failed**:
   - Check internet connectivity
   - Verify API endpoint availability
   - Check network security settings

3. **Poor Recognition Accuracy**:
   - Ensure good lighting conditions
   - Use clear, well-defined gestures
   - Check image quality and focus

4. **Text-to-Speech Not Working**:
   - Verify TTS engine availability
   - Check device volume settings
   - Test with different text inputs

## Contributing

When contributing to the sign language feature:

1. Follow the existing code structure and patterns
2. Add comprehensive error handling
3. Include unit tests for new functionality
4. Update documentation for API changes
5. Test on multiple devices and screen sizes

## References

- [SIGNify Repository](https://github.com/utmgdsc/SIGNify/) - Original implementation reference
- [Flutter Camera Plugin](https://pub.dev/packages/camera) - Camera functionality
- [Flutter TTS Plugin](https://pub.dev/packages/flutter_tts) - Text-to-speech
- [Image Picker Plugin](https://pub.dev/packages/image_picker) - Gallery access
