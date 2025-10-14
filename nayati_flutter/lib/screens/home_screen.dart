import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildModeCards(context),
              const SizedBox(height: 32),
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
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.accessibility_new,
            size: 64,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Choose your assistance mode',
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
    final modes = [
      {
        'id': 'visual',
        'title': 'Visual Assist',
        'description': 'Object detection, text reading, and navigation guidance',
        'icon': Icons.visibility_outlined,
        'color': AppTheme.visualAssistColor,
      },
      {
        'id': 'hearing',
        'title': 'Hearing Assist',
        'description': 'Live transcription, sound alerts, and visual notifications',
        'icon': Icons.hearing_outlined,
        'color': AppTheme.hearingAssistColor,
      },
      {
        'id': 'mobility',
        'title': 'Mobility Assist',
        'description': 'Accessible routes, indoor navigation, and mobility guidance',
        'icon': Icons.directions_walk_outlined,
        'color': AppTheme.mobilityAssistColor,
      },
    ];

    return Column(
      children: modes.map((mode) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: mode['color'] as Color,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => context.go('/${mode['id']}-assist'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(24),
                height: 120,
                child: Row(
                  children: [
                    Icon(
                      mode['icon'] as IconData,
                      size: 32,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
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
                          const SizedBox(height: 8),
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
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
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
              'History',
              Icons.history_outlined,
              () => context.go('/history'),
            ),
            const SizedBox(width: 16),
            _buildQuickAccessButton(
              context,
              'Settings',
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
    return Material(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppTheme.textPrimary),
              const SizedBox(width: 8),
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
        ),
      ),
    );
  }
}
