import React, { useState } from 'react';
import { View, StyleSheet, StatusBar, SafeAreaView } from 'react-native';
import { HomeScreen } from './components/HomeScreen';
import { VisualAssistScreen } from './components/VisualAssistScreen';
import { HearingAssistScreen } from './components/HearingAssistScreen';
import { MobilityAssistScreen } from './components/MobilityAssistScreen';
import { MapScreen } from './components/MapScreen';
import { HistoryScreen } from './components/HistoryScreen';
import { SettingsScreen } from './components/SettingsScreen';
import { BottomNavigation } from './components/BottomNavigation';
import { Screen } from './types/navigation';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('home');

  const renderScreen = () => {
    switch (currentScreen) {
      case 'home':
        return <HomeScreen onNavigate={setCurrentScreen} />;
      case 'visual':
        return <VisualAssistScreen onNavigate={setCurrentScreen} />;
      case 'hearing':
        return <HearingAssistScreen onNavigate={setCurrentScreen} />;
      case 'mobility':
        return <MobilityAssistScreen onNavigate={setCurrentScreen} />;
      case 'map':
        return <MapScreen onNavigate={setCurrentScreen} />;
      case 'history':
        return <HistoryScreen onNavigate={setCurrentScreen} />;
      case 'settings':
        return <SettingsScreen onNavigate={setCurrentScreen} />;
      default:
        return <HomeScreen onNavigate={setCurrentScreen} />;
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#FFFFFF" />
      
      {/* Main Content */}
      <View style={styles.content}>
        {renderScreen()}
      </View>

      {/* Bottom Navigation - Fixed at bottom */}
      <View style={styles.bottomNavigation}>
        <BottomNavigation currentScreen={currentScreen} onNavigate={setCurrentScreen} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  content: {
    flex: 1,
  },
  bottomNavigation: {
    backgroundColor: '#FFFFFF',
    borderTopWidth: 1,
    borderTopColor: '#E5E7EB',
  },
});
