import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MobilityAssistScreen extends StatefulWidget {
  const MobilityAssistScreen({super.key});

  @override
  State<MobilityAssistScreen> createState() => _MobilityAssistScreenState();
}

class _MobilityAssistScreenState extends State<MobilityAssistScreen> {
  bool _isNavigating = false;
  final TextEditingController _destinationController = TextEditingController();

  final List<Map<String, dynamic>> _navigationSteps = [
    {
      'instruction': 'Head north towards the main entrance',
      'distance': '50 ft',
      'icon': Icons.north,
    },
    {
      'instruction': 'Use the accessible ramp on your left',
      'distance': '20 ft',
      'icon': Icons.arrow_forward,
    },
    {
      'instruction': 'Enter through the automatic doors',
      'distance': '10 ft',
      'icon': Icons.door_front_door,
    },
    {
      'instruction': 'Turn right at the information desk',
      'distance': '30 ft',
      'icon': Icons.turn_right,
    },
  ];

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Mobility Assist'),
        backgroundColor: AppTheme.mobilityAssistColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickDestinations(),
            const SizedBox(height: 24),
            if (_isNavigating)
              _buildActiveNavigation()
            else
              _buildStartNavigation(),
            const SizedBox(height: 24),
            _buildAccessibilityFeatures(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDestinations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Destinations',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDestinationButton(
                'Building Map',
                Icons.map_outlined,
                () => context.go('/map'),
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDestinationButton(
                'Outdoor Nav',
                Icons.navigation_outlined,
                () {},
                isPrimary: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDestinationButton(
    String title,
    IconData icon,
    VoidCallback onTap, {
    required bool isPrimary,
  }) {
    return Material(
      color: isPrimary ? AppTheme.mobilityAssistColor : AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppTheme.textPrimary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isPrimary ? Colors.white : AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.mobilityAssistColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Navigation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.mobilityAssistColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppTheme.mobilityAssistColor,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '3 min remaining',
                      style: TextStyle(
                        color: AppTheme.mobilityAssistColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._navigationSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCurrentStep = index == 0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCurrentStep 
                          ? AppTheme.mobilityAssistColor 
                          : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrentStep 
                            ? AppTheme.mobilityAssistColor 
                            : AppTheme.borderColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrentStep ? Colors.white : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['instruction'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isCurrentStep ? FontWeight.w600 : FontWeight.w400,
                            color: isCurrentStep ? AppTheme.mobilityAssistColor : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['distance'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrentStep)
                    const Icon(
                      Icons.arrow_forward,
                      color: AppTheme.mobilityAssistColor,
                      size: 20,
                    ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isNavigating = false;
                });
              },
              icon: const Icon(Icons.stop),
              label: const Text('Stop Navigation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Start Indoor Navigation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _destinationController,
            decoration: InputDecoration(
              hintText: 'Enter destination (e.g., Room 101, Library)',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_destinationController.text.isNotEmpty) {
                  setState(() {
                    _isNavigating = true;
                  });
                }
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Start Navigation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mobilityAssistColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accessibility Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'Voice Guidance',
          'Audio instructions for navigation',
          Icons.record_voice_over,
          () {},
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          'Haptic Feedback',
          'Vibration alerts for turns and obstacles',
          Icons.vibration,
          () {},
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          'Accessible Routes',
          'Wheelchair-friendly navigation paths',
          Icons.accessible,
          () {},
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.mobilityAssistColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.mobilityAssistColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
