import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common/index.dart';
import '../constants/app_constants.dart';

/// Map screen for navigation and location services
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
    return const AppScaffold(
      title: AppConstants.mapTitle,
      body: EmptyState(
        title: 'Map Screen',
        subtitle: 'Interactive map will appear here',
        icon: Icons.map,
        color: AppTheme.textSecondary,
      ),
    );
  }
}
