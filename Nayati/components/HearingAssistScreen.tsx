import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Screen } from '../types/navigation';

interface HearingAssistScreenProps {
  onNavigate: (screen: Screen) => void;
}

export function HearingAssistScreen({ onNavigate }: HearingAssistScreenProps) {
  const [isListening, setIsListening] = useState(false);
  const [isMuted, setIsMuted] = useState(false);

  const transcript = [
    { speaker: 'John', text: 'Can you help me find the meeting room?', time: '2:34 PM' },
    { speaker: 'Sarah', text: 'Sure, it\'s on the second floor, room 205.', time: '2:35 PM' },
    { speaker: 'John', text: 'Thank you so much!', time: '2:35 PM' }
  ];

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>Hearing Assist</Text>
        <TouchableOpacity
          onPress={() => onNavigate('settings')}
          style={styles.settingsButton}
          activeOpacity={0.7}
        >
          <Ionicons name="settings-outline" size={24} color="#EA580C" />
        </TouchableOpacity>
      </View>

      {/* Live Transcription Controls */}
      <View style={styles.transcriptionContainer}>
        <View style={styles.transcriptionHeader}>
          <Text style={styles.transcriptionTitle}>Live Transcription</Text>
          <View style={styles.transcriptionControls}>
            <TouchableOpacity
              onPress={() => setIsMuted(!isMuted)}
              style={styles.muteButton}
              activeOpacity={0.7}
            >
              {isMuted ? <Ionicons name="volume-mute-outline" size={20} color="#EA580C" /> : <Ionicons name="volume-high-outline" size={20} color="#EA580C" />}
            </TouchableOpacity>
          </View>
        </View>

        {/* Main Listen Button */}
        <TouchableOpacity
          onPress={() => setIsListening(!isListening)}
          style={[styles.listenButton, { backgroundColor: isListening ? '#C2410C' : '#EA580C' }]}
          activeOpacity={0.8}
        >
          {isListening ? <Ionicons name="mic-off-outline" size={24} color="#FFFFFF" /> : <Ionicons name="mic-outline" size={24} color="#FFFFFF" />}
          <Text style={styles.listenButtonText}>
            {isListening ? 'Stop Listening' : 'Start Listening'}
          </Text>
        </TouchableOpacity>

        {/* Live Status */}
        {isListening && (
          <View style={styles.liveStatus}>
            <View style={styles.liveIndicator}>
              <View style={styles.liveDot} />
              <Text style={styles.liveText}>Live</Text>
            </View>
            <Text style={styles.liveDescription}>Currently listening for speech...</Text>
          </View>
        )}
      </View>

      {/* Subtitle Area */}
      <View style={styles.subtitleContainer}>
        <View style={styles.subtitleHeader}>
          <Text style={styles.subtitleTitle}>Subtitles</Text>
          <View style={styles.subtitleControls}>
            <TouchableOpacity style={styles.controlButton} activeOpacity={0.7}>
              <Ionicons name="play-outline" size={16} color="#EA580C" />
            </TouchableOpacity>
            <TouchableOpacity style={styles.controlButton} activeOpacity={0.7}>
              <Ionicons name="pause-outline" size={16} color="#EA580C" />
            </TouchableOpacity>
          </View>
        </View>
        
        <ScrollView style={styles.transcriptContainer} showsVerticalScrollIndicator={false}>
          {transcript.map((item, index) => (
            <View key={index} style={styles.transcriptItem}>
              <View style={styles.transcriptHeader}>
                <Text style={styles.speakerName}>{item.speaker}</Text>
                <Text style={styles.transcriptTime}>{item.time}</Text>
              </View>
              <Text style={styles.transcriptText}>{item.text}</Text>
            </View>
          ))}
        </ScrollView>
      </View>

      {/* Sound Alerts */}
      <View style={styles.soundAlerts}>
        <Text style={styles.soundAlertsTitle}>Sound Alerts</Text>
        <View style={styles.alertsGrid}>
          <View style={styles.alertItem}>
            <View style={styles.alertDot} />
            <Text style={styles.alertTitle}>Door Bell</Text>
            <Text style={styles.alertTime}>2 min ago</Text>
          </View>
          
          <View style={[styles.alertItem, styles.alertItemRed]}>
            <View style={[styles.alertDot, styles.alertDotRed]} />
            <Text style={styles.alertTitle}>Fire Alarm</Text>
            <Text style={styles.alertTime}>No alerts</Text>
          </View>
        </View>
      </View>

      {/* Quick Actions */}
      <View style={styles.quickActions}>
        <TouchableOpacity style={styles.quickActionButton} activeOpacity={0.7}>
          <Ionicons name="volume-high-outline" size={20} color="#EA580C" />
          <Text style={styles.quickActionText}>Amplify</Text>
        </TouchableOpacity>
        
        <TouchableOpacity style={styles.quickActionButton} activeOpacity={0.7}>
          <Ionicons name="settings-outline" size={20} color="#EA580C" />
          <Text style={styles.quickActionText}>Filters</Text>
        </TouchableOpacity>
        
        <TouchableOpacity
          onPress={() => onNavigate('history')}
          style={styles.quickActionButton}
          activeOpacity={0.7}
        >
          <Ionicons name="play-outline" size={20} color="#EA580C" />
          <Text style={styles.quickActionText}>History</Text>
        </TouchableOpacity>
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
  transcriptionContainer: {
    marginBottom: 24,
  },
  transcriptionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  transcriptionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000000',
  },
  transcriptionControls: {
    flexDirection: 'row',
    gap: 8,
  },
  muteButton: {
    padding: 8,
    borderRadius: 8,
  },
  listenButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 24,
    paddingHorizontal: 24,
    borderRadius: 16,
    gap: 12,
  },
  listenButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  liveStatus: {
    padding: 16,
    backgroundColor: 'rgba(234, 88, 12, 0.1)',
    borderWidth: 1,
    borderColor: 'rgba(234, 88, 12, 0.3)',
    borderRadius: 12,
    marginTop: 16,
  },
  liveIndicator: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 8,
  },
  liveDot: {
    width: 8,
    height: 8,
    backgroundColor: '#EA580C',
    borderRadius: 4,
  },
  liveText: {
    color: '#EA580C',
    fontSize: 14,
    fontWeight: '600',
  },
  liveDescription: {
    color: '#000000',
    fontSize: 14,
  },
  subtitleContainer: {
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 16,
    padding: 16,
    marginBottom: 24,
    minHeight: 200,
  },
  subtitleHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  subtitleTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000000',
  },
  subtitleControls: {
    flexDirection: 'row',
    gap: 8,
  },
  controlButton: {
    padding: 4,
    borderRadius: 4,
  },
  transcriptContainer: {
    maxHeight: 128,
  },
  transcriptItem: {
    borderLeftWidth: 2,
    borderLeftColor: '#EA580C',
    paddingLeft: 12,
    marginBottom: 12,
  },
  transcriptHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 4,
  },
  speakerName: {
    color: '#EA580C',
    fontSize: 14,
    fontWeight: '600',
  },
  transcriptTime: {
    color: '#6B7280',
    fontSize: 12,
  },
  transcriptText: {
    color: '#000000',
    fontSize: 14,
    lineHeight: 20,
  },
  soundAlerts: {
    marginBottom: 24,
  },
  soundAlertsTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000000',
    marginBottom: 12,
  },
  alertsGrid: {
    flexDirection: 'row',
    gap: 12,
  },
  alertItem: {
    flex: 1,
    padding: 12,
    backgroundColor: '#FEF3C7',
    borderWidth: 1,
    borderColor: '#FDE68A',
    borderRadius: 12,
  },
  alertItemRed: {
    backgroundColor: '#FEE2E2',
    borderColor: '#FECACA',
  },
  alertDot: {
    width: 8,
    height: 8,
    backgroundColor: '#F59E0B',
    borderRadius: 4,
    marginBottom: 8,
  },
  alertDotRed: {
    backgroundColor: '#EF4444',
  },
  alertTitle: {
    color: '#000000',
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 4,
  },
  alertTime: {
    color: '#6B7280',
    fontSize: 12,
  },
  quickActions: {
    flexDirection: 'row',
    gap: 12,
  },
  quickActionButton: {
    flex: 1,
    padding: 16,
    backgroundColor: '#F9FAFB',
    borderRadius: 12,
    alignItems: 'center',
    gap: 8,
  },
  quickActionText: {
    color: '#000000',
    fontSize: 12,
  },
});
