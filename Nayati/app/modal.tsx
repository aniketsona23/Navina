import { useLocalSearchParams, useSearchParams, router } from 'expo-router';
import { StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { VisualAssistScreen } from '@/components/VisualAssistScreenOptimized';
import { HearingAssistScreen } from '@/components/HearingAssistScreen';
import { MobilityAssistScreen } from '@/components/MobilityAssistScreen';

export default function ModalScreen() {
  const { screen } = useLocalSearchParams<{ screen: string }>();
  const searchParams = useSearchParams();

  // Debug logging
  console.log('ModalScreen rendered with screen:', screen);
  console.log('Screen type:', typeof screen);
  console.log('Screen length:', screen?.length);
  console.log('All params:', useLocalSearchParams());
  console.log('Search params:', searchParams);
  console.log('Search params screen:', searchParams.get('screen'));

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

  const renderScreen = () => {
    // Try to get screen from both sources
    const screenParam = screen || searchParams.get('screen');
    console.log('Rendering screen for:', screenParam);
    
    // Handle undefined or empty screen parameter
    if (!screenParam || screenParam === '') {
      console.log('Screen parameter is empty or undefined');
      return (
        <View style={styles.errorContainer}>
          <Ionicons name="alert-circle-outline" size={48} color="#6B7280" />
          <Text style={styles.errorTitle}>No Screen Specified</Text>
          <Text style={styles.errorMessage}>
            No screen parameter was provided. Please try again.
          </Text>
          <TouchableOpacity
            onPress={() => router.back()}
            style={styles.backButton}
          >
            <Text style={styles.backButtonText}>← Back to Home</Text>
          </TouchableOpacity>
        </View>
      );
    }
    
    switch (screenParam) {
      case 'visual':
        console.log('Rendering VisualAssistScreen');
        return <VisualAssistScreen onNavigate={handleNavigate} />;
      case 'hearing':
        console.log('Rendering HearingAssistScreen');
        return <HearingAssistScreen onNavigate={handleNavigate} />;
      case 'mobility':
        console.log('Rendering MobilityAssistScreen');
        return <MobilityAssistScreen onNavigate={handleNavigate} />;
      default:
        console.log('Screen not found, showing error');
        return (
          <View style={styles.errorContainer}>
            <Ionicons name="alert-circle-outline" size={48} color="#6B7280" />
            <Text style={styles.errorTitle}>Screen Not Found</Text>
            <Text style={styles.errorMessage}>
              The requested screen &quot;{screenParam}&quot; could not be found.
            </Text>
            <TouchableOpacity
              onPress={() => router.back()}
              style={styles.backButton}
            >
              <Text style={styles.backButtonText}>← Back to Home</Text>
            </TouchableOpacity>
          </View>
        );
    }
  };

  return (
    <View style={styles.container}>
      {renderScreen()}
      <TouchableOpacity
        onPress={() => router.back()}
        style={styles.floatingBackButton}
        activeOpacity={0.8}
      >
        <Ionicons name="arrow-back-outline" size={20} color="#FFFFFF" />
        <Text style={styles.floatingBackButtonText}>Back</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  errorTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000000',
    marginTop: 16,
    marginBottom: 8,
  },
  errorMessage: {
    fontSize: 16,
    color: '#6B7280',
    textAlign: 'center',
    marginBottom: 24,
  },
  backButton: {
    backgroundColor: '#2563EB',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  backButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
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
  floatingBackButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '600',
  },
});
