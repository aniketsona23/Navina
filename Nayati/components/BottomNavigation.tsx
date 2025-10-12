import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Screen } from '../types/navigation';

interface BottomNavigationProps {
  currentScreen: Screen;
  onNavigate: (screen: Screen) => void;
}

export function BottomNavigation({ currentScreen, onNavigate }: BottomNavigationProps) {
  const navItems = [
    { id: 'home' as Screen, icon: 'home-outline' as keyof typeof Ionicons.glyphMap, label: 'Home' },
    { id: 'history' as Screen, icon: 'time-outline' as keyof typeof Ionicons.glyphMap, label: 'History' },
    { id: 'map' as Screen, icon: 'location-outline' as keyof typeof Ionicons.glyphMap, label: 'Map' },
    { id: 'settings' as Screen, icon: 'settings-outline' as keyof typeof Ionicons.glyphMap, label: 'Settings' }
  ];

  return (
    <View style={styles.container}>
      <View style={styles.navContainer}>
        {navItems.map((item) => {
          const isActive = currentScreen === item.id;
          
          return (
            <TouchableOpacity
              key={item.id}
              onPress={() => onNavigate(item.id)}
              style={[styles.navItem, isActive && styles.activeNavItem]}
              activeOpacity={0.7}
            >
              <Ionicons 
                name={item.icon}
                size={20} 
                color={isActive ? '#2563EB' : '#111827'} 
              />
              <Text style={[styles.navLabel, isActive && styles.activeNavLabel]}>
                {item.label}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#F3F4F6',
    paddingHorizontal: 16,
    paddingVertical: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 8,
  },
  navContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
  },
  navItem: {
    flexDirection: 'column',
    alignItems: 'center',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 8,
    minWidth: 48,
    minHeight: 48,
    justifyContent: 'center',
    gap: 4,
  },
  activeNavItem: {
    backgroundColor: '#EFF6FF',
  },
  navLabel: {
    fontSize: 12,
    color: '#111827',
    fontWeight: '500',
  },
  activeNavLabel: {
    color: '#2563EB',
  },
});
