import React from 'react';
import { View, StyleSheet } from 'react-native';
import { HomeScreen } from '@/components/HomeScreen';
import { VisualAssistScreen } from '@/components/VisualAssistScreen';
import { HearingAssistScreen } from '@/components/HearingAssistScreen';
import { MobilityAssistScreen } from '@/components/MobilityAssistScreen';
import { useNavigation } from '@/contexts/NavigationContext';

export default function MainScreen() {
  const { currentScreen, navigate } = useNavigation();

  const renderScreen = () => {
    switch (currentScreen) {
      case 'home':
        return <HomeScreen onNavigate={navigate} />;
      case 'visual':
        return <VisualAssistScreen onNavigate={navigate} />;
      case 'hearing':
        return <HearingAssistScreen onNavigate={navigate} />;
      case 'mobility':
        return <MobilityAssistScreen onNavigate={navigate} />;
      default:
        return <HomeScreen onNavigate={navigate} />;
    }
  };

  return (
    <View style={styles.container}>
      {renderScreen()}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
});
