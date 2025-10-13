import React, { useState, useEffect, useRef } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView, Alert, Dimensions } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Screen } from '../types/navigation';
import { useObjectDetection } from '../hooks/useObjectDetection';
import * as ImageManipulator from 'expo-image-manipulator';
import { debugApi } from '../services/debugApi';

// Camera imports
import { CameraView, CameraType, useCameraPermissions } from 'expo-camera';

interface VisualAssistScreenProps {
  onNavigate: (screen: Screen) => void;
}

export function VisualAssistScreen({ onNavigate }: VisualAssistScreenProps) {
  
  const [isScanning, setIsScanning] = useState(false);
  const [permission, requestPermission] = useCameraPermissions();
  const [facing, setFacing] = useState<CameraType>('back');
  const cameraRef = useRef<CameraView>(null);
  const screenWidth = Dimensions.get('window').width;
  const screenHeight = Dimensions.get('window').height;
  const isCapturing = useRef(false);
  const captureIntervalRef = useRef<NodeJS.Timeout | null>(null);
  
  // Use object detection hook
  const {
    detections: detectedObjects,
    isDetecting,
    error: detectionError,
    processingTime,
    detectObjects,
    clearDetections,
  } = useObjectDetection();

  useEffect(() => {
    if (!permission?.granted) {
      requestPermission();
    }
  }, [permission, requestPermission]);

  // Note: Shutter sound configuration removed as it's not needed for camera capture

  useEffect(() => {
  }, [detectedObjects, isDetecting, processingTime]);

  // Start/stop interval based on isScanning state
  useEffect(() => {
    if (isScanning) {
      captureIntervalRef.current = setInterval(() => {
        captureAndDetect();
      }, 1000); // 1 second for better detection rate
    } else {
      if (captureIntervalRef.current) {
        clearInterval(captureIntervalRef.current);
        captureIntervalRef.current = null;
      }
    }

    // Cleanup on unmount
    return () => {
      if (captureIntervalRef.current) {
        clearInterval(captureIntervalRef.current);
        captureIntervalRef.current = null;
      }
    };
  }, [isScanning]);


  const toggleCameraFacing = () => {
    setFacing((current) => (current === 'back' ? 'front' : 'back'));
  };

  const captureAndDetect = async () => {
    if (!cameraRef.current || isCapturing.current || !isScanning) {
      return;
    }

    // Check if camera is ready
    if (!cameraRef.current.takePictureAsync) {
      return;
    }

    try {
      isCapturing.current = true;

      // Add a delay to ensure camera is ready
      await new Promise(resolve => setTimeout(resolve, 300));

      // Capture with stable settings
      const photo = await cameraRef.current.takePictureAsync({
        quality: 0.3, // Moderate quality for stability
        base64: false,
        skipProcessing: false, // Allow processing for stability
        exif: false,
        imageType: 'jpg',
        compress: 0.3, // Moderate compression for stability
        doNotSave: true, // Don't save to gallery
        mirror: false, // No mirroring
      });
      
      // Check if photo was captured successfully
      if (!photo || !photo.uri) {
        return;
      }
      

      // Resize immediately
      const resized = await ImageManipulator.manipulateAsync(
        photo.uri,
        [{ resize: { width: 320, height: 320 } }],
        { compress: 0.3, format: ImageManipulator.SaveFormat.JPEG }
      );

      if (!resized || !resized.uri) {
        return;
      }


      // Send to backend (non-blocking)
      detectObjects(resized.uri).catch(err => {
        console.error('❌ [OPTIMIZED] Detection error:', err);
      });

    } catch (error) {
      console.error('❌ [OPTIMIZED] Capture error:', error);
    } finally {
      isCapturing.current = false;
    }
  };

  const startScanning = async () => {
    
    if (!permission?.granted) {
      Alert.alert('Camera Permission', 'Camera permission is required to use this feature.');
      return;
    }
    
    setIsScanning(true);
    clearDetections();
  };

  const stopScanning = () => {
    setIsScanning(false);
    isCapturing.current = false;
    clearDetections();
  };

  const testApiConnection = async () => {
    debugApi.getNetworkInfo();
    
    const result = await debugApi.testConnectivity();
    if (result.success) {
      Alert.alert('✅ API Test', `Backend is working!\nModel: ${result.data.model_info?.model_name || 'Unknown'}`);
    } else {
      Alert.alert('❌ API Test Failed', `Error: ${result.error}\n\nMake sure:\n1. Backend is running\n2. Both devices are on same network\n3. IP address is correct`);
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>Visual Assist</Text>
        <TouchableOpacity
          onPress={() => onNavigate('settings')}
          style={styles.settingsButton}
          activeOpacity={0.7}
        >
          <Ionicons name="settings-outline" size={24} color="#2563EB" />
        </TouchableOpacity>
      </View>

      {/* Camera View */}
      <View style={styles.cameraContainer}>
        {permission?.granted ? (
          <CameraView
            ref={cameraRef}
            style={styles.camera}
            facing={facing}
            onCameraReady={() => {
            }}
          >
            {/* Camera overlay to minimize capture visibility */}
            <View style={styles.cameraOverlay} />
            {/* Camera Controls */}
            <View style={styles.cameraControls}>
              <TouchableOpacity
                onPress={toggleCameraFacing}
                style={styles.cameraControlButton}
                activeOpacity={0.7}
              >
                <Ionicons name="camera-reverse-outline" size={24} color="#FFFFFF" />
              </TouchableOpacity>
            </View>
            
            {/* Scanning Overlay */}
            {isScanning && (
              <>
                <View style={styles.scanningOverlay}>
                  <Text style={styles.scanningText}>
                    {isDetecting ? '🔍 Analyzing...' : '👁️ Scanning'}
                  </Text>
                  {processingTime > 0 && (
                    <Text style={styles.processingTimeText}>
                      {(processingTime * 1000).toFixed(0)}ms
                    </Text>
                  )}
                  {detectionError && (
                    <Text style={styles.errorText}>
                      {detectionError}
                    </Text>
                  )}
                </View>
                
                {/* Object detection boxes */}
                {detectedObjects.map((object) => {
                  // Calculate precise positioning with padding adjustment
                  const padding = 4; // Account for border width
                  const left = Math.max(0, object.bounds.x * screenWidth - padding);
                  const top = Math.max(0, object.bounds.y * screenHeight - padding);
                  const width = Math.min(screenWidth - left, object.bounds.width * screenWidth + (padding * 2));
                  const height = Math.min(screenHeight - top, object.bounds.height * screenHeight + (padding * 2));
                  
                  const boxStyle = {
                    position: 'absolute' as const,
                    left,
                    top,
                    width,
                    height,
                    borderWidth: 3,
                    borderColor: '#00FF00',
                    borderRadius: 6,
                    backgroundColor: 'rgba(0, 255, 0, 0.08)',
                    shadowColor: '#00FF00',
                    shadowOffset: { width: 0, height: 0 },
                    shadowOpacity: 0.9,
                    shadowRadius: 6,
                    elevation: 10,
                  };
                  
                  return (
                    <View key={object.id} style={boxStyle}>
                      {/* Object label - positioned inside the box at top-left */}
                      <View style={[styles.objectLabel, { 
                        top: 4, 
                        left: 4,
                        maxWidth: Math.min(width - 8, 120)
                      }]}>
                        <Text style={styles.objectLabelText}>
                          {object.name} ({Math.round(object.confidence * 100)}%)
                        </Text>
                      </View>
                    </View>
                  );
                })}

                {/* Detection count indicator */}
                {detectedObjects.length > 0 && (
                  <View style={styles.detectionCountOverlay}>
                    <Text style={styles.detectionCountText}>
                      {detectedObjects.length} object{detectedObjects.length !== 1 ? 's' : ''} detected
                    </Text>
                  </View>
                )}

                {/* Detection status indicator */}
                {isScanning && (
                  <View style={styles.statusIndicator}>
                    <View style={[styles.statusDot, isDetecting && styles.statusDotActive]} />
                    <Text style={styles.statusText}>
                      {isDetecting ? '🔍 Analyzing...' : '👁️ Scanning'}
                    </Text>
                  </View>
                )}
              </>
            )}
          </CameraView>
        ) : permission === null ? (
          <View style={styles.cameraPlaceholder}>
            <Ionicons name="camera-outline" size={48} color="#9CA3AF" />
            <Text style={styles.permissionText}>Requesting camera permission...</Text>
          </View>
        ) : (
          <View style={styles.cameraPlaceholder}>
            <Ionicons name="camera-outline" size={48} color="#9CA3AF" />
            <Text style={styles.permissionText}>Camera permission required</Text>
            <TouchableOpacity
              onPress={requestPermission}
              style={styles.permissionButton}
              activeOpacity={0.7}
            >
              <Text style={styles.permissionButtonText}>Grant Permission</Text>
            </TouchableOpacity>
          </View>
        )}
      </View>

      {/* Controls */}
      <View style={styles.controlsContainer}>
        {/* Primary Action */}
        <TouchableOpacity
          onPress={isScanning ? stopScanning : startScanning}
          style={[styles.primaryButton, { backgroundColor: isScanning ? '#DC2626' : '#2563EB' }]}
          activeOpacity={0.8}
        >
          {isScanning ? (
            <>
              <Ionicons name="stop-outline" size={20} color="#FFFFFF" />
              <Text style={styles.primaryButtonText}>Stop Detection</Text>
            </>
          ) : (
            <>
              <Ionicons name="scan-outline" size={20} color="#FFFFFF" />
              <Text style={styles.primaryButtonText}>Start Detection</Text>
            </>
          )}
        </TouchableOpacity>

        {/* Secondary Actions */}
        <View style={styles.secondaryActions}>
          <TouchableOpacity
            onPress={testApiConnection}
            style={[styles.secondaryButton, { backgroundColor: '#10B981' }]}
            activeOpacity={0.7}
          >
            <Ionicons name="bug-outline" size={20} color="#FFFFFF" />
            <Text style={[styles.secondaryButtonText, { color: '#FFFFFF' }]}>Test API</Text>
          </TouchableOpacity>
          
          <TouchableOpacity
            onPress={() => onNavigate('map')}
            style={styles.secondaryButton}
            activeOpacity={0.7}
          >
            <Ionicons name="navigate-outline" size={20} color="#2563EB" />
            <Text style={styles.secondaryButtonText}>Navigate</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Info Section */}
      <View style={styles.infoSection}>
        <View style={styles.infoCard}>
          <Ionicons name="eye-outline" size={24} color="#2563EB" />
          <View style={styles.infoTextContainer}>
            <Text style={styles.infoTitle}>Real-Time Detection</Text>
            <Text style={styles.infoDescription}>
              Powered by YOLOv5 AI - detects objects at 2 FPS
            </Text>
          </View>
        </View>

        <View style={styles.infoCard}>
          <Ionicons name="flash-outline" size={24} color="#10B981" />
          <View style={styles.infoTextContainer}>
            <Text style={styles.infoTitle}>Optimized Performance</Text>
            <Text style={styles.infoDescription}>
              Low quality capture for faster processing
            </Text>
          </View>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  contentContainer: {
    padding: 24,
    paddingBottom: 24,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 24,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000000',
  },
  settingsButton: {
    padding: 8,
    borderRadius: 8,
  },
  cameraContainer: {
    position: 'relative',
    backgroundColor: '#1F2937',
    borderRadius: 16,
    aspectRatio: 9/16,
    marginBottom: 24,
    overflow: 'hidden',
  },
  camera: {
    flex: 1,
  },
  cameraOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'transparent',
    pointerEvents: 'none',
  },
  cameraPlaceholder: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  cameraControls: {
    position: 'absolute',
    top: 16,
    right: 16,
    flexDirection: 'row',
    gap: 8,
  },
  cameraControlButton: {
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    borderRadius: 20,
    padding: 8,
  },
  permissionText: {
    color: '#9CA3AF',
    fontSize: 16,
    textAlign: 'center',
    marginTop: 12,
    marginBottom: 16,
  },
  permissionButton: {
    backgroundColor: '#2563EB',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 8,
  },
  permissionButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '600',
  },
  scanningOverlay: {
    position: 'absolute',
    top: 16,
    left: 16,
    right: 16,
    padding: 12,
    backgroundColor: 'rgba(37, 99, 235, 0.9)',
    borderRadius: 8,
  },
  scanningText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
  processingTimeText: {
    color: '#D1D5DB',
    fontSize: 12,
    textAlign: 'center',
    marginTop: 4,
  },
  errorText: {
    color: '#FCA5A5',
    fontSize: 12,
    textAlign: 'center',
    marginTop: 4,
  },
  detectionCountOverlay: {
    position: 'absolute',
    bottom: 120,
    left: 16,
    right: 16,
    padding: 12,
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    borderRadius: 8,
    alignItems: 'center',
  },
  detectionCountText: {
    color: '#00FF00',
    fontSize: 14,
    fontWeight: '600',
  },
  statusIndicator: {
    position: 'absolute',
    top: 20,
    right: 20,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 20,
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#9CA3AF',
    marginRight: 8,
  },
  statusDotActive: {
    backgroundColor: '#00FF00',
  },
  statusText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '600',
  },
  objectLabel: {
    position: 'absolute',
    top: 4,
    left: 4,
    backgroundColor: '#00FF00',
    borderWidth: 1,
    borderColor: '#000000',
    borderRadius: 4,
    paddingHorizontal: 6,
    paddingVertical: 3,
    maxWidth: 120,
    zIndex: 1000,
    elevation: 15,
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.8,
    shadowRadius: 2,
  },
  objectLabelText: {
    color: '#000000',
    fontSize: 11,
    fontWeight: '800',
    textShadowColor: '#FFFFFF',
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 2,
    letterSpacing: 0.2,
  },
  controlsContainer: {
    marginBottom: 24,
  },
  primaryButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    paddingHorizontal: 24,
    borderRadius: 16,
    marginBottom: 16,
    gap: 12,
  },
  primaryButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  secondaryActions: {
    flexDirection: 'row',
    gap: 12,
  },
  secondaryButton: {
    flex: 1,
    padding: 16,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 12,
    alignItems: 'center',
    gap: 8,
  },
  secondaryButtonText: {
    color: '#000000',
    fontSize: 12,
  },
  infoSection: {
    marginBottom: 24,
  },
  infoCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F9FAFB',
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
  },
  infoTextContainer: {
    flex: 1,
    marginLeft: 12,
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000000',
    marginBottom: 4,
  },
  infoDescription: {
    fontSize: 14,
    color: '#6B7280',
  },
});

