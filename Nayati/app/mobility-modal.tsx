import { router } from 'expo-router';
import { StyleSheet, View, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { MobilityAssistScreen } from '@/components/MobilityAssistScreen';

export default function MobilityModalScreen() {
  const handleNavigate = (screen: string) => {
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
      default:
        break;
    }
  };

  return (
    <View style={styles.container}>
      <MobilityAssistScreen onNavigate={handleNavigate} />
      <TouchableOpacity
        onPress={() => router.back()}
        style={styles.floatingBackButton}
        activeOpacity={0.8}
      >
        <Ionicons name="arrow-back-outline" size={20} color="#FFFFFF" />
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  floatingBackButton: {
    position: 'absolute',
    top: 50,
    left: 20,
    zIndex: 1000,
    backgroundColor: 'rgba(0,0,0,0.7)',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 20,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
});
