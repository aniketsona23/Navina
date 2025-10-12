import React, { useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet, ScrollView, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Screen } from '../types/navigation';

interface HistoryScreenProps {
  onNavigate: (screen: Screen) => void;
}

interface HistoryItem {
  id: string;
  type: 'visual' | 'hearing' | 'navigation';
  title: string;
  description: string;
  timestamp: string;
  duration?: string;
}

export function HistoryScreen({ onNavigate }: HistoryScreenProps) {
  const [swipedItem, setSwipedItem] = useState<string | null>(null);
  const [activeFilter, setActiveFilter] = useState<'all' | 'visual' | 'hearing' | 'navigation'>('all');

  const historyItems: HistoryItem[] = [
    {
      id: '1',
      type: 'visual',
      title: 'Object Detection Session',
      description: 'Detected 5 objects: chair, table, door, window, lamp',
      timestamp: '2 hours ago',
      duration: '3 min'
    },
    {
      id: '2',
      type: 'hearing',
      title: 'Meeting Transcription',
      description: 'Transcribed conversation with Sarah and John',
      timestamp: '4 hours ago',
      duration: '15 min'
    },
    {
      id: '3',
      type: 'navigation',
      title: 'Route to Room 205',
      description: 'Successfully navigated to meeting room',
      timestamp: 'Yesterday',
      duration: '8 min'
    },
    {
      id: '4',
      type: 'visual',
      title: 'Text Reading Session',
      description: 'Read menu at restaurant',
      timestamp: 'Yesterday',
      duration: '2 min'
    },
    {
      id: '5',
      type: 'hearing',
      title: 'Sound Alert Log',
      description: 'Detected doorbell and phone notifications',
      timestamp: '2 days ago',
      duration: '1 hour'
    }
  ];

  const getIcon = (type: string) => {
    switch (type) {
      case 'visual': return { icon: 'eye-outline' as keyof typeof Ionicons.glyphMap, color: '#2563EB', bg: '#EFF6FF' };
      case 'hearing': return { icon: 'ear-outline' as keyof typeof Ionicons.glyphMap, color: '#EA580C', bg: '#FFF7ED' };
      case 'navigation': return { icon: 'location-outline' as keyof typeof Ionicons.glyphMap, color: '#16A34A', bg: '#F0FDF4' };
      default: return { icon: 'eye-outline' as keyof typeof Ionicons.glyphMap, color: '#6B7280', bg: '#F9FAFB' };
    }
  };

  const handleSwipe = (itemId: string) => {
    setSwipedItem(swipedItem === itemId ? null : itemId);
  };

  const handleDelete = (itemId: string) => {
    Alert.alert(
      'Delete Item',
      'Are you sure you want to delete this history item?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Delete', style: 'destructive', onPress: () => setSwipedItem(null) }
      ]
    );
  };

  const handleReplay = (itemId: string) => {
    // Handle replay action
    setSwipedItem(null);
  };

  const handleShare = (itemId: string) => {
    // Handle share action
    setSwipedItem(null);
  };

  const handleClearAll = () => {
    Alert.alert(
      'Clear All History',
      'Are you sure you want to clear all history items?',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Clear All', style: 'destructive' }
      ]
    );
  };

  // Filter history items based on active filter
  const filteredHistoryItems = historyItems.filter(item => {
    if (activeFilter === 'all') return true;
    return item.type === activeFilter;
  });

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>History</Text>
        <TouchableOpacity onPress={handleClearAll} activeOpacity={0.7}>
          <Text style={styles.clearAllText}>Clear All</Text>
        </TouchableOpacity>
      </View>

      {/* Filter Tabs */}
      <View style={styles.filterContainer}>
        <TouchableOpacity 
          onPress={() => setActiveFilter('all')}
          style={[styles.filterTab, activeFilter === 'all' && styles.activeFilterTab]}
          activeOpacity={0.7}
        >
          <Text style={[styles.filterTabText, activeFilter === 'all' && styles.activeFilterTabText]}>
            All
          </Text>
        </TouchableOpacity>
        <TouchableOpacity 
          onPress={() => setActiveFilter('visual')}
          style={[styles.filterTab, activeFilter === 'visual' && styles.activeFilterTab]}
          activeOpacity={0.7}
        >
          <Text style={[styles.filterTabText, activeFilter === 'visual' && styles.activeFilterTabText]}>
            Visual
          </Text>
        </TouchableOpacity>
        <TouchableOpacity 
          onPress={() => setActiveFilter('hearing')}
          style={[styles.filterTab, activeFilter === 'hearing' && styles.activeFilterTab]}
          activeOpacity={0.7}
        >
          <Text style={[styles.filterTabText, activeFilter === 'hearing' && styles.activeFilterTabText]}>
            Hearing
          </Text>
        </TouchableOpacity>
        <TouchableOpacity 
          onPress={() => setActiveFilter('navigation')}
          style={[styles.filterTab, activeFilter === 'navigation' && styles.activeFilterTab]}
          activeOpacity={0.7}
        >
          <Text style={[styles.filterTabText, activeFilter === 'navigation' && styles.activeFilterTabText]}>
            Navigation
          </Text>
        </TouchableOpacity>
      </View>

      {/* History List */}
      <View style={styles.historyList}>
        {filteredHistoryItems.length === 0 ? (
          <View style={styles.emptyState}>
            <Text style={styles.emptyStateText}>
              No {activeFilter === 'all' ? '' : activeFilter + ' '}history items found
            </Text>
          </View>
        ) : (
          filteredHistoryItems.map((item) => {
            const iconData = getIcon(item.type);
            const IconComponent = iconData.icon;
            const isSwipeActive = swipedItem === item.id;

            return (
              <View key={item.id} style={styles.historyItemContainer}>
                {/* Swipe Actions Background */}
                {isSwipeActive && (
                  <View style={styles.swipeActions}>
                    <TouchableOpacity
                      onPress={() => handleDelete(item.id)}
                      style={styles.swipeActionDelete}
                      activeOpacity={0.8}
                    >
                      <Ionicons name="trash-outline" size={20} color="#FFFFFF" />
                    </TouchableOpacity>
                    <TouchableOpacity
                      onPress={() => handleReplay(item.id)}
                      style={styles.swipeActionReplay}
                      activeOpacity={0.8}
                    >
                      <Ionicons name="refresh-outline" size={20} color="#FFFFFF" />
                    </TouchableOpacity>
                    <TouchableOpacity
                      onPress={() => handleShare(item.id)}
                      style={styles.swipeActionShare}
                      activeOpacity={0.8}
                    >
                      <Ionicons name="share-outline" size={20} color="#FFFFFF" />
                    </TouchableOpacity>
                  </View>
                )}

                {/* Main Card */}
                <TouchableOpacity
                  style={[styles.historyItem, isSwipeActive && styles.swipedItem]}
                  onPress={() => handleSwipe(item.id)}
                  activeOpacity={0.7}
                >
                  <View style={styles.historyItemContent}>
                    <View style={[styles.historyIcon, { backgroundColor: iconData.bg }]}>
                      <Ionicons name={iconData.icon} size={20} color={iconData.color} />
                    </View>
                    
                    <View style={styles.historyItemInfo}>
                      <View style={styles.historyItemHeader}>
                        <Text style={styles.historyItemTitle} numberOfLines={1}>
                          {item.title}
                        </Text>
                        <View style={styles.historyItemDuration}>
                          <Ionicons name="time-outline" size={12} color="#6B7280" />
                          <Text style={styles.durationText}>{item.duration}</Text>
                        </View>
                      </View>
                      
                      <Text style={styles.historyItemDescription} numberOfLines={2}>
                        {item.description}
                      </Text>
                      
                      <Text style={styles.historyItemTimestamp}>{item.timestamp}</Text>
                    </View>
                  </View>
                </TouchableOpacity>
              </View>
            );
          })
        )}
      </View>

      {/* Usage Statistics */}
      <View style={styles.statsContainer}>
        <Text style={styles.statsTitle}>This Week</Text>
        <View style={styles.statsGrid}>
          <View style={styles.statItem}>
            <View style={styles.statIcon}>
              <Ionicons name="eye-outline" size={16} color="#2563EB" />
            </View>
            <Text style={styles.statNumber}>12</Text>
            <Text style={styles.statLabel}>Visual</Text>
          </View>
          
          <View style={styles.statItem}>
            <View style={[styles.statIcon, styles.statIconOrange]}>
              <Ionicons name="ear-outline" size={16} color="#EA580C" />
            </View>
            <Text style={styles.statNumber}>8</Text>
            <Text style={styles.statLabel}>Hearing</Text>
          </View>
          
          <View style={styles.statItem}>
            <View style={[styles.statIcon, styles.statIconGreen]}>
              <Ionicons name="location-outline" size={16} color="#16A34A" />
            </View>
            <Text style={styles.statNumber}>5</Text>
            <Text style={styles.statLabel}>Navigation</Text>
          </View>
        </View>
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
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 24,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000000',
  },
  clearAllText: {
    fontSize: 16,
    color: '#6B7280',
    fontWeight: '500',
  },
  filterContainer: {
    flexDirection: 'row',
    backgroundColor: '#F3F4F6',
    borderRadius: 12,
    padding: 4,
    marginBottom: 24,
  },
  filterTab: {
    flex: 1,
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 8,
    alignItems: 'center',
  },
  activeFilterTab: {
    backgroundColor: '#FFFFFF',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  filterTabText: {
    fontSize: 14,
    color: '#6B7280',
    fontWeight: '500',
  },
  activeFilterTabText: {
    color: '#000000',
  },
  historyList: {
    marginBottom: 24,
  },
  emptyState: {
    alignItems: 'center',
    paddingVertical: 32,
  },
  emptyStateText: {
    fontSize: 16,
    color: '#6B7280',
  },
  historyItemContainer: {
    position: 'relative',
    marginBottom: 12,
    overflow: 'hidden',
    borderRadius: 12,
  },
  swipeActions: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    flexDirection: 'row',
    zIndex: 1,
  },
  swipeActionDelete: {
    flex: 1,
    backgroundColor: '#DC2626',
    alignItems: 'center',
    justifyContent: 'center',
  },
  swipeActionReplay: {
    flex: 1,
    backgroundColor: '#2563EB',
    alignItems: 'center',
    justifyContent: 'center',
  },
  swipeActionShare: {
    flex: 1,
    backgroundColor: '#2563EB',
    alignItems: 'center',
    justifyContent: 'center',
  },
  historyItem: {
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 12,
    padding: 16,
  },
  swipedItem: {
    transform: [{ translateX: -300 }],
  },
  historyItemContent: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 12,
  },
  historyIcon: {
    width: 40,
    height: 40,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  historyItemInfo: {
    flex: 1,
  },
  historyItemHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
    marginBottom: 4,
  },
  historyItemTitle: {
    fontSize: 14,
    color: '#000000',
    fontWeight: '600',
    flex: 1,
  },
  historyItemDuration: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    marginLeft: 8,
  },
  durationText: {
    fontSize: 12,
    color: '#6B7280',
  },
  historyItemDescription: {
    fontSize: 12,
    color: '#6B7280',
    lineHeight: 16,
    marginBottom: 8,
  },
  historyItemTimestamp: {
    fontSize: 12,
    color: '#9CA3AF',
  },
  statsContainer: {
    backgroundColor: '#F9FAFB',
    borderRadius: 12,
    padding: 16,
    marginBottom: 24,
  },
  statsTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000000',
    marginBottom: 12,
  },
  statsGrid: {
    flexDirection: 'row',
    gap: 16,
  },
  statItem: {
    flex: 1,
    alignItems: 'center',
  },
  statIcon: {
    width: 32,
    height: 32,
    backgroundColor: '#EFF6FF',
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 4,
  },
  statIconOrange: {
    backgroundColor: '#FFF7ED',
  },
  statIconGreen: {
    backgroundColor: '#F0FDF4',
  },
  statNumber: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000000',
    marginBottom: 2,
  },
  statLabel: {
    fontSize: 12,
    color: '#6B7280',
  },
});
