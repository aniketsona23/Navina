import React, { useState, useEffect, useRef } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView, Alert, Dimensions } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Screen } from '../types/navigation';

// Camera imports - will be available after installing expo-camera
import { CameraView, CameraType, useCameraPermissions } from 'expo-camera';

interface VisualAssistScreenProps {
  onNavigate: (screen: Screen) => void;
}

export function VisualAssistScreen({ onNavigate }: VisualAssistScreenProps) {
  const [isScanning, setIsScanning] = useState(false);
  const [permission, requestPermission] = useCameraPermissions();
  const [facing, setFacing] = useState<CameraType>('back');
  const cameraRef = useRef<CameraView>(null);
  const [detectedObjects, setDetectedObjects] = useState<{id: string, name: string, confidence: number, bounds: {x: number, y: number, width: number, height: number}}[]>([]);
  const screenWidth = Dimensions.get('window').width;
  const screenHeight = Dimensions.get('window').height;

  useEffect(() => {
    if (!permission?.granted) {
      requestPermission();
    }
  }, [permission, requestPermission]);



  const toggleCameraFacing = () => {
    setFacing((current) => (current === 'back' ? 'front' : 'back'));
  };

  const startScanning = () => {
    if (!permission?.granted) {
      Alert.alert('Camera Permission', 'Camera permission is required to use this feature.');
      return;
    }
    setIsScanning(true);
    // Simulate object detection
    setTimeout(() => {
      setDetectedObjects([
        { id: '1', name: 'Chair', confidence: 0.95, bounds: { x: 0.1, y: 0.2, width: 0.25, height: 0.15 } },
        { id: '2', name: 'Table', confidence: 0.87, bounds: { x: 0.6, y: 0.4, width: 0.2, height: 0.12 } },
        { id: '3', name: 'Door', confidence: 0.92, bounds: { x: 0.3, y: 0.6, width: 0.15, height: 0.25 } }
      ]);
    }, 1000);
  };

  const stopScanning = () => {
    setIsScanning(false);
    setDetectedObjects([]);
  };

  const handleBarcodeScanned = ({ type, data }: { type: string; data: string }) => {
    // Handle barcode scanning if needed
    console.log('Barcode scanned:', { type, data });
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
            onBarcodeScanned={isScanning ? handleBarcodeScanned : undefined}
          >
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
            
            {/* Overlay zones */}
            {isScanning && (
              <>
                <View style={styles.scanningOverlay}>
                  <Text style={styles.scanningText}>Scanning objects...</Text>
                </View>
                
                {/* Object detection boxes */}
                {detectedObjects.map((object) => (
                  <View
                    key={object.id}
                    style={[
                      styles.objectBox,
                      {
                        left: object.bounds.x * screenWidth,
                        top: object.bounds.y * screenHeight,
                        width: object.bounds.width * screenWidth,
                        height: object.bounds.height * screenHeight,
                      }
                    ]}
                  >
                    <View style={styles.objectLabel}>
                      <Text style={styles.objectLabelText}>
                        {object.name} ({Math.round(object.confidence * 100)}%)
                      </Text>
                    </View>
                  </View>
                ))}
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
          style={[styles.primaryButton, { backgroundColor: isScanning ? '#C2410C' : '#2563EB' }]}
          activeOpacity={0.8}
        >
          {isScanning ? (
            <>
              <Ionicons name="stop-outline" size={20} color="#FFFFFF" />
              <Text style={styles.primaryButtonText}>Stop Scanning</Text>
            </>
          ) : (
            <>
              <Ionicons name="camera-outline" size={20} color="#FFFFFF" />
              <Text style={styles.primaryButtonText}>Start Object Detection</Text>
            </>
          )}
        </TouchableOpacity>

        {/* Secondary Actions */}
        <View style={styles.secondaryActions}>
          <TouchableOpacity style={styles.secondaryButton} activeOpacity={0.7}>
            <Ionicons name="volume-high-outline" size={20} color="#2563EB" />
            <Text style={styles.secondaryButtonText}>Read Text</Text>
          </TouchableOpacity>
          
          <TouchableOpacity style={styles.secondaryButton} activeOpacity={0.7}>
            <Ionicons name="send-outline" size={20} color="#2563EB" />
            <Text style={styles.secondaryButtonText}>Share</Text>
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

      {/* SOS Button */}
      <TouchableOpacity style={styles.sosButton} activeOpacity={0.8}>
        <Ionicons name="warning-outline" size={20} color="#FFFFFF" />
        <Text style={styles.sosButtonText}>Emergency SOS</Text>
      </TouchableOpacity>

      {/* Recent Detections */}
      <View style={styles.recentDetections}>
        <Text style={styles.recentDetectionsTitle}>Recent Detections</Text>
        <View style={styles.detectionList}>
          {['Chair - dining room', 'Door - entrance', 'Table - wooden'].map((item, index) => (
            <View key={index} style={styles.detectionItem}>
              <Text style={styles.detectionItemText}>{item}</Text>
            </View>
          ))}
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
    backgroundColor: 'rgba(37, 99, 235, 0.3)',
    borderRadius: 8,
  },
  scanningText: {
    color: '#FFFFFF',
    fontSize: 14,
  },
  objectBox: {
    position: 'absolute',
    borderWidth: 2,
    borderColor: '#2563EB',
    borderRadius: 4,
  },
  objectLabel: {
    position: 'absolute',
    top: -1,
    left: -1,
    right: -1,
    backgroundColor: '#2563EB',
    borderTopLeftRadius: 4,
    borderTopRightRadius: 4,
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
  objectLabelText: {
    color: '#FFFFFF',
    fontSize: 12,
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
  sosButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    backgroundColor: '#DC2626',
    borderRadius: 16,
    marginBottom: 24,
    gap: 8,
  },
  sosButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  recentDetections: {
    marginBottom: 24,
  },
  recentDetectionsTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000000',
    marginBottom: 12,
  },
  detectionList: {
    gap: 8,
  },
  detectionItem: {
    padding: 12,
    backgroundColor: '#F9FAFB',
    borderRadius: 12,
  },
  detectionItemText: {
    color: '#000000',
    fontSize: 14,
  },
});
