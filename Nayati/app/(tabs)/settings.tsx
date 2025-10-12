import React from 'react';
import { View, StyleSheet } from 'react-native';
import { SettingsScreen } from '@/components/SettingsScreen';
import { useNavigation } from '@/contexts/NavigationContext';

export default function SettingsTab() {
  const { navigate } = useNavigation();

  return (
    <View style={styles.container}>
      <SettingsScreen onNavigate={navigate} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
});
