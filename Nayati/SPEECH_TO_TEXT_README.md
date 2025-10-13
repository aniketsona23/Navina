# Speech-to-Text Implementation

This implementation adds real-time speech-to-text functionality to the Hearing Assist screen using AssemblyAI.

## Features

- **Real-time Transcription**: Converts speech to text in real-time
- **Live Audio Recording**: Records audio in 3-second chunks for processing
- **Error Handling**: Comprehensive error handling with user feedback
- **Permission Management**: Automatically requests audio recording permissions
- **Cross-platform Support**: Works on iOS, Android, and Web platforms

## How it Works

1. **Audio Recording**: Uses Expo's Audio API to record audio in WAV format
2. **Periodic Processing**: Records audio in 3-second chunks and processes them
3. **AssemblyAI Integration**: Sends audio chunks to AssemblyAI for transcription
4. **Real-time Display**: Displays transcribed text in the subtitle area

## API Configuration

The implementation uses the AssemblyAI API with the provided API key:
- API Key: `7515813707144831b2e9965e9c796a7a`
- Sample Rate: 16kHz
- Format: WAV (Linear PCM)
- Language Detection: Enabled
- Punctuation: Enabled
- Text Formatting: Enabled

## Usage

1. Navigate to the Hearing Assist screen
2. Tap "Start Listening" to begin speech recognition
3. Speak into the device microphone
4. Transcribed text will appear in real-time in the subtitle area
5. Tap "Stop Listening" to end the session

## Controls

- **Start/Stop Listening**: Main button to control speech recognition
- **Clear Transcript**: Trash icon to clear the transcript history
- **Mute**: Volume control (placeholder for future audio features)

## Technical Details

### Audio Recording Configuration

```typescript
const recordingOptions = {
  android: {
    extension: '.wav',
    outputFormat: Audio.RECORDING_OPTION_ANDROID_OUTPUT_FORMAT_DEFAULT,
    audioEncoder: Audio.RECORDING_OPTION_ANDROID_AUDIO_ENCODER_DEFAULT,
    sampleRate: 16000,
    numberOfChannels: 1,
    bitRate: 128000,
  },
  ios: {
    extension: '.wav',
    outputFormat: Audio.RECORDING_OPTION_IOS_OUTPUT_FORMAT_LINEARPCM,
    audioQuality: Audio.RECORDING_OPTION_IOS_AUDIO_QUALITY_HIGH,
    sampleRate: 16000,
    numberOfChannels: 1,
    bitRate: 128000,
    linearPCMBitDepth: 16,
    linearPCMIsBigEndian: false,
    linearPCMIsFloat: false,
  },
  web: {
    mimeType: 'audio/wav',
    bitsPerSecond: 128000,
  },
};
```

### Transcription Processing

- Records audio for 3 seconds
- Stops recording and gets the file URI
- Converts audio to buffer for AssemblyAI
- Sends to AssemblyAI for transcription
- Displays results in the UI
- Starts new recording cycle

## Error Handling

The implementation includes comprehensive error handling for:
- Permission denials
- Network connectivity issues
- Audio recording failures
- Transcription API errors

## Dependencies

- `assemblyai`: AssemblyAI SDK for speech recognition
- `expo-av`: Expo Audio API for recording
- `react-native`: Core React Native components

## Future Enhancements

- Real-time streaming transcription (when supported by AssemblyAI in React Native)
- Speaker identification
- Language switching
- Audio quality optimization
- Offline transcription support
