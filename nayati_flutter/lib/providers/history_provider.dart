import 'package:flutter/material.dart';

class HistoryItem {
  final String id;
  final String type; // 'visual', 'hearing', 'navigation'
  final String title;
  final String description;
  final DateTime timestamp;
  final String? duration;
  final Map<String, dynamic>? metadata;

  HistoryItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.duration,
    this.metadata,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'duration': duration,
      'metadata': metadata,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      duration: json['duration'],
      metadata: json['metadata'],
    );
  }
}

class HistoryProvider extends ChangeNotifier {
  List<HistoryItem> _historyItems = [];
  String _activeFilter = 'all';
  String? _swipedItemId;

  // Getters
  List<HistoryItem> get historyItems => _historyItems;
  String get activeFilter => _activeFilter;
  String? get swipedItemId => _swipedItemId;

  // Filtered items based on active filter
  List<HistoryItem> get filteredHistoryItems {
    if (_activeFilter == 'all') {
      return _historyItems;
    }
    return _historyItems.where((item) => item.type == _activeFilter).toList();
  }

  // Statistics
  Map<String, int> get weeklyStats {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final visualCount = _historyItems.where((item) => 
      item.type == 'visual' && item.timestamp.isAfter(weekAgo)
    ).length;
    
    final hearingCount = _historyItems.where((item) => 
      item.type == 'hearing' && item.timestamp.isAfter(weekAgo)
    ).length;
    
    final navigationCount = _historyItems.where((item) => 
      item.type == 'navigation' && item.timestamp.isAfter(weekAgo)
    ).length;

    return {
      'visual': visualCount,
      'hearing': hearingCount,
      'navigation': navigationCount,
    };
  }

  // Initialize with sample data
  void initializeSampleData() {
    final now = DateTime.now();
    
    _historyItems = [
      HistoryItem(
        id: '1',
        type: 'visual',
        title: 'Object Detection Session',
        description: 'Detected 5 objects: chair, table, door, window, lamp',
        timestamp: now.subtract(const Duration(hours: 2)),
        duration: '3 min',
        metadata: {'objects_detected': 5, 'confidence_avg': 0.85},
      ),
      HistoryItem(
        id: '2',
        type: 'hearing',
        title: 'Meeting Transcription',
        description: 'Transcribed conversation with Sarah and John',
        timestamp: now.subtract(const Duration(hours: 4)),
        duration: '15 min',
        metadata: {'words_transcribed': 245, 'confidence_avg': 0.92},
      ),
      HistoryItem(
        id: '3',
        type: 'navigation',
        title: 'Route to Room 205',
        description: 'Successfully navigated to meeting room',
        timestamp: now.subtract(const Duration(days: 1)),
        duration: '8 min',
        metadata: {'steps_completed': 12, 'distance': '150m'},
      ),
      HistoryItem(
        id: '4',
        type: 'visual',
        title: 'Text Reading Session',
        description: 'Read menu at restaurant',
        timestamp: now.subtract(const Duration(days: 1)),
        duration: '2 min',
        metadata: {'text_length': 156, 'accuracy': 0.88},
      ),
      HistoryItem(
        id: '5',
        type: 'hearing',
        title: 'Sound Alert Log',
        description: 'Detected doorbell and phone notifications',
        timestamp: now.subtract(const Duration(days: 2)),
        duration: '1 hour',
        metadata: {'alerts_detected': 8, 'types': ['doorbell', 'phone']},
      ),
      HistoryItem(
        id: '6',
        type: 'visual',
        title: 'Document Scanning',
        description: 'Scanned and read important document',
        timestamp: now.subtract(const Duration(days: 3)),
        duration: '5 min',
        metadata: {'pages_scanned': 3, 'text_extracted': 1200},
      ),
      HistoryItem(
        id: '7',
        type: 'navigation',
        title: 'Indoor Navigation',
        description: 'Navigated through office building',
        timestamp: now.subtract(const Duration(days: 4)),
        duration: '12 min',
        metadata: {'floors_visited': 3, 'rooms_found': 2},
      ),
    ];
    
    notifyListeners();
  }

  // Add new history item
  void addHistoryItem(HistoryItem item) {
    _historyItems.insert(0, item); // Add to beginning
    notifyListeners();
  }

  // Remove history item
  void removeHistoryItem(String id) {
    _historyItems.removeWhere((item) => item.id == id);
    if (_swipedItemId == id) {
      _swipedItemId = null;
    }
    notifyListeners();
  }

  // Clear all history
  void clearAllHistory() {
    _historyItems.clear();
    _swipedItemId = null;
    notifyListeners();
  }

  // Set active filter
  void setActiveFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  // Set swiped item
  void setSwipedItem(String? id) {
    _swipedItemId = id;
    notifyListeners();
  }

  // Get icon data for history type
  Map<String, dynamic> getIconData(String type) {
    switch (type) {
      case 'visual':
        return {
          'icon': Icons.visibility_outlined,
          'color': const Color(0xFF2563EB),
          'bg': const Color(0xFFEFF6FF),
        };
      case 'hearing':
        return {
          'icon': Icons.hearing_outlined,
          'color': const Color(0xFFEA580C),
          'bg': const Color(0xFFFFF7ED),
        };
      case 'navigation':
        return {
          'icon': Icons.location_on_outlined,
          'color': const Color(0xFF16A34A),
          'bg': const Color(0xFFF0FDF4),
        };
      default:
        return {
          'icon': Icons.history,
          'color': const Color(0xFF6B7280),
          'bg': const Color(0xFFF9FAFB),
        };
    }
  }
}

