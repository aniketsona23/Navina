import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _hapticFeedbackEnabled = true;
  bool _voiceGuidanceEnabled = true;
  String _selectedLanguage = 'English';
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('General'),
            _buildSettingsCard([
              _buildSwitchTile(
                'Notifications',
                'Receive alerts and updates',
                Icons.notifications_outlined,
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value!),
              ),
              _buildDivider(),
              _buildSwitchTile(
                'Haptic Feedback',
                'Vibration for interactions',
                Icons.vibration,
                _hapticFeedbackEnabled,
                (value) => setState(() => _hapticFeedbackEnabled = value!),
              ),
            ]),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Accessibility'),
            _buildSettingsCard([
              _buildSwitchTile(
                'Voice Guidance',
                'Audio instructions for navigation',
                Icons.record_voice_over,
                _voiceGuidanceEnabled,
                (value) => setState(() => _voiceGuidanceEnabled = value!),
              ),
              _buildDivider(),
              _buildListTile(
                'Language',
                _selectedLanguage,
                Icons.language,
                () => _showLanguageDialog(),
              ),
              _buildDivider(),
              _buildSliderTile(
                'Font Size',
                _fontSize,
                (value) => setState(() => _fontSize = value),
              ),
            ]),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('About'),
            _buildSettingsCard([
              _buildListTile(
                'App Version',
                '1.0.0',
                Icons.info_outline,
                null,
              ),
              _buildDivider(),
              _buildListTile(
                'Privacy Policy',
                '',
                Icons.privacy_tip_outlined,
                () {},
              ),
              _buildDivider(),
              _buildListTile(
                'Terms of Service',
                '',
                Icons.description_outlined,
                () {},
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
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

  Widget _buildSliderTile(
    String title,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${value.round()}px',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 12.0,
            max: 24.0,
            divisions: 12,
            activeColor: AppTheme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 56,
      color: AppTheme.borderColor,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', 'en'),
            _buildLanguageOption('Spanish', 'es'),
            _buildLanguageOption('French', 'fr'),
            _buildLanguageOption('German', 'de'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, String code) {
    return ListTile(
      title: Text(language),
      trailing: _selectedLanguage == language
          ? const Icon(Icons.check, color: AppTheme.primaryColor)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }
}
