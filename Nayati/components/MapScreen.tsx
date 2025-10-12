import React, { useState, useMemo } from 'react';
import { View, Text, TouchableOpacity, TextInput, StyleSheet, ScrollView, Modal } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Screen } from '../types/navigation';

interface MapScreenProps {
  onNavigate: (screen: Screen) => void;
}

interface Location {
  id: string;
  name: string;
  type: 'room' | 'facility' | 'amenity' | 'emergency';
  floor: string;
  description: string;
  coordinates: { x: number; y: number };
  accessible: boolean;
  keywords: string[];
}

export function MapScreen({ onNavigate }: MapScreenProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedLocation, setSelectedLocation] = useState<Location | null>(null);
  const [recentSearches, setRecentSearches] = useState<string[]>(['Room 205', 'Restroom', 'Emergency Exit']);
  const [showSearchResults, setShowSearchResults] = useState(false);

  const locations: Location[] = [
    {
      id: '1',
      name: 'Room 101',
      type: 'room',
      floor: '1F',
      description: 'Conference Room - Seats 8 people',
      coordinates: { x: 60, y: 50 },
      accessible: true,
      keywords: ['conference', 'meeting', '101', 'room']
    },
    {
      id: '2',
      name: 'Room 102',
      type: 'room',
      floor: '1F',
      description: 'Office Space - Marketing Team',
      coordinates: { x: 160, y: 50 },
      accessible: true,
      keywords: ['office', 'marketing', '102', 'room']
    },
    {
      id: '3',
      name: 'Accessible Restroom',
      type: 'facility',
      floor: '1F',
      description: 'Ground floor, near elevator',
      coordinates: { x: 250, y: 50 },
      accessible: true,
      keywords: ['restroom', 'bathroom', 'toilet', 'accessible', 'facility']
    },
    {
      id: '4',
      name: 'Room 201',
      type: 'room',
      floor: '1F',
      description: 'Executive Meeting Room',
      coordinates: { x: 60, y: 190 },
      accessible: true,
      keywords: ['executive', 'meeting', '201', 'room']
    },
    {
      id: '5',
      name: 'Room 202',
      type: 'room',
      floor: '1F',
      description: 'Training Room - Capacity 20',
      coordinates: { x: 160, y: 190 },
      accessible: true,
      keywords: ['training', 'classroom', '202', 'room']
    },
    {
      id: '6',
      name: 'Elevator',
      type: 'facility',
      floor: '1F',
      description: 'Wheelchair accessible elevator',
      coordinates: { x: 250, y: 190 },
      accessible: true,
      keywords: ['elevator', 'lift', 'accessible', 'facility']
    },
    {
      id: '7',
      name: 'Emergency Exit',
      type: 'emergency',
      floor: '1F',
      description: '50ft north, wheelchair accessible',
      coordinates: { x: 150, y: 20 },
      accessible: true,
      keywords: ['emergency', 'exit', 'escape', 'safety']
    },
    {
      id: '8',
      name: 'Reception',
      type: 'amenity',
      floor: '1F',
      description: 'Main reception desk',
      coordinates: { x: 150, y: 120 },
      accessible: true,
      keywords: ['reception', 'front desk', 'help', 'information']
    },
    {
      id: '9',
      name: 'Cafeteria',
      type: 'amenity',
      floor: '2F',
      description: 'Food court and dining area',
      coordinates: { x: 150, y: 100 },
      accessible: true,
      keywords: ['cafeteria', 'food', 'dining', 'restaurant', 'eat']
    },
    {
      id: '10',
      name: 'Library',
      type: 'amenity',
      floor: '2F',
      description: 'Quiet study area with resources',
      coordinates: { x: 100, y: 150 },
      accessible: true,
      keywords: ['library', 'books', 'study', 'quiet', 'resources']
    }
  ];

  const filteredLocations = useMemo(() => {
    if (!searchQuery.trim()) return [];
    
    const query = searchQuery.toLowerCase();
    return locations.filter(location => 
      location.name.toLowerCase().includes(query) ||
      location.description.toLowerCase().includes(query) ||
      location.keywords.some(keyword => keyword.toLowerCase().includes(query))
    ).slice(0, 5);
  }, [searchQuery]);

  const handleSearchSelect = (location: Location) => {
    setSelectedLocation(location);
    setSearchQuery(location.name);
    setShowSearchResults(false);
    
    if (!recentSearches.includes(location.name)) {
      setRecentSearches(prev => [location.name, ...prev.slice(0, 4)]);
    }
  };

  const handleRecentSearch = (query: string) => {
    setSearchQuery(query);
    const location = locations.find(loc => loc.name === query);
    if (location) {
      setSelectedLocation(location);
    }
    setShowSearchResults(false);
  };

  const clearSearch = () => {
    setSearchQuery('');
    setSelectedLocation(null);
    setShowSearchResults(false);
  };

  const getLocationTypeIcon = (type: string) => {
    switch (type) {
      case 'room': return '🏠';
      case 'facility': return '🚻';
      case 'amenity': return '🍽️';
      case 'emergency': return '🚪';
      default: return '📍';
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity
          onPress={() => onNavigate('mobility')}
          style={styles.backButton}
          activeOpacity={0.7}
        >
          <Ionicons name="arrow-back-outline" size={24} color="#16A34A" />
        </TouchableOpacity>
        <Text style={styles.title}>Building Map</Text>
        <View style={styles.placeholder} />
      </View>

      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <View style={styles.searchInputContainer}>
          <Ionicons name="search-outline" size={20} color="#9CA3AF" style={styles.searchIcon} />
          <TextInput
            style={styles.searchInput}
            placeholder="Search rooms, facilities..."
            placeholderTextColor="#9CA3AF"
            value={searchQuery}
            onChangeText={(text) => {
              setSearchQuery(text);
              setShowSearchResults(text.length > 0);
            }}
            onFocus={() => setShowSearchResults(true)}
          />
          {searchQuery ? (
            <TouchableOpacity onPress={clearSearch} style={styles.clearButton}>
              <Ionicons name="close-outline" size={20} color="#9CA3AF" />
            </TouchableOpacity>
          ) : null}
        </View>
        
        {/* Search Results Modal */}
        <Modal
          visible={showSearchResults}
          transparent
          animationType="fade"
          onRequestClose={() => setShowSearchResults(false)}
        >
          <TouchableOpacity
            style={styles.modalOverlay}
            activeOpacity={1}
            onPress={() => setShowSearchResults(false)}
          >
            <View style={styles.searchResultsContainer}>
              {/* Search Results */}
              {filteredLocations.length > 0 && (
                <View style={styles.searchResultsSection}>
                  <Text style={styles.sectionHeader}>Search Results</Text>
                  {filteredLocations.map((location) => (
                    <TouchableOpacity
                      key={location.id}
                      onPress={() => handleSearchSelect(location)}
                      style={styles.searchResultItem}
                      activeOpacity={0.7}
                    >
                      <Text style={styles.locationIcon}>{getLocationTypeIcon(location.type)}</Text>
                      <View style={styles.searchResultContent}>
                        <View style={styles.searchResultHeader}>
                          <Text style={styles.searchResultName}>{location.name}</Text>
                          <View style={styles.floorBadge}>
                            <Text style={styles.floorText}>{location.floor}</Text>
                          </View>
                          {location.accessible && (
                            <Text style={styles.accessibleIcon}>♿</Text>
                          )}
                        </View>
                        <Text style={styles.searchResultDescription}>{location.description}</Text>
                      </View>
                    </TouchableOpacity>
                  ))}
                </View>
              )}
              
              {/* Recent Searches */}
              {!searchQuery.trim() && recentSearches.length > 0 && (
                <View style={styles.searchResultsSection}>
                  <View style={styles.sectionHeaderContainer}>
                    <Ionicons name="time-outline" size={12} color="#6B7280" />
                    <Text style={styles.sectionHeader}>Recent Searches</Text>
                  </View>
                  {recentSearches.map((search, index) => (
                    <TouchableOpacity
                      key={index}
                      onPress={() => handleRecentSearch(search)}
                      style={styles.searchResultItem}
                      activeOpacity={0.7}
                    >
                      <Ionicons name="time-outline" size={16} color="#9CA3AF" />
                      <Text style={styles.recentSearchText}>{search}</Text>
                    </TouchableOpacity>
                  ))}
                </View>
              )}
            </View>
          </TouchableOpacity>
        </Modal>
      </View>

      {/* Interactive Map */}
      <View style={styles.mapContainer}>
        <View style={styles.mapBackground}>
          {/* Map Legend */}
          <View style={styles.mapLegend}>
            <View style={styles.legendItem}>
              <View style={styles.legendDot} />
              <Text style={styles.legendText}>Your Location</Text>
            </View>
            <View style={styles.legendItem}>
              <View style={styles.legendLine} />
              <Text style={styles.legendText}>Accessible Route</Text>
            </View>
            <View style={styles.legendItem}>
              <View style={styles.legendWaypoint} />
              <Text style={styles.legendText}>Waypoint</Text>
            </View>
          </View>

          {/* Floor Selector */}
          <View style={styles.floorSelector}>
            <TouchableOpacity style={styles.floorButton}>
              <Text style={styles.floorButtonText}>2F</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.floorButton, styles.activeFloorButton]}>
              <Text style={[styles.floorButtonText, styles.activeFloorButtonText]}>1F</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.floorButton}>
              <Text style={styles.floorButtonText}>B1</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>

      {/* Selected Location Info */}
      {selectedLocation && (
        <View style={styles.selectedLocationContainer}>
          <View style={styles.selectedLocationHeader}>
            <View style={styles.selectedLocationInfo}>
              <Text style={styles.selectedLocationIcon}>{getLocationTypeIcon(selectedLocation.type)}</Text>
              <View>
                <View style={styles.selectedLocationTitleRow}>
                  <Text style={styles.selectedLocationName}>{selectedLocation.name}</Text>
                  <View style={styles.selectedLocationFloorBadge}>
                    <Text style={styles.selectedLocationFloorText}>{selectedLocation.floor}</Text>
                  </View>
                  {selectedLocation.accessible && (
                    <Text style={styles.selectedLocationAccessible}>♿</Text>
                  )}
                </View>
                <Text style={styles.selectedLocationDescription}>{selectedLocation.description}</Text>
              </View>
            </View>
            <TouchableOpacity onPress={clearSearch} style={styles.closeButton}>
              <Ionicons name="close-outline" size={20} color="#9CA3AF" />
            </TouchableOpacity>
          </View>
          
          <View style={styles.selectedLocationActions}>
            <TouchableOpacity
              onPress={() => onNavigate('mobility')}
              style={styles.navigateButton}
              activeOpacity={0.8}
            >
              <Ionicons name="navigate-outline" size={16} color="#FFFFFF" />
              <Text style={styles.navigateButtonText}>Navigate Here</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.favoriteButton} activeOpacity={0.7}>
              <Ionicons name="star-outline" size={16} color="#16A34A" />
            </TouchableOpacity>
          </View>
        </View>
      )}

      {/* Quick Actions */}
      <View style={styles.quickActions}>
        <TouchableOpacity
          onPress={() => onNavigate('mobility')}
          style={styles.quickActionButton}
          activeOpacity={0.8}
        >
          <Ionicons name="navigate-outline" size={20} color="#FFFFFF" />
          <Text style={styles.quickActionText}>Navigate</Text>
        </TouchableOpacity>
        
        <TouchableOpacity style={styles.quickActionButtonSecondary} activeOpacity={0.7}>
          <Ionicons name="location-outline" size={20} color="#16A34A" />
          <Text style={styles.quickActionTextSecondary}>Mark Point</Text>
        </TouchableOpacity>
        
        <TouchableOpacity style={styles.quickActionButtonSecondary} activeOpacity={0.7}>
          <Ionicons name="flash-outline" size={20} color="#16A34A" />
          <Text style={styles.quickActionTextSecondary}>Quick Route</Text>
        </TouchableOpacity>
      </View>

      {/* Facility Information */}
      <View style={styles.facilitiesContainer}>
        <Text style={styles.facilitiesTitle}>Nearby Facilities</Text>
        <View style={styles.facilitiesList}>
          <View style={styles.facilityItem}>
            <View style={styles.facilityInfo}>
              <Text style={styles.facilityName}>Accessible Restroom</Text>
              <Text style={styles.facilityDescription}>Ground floor, near elevator</Text>
            </View>
            <TouchableOpacity style={styles.facilityButton} activeOpacity={0.7}>
              <Text style={styles.facilityButtonText}>Go</Text>
            </TouchableOpacity>
          </View>
          
          <View style={styles.facilityItem}>
            <View style={styles.facilityInfo}>
              <Text style={styles.facilityName}>Emergency Exit</Text>
              <Text style={styles.facilityDescription}>50ft north, wheelchair accessible</Text>
            </View>
            <TouchableOpacity style={styles.facilityButton} activeOpacity={0.7}>
              <Text style={styles.facilityButtonText}>Go</Text>
            </TouchableOpacity>
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
  backButton: {
    padding: 8,
    borderRadius: 8,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000000',
  },
  placeholder: {
    width: 40,
  },
  searchContainer: {
    marginBottom: 24,
  },
  searchInputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#16A34A',
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    paddingHorizontal: 12,
  },
  searchIcon: {
    marginRight: 8,
  },
  searchInput: {
    flex: 1,
    paddingVertical: 12,
    fontSize: 16,
    color: '#000000',
  },
  clearButton: {
    padding: 4,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-start',
    paddingTop: 100,
  },
  searchResultsContainer: {
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 12,
    marginHorizontal: 24,
    maxHeight: 320,
  },
  searchResultsSection: {
    padding: 8,
  },
  sectionHeaderContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#F3F4F6',
  },
  sectionHeader: {
    fontSize: 12,
    color: '#6B7280',
    fontWeight: '600',
  },
  searchResultItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    gap: 12,
  },
  locationIcon: {
    fontSize: 18,
  },
  searchResultContent: {
    flex: 1,
  },
  searchResultHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 4,
  },
  searchResultName: {
    fontSize: 14,
    color: '#000000',
    fontWeight: '600',
    flex: 1,
  },
  floorBadge: {
    backgroundColor: '#16A34A',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 12,
  },
  floorText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '600',
  },
  accessibleIcon: {
    fontSize: 12,
    color: '#16A34A',
  },
  searchResultDescription: {
    fontSize: 12,
    color: '#6B7280',
  },
  recentSearchText: {
    fontSize: 14,
    color: '#000000',
    marginLeft: 12,
  },
  mapContainer: {
    backgroundColor: '#F3F4F6',
    borderRadius: 16,
    aspectRatio: 1,
    marginBottom: 24,
    overflow: 'hidden',
  },
  mapBackground: {
    flex: 1,
    backgroundColor: '#E5E7EB',
    position: 'relative',
  },
  mapLegend: {
    position: 'absolute',
    top: 16,
    left: 16,
    backgroundColor: '#FFFFFF',
    borderRadius: 8,
    padding: 12,
    gap: 8,
  },
  legendItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  legendDot: {
    width: 12,
    height: 12,
    backgroundColor: '#2563EB',
    borderRadius: 6,
  },
  legendLine: {
    width: 12,
    height: 4,
    backgroundColor: '#16A34A',
  },
  legendWaypoint: {
    width: 12,
    height: 12,
    backgroundColor: '#EA580C',
    borderRadius: 6,
  },
  legendText: {
    fontSize: 12,
    color: '#000000',
  },
  floorSelector: {
    position: 'absolute',
    top: 16,
    right: 16,
    backgroundColor: '#FFFFFF',
    borderRadius: 8,
    overflow: 'hidden',
  },
  floorButton: {
    paddingHorizontal: 12,
    paddingVertical: 8,
  },
  activeFloorButton: {
    backgroundColor: '#16A34A',
  },
  floorButtonText: {
    fontSize: 14,
    color: '#000000',
    fontWeight: '600',
  },
  activeFloorButtonText: {
    color: '#FFFFFF',
  },
  selectedLocationContainer: {
    backgroundColor: '#FFFFFF',
    borderWidth: 2,
    borderColor: '#16A34A',
    borderRadius: 12,
    padding: 16,
    marginBottom: 24,
    gap: 12,
  },
  selectedLocationHeader: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-between',
  },
  selectedLocationInfo: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 12,
    flex: 1,
  },
  selectedLocationIcon: {
    fontSize: 24,
  },
  selectedLocationTitleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 4,
  },
  selectedLocationName: {
    fontSize: 16,
    color: '#000000',
    fontWeight: '600',
  },
  selectedLocationFloorBadge: {
    backgroundColor: '#16A34A',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 12,
  },
  selectedLocationFloorText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '600',
  },
  selectedLocationAccessible: {
    fontSize: 12,
    color: '#16A34A',
  },
  selectedLocationDescription: {
    fontSize: 14,
    color: '#6B7280',
  },
  closeButton: {
    padding: 4,
  },
  selectedLocationActions: {
    flexDirection: 'row',
    gap: 8,
  },
  navigateButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#16A34A',
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 8,
    gap: 8,
  },
  navigateButtonText: {
    color: '#FFFFFF',
    fontSize: 14,
    fontWeight: '600',
  },
  favoriteButton: {
    padding: 8,
    backgroundColor: '#F3F4F6',
    borderRadius: 8,
  },
  quickActions: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 24,
  },
  quickActionButton: {
    flex: 1,
    backgroundColor: '#16A34A',
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    gap: 8,
  },
  quickActionText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '600',
  },
  quickActionButtonSecondary: {
    flex: 1,
    backgroundColor: '#F3F4F6',
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    gap: 8,
  },
  quickActionTextSecondary: {
    color: '#000000',
    fontSize: 12,
    fontWeight: '600',
  },
  facilitiesContainer: {
    marginBottom: 24,
  },
  facilitiesTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000000',
    marginBottom: 12,
  },
  facilitiesList: {
    gap: 8,
  },
  facilityItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: 12,
    backgroundColor: '#FFFFFF',
    borderWidth: 1,
    borderColor: '#E5E7EB',
    borderRadius: 12,
  },
  facilityInfo: {
    flex: 1,
  },
  facilityName: {
    fontSize: 14,
    color: '#000000',
    fontWeight: '600',
    marginBottom: 4,
  },
  facilityDescription: {
    fontSize: 12,
    color: '#6B7280',
  },
  facilityButton: {
    backgroundColor: '#16A34A',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 8,
  },
  facilityButtonText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '600',
  },
});
