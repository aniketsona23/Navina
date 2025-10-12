import React from 'react';
import { View, StyleSheet } from 'react-native';
import { HistoryScreen } from '@/components/HistoryScreen';
import { useNavigation } from '@/contexts/NavigationContext';

export default function HistoryTab() {
  const { navigate } = useNavigation();

  return (
    <View style={styles.container}>
      <HistoryScreen onNavigate={navigate} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
});
