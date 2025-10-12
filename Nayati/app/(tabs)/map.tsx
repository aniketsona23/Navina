import React from 'react';
import { View, StyleSheet } from 'react-native';
import { MapScreen } from '@/components/MapScreen';
import { useNavigation } from '@/contexts/NavigationContext';

export default function MapTab() {
  const { navigate } = useNavigation();

  return (
    <View style={styles.container}>
      <MapScreen onNavigate={navigate} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
});
