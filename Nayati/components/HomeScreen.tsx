import React from 'react';
import { View, Text, TouchableOpacity, Image, StyleSheet, ScrollView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Screen } from '../types/navigation';

interface HomeScreenProps {
  onNavigate: (screen: Screen) => void;
}

export function HomeScreen({ onNavigate }: HomeScreenProps) {
  const modes = [
    {
      id: 'visual' as Screen,
      title: 'Visual Assist',
      description: 'Object detection, text reading, and navigation guidance',
      icon: 'eye-outline' as keyof typeof Ionicons.glyphMap,
      bgColor: '#2563EB',
      textColor: '#FFFFFF'
    },
    {
      id: 'hearing' as Screen,
      title: 'Hearing Assist',
      description: 'Live transcription, sound alerts, and visual notifications',
      icon: 'ear-outline' as keyof typeof Ionicons.glyphMap,
      bgColor: '#EA580C',
      textColor: '#FFFFFF'
    },
    {
      id: 'mobility' as Screen,
      title: 'Mobility Assist',
      description: 'Accessible routes, indoor navigation, and mobility guidance',
      icon: 'location-outline' as keyof typeof Ionicons.glyphMap,
      bgColor: '#16A34A',
      textColor: '#FFFFFF'
    }
  ];

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.logoContainer}>
          <Image 
            source={require('../assets/images/icon.png')} 
            style={styles.logo}
            resizeMode="contain"
          />
        </View>
        <Text style={styles.subtitle}>Choose your assistance mode</Text>
      </View>

      {/* Mode Cards */}
      <View style={styles.modesContainer}>
        {modes.map((mode) => {
          return (
            <TouchableOpacity
              key={mode.id}
              onPress={() => onNavigate(mode.id)}
              style={[styles.modeCard, { backgroundColor: mode.bgColor }]}
              activeOpacity={0.8}
            >
              <View style={styles.modeContent}>
                <Ionicons name={mode.icon} size={32} color={mode.textColor} />
                <View style={styles.modeTextContainer}>
                  <Text style={[styles.modeTitle, { color: mode.textColor }]}>
                    {mode.title}
                  </Text>
                  <Text style={[styles.modeDescription, { color: mode.textColor, opacity: 0.9 }]}>
                    {mode.description}
                  </Text>
                </View>
              </View>
            </TouchableOpacity>
          );
        })}
      </View>

      {/* Quick Access */}
      <View style={styles.quickAccessContainer}>
        <Text style={styles.quickAccessTitle}>Quick Access</Text>
        <View style={styles.quickAccessButtons}>
          <TouchableOpacity
            onPress={() => onNavigate('history')}
            style={styles.quickAccessButton}
            activeOpacity={0.7}
          >
            <Text style={styles.quickAccessButtonText}>History</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => onNavigate('settings')}
            style={styles.quickAccessButton}
            activeOpacity={0.7}
          >
            <Text style={styles.quickAccessButtonText}>Settings</Text>
          </TouchableOpacity>
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
    alignItems: 'center',
    marginBottom: 24,
  },
  logoContainer: {
    marginBottom: 16,
  },
  logo: {
    width: 128,
    height: 128,
  },
  subtitle: {
    fontSize: 16,
    color: '#6B7280',
    textAlign: 'center',
  },
  modesContainer: {
    marginBottom: 32,
  },
  modeCard: {
    marginBottom: 16,
    padding: 24,
    borderRadius: 16,
    minHeight: 120,
    justifyContent: 'center',
  },
  modeContent: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  modeTextContainer: {
    flex: 1,
    marginLeft: 16,
  },
  modeTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 8,
  },
  modeDescription: {
    fontSize: 14,
    lineHeight: 20,
  },
  quickAccessContainer: {
    paddingTop: 16,
  },
  quickAccessTitle: {
    fontSize: 16,
    color: '#6B7280',
    textAlign: 'center',
    marginBottom: 16,
  },
  quickAccessButtons: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 16,
  },
  quickAccessButton: {
    paddingHorizontal: 24,
    paddingVertical: 12,
    backgroundColor: '#F3F4F6',
    borderRadius: 12,
  },
  quickAccessButtonText: {
    color: '#000000',
    fontSize: 16,
    fontWeight: '500',
  },
});
