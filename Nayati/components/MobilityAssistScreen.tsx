import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView, TextInput } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Screen } from '../types/navigation';

interface MobilityAssistScreenProps {
  onNavigate: (screen: Screen) => void;
}

export function MobilityAssistScreen({ onNavigate }: MobilityAssistScreenProps) {
  const [isNavigating, setIsNavigating] = useState(false);

  const navigationSteps = [
    { instruction: 'Head north towards the main entrance', distance: '50 ft', icon: 'arrow-forward-outline' as keyof typeof Ionicons.glyphMap },
    { instruction: 'Use the accessible ramp on your left', distance: '20 ft', icon: 'arrow-forward-outline' as keyof typeof Ionicons.glyphMap },
    { instruction: 'Enter through the automatic doors', distance: '10 ft', icon: 'arrow-forward-outline' as keyof typeof Ionicons.glyphMap },
    { instruction: 'Turn right at the information desk', distance: '30 ft', icon: 'arrow-forward-outline' as keyof typeof Ionicons.glyphMap }
  ];

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>Mobility Assist</Text>
        <TouchableOpacity
          onPress={() => onNavigate('settings')}
          style={styles.settingsButton}
          activeOpacity={0.7}
        >
          <Ionicons name="settings-outline" size={24} color="#16A34A" />
        </TouchableOpacity>
      </View>

      {/* Quick Destination */}
      <View style={styles.quickDestinations}>
        <Text style={styles.sectionTitle}>Quick Destinations</Text>
        <View style={styles.destinationGrid}>
          <TouchableOpacity
            onPress={() => onNavigate('map')}
            style={styles.destinationButton}
            activeOpacity={0.8}
          >
            <Ionicons name="location-outline" size={20} color="#FFFFFF" />
            <Text style={styles.destinationButtonText}>Building Map</Text>
          </TouchableOpacity>
          
          <TouchableOpacity style={styles.destinationButtonSecondary} activeOpacity={0.8}>
            <Ionicons name="navigate-outline" size={20} color="#000000" />
            <Text style={styles.destinationButtonTextSecondary}>Outdoor Nav</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Current Navigation */}
      {isNavigating ? (
        <View style={styles.navigationContainer}>
          <View style={styles.navigationHeader}>
            <Text style={styles.sectionTitle}>Active Navigation</Text>
            <View style={styles.timeRemaining}>
              <Ionicons name="time-outline" size={16} color="#16A34A" />
              <Text style={styles.timeText}>3 min remaining</Text>
            </View>
          </View>

          {/* Step-by-step directions */}
          <View style={styles.directionsContainer}>
            {navigationSteps.map((step, index) => (
              <View key={index} style={[styles.directionStep, index === 0 && styles.currentStep]}>
                <View style={[styles.stepNumber, index === 0 && styles.currentStepNumber]}>
                  <Text style={[styles.stepNumberText, index === 0 && styles.currentStepNumberText]}>
                    {index + 1}
                  </Text>
                </View>
                <View style={styles.stepContent}>
                  <Text style={[styles.stepInstruction, index === 0 && styles.currentStepInstruction]}>
                    {step.instruction}
                  </Text>
                  <Text style={styles.stepDistance}>{step.distance}</Text>
                </View>
                {index === 0 && <Ionicons name="arrow-forward-outline" size={16} color="#16A34A" />}
              </View>
            ))}
          </View>

          <TouchableOpacity
            onPress={() => setIsNavigating(false)}
            style={styles.stopButton}
            activeOpacity={0.8}
          >
            <View style={styles.stopIcon} />
            <Text style={styles.stopButtonText}>Stop Navigation</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <View style={styles.startNavigationContainer}>
          <Text style={styles.sectionTitle}>Start Indoor Navigation</Text>
          
          {/* Destination Input */}
          <View style={styles.inputContainer}>
            <TextInput
              style={styles.destinationInput}
              placeholder="Enter destination (e.g., Room 205)"
              placeholderTextColor="#9CA3AF"
            />
            
            <TouchableOpacity
              onPress={() => setIsNavigating(true)}
              style={styles.startButton}
              activeOpacity={0.8}
            >
              <Text style={styles.startButtonText}>Start Guidance</Text>
            </TouchableOpacity>
          </View>
        </View>
      )}

      {/* Accessibility Features */}
      <View style={styles.accessibilityFeatures}>
        <Text style={styles.sectionTitle}>Accessibility Features</Text>
        <View style={styles.featuresGrid}>
          <View style={styles.featureItem}>
            <View style={styles.featureDot} />
            <Text style={styles.featureTitle}>Ramp Access</Text>
            <Text style={styles.featureStatus}>Available</Text>
          </View>
          
          <View style={styles.featureItem}>
            <View style={styles.featureDot} />
            <Text style={styles.featureTitle}>Elevator</Text>
            <Text style={styles.featureStatus}>Working</Text>
          </View>
          
          <View style={[styles.featureItem, styles.featureItemYellow]}>
            <View style={[styles.featureDot, styles.featureDotYellow]} />
            <Text style={styles.featureTitle}>Auto Doors</Text>
            <Text style={styles.featureStatus}>Main entrance</Text>
          </View>
          
          <View style={[styles.featureItem, styles.featureItemBlue]}>
            <View style={[styles.featureDot, styles.featureDotBlue]} />
            <Text style={styles.featureTitle}>Restrooms</Text>
            <Text style={styles.featureStatus}>Accessible</Text>
          </View>
        </View>
      </View>

      {/* Emergency Contact */}
      <TouchableOpacity style={styles.emergencyButton} activeOpacity={0.8}>
        <Ionicons name="call-outline" size={20} color="#FFFFFF" />
        <Text style={styles.emergencyButtonText}>Emergency Assistance</Text>
      </TouchableOpacity>
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
  quickDestinations: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000000',
    marginBottom: 12,
  },
  destinationGrid: {
    flexDirection: 'row',
    gap: 12,
  },
  destinationButton: {
    flex: 1,
    padding: 16,
    backgroundColor: '#16A34A',
    borderRadius: 12,
    alignItems: 'center',
    gap: 8,
  },
  destinationButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '600',
  },
  destinationButtonSecondary: {
    flex: 1,
    padding: 16,
    backgroundColor: '#F3F4F6',
    borderRadius: 12,
    alignItems: 'center',
    gap: 8,
  },
  destinationButtonTextSecondary: {
    color: '#000000',
    fontSize: 14,
    fontWeight: '600',
  },
  navigationContainer: {
    marginBottom: 24,
  },
  navigationHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  timeRemaining: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  timeText: {
    color: '#16A34A',
    fontSize: 14,
    fontWeight: '600',
  },
  directionsContainer: {
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 16,
    padding: 16,
    marginBottom: 16,
    gap: 12,
  },
  directionStep: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    padding: 12,
    borderRadius: 12,
    gap: 12,
  },
  currentStep: {
    backgroundColor: 'rgba(22, 163, 74, 0.1)',
    borderWidth: 1,
    borderColor: 'rgba(22, 163, 74, 0.3)',
  },
  stepNumber: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: '#E5E7EB',
    alignItems: 'center',
    justifyContent: 'center',
  },
  currentStepNumber: {
    backgroundColor: '#16A34A',
  },
  stepNumberText: {
    fontSize: 12,
    color: '#6B7280',
    fontWeight: '600',
  },
  currentStepNumberText: {
    color: '#FFFFFF',
  },
  stepContent: {
    flex: 1,
  },
  stepInstruction: {
    fontSize: 14,
    color: '#6B7280',
    marginBottom: 4,
  },
  currentStepInstruction: {
    color: '#000000',
  },
  stepDistance: {
    fontSize: 12,
    color: '#6B7280',
  },
  stopButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    paddingHorizontal: 24,
    backgroundColor: '#DC2626',
    borderRadius: 12,
    gap: 8,
  },
  stopIcon: {
    width: 16,
    height: 16,
    backgroundColor: '#FFFFFF',
    borderRadius: 2,
  },
  stopButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  startNavigationContainer: {
    marginBottom: 24,
  },
  inputContainer: {
    gap: 12,
  },
  destinationInput: {
    padding: 16,
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 12,
    fontSize: 16,
    color: '#000000',
  },
  startButton: {
    paddingVertical: 16,
    paddingHorizontal: 24,
    backgroundColor: '#16A34A',
    borderRadius: 12,
    alignItems: 'center',
  },
  startButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  accessibilityFeatures: {
    marginBottom: 24,
  },
  featuresGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
  },
  featureItem: {
    width: '48%',
    padding: 12,
    backgroundColor: '#F0FDF4',
    borderWidth: 1,
    borderColor: '#BBF7D0',
    borderRadius: 12,
  },
  featureItemYellow: {
    backgroundColor: '#FFFBEB',
    borderColor: '#FDE68A',
  },
  featureItemBlue: {
    backgroundColor: '#EFF6FF',
    borderColor: '#BFDBFE',
  },
  featureDot: {
    width: 8,
    height: 8,
    backgroundColor: '#16A34A',
    borderRadius: 4,
    marginBottom: 8,
  },
  featureDotYellow: {
    backgroundColor: '#F59E0B',
  },
  featureDotBlue: {
    backgroundColor: '#3B82F6',
  },
  featureTitle: {
    color: '#000000',
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 4,
  },
  featureStatus: {
    color: '#6B7280',
    fontSize: 12,
  },
  emergencyButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    backgroundColor: '#DC2626',
    borderRadius: 12,
    gap: 8,
  },
  emergencyButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
});
