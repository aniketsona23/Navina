import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/index.dart';
import '../constants/app_constants.dart';

/// History screen displaying past assistance sessions
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.defaultAnimation,
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: -300.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize sample data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HistoryProvider>(context, listen: false);
      if (provider.historyItems.isEmpty) {
        provider.initializeSampleData();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSwipe(String itemId) {
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    if (provider.swipedItemId == itemId) {
      provider.setSwipedItem(null);
      _animationController.reverse();
    } else {
      provider.setSwipedItem(itemId);
      _animationController.forward();
    }
  }

  void _handleDelete(String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this history item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final provider = Provider.of<HistoryProvider>(context, listen: false);
              provider.removeHistoryItem(itemId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleReplay(String itemId) {
    // Handle replay action
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    provider.setSwipedItem(null);
    _animationController.reverse();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Replay functionality coming soon!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _handleShare(String itemId) {
    // Handle share action
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    provider.setSwipedItem(null);
    _animationController.reverse();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _handleClearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text('Are you sure you want to clear all history items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final provider = Provider.of<HistoryProvider>(context, listen: false);
              provider.clearAllHistory();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppConstants.historyTitle,
      actions: [
        TextButton(
          onPressed: _handleClearAll,
          child: const Text(
            'Clear All',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ),
      ],
      body: Consumer<HistoryProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Filter Tabs
              _buildFilterTabs(provider),
              
              // History List
              Expanded(
                child: provider.filteredHistoryItems.isEmpty
                    ? _buildEmptyState(provider.activeFilter)
                    : _buildHistoryList(provider),
              ),
              
              // Usage Statistics
              _buildStatsSection(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterTabs(HistoryProvider provider) {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'visual', 'label': 'Visual'},
      {'key': 'hearing', 'label': 'Hearing'},
      {'key': 'navigation', 'label': 'Navigation'},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: filters.map((filter) {
          final isActive = provider.activeFilter == filter['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.setActiveFilter(filter['key']!),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ] : null,
                ),
                child: Text(
                  filter['label']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.black : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(String activeFilter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ${activeFilter == 'all' ? '' : '$activeFilter '}history found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your activity history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(HistoryProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.filteredHistoryItems.length,
      itemBuilder: (context, index) {
        final item = provider.filteredHistoryItems[index];
        final isSwipeActive = provider.swipedItemId == item.id;
        
        return _buildHistoryItem(item, isSwipeActive, provider);
      },
    );
  }

  Widget _buildHistoryItem(HistoryItem item, bool isSwipeActive, HistoryProvider provider) {
    final iconData = provider.getIconData(item.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          // Swipe Actions Background
          if (isSwipeActive)
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_slideAnimation.value, 0),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Delete Action
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _handleDelete(item.id),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        // Replay Action
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _handleReplay(item.id),
                            child: Container(
                              color: AppTheme.primaryColor,
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        // Share Action
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _handleShare(item.id),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: const Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          
          // Main Card
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(isSwipeActive ? _slideAnimation.value : 0, 0),
                child: GestureDetector(
                  onTap: () => _handleSwipe(item.id),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: iconData['bg'],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            iconData['icon'],
                            color: iconData['color'],
                            size: 20,
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with title and duration
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (item.duration != null) ...[
                                    const SizedBox(width: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.duration!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // Description
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Timestamp
                              Text(
                                item.timeAgo,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(HistoryProvider provider) {
    final stats = provider.weeklyStats;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              // Visual Stats
              Expanded(
                child: _buildStatItem(
                  icon: Icons.visibility_outlined,
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                  number: stats['visual']!,
                  label: 'Visual',
                ),
              ),
              
              // Hearing Stats
              Expanded(
                child: _buildStatItem(
                  icon: Icons.hearing_outlined,
                  color: const Color(0xFFEA580C),
                  bgColor: const Color(0xFFFFF7ED),
                  number: stats['hearing']!,
                  label: 'Hearing',
                ),
              ),
              
              // Navigation Stats
              Expanded(
                child: _buildStatItem(
                  icon: Icons.location_on_outlined,
                  color: const Color(0xFF16A34A),
                  bgColor: const Color(0xFFF0FDF4),
                  number: stats['navigation']!,
                  label: 'Navigation',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required int number,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}