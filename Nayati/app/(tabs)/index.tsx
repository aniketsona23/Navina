import React from 'react';
import { View, StyleSheet } from 'react-native';
import { HomeScreen } from '@/components/HomeScreen';
import { router } from 'expo-router';

export default function MainScreen() {
  const navigate = (screen: string) => {
    console.log('Navigating to screen:', screen);
    switch (screen) {
      case 'settings':
        router.push('/(tabs)/settings');
        break;
      case 'history':
        router.push('/(tabs)/history');
        break;
      case 'map':
        router.push('/(tabs)/map');
        break;
      case 'visual':
        console.log('Pushing to visual modal');
        router.push('/visual-modal');
        break;
      case 'hearing':
        console.log('Pushing to hearing modal');
        router.push('/hearing-modal');
        break;
      case 'mobility':
        console.log('Pushing to mobility modal');
        router.push('/mobility-modal');
        break;
      default:
        console.log('Unknown screen:', screen);
        break;
    }
  };

  return (
    <View style={styles.container}>
      <HomeScreen onNavigate={navigate} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
});
