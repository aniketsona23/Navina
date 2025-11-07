import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/common/index.dart';
import '../constants/app_constants.dart';

/// Main home screen displaying assistance mode options
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: AppConstants.defaultSpacing),
              _buildModeCards(context),
              const SizedBox(height: AppConstants.largeSpacing),
              _buildQuickAccess(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 128.0,
          height: 128.0,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              AppConstants.appIconPath,
              width: 128.0,
              height: 128.0,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.defaultSpacing),
        const Text(
          AppConstants.chooseModeText,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildModeCards(BuildContext context) {
    const modes = [
      {
        'id': 'visual',
        'title': AppConstants.visualAssistTitle,
        'description':
            'Object detection, text reading, and navigation guidance',
        'icon': Icons.visibility_outlined,
        'color': AppTheme.visualAssistColor,
      },
      {
        'id': 'hearing',
        'title': AppConstants.hearingAssistTitle,
        'description':
            'Live transcription, sound alerts, and visual notifications',
        'icon': Icons.hearing_outlined,
        'color': AppTheme.hearingAssistColor,
      },
      {
        'id': 'mobility',
        'title': AppConstants.mobilityAssistTitle,
        'description':
            'Accessible routes, indoor navigation, and mobility guidance',
        'icon': Icons.directions_walk_outlined,
        'color': AppTheme.mobilityAssistColor,
      },
    ];

    return Column(
      children: modes.map((mode) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
          child: AppCard(
            backgroundColor: mode['color'] as Color,
            borderRadius: 16,
            onTap: () => context.go('/${mode['id']}-assist'),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: SizedBox(
              height: 120.0,
              child: Row(
                children: [
                  Icon(
                    mode['icon'] as IconData,
                    size: AppConstants.largeIconSize,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppConstants.defaultSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mode['title'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallSpacing),
                        Text(
                          mode['description'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.4,
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
      }).toList(),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Column(
      children: [
        const Text(
          AppConstants.quickAccessText,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.defaultSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQuickAccessButton(
              context,
              'Map',
              Icons.map_outlined,
              () => context.go('/map'),
            ),
            const SizedBox(width: 16),
            _buildQuickAccessButton(
              context,
              AppConstants.historyTitle,
              Icons.history_outlined,
              () => context.go('/history'),
            ),
            const SizedBox(width: AppConstants.defaultSpacing),
            _buildQuickAccessButton(
              context,
              AppConstants.settingsTitle,
              Icons.settings_outlined,
              () => context.go('/settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap,
  ) {
    return AppCard(
      backgroundColor: AppTheme.surfaceColor,
      borderRadius: AppConstants.buttonBorderRadius,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: AppConstants.defaultIconSize, color: AppTheme.textPrimary),
          const SizedBox(width: AppConstants.smallSpacing),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
