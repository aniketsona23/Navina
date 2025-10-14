import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common/index.dart';
import '../constants/app_constants.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _notificationsEnabled = true;
  bool _hapticFeedbackEnabled = true;
  bool _voiceGuidanceEnabled = true;
  String _selectedLanguage = AppConstants.defaultLanguage;
  double _fontSize = AppConstants.defaultFontSize;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppConstants.settingsTitle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('General'),
            AppCard(
              child: Column(
                children: [
                  AppSwitchTile(
                    title: 'Notifications',
                    subtitle: 'Receive alerts and updates',
                    leadingIcon: Icons.notifications_outlined,
                    value: _notificationsEnabled,
                    onChanged: (value) => setState(() => _notificationsEnabled = value),
                  ),
                  const Divider(),
                  AppSwitchTile(
                    title: 'Haptic Feedback',
                    subtitle: 'Vibration for interactions',
                    leadingIcon: Icons.vibration,
                    value: _hapticFeedbackEnabled,
                    onChanged: (value) => setState(() => _hapticFeedbackEnabled = value),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultSpacing),
            
            const SectionTitle('Accessibility'),
            AppCard(
              child: Column(
                children: [
                  AppSwitchTile(
                    title: 'Voice Guidance',
                    subtitle: 'Audio instructions for navigation',
                    leadingIcon: Icons.record_voice_over,
                    value: _voiceGuidanceEnabled,
                    onChanged: (value) => setState(() => _voiceGuidanceEnabled = value),
                  ),
                  const Divider(),
                  _buildLanguageTile(),
                  const Divider(),
                  _buildFontSizeTile(),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.defaultSpacing),
            
            const SectionTitle('About'),
            AppCard(
              child: Column(
                children: [
                  _buildInfoTile(
                    'App Version',
                    '1.0.0',
                    Icons.info_outline,
                  ),
                  const Divider(),
                  _buildInfoTile(
                    'Privacy Policy',
                    '',
                    Icons.privacy_tip_outlined,
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildInfoTile(
                    'Terms of Service',
                    '',
                    Icons.description_outlined,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      leading: const Icon(
        Icons.language,
        color: AppTheme.textPrimary,
        size: 24,
      ),
      title: const Text(
        'Language',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        _selectedLanguage,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.textSecondary,
      ),
      onTap: _showLanguageDialog,
    );
  }

  Widget _buildFontSizeTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AppSlider(
        label: 'Font Size',
        value: _fontSize,
        min: 12.0,
        max: 24.0,
        divisions: 12,
        onChanged: (value) => setState(() => _fontSize = value),
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.textPrimary,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            )
          : null,
      trailing: onTap != null
          ? const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textSecondary,
            )
          : null,
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.supportedLanguages.map((language) {
            return ListTile(
              title: Text(language),
              leading: Radio<String>(
                value: language,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}