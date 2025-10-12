import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView, Switch } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Screen } from '../types/navigation';

interface SettingsScreenProps {
  onNavigate: (screen: Screen) => void;
}

export function SettingsScreen({ onNavigate }: SettingsScreenProps) {
  const [activeTab, setActiveTab] = useState<'profile' | 'accessibility' | 'privacy'>('profile');
  const [settings, setSettings] = useState({
    visualAlerts: true,
    audioFeedback: false,
    hapticFeedback: true,
    autoTranscription: true,
    voiceAnnouncements: true,
    highContrast: false,
    largeText: false,
    locationSharing: true,
    dataCollection: false,
    emergencyContacts: true
  });

  const updateSetting = (key: string, value: boolean) => {
    setSettings(prev => ({ ...prev, [key]: value }));
  };

  const tabs = [
    { id: 'profile' as const, label: 'Profile', icon: 'person-outline' as keyof typeof Ionicons.glyphMap },
    { id: 'accessibility' as const, label: 'Accessibility', icon: 'eye-outline' as keyof typeof Ionicons.glyphMap },
    { id: 'privacy' as const, label: 'Privacy', icon: 'shield-outline' as keyof typeof Ionicons.glyphMap }
  ];

  const renderProfileTab = () => (
    <View style={styles.tabContent}>
      {/* User Profile */}
      <View style={styles.profileCard}>
        <View style={styles.profileAvatar}>
          <Ionicons name="person-outline" size={24} color="#6B7280" />
        </View>
        <View style={styles.profileInfo}>
          <Text style={styles.profileName}>John Doe</Text>
          <Text style={styles.profileEmail}>john.doe@example.com</Text>
        </View>
        <TouchableOpacity style={styles.editButton} activeOpacity={0.7}>
          <Text style={styles.editButtonText}>Edit</Text>
        </TouchableOpacity>
      </View>

      {/* Preferences */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Preferences</Text>
        
        <View style={styles.settingsList}>
          <View style={styles.settingItem}>
            <View style={styles.settingInfo}>
              <Ionicons name="notifications-outline" size={20} color="#6B7280" />
              <View style={styles.settingText}>
                <Text style={styles.settingTitle}>Notifications</Text>
                <Text style={styles.settingDescription}>Manage alert preferences</Text>
              </View>
            </View>
            <Switch
              value={settings.visualAlerts}
              onValueChange={(value) => updateSetting('visualAlerts', value)}
              trackColor={{ false: '#E5E7EB', true: '#2563EB' }}
              thumbColor={settings.visualAlerts ? '#FFFFFF' : '#FFFFFF'}
            />
          </View>

          <View style={styles.settingItem}>
            <View style={styles.settingInfo}>
              <Ionicons name="eye-outline" size={20} color="#6B7280" />
              <View style={styles.settingText}>
                <Text style={styles.settingTitle}>Audio Feedback</Text>
                <Text style={styles.settingDescription}>Voice confirmations</Text>
              </View>
            </View>
            <Switch
              value={settings.audioFeedback}
              onValueChange={(value) => updateSetting('audioFeedback', value)}
              trackColor={{ false: '#E5E7EB', true: '#2563EB' }}
              thumbColor={settings.audioFeedback ? '#FFFFFF' : '#FFFFFF'}
            />
          </View>

          <View style={styles.settingItem}>
            <View style={styles.settingInfo}>
              <Ionicons name="location-outline" size={20} color="#6B7280" />
              <View style={styles.settingText}>
                <Text style={styles.settingTitle}>Haptic Feedback</Text>
                <Text style={styles.settingDescription}>Vibration alerts</Text>
              </View>
            </View>
            <Switch
              value={settings.hapticFeedback}
              onValueChange={(value) => updateSetting('hapticFeedback', value)}
              trackColor={{ false: '#E5E7EB', true: '#2563EB' }}
              thumbColor={settings.hapticFeedback ? '#FFFFFF' : '#FFFFFF'}
            />
          </View>
        </View>
      </View>
    </View>
  );

  const renderAccessibilityTab = () => (
    <View style={styles.tabContent}>
      {/* Visual Accessibility */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Visual Accessibility</Text>
        
        <View style={styles.settingsList}>
          <View style={styles.settingItem}>
            <View style={styles.settingText}>
              <Text style={styles.settingTitle}>High Contrast Mode</Text>
              <Text style={styles.settingDescription}>Enhanced visibility for low vision</Text>
            </View>
            <Switch
              value={settings.highContrast}
              onValueChange={(value) => updateSetting('highContrast', value)}
              trackColor={{ false: '#E5E7EB', true: '#2563EB' }}
              thumbColor={settings.highContrast ? '#FFFFFF' : '#FFFFFF'}
            />
          </View>

          <View style={styles.settingItem}>
            <View style={styles.settingText}>
              <Text style={styles.settingTitle}>Large Text</Text>
              <Text style={styles.settingDescription}>Increase font size throughout app</Text>
            </View>
            <Switch
              value={settings.largeText}
              onValueChange={(value) => updateSetting('largeText', value)}
              trackColor={{ false: '#E5E7EB', true: '#2563EB' }}
              thumbColor={settings.largeText ? '#FFFFFF' : '#FFFFFF'}
            />
          </View>
        </View>
      </View>

      {/* Hearing Accessibility */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Hearing Accessibility</Text>
        
        <View style={styles.settingsList}>
          <View style={styles.settingItem}>
            <View style={styles.settingText}>
              <Text style={styles.settingTitle}>Auto Transcription</Text>
              <Text style={styles.settingDescription}>Real-time speech to text</Text>
            </View>
            <Switch
              value={settings.autoTranscription}
              onValueChange={(value) => updateSetting('autoTranscription', value)}
              trackColor={{ false: '#E5E7EB', true: '#2563EB' }}
              thumbColor={settings.autoTranscription ? '#FFFFFF' : '#FFFFFF'}
            />
          </View>

          <View style={styles.settingItem}>
            <View style={styles.settingText}>
              <Text style={styles.settingTitle}>Voice Announcements</Text>
              <Text style={styles.settingDescription}>Spoken navigation instructions</Text>
            </View>
            <Switch
              value={settings.voiceAnnouncements}
              onValueChange={(value) => updateSetting('voiceAnnouncements', value)}
              trackColor={{ false: '#E5E7EB', true: '#2563EB' }}
              thumbColor={settings.voiceAnnouncements ? '#FFFFFF' : '#FFFFFF'}
            />
          </View>
        </View>
      </View>

      {/* Save Button */}
      <TouchableOpacity style={styles.saveButton} activeOpacity={0.8}>
        <Text style={styles.saveButtonText}>Save Accessibility Settings</Text>
      </TouchableOpacity>
    </View>
  );

  const renderPrivacyTab = () => (
    <View style={styles.tabContent}>
      {/* Data & Privacy */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Data & Privacy</Text>
        
        <View style={styles.settingsList}>
          <View style={styles.settingItem}>
            <View style={styles.settingText}>
              <Text style={styles.settingTitle}>Location Sharing</Text>
              <Text style={styles.settingDescription}>Share location for navigation assistance</Text>
            </View>
            <Switch
              value={settings.locationSharing}
              onValueChange={(value) => updateSetting('locationSharing', value)}
              trackColor={{ false: '#E5E7EB', true: '#2563EB' }}
              thumbColor={settings.locationSharing ? '#FFFFFF' : '#FFFFFF'}
            />
          </View>

          <View style={styles.settingItem}>
            <View style={styles.settingText}>
              <Text style={styles.settingTitle}>Data Collection</Text>
              <Text style={styles.settingDescription}>Help improve app with usage data</Text>
            </View>
            <Switch
              value={settings.dataCollection}
              onValueChange={(value) => updateSetting('dataCollection', value)}
              trackColor={{ false: '#E5E7EB', true: '#2563EB' }}
              thumbColor={settings.dataCollection ? '#FFFFFF' : '#FFFFFF'}
            />
          </View>

          <View style={styles.settingItem}>
            <View style={styles.settingText}>
              <Text style={styles.settingTitle}>Emergency Contacts</Text>
              <Text style={styles.settingDescription}>Allow emergency contact access</Text>
            </View>
            <Switch
              value={settings.emergencyContacts}
              onValueChange={(value) => updateSetting('emergencyContacts', value)}
              trackColor={{ false: '#E5E7EB', true: '#2563EB' }}
              thumbColor={settings.emergencyContacts ? '#FFFFFF' : '#FFFFFF'}
            />
          </View>
        </View>
      </View>

      {/* Privacy Notice */}
      <View style={styles.privacyNotice}>
        <Text style={styles.privacyNoticeTitle}>Privacy Notice</Text>
        <Text style={styles.privacyNoticeText}>
          Navina is designed with privacy in mind. We do not collect personal identifiable information (PII) or sensitive data. All processing happens locally on your device when possible.
        </Text>
      </View>
    </View>
  );

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {/* Header */}
      <Text style={styles.title}>Settings</Text>

      {/* Tabs */}
      <View style={styles.tabsContainer}>
        {tabs.map((tab) => {
          return (
            <TouchableOpacity
              key={tab.id}
              onPress={() => setActiveTab(tab.id)}
              style={[styles.tab, activeTab === tab.id && styles.activeTab]}
              activeOpacity={0.7}
            >
              <Ionicons name={tab.icon} size={16} color={activeTab === tab.id ? '#2563EB' : '#6B7280'} />
              <Text style={[styles.tabText, activeTab === tab.id && styles.activeTabText]}>
                {tab.label}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>

      {/* Tab Content */}
      <View style={styles.tabContentContainer}>
        {activeTab === 'profile' && renderProfileTab()}
        {activeTab === 'accessibility' && renderAccessibilityTab()}
        {activeTab === 'privacy' && renderPrivacyTab()}
      </View>

      {/* Help & Support */}
      <View style={styles.helpSection}>
        <TouchableOpacity style={styles.helpItem} activeOpacity={0.7}>
          <View style={styles.helpItemContent}>
            <Ionicons name="help-circle-outline" size={20} color="#6B7280" />
            <Text style={styles.helpItemText}>Help & Support</Text>
          </View>
          <Text style={styles.helpItemAction}>Open</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.helpItem} activeOpacity={0.7}>
          <View style={styles.helpItemContent}>
            <Ionicons name="log-out-outline" size={20} color="#DC2626" />
            <Text style={[styles.helpItemText, styles.helpItemTextRed]}>Sign Out</Text>
          </View>
          <Text style={styles.helpItemActionRed}>Sign Out</Text>
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
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000000',
    marginBottom: 24,
  },
  tabsContainer: {
    flexDirection: 'row',
    backgroundColor: '#F3F4F6',
    borderRadius: 12,
    padding: 4,
    marginBottom: 24,
  },
  tab: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderRadius: 8,
    gap: 8,
  },
  activeTab: {
    backgroundColor: '#FFFFFF',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
    borderBottomWidth: 2,
    borderBottomColor: '#2563EB',
  },
  tabText: {
    fontSize: 14,
    color: '#6B7280',
    fontWeight: '500',
  },
  activeTabText: {
    color: '#2563EB',
  },
  tabContentContainer: {
    marginBottom: 24,
  },
  tabContent: {
    gap: 24,
  },
  profileCard: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 12,
    gap: 16,
  },
  profileAvatar: {
    width: 64,
    height: 64,
    backgroundColor: '#D1D5DB',
    borderRadius: 32,
    alignItems: 'center',
    justifyContent: 'center',
  },
  profileInfo: {
    flex: 1,
  },
  profileName: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000000',
    marginBottom: 4,
  },
  profileEmail: {
    fontSize: 14,
    color: '#6B7280',
  },
  editButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: '#F3F4F6',
    borderRadius: 8,
  },
  editButtonText: {
    fontSize: 14,
    color: '#000000',
    fontWeight: '500',
  },
  section: {
    gap: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000000',
  },
  settingsList: {
    gap: 12,
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 12,
  },
  settingInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    flex: 1,
  },
  settingText: {
    flex: 1,
  },
  settingTitle: {
    fontSize: 14,
    color: '#000000',
    fontWeight: '500',
    marginBottom: 2,
  },
  settingDescription: {
    fontSize: 12,
    color: '#6B7280',
  },
  saveButton: {
    paddingVertical: 12,
    paddingHorizontal: 24,
    backgroundColor: '#374151',
    borderRadius: 12,
    alignItems: 'center',
  },
  saveButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  privacyNotice: {
    padding: 16,
    backgroundColor: '#EFF6FF',
    borderWidth: 1,
    borderColor: '#BFDBFE',
    borderRadius: 12,
  },
  privacyNoticeTitle: {
    fontSize: 14,
    color: '#000000',
    fontWeight: '600',
    marginBottom: 8,
  },
  privacyNoticeText: {
    fontSize: 12,
    color: '#6B7280',
    lineHeight: 16,
  },
  helpSection: {
    gap: 12,
  },
  helpItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 16,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 12,
  },
  helpItemContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  helpItemText: {
    fontSize: 14,
    color: '#000000',
    fontWeight: '500',
  },
  helpItemTextRed: {
    color: '#DC2626',
  },
  helpItemAction: {
    fontSize: 14,
    color: '#2563EB',
    fontWeight: '500',
  },
  helpItemActionRed: {
    fontSize: 14,
    color: '#DC2626',
    fontWeight: '500',
  },
});
